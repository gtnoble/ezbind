#ifndef EZBIND_QPDF_BRIDGE_H
#define EZBIND_QPDF_BRIDGE_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct ez_qpdf_input ez_qpdf_input;
typedef struct ez_qpdf_output ez_qpdf_output;

int ez_qpdf_open_input (const char *path,
                          ez_qpdf_input **result,
                          size_t *page_count,
                          char *error_text,
                          size_t error_size);

int ez_qpdf_create_output (double width,
                           double height,
                           ez_qpdf_output **result,
                           char *error_text,
                           size_t error_size);

int ez_qpdf_place_page (ez_qpdf_input *input,
                        size_t source_index,
                        ez_qpdf_output *output,
                        double left,
                        double bottom,
                        double right,
                        double top,
                        char *error_text,
                        size_t error_size);

int ez_qpdf_append_line (ez_qpdf_output *output,
                         double x1,
                         double y1,
                         double x2,
                         double y2,
                         char *error_text,
                         size_t error_size);

int ez_qpdf_write_output (ez_qpdf_output *output,
                          const char *path,
                          char *error_text,
                          size_t error_size);

void ez_qpdf_close_input (ez_qpdf_input *input);
void ez_qpdf_close_output (ez_qpdf_output *output);

#ifdef __cplusplus
}
#endif

#endif
