#ifndef EZBIND_SVG_BRIDGE_H
#define EZBIND_SVG_BRIDGE_H

#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif

int ez_svg_render_cover_sheet(const char *back_path,
                              const char *front_path,
                              double width,
                              double height,
                              const char *output_path,
                              char *error_text,
                              size_t error_size);

#ifdef __cplusplus
}
#endif

#endif
