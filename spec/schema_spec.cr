require "./spec_helper"

describe Nanoarrow::Schema do
  it "wraps primitive Arrow C Data format strings" do
    schema = Nanoarrow::Schema.int32("value")
    schema.format.should eq("i")
    schema.name.should eq("value")
    schema.released?.should be_false
    schema.release
    schema.released?.should be_true
  end

  it "bool schema has format 'b'" do
    schema = Nanoarrow::Schema.bool("flag")
    schema.format.should eq("b")
    schema.name.should eq("flag")
  end

  it "int64 schema has format 'l'" do
    schema = Nanoarrow::Schema.int64("count")
    schema.format.should eq("l")
  end

  it "uint32 schema has format 'I'" do
    schema = Nanoarrow::Schema.uint32("id")
    schema.format.should eq("I")
  end

  it "float32 schema has format 'f'" do
    schema = Nanoarrow::Schema.float32("weight")
    schema.format.should eq("f")
  end

  it "float64 schema has format 'g'" do
    schema = Nanoarrow::Schema.float64("score")
    schema.format.should eq("g")
  end

  it "string schema has format 'u'" do
    schema = Nanoarrow::Schema.string("label")
    schema.format.should eq("u")
  end

  it "schema without name returns nil for name" do
    schema = Nanoarrow::Schema.int32
    schema.name.should be_nil
  end
end
