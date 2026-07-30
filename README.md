# Ucwidth

A port of [ucwidth C library](https://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c) to Elixir, with Emoji (basis, variations and zwj-combined-sequences) supported.

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

iex> Ucwidth.width("Hello, <<👪>>, family lovers!")
29
```

Note: according to Unicode standard, not every character has fixed width. There are some characters with variable width, which is called `ambiguous width characters`. Their width vary depends on the context. This library by default treats ambiguous charaters as narrow ones, and also provides a way to pass be context, e.g:

```elixir
iex> Ucwidth.width("\u00a1")
1

iex> Ucwidth.width("\u00a1", :wide)
2
```

Emoji presentation sequences (a base character plus the variation selector `U+FE0F`, "VS16") request the full-width emoji rendering and are measured as 2 cells, while the text selector `U+FE0E` keeps the base narrow:

```elixir
iex> Ucwidth.width("\u{2699}\u{FE0F}") # ⚙️ gear + VS16
2

iex> Ucwidth.width("\u{2699}\u{FE0E}") # ⚙︎ gear + VS15 (text)
1
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
