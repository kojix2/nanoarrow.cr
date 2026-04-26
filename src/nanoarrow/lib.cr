{% if flag?(:msvc) %}
  @[Link("nanoarrow_bridge", ldflags: "/LIBPATH:#{__DIR__}\\..\\..\\ext\\build")]
{% else %}
  @[Link(ldflags: "-L#{__DIR__}/../../ext/build -lnanoarrow_bridge")]
{% end %}
lib LibNanoarrowBridge
  struct ArrowSchema
    format : UInt8*
    name : UInt8*
    metadata : UInt8*
    flags : Int64
    n_children : Int64
    children : ArrowSchema**
    dictionary : ArrowSchema*
    release : Void*
    private_data : Void*
  end

  struct ArrowArray
    length : Int64
    null_count : Int64
    offset : Int64
    n_buffers : Int64
    n_children : Int64
    buffers : Void**
    children : ArrowArray**
    dictionary : ArrowArray*
    release : Void*
    private_data : Void*
  end

  struct ArrowArrayStream
    get_schema : Void*
    get_next : Void*
    get_last_error : Void*
    release : Void*
    private_data : Void*
  end

  fun schema_init = nanoarrow_bridge_schema_init(schema : ArrowSchema*, format : UInt8*, name : UInt8*) : Void
  fun schema_release = nanoarrow_bridge_schema_release(schema : ArrowSchema*) : Void
  fun schema_released = nanoarrow_bridge_schema_released(schema : ArrowSchema*) : Int32

  fun array_init_bool = nanoarrow_bridge_array_init_bool(array : ArrowArray*, values : UInt8*, valid : UInt8*, length : Int64) : Int32
  fun array_init_i32 = nanoarrow_bridge_array_init_i32(array : ArrowArray*, values : Int32*, valid : UInt8*, length : Int64) : Int32
  fun array_init_i64 = nanoarrow_bridge_array_init_i64(array : ArrowArray*, values : Int64*, valid : UInt8*, length : Int64) : Int32
  fun array_init_u32 = nanoarrow_bridge_array_init_u32(array : ArrowArray*, values : UInt32*, valid : UInt8*, length : Int64) : Int32
  fun array_init_f32 = nanoarrow_bridge_array_init_f32(array : ArrowArray*, values : Float32*, valid : UInt8*, length : Int64) : Int32
  fun array_init_f64 = nanoarrow_bridge_array_init_f64(array : ArrowArray*, values : Float64*, valid : UInt8*, length : Int64) : Int32
  fun array_init_string = nanoarrow_bridge_array_init_string(array : ArrowArray*, values : UInt8**, valid : UInt8*, length : Int64) : Int32

  fun array_release = nanoarrow_bridge_array_release(array : ArrowArray*) : Void
  fun array_released = nanoarrow_bridge_array_released(array : ArrowArray*) : Int32
  fun array_is_null = nanoarrow_bridge_array_is_null(array : ArrowArray*, index : Int64) : Int32

  fun array_bool_get = nanoarrow_bridge_array_bool_get(array : ArrowArray*, index : Int64, out : Int32*) : Int32
  fun array_i32_get = nanoarrow_bridge_array_i32_get(array : ArrowArray*, index : Int64, out : Int32*) : Int32
  fun array_i64_get = nanoarrow_bridge_array_i64_get(array : ArrowArray*, index : Int64, out : Int64*) : Int32
  fun array_u32_get = nanoarrow_bridge_array_u32_get(array : ArrowArray*, index : Int64, out : UInt32*) : Int32
  fun array_f32_get = nanoarrow_bridge_array_f32_get(array : ArrowArray*, index : Int64, out : Float32*) : Int32
  fun array_f64_get = nanoarrow_bridge_array_f64_get(array : ArrowArray*, index : Int64, out : Float64*) : Int32
  fun array_string_get = nanoarrow_bridge_array_string_get(array : ArrowArray*, index : Int64, out : UInt8**, size_out : Int64*) : Int32
end
