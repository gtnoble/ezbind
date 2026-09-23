#ifndef EZBIND_QPDF_BRIDGE_H
#define EZBIND_QPDF_BRIDGE_H
#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef struct ez_qpdf_input ez_qpdf_input;
typedef struct ez_qpdf_output ez_qpdf_output;
int ez_qpdf_open_input(const char*, ez_qpdf_input**, size_t*, char*, size_t);
int ez_qpdf_get_page_descriptor(ez_qpdf_input*, size_t, double*, double*, char*, size_t);
int ez_qpdf_create_output(double, double, ez_qpdf_output**, char*, size_t);
int ez_qpdf_begin_page(ez_qpdf_output*, char*, size_t);
int ez_qpdf_place_page(ez_qpdf_input*, size_t, ez_qpdf_output*,
                       double, double, double, double,
                       double, double, double, double, char*, size_t);
int ez_qpdf_append_line(ez_qpdf_output*, double, double, double, double, char*, size_t);
int ez_qpdf_write_output(ez_qpdf_output*, const char*, char*, size_t);
void ez_qpdf_close_input(ez_qpdf_input*);
void ez_qpdf_close_output(ez_qpdf_output*);
#ifdef __cplusplus
}
#endif
#endif
