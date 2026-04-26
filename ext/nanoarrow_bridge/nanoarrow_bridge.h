#ifndef NANOARROW_BRIDGE_H_INCLUDED
#define NANOARROW_BRIDGE_H_INCLUDED

#include <stdint.h>
#include "nanoarrow/nanoarrow.h"

#ifdef __cplusplus
extern "C" {
#endif

void nanoarrow_bridge_schema_init(struct ArrowSchema* schema, const char* format, const char* name);
void nanoarrow_bridge_schema_release(struct ArrowSchema* schema);
int  nanoarrow_bridge_schema_released(const struct ArrowSchema* schema);

int nanoarrow_bridge_array_init_bool(struct ArrowArray* array, const uint8_t* values, const uint8_t* valid, int64_t length);
int nanoarrow_bridge_array_init_i32(struct ArrowArray* array, const int32_t* values, const uint8_t* valid, int64_t length);
int nanoarrow_bridge_array_init_i64(struct ArrowArray* array, const int64_t* values, const uint8_t* valid, int64_t length);
int nanoarrow_bridge_array_init_u32(struct ArrowArray* array, const uint32_t* values, const uint8_t* valid, int64_t length);
int nanoarrow_bridge_array_init_f32(struct ArrowArray* array, const float* values, const uint8_t* valid, int64_t length);
int nanoarrow_bridge_array_init_f64(struct ArrowArray* array, const double* values, const uint8_t* valid, int64_t length);
int nanoarrow_bridge_array_init_string(struct ArrowArray* array, const char* const* values, const uint8_t* valid, int64_t length);

void nanoarrow_bridge_array_release(struct ArrowArray* array);
int  nanoarrow_bridge_array_released(const struct ArrowArray* array);
int  nanoarrow_bridge_array_is_null(const struct ArrowArray* array, int64_t index);

int nanoarrow_bridge_array_bool_get(const struct ArrowArray* array, int64_t index, int32_t* out);
int nanoarrow_bridge_array_i32_get(const struct ArrowArray* array, int64_t index, int32_t* out);
int nanoarrow_bridge_array_i64_get(const struct ArrowArray* array, int64_t index, int64_t* out);
int nanoarrow_bridge_array_u32_get(const struct ArrowArray* array, int64_t index, uint32_t* out);
int nanoarrow_bridge_array_f32_get(const struct ArrowArray* array, int64_t index, float* out);
int nanoarrow_bridge_array_f64_get(const struct ArrowArray* array, int64_t index, double* out);
int nanoarrow_bridge_array_string_get(const struct ArrowArray* array, int64_t index, const char** out, int64_t* size_out);

#ifdef __cplusplus
}
#endif

#endif
