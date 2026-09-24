#include "ez_svg_bridge.h"

#include <cairo-pdf.h>
#include <gio/gio.h>
#include <librsvg/rsvg.h>

#include <cstring>
#include <exception>
#include <string>

static void set_error(char* buffer, size_t size, std::string const& message)
{
    if (buffer == nullptr || size == 0)
    {
        return;
    }
    std::strncpy(buffer, message.c_str(), size - 1);
    buffer[size - 1] = '\0';
}

static std::string glib_error_message(GError* error)
{
    std::string message = error == nullptr ? "unknown SVG rendering error" : error->message;
    if (error != nullptr)
    {
        g_error_free(error);
    }
    return message;
}

static RsvgHandle* load_svg(char const* path, GError** error)
{
    GFile* file = g_file_new_for_path(path);
    RsvgHandle* handle = rsvg_handle_new_from_gfile_sync(
        file,
        RSVG_HANDLE_FLAG_KEEP_IMAGE_DATA,
        nullptr,
        error);
    g_object_unref(file);
    return handle;
}

static bool render_svg(cairo_t* context,
                       char const* path,
                       double left,
                       double bottom,
                       double width,
                       double height,
                       GError** error)
{
    RsvgHandle* handle = load_svg(path, error);
    if (handle == nullptr)
    {
        return false;
    }

    RsvgRectangle viewport{left, bottom, width, height};
    gboolean rendered = rsvg_handle_render_document(handle, context, &viewport, error);
    g_object_unref(handle);
    return rendered != FALSE;
}

extern "C" int ez_svg_render_cover_sheet(char const* back_path,
                                           char const* front_path,
                                           double width,
                                           double height,
                                           char const* output_path,
                                           char* error_text,
                                           size_t error_size)
{
    if (back_path == nullptr || front_path == nullptr || output_path == nullptr
        || width <= 0.0 || height <= 0.0)
    {
        set_error(error_text, error_size, "invalid SVG cover arguments");
        return 1;
    }

    cairo_surface_t* surface = nullptr;
    cairo_t* context = nullptr;
    try
    {
        surface = cairo_pdf_surface_create(output_path, width, height);
        if (cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS)
        {
            set_error(error_text, error_size, "cannot create cover PDF surface");
            cairo_surface_destroy(surface);
            return 1;
        }

        context = cairo_create(surface);
        if (cairo_status(context) != CAIRO_STATUS_SUCCESS)
        {
            set_error(error_text, error_size, "cannot create Cairo context");
            cairo_destroy(context);
            cairo_surface_destroy(surface);
            return 1;
        }

        GError* error = nullptr;
        bool okay = render_svg(context, back_path, 0.0, 0.0,
                               width / 2.0, height, &error);
        if (!okay)
        {
            set_error(error_text, error_size, glib_error_message(error));
        }
        else
        {
            okay = render_svg(context, front_path, width / 2.0, 0.0,
                              width / 2.0, height, &error);
            if (!okay)
            {
                set_error(error_text, error_size, glib_error_message(error));
            }
        }

        if (okay)
        {
            constexpr double cut_line_inset = 12.0;
            constexpr double cut_line_width = 0.5;
            constexpr double cut_dash[] = {4.0, 3.0};
            cairo_save(context);
            cairo_set_source_rgb(context, 0.45, 0.45, 0.45);
            cairo_set_line_width(context, cut_line_width);
            cairo_set_dash(context, cut_dash, 2, 0.0);
            cairo_move_to(context, width / 2.0, cut_line_inset);
            cairo_line_to(context, width / 2.0, height - cut_line_inset);
            cairo_stroke(context);
            cairo_restore(context);
            okay = cairo_status(context) == CAIRO_STATUS_SUCCESS;
            if (!okay)
            {
                set_error(error_text, error_size, "Cairo failed while drawing cover cut guide");
            }
        }

        if (okay)
        {
            cairo_show_page(context);
            okay = cairo_status(context) == CAIRO_STATUS_SUCCESS;
            if (!okay)
            {
                set_error(error_text, error_size, "Cairo failed while writing cover PDF");
            }
        }

        cairo_destroy(context);
        cairo_surface_finish(surface);
        okay = okay && cairo_surface_status(surface) == CAIRO_STATUS_SUCCESS;
        cairo_surface_destroy(surface);
        return okay ? 0 : 1;
    }
    catch (std::exception const& exception)
    {
        if (context != nullptr)
        {
            cairo_destroy(context);
        }
        if (surface != nullptr)
        {
            cairo_surface_destroy(surface);
        }
        set_error(error_text, error_size, exception.what());
        return 1;
    }
    catch (...)
    {
        if (context != nullptr)
        {
            cairo_destroy(context);
        }
        if (surface != nullptr)
        {
            cairo_surface_destroy(surface);
        }
        set_error(error_text, error_size, "unknown SVG rendering error");
        return 1;
    }
}
