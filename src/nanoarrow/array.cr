require "./lib"
require "./error"

module Nanoarrow
  abstract class ArrayBase(T)
    include Enumerable(T?)

    getter ptr : Pointer(LibNanoarrowBridge::ArrowArray)

    def initialize(@ptr : Pointer(LibNanoarrowBridge::ArrowArray))
    end

    # Subclasses implement raw element access (index is already bounds-checked).
    abstract def unsafe_get(index : Int64) : T?

    # Returns the element at *index*, supporting negative indices.
    def [](index : Int) : T?
      idx = index.to_i64
      idx += length if idx < 0
      check_index(idx)
      unsafe_get(idx)
    end

    def length : Int64
      @ptr.value.length
    end

    def size : Int64
      length
    end

    def null_count : Int64
      @ptr.value.null_count
    end

    def empty? : Bool
      length == 0
    end

    # Yields each element (nil for null entries). Provides the full Enumerable API.
    def each(& : T? ->) : Nil
      length.times { |i| yield unsafe_get(i.to_i64) }
    end

    def null?(index : Int) : Bool
      idx = index.to_i64
      idx += length if idx < 0
      check_index(idx)
      LibNanoarrowBridge.array_is_null(@ptr, idx) == 1
    end

    # Returns a new Array containing only non-null values.
    def compact : ::Array(T)
      result = [] of T

      each do |v|
        next if v.nil?
        result << v
      end

      result
    end

    # Returns the sub-array for the given Range, supporting negative indices.
    def [](range : Range) : ::Array(T?)
      b = (range.begin || 0).to_i
      b = b < 0 ? (length + b).to_i : b
      e = range.end
      if e.nil?
        e_idx = length.to_i - 1
      else
        e_idx = e.to_i
        e_idx = e_idx < 0 ? (length + e_idx).to_i : e_idx
        e_idx -= 1 if range.excludes_end?
      end
      (b..e_idx).map { |i| self[i] }
    end

    def released? : Bool
      LibNanoarrowBridge.array_released(@ptr) != 0
    end

    def release : Nil
      LibNanoarrowBridge.array_release(@ptr) unless released?
    end

    def finalize
      release
    end

    def inspect(io : IO) : Nil
      io << self.class.name << "["
      each_with_index do |v, i|
        io << ", " if i > 0
        v.nil? ? (io << "nil") : v.inspect(io)
      end
      io << "]"
    end

    def to_s(io : IO) : Nil
      inspect(io)
    end

    def to_unsafe : Pointer(LibNanoarrowBridge::ArrowArray)
      @ptr
    end

    protected def check_index(index : Int64) : Nil
      unless index >= 0 && index < length
        raise IndexError.new("index #{index} outside 0...#{length}")
      end
    end
  end

  class BoolArray < ArrayBase(Bool)
    def self.build(values : Enumerable(Bool?)) : self
      vals = values.to_a
      data = vals.map { |v| v ? 1_u8 : 0_u8 }
      valid = vals.map { |v| v.nil? ? 0_u8 : 1_u8 }
      ptr = Pointer(LibNanoarrowBridge::ArrowArray).malloc(1)
      Error.check LibNanoarrowBridge.array_init_bool(ptr, data.to_unsafe, valid.to_unsafe, vals.size.to_i64), "building BoolArray"
      new(ptr)
    end

    def unsafe_get(index : Int64) : Bool?
      val = uninitialized Int32
      code = LibNanoarrowBridge.array_bool_get(@ptr, index, pointerof(val))
      return if code == 1
      Error.check code, "reading BoolArray"
      val != 0
    end

    def to_a : ::Array(Bool?)
      (0_i64...length).map { |i| unsafe_get(i) }
    end
  end

  class Int32Array < ArrayBase(Int32)
    def self.build(values : Enumerable(Int32?)) : self
      vals = values.to_a
      data = vals.map { |v| v || 0 }
      valid = vals.map { |v| v.nil? ? 0_u8 : 1_u8 }
      ptr = Pointer(LibNanoarrowBridge::ArrowArray).malloc(1)
      Error.check LibNanoarrowBridge.array_init_i32(ptr, data.to_unsafe, valid.to_unsafe, vals.size.to_i64), "building Int32Array"
      new(ptr)
    end

    def unsafe_get(index : Int64) : Int32?
      val = uninitialized Int32
      code = LibNanoarrowBridge.array_i32_get(@ptr, index, pointerof(val))
      return if code == 1
      Error.check code, "reading Int32Array"
      val
    end

    def to_a : ::Array(Int32?)
      (0_i64...length).map { |i| unsafe_get(i) }
    end
  end

  class Int64Array < ArrayBase(Int64)
    def self.build(values : Enumerable(Int64?)) : self
      vals = values.to_a
      data = vals.map { |v| v || 0_i64 }
      valid = vals.map { |v| v.nil? ? 0_u8 : 1_u8 }
      ptr = Pointer(LibNanoarrowBridge::ArrowArray).malloc(1)
      Error.check LibNanoarrowBridge.array_init_i64(ptr, data.to_unsafe, valid.to_unsafe, vals.size.to_i64), "building Int64Array"
      new(ptr)
    end

    def unsafe_get(index : Int64) : Int64?
      val = uninitialized Int64
      code = LibNanoarrowBridge.array_i64_get(@ptr, index, pointerof(val))
      return if code == 1
      Error.check code, "reading Int64Array"
      val
    end

    def to_a : ::Array(Int64?)
      (0_i64...length).map { |i| unsafe_get(i) }
    end
  end

  class UInt32Array < ArrayBase(UInt32)
    def self.build(values : Enumerable(UInt32?)) : self
      vals = values.to_a
      data = vals.map { |v| v || 0_u32 }
      valid = vals.map { |v| v.nil? ? 0_u8 : 1_u8 }
      ptr = Pointer(LibNanoarrowBridge::ArrowArray).malloc(1)
      Error.check LibNanoarrowBridge.array_init_u32(ptr, data.to_unsafe, valid.to_unsafe, vals.size.to_i64), "building UInt32Array"
      new(ptr)
    end

    def unsafe_get(index : Int64) : UInt32?
      val = uninitialized UInt32
      code = LibNanoarrowBridge.array_u32_get(@ptr, index, pointerof(val))
      return if code == 1
      Error.check code, "reading UInt32Array"
      val
    end

    def to_a : ::Array(UInt32?)
      (0_i64...length).map { |i| unsafe_get(i) }
    end
  end

  class Float32Array < ArrayBase(Float32)
    def self.build(values : Enumerable(Float32?)) : self
      vals = values.to_a
      data = vals.map { |v| v || 0.0_f32 }
      valid = vals.map { |v| v.nil? ? 0_u8 : 1_u8 }
      ptr = Pointer(LibNanoarrowBridge::ArrowArray).malloc(1)
      Error.check LibNanoarrowBridge.array_init_f32(ptr, data.to_unsafe, valid.to_unsafe, vals.size.to_i64), "building Float32Array"
      new(ptr)
    end

    def unsafe_get(index : Int64) : Float32?
      val = uninitialized Float32
      code = LibNanoarrowBridge.array_f32_get(@ptr, index, pointerof(val))
      return if code == 1
      Error.check code, "reading Float32Array"
      val
    end

    def to_a : ::Array(Float32?)
      (0_i64...length).map { |i| unsafe_get(i) }
    end
  end

  class Float64Array < ArrayBase(Float64)
    def self.build(values : Enumerable(Float64?)) : self
      vals = values.to_a
      data = vals.map { |v| v || 0.0 }
      valid = vals.map { |v| v.nil? ? 0_u8 : 1_u8 }
      ptr = Pointer(LibNanoarrowBridge::ArrowArray).malloc(1)
      Error.check LibNanoarrowBridge.array_init_f64(ptr, data.to_unsafe, valid.to_unsafe, vals.size.to_i64), "building Float64Array"
      new(ptr)
    end

    def unsafe_get(index : Int64) : Float64?
      val = uninitialized Float64
      code = LibNanoarrowBridge.array_f64_get(@ptr, index, pointerof(val))
      return if code == 1
      Error.check code, "reading Float64Array"
      val
    end

    def to_a : ::Array(Float64?)
      (0_i64...length).map { |i| unsafe_get(i) }
    end
  end

  class StringArray < ArrayBase(String)
    def self.build(values : Enumerable(String?)) : self
      vals = values.to_a
      storage = vals.map { |v| v || "" }
      raw = storage.map(&.to_unsafe)
      valid = vals.map { |v| v.nil? ? 0_u8 : 1_u8 }
      ptr = Pointer(LibNanoarrowBridge::ArrowArray).malloc(1)
      Error.check LibNanoarrowBridge.array_init_string(ptr, raw.to_unsafe, valid.to_unsafe, vals.size.to_i64), "building StringArray"
      new(ptr)
    end

    def unsafe_get(index : Int64) : String?
      str_ptr = Pointer(UInt8).null
      str_size = uninitialized Int64
      code = LibNanoarrowBridge.array_string_get(@ptr, index, pointerof(str_ptr), pointerof(str_size))
      return if code == 1
      Error.check code, "reading StringArray"
      String.new(Bytes.new(str_ptr, str_size))
    end

    def to_a : ::Array(String?)
      (0_i64...length).map { |i| unsafe_get(i) }
    end
  end
end
