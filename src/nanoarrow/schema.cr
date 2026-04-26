require "./lib"
require "./error"

module Nanoarrow
  # Small owning wrapper around ArrowSchema from the Arrow C Data Interface.
  #
  # This MVP supports primitive field schemas. A later version should replace
  # these helpers with direct bindings to upstream nanoarrow's ArrowSchemaInit*()
  # and ArrowSchemaSetType*() functions.
  class Schema
    getter ptr : Pointer(LibNanoarrowBridge::ArrowSchema)

    def initialize(format : String, name : String? = nil)
      @ptr = Pointer(LibNanoarrowBridge::ArrowSchema).malloc(1)
      LibNanoarrowBridge.schema_init(@ptr, format.to_unsafe, name ? name.to_unsafe : Pointer(UInt8).null)
    end

    def self.bool(name : String? = nil) : self
      new("b", name)
    end

    def self.int32(name : String? = nil) : self
      new("i", name)
    end

    def self.int64(name : String? = nil) : self
      new("l", name)
    end

    def self.uint32(name : String? = nil) : self
      new("I", name)
    end

    def self.float32(name : String? = nil) : self
      new("f", name)
    end

    def self.float64(name : String? = nil) : self
      new("g", name)
    end

    def self.string(name : String? = nil) : self
      new("u", name)
    end

    def format : String?
      raw = @ptr.value.format
      raw.null? ? nil : String.new(raw)
    end

    def name : String?
      raw = @ptr.value.name
      raw.null? ? nil : String.new(raw)
    end

    def released? : Bool
      LibNanoarrowBridge.schema_released(@ptr) != 0
    end

    def release : Nil
      LibNanoarrowBridge.schema_release(@ptr) unless released?
    end

    def finalize
      release
    end

    def to_unsafe : Pointer(LibNanoarrowBridge::ArrowSchema)
      @ptr
    end
  end
end
