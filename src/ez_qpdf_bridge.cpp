#include "ez_qpdf_bridge.h"

#include <qpdf/QPDF.hh>
#include <qpdf/QPDFPageDocumentHelper.hh>
#include <qpdf/QPDFPageObjectHelper.hh>
#include <qpdf/QPDFObjectHandle.hh>
#include <qpdf/QPDFWriter.hh>
#include <qpdf/QUtil.hh>

#include <algorithm>
#include <cstring>
#include <memory>
#include <string>
#include <vector>

struct ez_qpdf_input
{
    QPDF document;
    std::vector<QPDFPageObjectHelper> pages;
};

struct ez_qpdf_output
{
    QPDF document;
    double width;
    double height;
};

static void set_error(char *buffer, size_t size, std::string const& message)
{
    if (buffer == nullptr || size == 0)
    {
        return;
    }
    std::strncpy(buffer, message.c_str(), size - 1);
    buffer[size - 1] = '\0';
}

template <typename Function>
static int guarded(char *error_text, size_t error_size, Function function)
{
    try
    {
        function();
        return 0;
    }
    catch (std::exception const& exception)
    {
        set_error(error_text, error_size, exception.what());
        return 1;
    }
    catch (...)
    {
        set_error(error_text, error_size, "unknown qpdf error");
        return 1;
    }
}

extern "C" int ez_qpdf_open_input(char const* path,
                                    ez_qpdf_input** result,
                                    size_t* page_count,
                                    char* error_text,
                                    size_t error_size)
{
    if (path == nullptr || result == nullptr || page_count == nullptr)
    {
        set_error(error_text, error_size, "invalid qpdf input arguments");
        return 1;
    }
    return guarded(error_text, error_size, [&]() {
        std::unique_ptr<ez_qpdf_input> input(new ez_qpdf_input);
        input->document.processFile(path);
        input->pages = QPDFPageDocumentHelper(input->document).getAllPages();
        *page_count = input->pages.size();
        *result = input.release();
    });
}

extern "C" int ez_qpdf_create_output(double width,
                                       double height,
                                       ez_qpdf_output** result,
                                       char* error_text,
                                       size_t error_size)
{
    if (result == nullptr || width <= 0.0 || height <= 0.0)
    {
        set_error(error_text, error_size, "invalid qpdf output geometry");
        return 1;
    }
    return guarded(error_text, error_size, [&]() {
        std::unique_ptr<ez_qpdf_output> output(new ez_qpdf_output);
        output->width = width;
        output->height = height;
        output->document.emptyPDF();
        *result = output.release();
    });
}

extern "C" int ez_qpdf_begin_page(ez_qpdf_output* output,
                                   char* error_text,
                                   size_t error_size)
{
    if (output == nullptr)
    {
        set_error(error_text, error_size, "invalid qpdf page target");
        return 1;
    }
    return guarded(error_text, error_size, [&]() {
        QPDFObjectHandle page = QPDFObjectHandle::newDictionary();
        page.replaceKey("/Type", QPDFObjectHandle::newName("/Page"));
        page.replaceKey(
            "/MediaBox",
            QPDFObjectHandle::newArray(
                QPDFObjectHandle::Rectangle(
                    0.0, 0.0, output->width, output->height)));
        page.replaceKey("/Resources", QPDFObjectHandle::newDictionary());
        output->document.addPage(output->document.makeIndirectObject(page), false);
    });
}

extern "C" int ez_qpdf_place_page(ez_qpdf_input* input,
                                    size_t source_index,
                                    ez_qpdf_output* output,
                                    double left,
                                    double bottom,
                                    double right,
                                    double top,
                                    char* error_text,
                                    size_t error_size)
{
    if (input == nullptr || output == nullptr || source_index >= input->pages.size()
        || right <= left || top <= bottom)
    {
        set_error(error_text, error_size, "invalid qpdf placement arguments");
        return 1;
    }
    return guarded(error_text, error_size, [&]() {
        std::vector<QPDFPageObjectHelper> pages =
            QPDFPageDocumentHelper(output->document).getAllPages();
        QPDFPageObjectHelper destination = pages.back();
        QPDFObjectHandle resources = destination.getAttribute("/Resources", true);
        int minimum_suffix = 1;
        std::string name = resources.getUniqueResourceName("/Fx", minimum_suffix);
        QPDFObjectHandle form = input->pages.at(source_index).getFormXObjectForPage(true);
        QPDFObjectHandle copied_form = output->document.copyForeignObject(form);
        std::string content = destination.placeFormXObject(
            copied_form,
            name,
            QPDFObjectHandle::Rectangle(left, bottom, right, top),
            true,
            true,
            false);
        resources.mergeResources("<< /XObject << >> >>"_qpdf);
        resources.getKey("/XObject").replaceKey(name, copied_form);
        destination.addPageContents(output->document.newStream(content), false);
    });
}

extern "C" int ez_qpdf_append_line(ez_qpdf_output* output,
                                     double x1,
                                     double y1,
                                     double x2,
                                     double y2,
                                     char* error_text,
                                     size_t error_size)
{
    if (output == nullptr)
    {
        set_error(error_text, error_size, "invalid qpdf guide target");
        return 1;
    }
    return guarded(error_text, error_size, [&]() {
        std::vector<QPDFPageObjectHelper> pages =
            QPDFPageDocumentHelper(output->document).getAllPages();
        if (pages.empty())
        {
            throw std::runtime_error("no qpdf output page exists");
        }
        std::string content = "q 0.75 0.75 0.75 RG 0.25 w "
          + std::to_string(x1) + " " + std::to_string(y1) + " m "
          + std::to_string(x2) + " " + std::to_string(y2) + " l S Q\n";
        pages.back().addPageContents(output->document.newStream(content), false);
    });
}

extern "C" int ez_qpdf_write_output(ez_qpdf_output* output,
                                      char const* path,
                                      char* error_text,
                                      size_t error_size)
{
    if (output == nullptr || path == nullptr)
    {
        set_error(error_text, error_size, "invalid qpdf write arguments");
        return 1;
    }
    return guarded(error_text, error_size, [&]() {
        QPDFWriter writer(output->document, path);
        writer.setStaticID(true);
        writer.write();
    });
}

extern "C" void ez_qpdf_close_input(ez_qpdf_input* input)
{
    delete input;
}

extern "C" void ez_qpdf_close_output(ez_qpdf_output* output)
{
    delete output;
}
