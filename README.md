# Ucwidth

A port of [ucwidth C library](https://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c) to Elixir, with Emoji supported.

[Online documentation](https://hexdocs.pm/ucwidth/Ucwidth.html)

## Motivation

When developing a terminal based Elixir application, I found lack of some library handling character width correctly. Turns out there's a need to port [ucwidth](https://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c) to Elixir. So I made this library.

I'm not professional at Unicode, just read the specifications and some references. So please report any issues you meet, thanks in advance.

## Usage

This library provides a function `Ucwidth.width/2` for detecting the display width of a Unicode character.

For example:

```elixir
iex> Ucwidth.width("行")
2

iex> Ucwidth.width("h")
1

iex> Ucwidth.width("\x0C")
0
```

## Installation

Add `ucwidth` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ucwidth, "~> 0.2"}
  ]
end
```

## Performance

Attention to performance was paid during development. You can check the performance by running:

```sh
mix run bench/benchmark.exs
```

## License

This library is open-sourced under an MIT license.
