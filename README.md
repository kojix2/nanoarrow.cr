# nanoarrow.cr

[![CI](https://github.com/kojix2/nanoarrow.cr/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/nanoarrow.cr/actions/workflows/ci.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fnanoarrow.cr%2Flines)](https://tokei.kojix2.net/github/kojix2/nanoarrow.cr)
![Static Badge](https://img.shields.io/badge/PURE-Vibe_Coding-magenta)

nanoarrow bindings for Crystal.

## Installation

```yaml
dependencies:
  nanoarrow:
    github: kojix2/nanoarrow.cr
```

## Usage

```crystal
require "../src/nanoarrow"

ints = Nanoarrow::Int32Array.build([1, 2, nil, 4])
puts ints.length
puts ints.null_count
puts ints.to_a.inspect

strings = Nanoarrow::StringArray.build(["alpha", nil, "gamma"])
puts strings.to_a.inspect
```

## License

Apache-2.0
