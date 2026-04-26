/* nanoarrow_bridge.c – thin Crystal-facing wrapper built on top of nanoarrow.
 *
 * Building uses nanoarrow's append API.
 * Reading uses direct Arrow-spec buffer access (bitmap + typed data buffer),
 * which works regardless of whether nanoarrow or any other conformant
 * implementation produced the array.
 */
#include "nanoarrow_bridge.h"

#include <errno.h>
#include <string.h>

/* ── helpers ─────────────────────────────────────────────────────────── */

/* Arrow bit-layout: bit i lives at byte (i>>3), bit position (i&7). */
static int na_bridge_is_null_raw(const struct ArrowArray* array, int64_t index) {
  if (array->buffers[0] == NULL) return 0;          /* no bitmap → all valid */
  const uint8_t* bits = (const uint8_t*)array->buffers[0];
  int64_t phys = index + array->offset;
  return ((bits[phys >> 3] >> (phys & 7)) & 1) ? 0 : 1;
}

static int na_bridge_check(const struct ArrowArray* array, int64_t index,
                       int64_t need_buffers) {
  if (!array || array->release == NULL || !array->buffers) return EINVAL;
  if (array->n_buffers < need_buffers)                     return EINVAL;
  if (index < 0 || index >= array->length)                 return ERANGE;
  return 0;
}

/* ── Schema ──────────────────────────────────────────────────────────── */

void nanoarrow_bridge_schema_init(struct ArrowSchema* schema,
                               const char* format, const char* name) {
  if (!schema) return;
  ArrowSchemaInit(schema);
  ArrowSchemaSetFormat(schema, format);
  if (name) ArrowSchemaSetName(schema, name);
}

void nanoarrow_bridge_schema_release(struct ArrowSchema* schema) {
  if (schema && schema->release) ArrowSchemaRelease(schema);
}

int nanoarrow_bridge_schema_released(const struct ArrowSchema* schema) {
  return schema == NULL || schema->release == NULL;
}

/* ── Array building ──────────────────────────────────────────────────── */

int nanoarrow_bridge_array_init_bool(struct ArrowArray* array,
                                  const uint8_t* values, const uint8_t* valid,
                                  int64_t length) {
  if (!array || length < 0) return EINVAL;
  int rc = ArrowArrayInitFromType(array, NANOARROW_TYPE_BOOL);
  if (rc != NANOARROW_OK) return rc;
  if ((rc = ArrowArrayStartAppending(array)) != NANOARROW_OK) goto fail;
  for (int64_t i = 0; i < length; i++) {
    rc = (valid && valid[i] == 0)
           ? ArrowArrayAppendNull(array, 1)
           : ArrowArrayAppendInt(array, values ? (int64_t)(values[i] != 0) : 0);
    if (rc != NANOARROW_OK) goto fail;
  }
  if ((rc = ArrowArrayFinishBuildingDefault(array, NULL)) != NANOARROW_OK) goto fail;
  return NANOARROW_OK;
fail:
  ArrowArrayRelease(array);
  return rc;
}

int nanoarrow_bridge_array_init_i32(struct ArrowArray* array,
                                 const int32_t* values, const uint8_t* valid,
                                 int64_t length) {
  if (!array || length < 0) return EINVAL;
  int rc = ArrowArrayInitFromType(array, NANOARROW_TYPE_INT32);
  if (rc != NANOARROW_OK) return rc;
  if ((rc = ArrowArrayStartAppending(array)) != NANOARROW_OK) goto fail;
  for (int64_t i = 0; i < length; i++) {
    rc = (valid && valid[i] == 0)
           ? ArrowArrayAppendNull(array, 1)
           : ArrowArrayAppendInt(array, values ? (int64_t)values[i] : 0);
    if (rc != NANOARROW_OK) goto fail;
  }
  if ((rc = ArrowArrayFinishBuildingDefault(array, NULL)) != NANOARROW_OK) goto fail;
  return NANOARROW_OK;
fail:
  ArrowArrayRelease(array);
  return rc;
}

int nanoarrow_bridge_array_init_i64(struct ArrowArray* array,
                                 const int64_t* values, const uint8_t* valid,
                                 int64_t length) {
  if (!array || length < 0) return EINVAL;
  int rc = ArrowArrayInitFromType(array, NANOARROW_TYPE_INT64);
  if (rc != NANOARROW_OK) return rc;
  if ((rc = ArrowArrayStartAppending(array)) != NANOARROW_OK) goto fail;
  for (int64_t i = 0; i < length; i++) {
    rc = (valid && valid[i] == 0)
           ? ArrowArrayAppendNull(array, 1)
           : ArrowArrayAppendInt(array, values ? values[i] : 0);
    if (rc != NANOARROW_OK) goto fail;
  }
  if ((rc = ArrowArrayFinishBuildingDefault(array, NULL)) != NANOARROW_OK) goto fail;
  return NANOARROW_OK;
fail:
  ArrowArrayRelease(array);
  return rc;
}

int nanoarrow_bridge_array_init_f64(struct ArrowArray* array,
                                 const double* values, const uint8_t* valid,
                                 int64_t length) {
  if (!array || length < 0) return EINVAL;
  int rc = ArrowArrayInitFromType(array, NANOARROW_TYPE_DOUBLE);
  if (rc != NANOARROW_OK) return rc;
  if ((rc = ArrowArrayStartAppending(array)) != NANOARROW_OK) goto fail;
  for (int64_t i = 0; i < length; i++) {
    rc = (valid && valid[i] == 0)
           ? ArrowArrayAppendNull(array, 1)
           : ArrowArrayAppendDouble(array, values ? values[i] : 0.0);
    if (rc != NANOARROW_OK) goto fail;
  }
  if ((rc = ArrowArrayFinishBuildingDefault(array, NULL)) != NANOARROW_OK) goto fail;
  return NANOARROW_OK;
fail:
  ArrowArrayRelease(array);
  return rc;
}

int nanoarrow_bridge_array_init_u32(struct ArrowArray* array,
                                 const uint32_t* values, const uint8_t* valid,
                                 int64_t length) {
  if (!array || length < 0) return EINVAL;
  int rc = ArrowArrayInitFromType(array, NANOARROW_TYPE_UINT32);
  if (rc != NANOARROW_OK) return rc;
  if ((rc = ArrowArrayStartAppending(array)) != NANOARROW_OK) goto fail;
  for (int64_t i = 0; i < length; i++) {
    rc = (valid && valid[i] == 0)
           ? ArrowArrayAppendNull(array, 1)
           : ArrowArrayAppendUInt(array, values ? (uint64_t)values[i] : 0);
    if (rc != NANOARROW_OK) goto fail;
  }
  if ((rc = ArrowArrayFinishBuildingDefault(array, NULL)) != NANOARROW_OK) goto fail;
  return NANOARROW_OK;
fail:
  ArrowArrayRelease(array);
  return rc;
}

int nanoarrow_bridge_array_init_f32(struct ArrowArray* array,
                                 const float* values, const uint8_t* valid,
                                 int64_t length) {
  if (!array || length < 0) return EINVAL;
  int rc = ArrowArrayInitFromType(array, NANOARROW_TYPE_FLOAT);
  if (rc != NANOARROW_OK) return rc;
  if ((rc = ArrowArrayStartAppending(array)) != NANOARROW_OK) goto fail;
  for (int64_t i = 0; i < length; i++) {
    rc = (valid && valid[i] == 0)
           ? ArrowArrayAppendNull(array, 1)
           : ArrowArrayAppendDouble(array, values ? (double)values[i] : 0.0);
    if (rc != NANOARROW_OK) goto fail;
  }
  if ((rc = ArrowArrayFinishBuildingDefault(array, NULL)) != NANOARROW_OK) goto fail;
  return NANOARROW_OK;
fail:
  ArrowArrayRelease(array);
  return rc;
}

int nanoarrow_bridge_array_init_string(struct ArrowArray* array,
                                    const char* const* values, const uint8_t* valid,
                                    int64_t length) {
  if (!array || length < 0) return EINVAL;
  int rc = ArrowArrayInitFromType(array, NANOARROW_TYPE_STRING);
  if (rc != NANOARROW_OK) return rc;
  if ((rc = ArrowArrayStartAppending(array)) != NANOARROW_OK) goto fail;
  for (int64_t i = 0; i < length; i++) {
    if (valid && valid[i] == 0) {
      rc = ArrowArrayAppendNull(array, 1);
    } else {
      const char* s = (values && values[i]) ? values[i] : "";
      struct ArrowStringView sv;
      sv.data       = s;
      sv.size_bytes = (int64_t)strlen(s);
      rc = ArrowArrayAppendString(array, sv);
    }
    if (rc != NANOARROW_OK) goto fail;
  }
  if ((rc = ArrowArrayFinishBuildingDefault(array, NULL)) != NANOARROW_OK) goto fail;
  return NANOARROW_OK;
fail:
  ArrowArrayRelease(array);
  return rc;
}

/* ── Array lifecycle ─────────────────────────────────────────────────── */

void nanoarrow_bridge_array_release(struct ArrowArray* array) {
  if (array && array->release) ArrowArrayRelease(array);
}

int nanoarrow_bridge_array_released(const struct ArrowArray* array) {
  return array == NULL || array->release == NULL;
}

int nanoarrow_bridge_array_is_null(const struct ArrowArray* array, int64_t index) {
  if (!array || array->release == NULL || index < 0 || index >= array->length)
    return EINVAL;
  return na_bridge_is_null_raw(array, index);
}

/* ── Array reading (direct Arrow buffer access) ───────────────────────── */

int nanoarrow_bridge_array_bool_get(const struct ArrowArray* array, int64_t index,
                                 int32_t* out) {
  int rc = na_bridge_check(array, index, 2);
  if (rc) return rc;
  if (na_bridge_is_null_raw(array, index)) return 1;
  const uint8_t* data = (const uint8_t*)array->buffers[1];
  int64_t phys = index + array->offset;
  if (out) *out = (data[phys >> 3] >> (phys & 7)) & 1;
  return 0;
}

int nanoarrow_bridge_array_i32_get(const struct ArrowArray* array, int64_t index,
                                int32_t* out) {
  int rc = na_bridge_check(array, index, 2);
  if (rc) return rc;
  if (na_bridge_is_null_raw(array, index)) return 1;
  if (out) *out = ((const int32_t*)array->buffers[1])[index + array->offset];
  return 0;
}

int nanoarrow_bridge_array_i64_get(const struct ArrowArray* array, int64_t index,
                                int64_t* out) {
  int rc = na_bridge_check(array, index, 2);
  if (rc) return rc;
  if (na_bridge_is_null_raw(array, index)) return 1;
  if (out) *out = ((const int64_t*)array->buffers[1])[index + array->offset];
  return 0;
}

int nanoarrow_bridge_array_f64_get(const struct ArrowArray* array, int64_t index,
                                double* out) {
  int rc = na_bridge_check(array, index, 2);
  if (rc) return rc;
  if (na_bridge_is_null_raw(array, index)) return 1;
  if (out) *out = ((const double*)array->buffers[1])[index + array->offset];
  return 0;
}

int nanoarrow_bridge_array_u32_get(const struct ArrowArray* array, int64_t index,
                                uint32_t* out) {
  int rc = na_bridge_check(array, index, 2);
  if (rc) return rc;
  if (na_bridge_is_null_raw(array, index)) return 1;
  if (out) *out = ((const uint32_t*)array->buffers[1])[index + array->offset];
  return 0;
}

int nanoarrow_bridge_array_f32_get(const struct ArrowArray* array, int64_t index,
                                float* out) {
  int rc = na_bridge_check(array, index, 2);
  if (rc) return rc;
  if (na_bridge_is_null_raw(array, index)) return 1;
  if (out) *out = ((const float*)array->buffers[1])[index + array->offset];
  return 0;
}

int nanoarrow_bridge_array_string_get(const struct ArrowArray* array, int64_t index,
                                   const char** out, int64_t* size_out) {
  int rc = na_bridge_check(array, index, 3);
  if (rc) return rc;
  if (na_bridge_is_null_raw(array, index)) return 1;
  const int32_t* offsets = (const int32_t*)array->buffers[1];
  const char*    data    = (const char*)array->buffers[2];
  int64_t phys  = index + array->offset;
  int32_t begin = offsets[phys];
  int32_t end   = offsets[phys + 1];
  int64_t size  = (int64_t)(end - begin);
  static const char empty[] = "";
  if (out)      *out      = (size == 0) ? empty : data + begin;
  if (size_out) *size_out = size;
  return 0;
}
