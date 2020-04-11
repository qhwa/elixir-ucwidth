# Ucwidth

A port of [ucwidth C library](https://www.cl.cam.ac.uk/~mgk25/) to Elixir.

## Installation

Add `ucwidth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ucwidth, "~> 0.1"}
  ]
end
```

## Usage

This library provides only one function `Ucwidth.width/1` for detecting the display width of a Unicode character.

For example:

```elixir
iex> Ucwidth.width("行")
2

iex> Ucwidth.width("h")
1

iex> Ucwidth.width("\x00")
0
```

## License

This library is open-sourced under an MIT license.
