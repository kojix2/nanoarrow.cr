require "../src/nanoarrow"

ints = Nanoarrow::Int32Array.build([1, 2, nil, 4])
puts ints.length
puts ints.null_count
puts ints.to_a.inspect

strings = Nanoarrow::StringArray.build(["alpha", nil, "gamma"])
puts strings.to_a.inspect
