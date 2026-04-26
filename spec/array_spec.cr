require "./spec_helper"

describe Nanoarrow::BoolArray do
  it "builds and reads nullable bool arrays" do
    array = Nanoarrow::BoolArray.build([true, false, nil, true])
    array.length.should eq(4)
    array.null_count.should eq(1)
    array[0].should be_true
    array[1].should be_false
    array[2].should be_nil
    array[3].should be_true
    array.to_a.should eq([true, false, nil, true])
  end

  it "supports negative indexing" do
    array = Nanoarrow::BoolArray.build([true, false, true])
    array[-1].should be_true
    array[-3].should be_true
  end

  it "compact removes nils" do
    array = Nanoarrow::BoolArray.build([true, nil, false])
    array.compact.should eq([true, false])
  end

  it "supports Enumerable: map and select" do
    array = Nanoarrow::BoolArray.build([true, false, nil, true])
    array.select { |v| v == true }.should eq([true, true])
    array.count { |v| !v.nil? }.should eq(3)
  end

  it "null? works correctly" do
    array = Nanoarrow::BoolArray.build([true, nil])
    array.null?(0).should be_false
    array.null?(1).should be_true
  end
end

describe Nanoarrow::Int32Array do
  it "builds and reads nullable int32 arrays" do
    array = Nanoarrow::Int32Array.build([1, 2, nil, 4])
    array.length.should eq(4)
    array.null_count.should eq(1)
    array[0].should eq(1)
    array[2].should be_nil
    array.to_a.should eq([1, 2, nil, 4])
  end

  it "supports negative indexing" do
    array = Nanoarrow::Int32Array.build([10, 20, 30])
    array[-1].should eq(30)
    array[-2].should eq(20)
    array[-3].should eq(10)
  end

  it "supports range indexing" do
    array = Nanoarrow::Int32Array.build([1, 2, 3, 4, 5])
    array[1..3].should eq([2, 3, 4])
    array[0...2].should eq([1, 2])
  end

  it "raises IndexError for out-of-bounds" do
    array = Nanoarrow::Int32Array.build([1, 2, 3])
    expect_raises(IndexError) { array[5] }
    expect_raises(IndexError) { array[-4] }
  end

  it "supports Enumerable: map, select, any?, all?, min, max" do
    array = Nanoarrow::Int32Array.build([3, 1, 4, 1, 5])
    array.map { |v| v.try(&.* 2) }.should eq([6, 2, 8, 2, 10])
    array.select { |v| v && v > 2 }.should eq([3, 4, 5])
    array.any? { |v| v == 5 }.should be_true
    array.all? { |v| !v.nil? }.should be_true
    array.compact.min.should eq(1)
    array.compact.max.should eq(5)
  end

  it "compact removes nils" do
    array = Nanoarrow::Int32Array.build([1, nil, 3, nil, 5])
    array.compact.should eq([1, 3, 5])
  end

  it "empty? works" do
    Nanoarrow::Int32Array.build([] of Int32?).empty?.should be_true
    Nanoarrow::Int32Array.build([1]).empty?.should be_false
  end

  it "inspect produces readable output" do
    array = Nanoarrow::Int32Array.build([1, nil, 3])
    array.inspect.should eq("Nanoarrow::Int32Array[1, nil, 3]")
  end
end

describe Nanoarrow::Int64Array do
  it "builds and reads nullable int64 arrays" do
    array = Nanoarrow::Int64Array.build([100_i64, nil, 300_i64])
    array.length.should eq(3)
    array.null_count.should eq(1)
    array[0].should eq(100_i64)
    array[1].should be_nil
    array[2].should eq(300_i64)
  end

  it "handles large values" do
    big = Int64::MAX
    array = Nanoarrow::Int64Array.build([big, Int64::MIN])
    array[0].should eq(big)
    array[1].should eq(Int64::MIN)
  end

  it "compact and Enumerable work" do
    array = Nanoarrow::Int64Array.build([1_i64, nil, 3_i64])
    array.compact.should eq([1_i64, 3_i64])
    array.first.should eq(1_i64)
    array.length.should eq(3)
  end
end

describe Nanoarrow::UInt32Array do
  it "builds and reads nullable uint32 arrays" do
    array = Nanoarrow::UInt32Array.build([0_u32, 1_u32, nil, UInt32::MAX])
    array.length.should eq(4)
    array.null_count.should eq(1)
    array[0].should eq(0_u32)
    array[1].should eq(1_u32)
    array[2].should be_nil
    array[3].should eq(UInt32::MAX)
  end

  it "supports negative indexing" do
    array = Nanoarrow::UInt32Array.build([10_u32, 20_u32, 30_u32])
    array[-1].should eq(30_u32)
  end

  it "compact and to_a work" do
    array = Nanoarrow::UInt32Array.build([5_u32, nil, 7_u32])
    array.compact.should eq([5_u32, 7_u32])
    array.to_a.should eq([5_u32, nil, 7_u32])
  end
end

describe Nanoarrow::Float32Array do
  it "builds and reads nullable float32 arrays" do
    array = Nanoarrow::Float32Array.build([1.5_f32, nil, 3.14_f32])
    array.length.should eq(3)
    array.null_count.should eq(1)
    array[0].should eq(1.5_f32)
    array[1].should be_nil
    array_2 = array[2]
    array_2.should_not be_nil
    if array_2
      (array_2 - 3.14_f32).abs.should be < 0.001_f32
    end
  end

  it "compact removes nils" do
    array = Nanoarrow::Float32Array.build([1.0_f32, nil, 2.0_f32])
    array.compact.should eq([1.0_f32, 2.0_f32])
  end

  it "Enumerable: map works" do
    array = Nanoarrow::Float32Array.build([1.0_f32, 2.0_f32, 3.0_f32])
    array.map { |v| v.try(&.* 2) }.should eq([2.0_f32, 4.0_f32, 6.0_f32])
  end
end

describe Nanoarrow::Float64Array do
  it "builds and reads nullable float64 arrays" do
    array = Nanoarrow::Float64Array.build([1.1, nil, 3.3])
    array.length.should eq(3)
    array.null_count.should eq(1)
    array[0].should eq(1.1)
    array[1].should be_nil
    array[2].should eq(3.3)
  end

  it "handles all-null array" do
    array = Nanoarrow::Float64Array.build([nil, nil, nil] of Float64?)
    array.null_count.should eq(3)
    array.compact.should be_empty
    array.all?(Nil).should be_true
  end
end

describe Nanoarrow::StringArray do
  it "builds and reads nullable utf8 arrays" do
    array = Nanoarrow::StringArray.build(["alpha", nil, "gamma"])
    array.length.should eq(3)
    array.null_count.should eq(1)
    array[0].should eq("alpha")
    array[1].should be_nil
    array[2].should eq("gamma")
  end

  it "handles empty strings" do
    array = Nanoarrow::StringArray.build(["", "hello", ""])
    array[0].should eq("")
    array[1].should eq("hello")
    array[2].should eq("")
  end

  it "supports negative indexing" do
    array = Nanoarrow::StringArray.build(["a", "b", "c"])
    array[-1].should eq("c")
    array[-3].should eq("a")
  end

  it "supports range indexing" do
    array = Nanoarrow::StringArray.build(["a", "b", "c", "d"])
    array[1..2].should eq(["b", "c"])
  end

  it "compact removes nils" do
    array = Nanoarrow::StringArray.build(["x", nil, "z"])
    array.compact.should eq(["x", "z"])
  end

  it "Enumerable: map, select, first, last" do
    array = Nanoarrow::StringArray.build(["hello", "world", nil])
    array.map { |v| v.try(&.upcase) }.should eq(["HELLO", "WORLD", nil])
    array.select { |v| v }.should eq(["hello", "world"])
    array.first.should eq("hello")
  end

  it "inspect produces readable output" do
    array = Nanoarrow::StringArray.build(["a", nil, "b"])
    array.inspect.should eq(%(Nanoarrow::StringArray["a", nil, "b"]))
  end
end
