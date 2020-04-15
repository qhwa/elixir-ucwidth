defmodule Ucwidth do
  use Ucwidth.ParseUnicode

  @moduledoc """
  A module to determine the width of a Unicode charactor (or codepoint) on monotyped screens.

  A quick comparing between full-width and half-width:

  ```elixir
  "丐" # 1 full-width grapheme
  "gg" # 2 half-width graphemes
  ```

  This module is originally ported from [Dr Markus Kuhn](https://www.cl.cam.ac.uk/~mgk25/)'s [ucwidth library](https://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c) in C, but with updated Unicode database (v13.0.0 currently).

  Furthermore, Emoji characters are supported, e.g:

  ```elixir
  iex> Ucwidth.width("\u{1f36d}")
  2
  ```

  Functions provided by this module are grouped into:

  - `width/2` for determining the display width
  - `wide?/1`, `ambiguous?/1`, `combining?/1` for determining the property of a grapheme

  ## Ambiguous width

  According to the [Unicode specification of East Asian Width](https://www.unicode.org/reports/tr11/),
  some characters have variable width, depending on the context. The left single quotation mark `"\u{2018}"` (`\\u{2018}`), for example, may take one ore two cells depending on whether it is in a East Asian context or not.

  see https://www.unicode.org/reports/tr11/#ED6 for more information.

  This module provides an option to specify how ambiguous characters are treated.
  see `width/2` for more information.
  """

  @max_codepoint 0x10FFFF
  defguardp is_valid_code(code) when is_integer(code) and code in 0..@max_codepoint

  @external_resource comb_data = Path.join(__DIR__, "data/combining.txt")
  @external_resource wide_data = Path.join(__DIR__, "data/wide.txt")
  @external_resource full_data = Path.join(__DIR__, "data/wide_or_ambi.txt")
  @external_resource ambi_data = Path.join(__DIR__, "data/ambi.txt")

  def_ucwidth(:combining?, comb_data, """
  Check if a Unicode grapheme is a combining character.

  The dataset is generated with [uniset](https://github.com/depp/uniset): `uniset cat:Me,Mn,Cf + U+00AD + U+1160..U+11FF + U+200B + U+000C`

  For example:

  ```elixir
  iex> Ucwidth.combining?("\\u061c")
  true

  iex> Ucwidth.combining?("-")
  false
  ```
  """)

  def_ucwidth(:wide?, wide_data, """
  Check if a grapheme is wide in Unicode.

  The dataset is generated with [uniset](https://github.com/depp/uniset): `uniset eaw:W,F`

  A grapheme is considered wide only if it:
  - is East Asia Wide, or
  - is East Asia Fullwidth
  """)

  def_ucwidth(:wide_or_ambiguous?, full_data, """
  Check if a grapheme is wide or ambiguous in Unicode.

  The dataset is generated with [uniset](https://github.com/depp/uniset): `uniset eaw:W,F,A`

  see `wide?/1` for definition of **wide**.
  see `ambiguous?/1` for definition of **ambiguous**.
  """)

  def_ucwidth(:ambiguous?, ambi_data, """
  Check if a grapheme is ambiguous in Unicode.

  The dataset is generated with [uniset](https://github.com/depp/uniset): `uniset eaw:A`

  The display width of an ambiguous grapheme is termined based on the
  context provided. It might take two cells if in an East Asia content
  context, and one cell otherwise.

  ```elixir
  iex> Ucwidth.ambiguous?(0x273d)
  true

  iex> Ucwidth.ambiguous?("在")
  false
  ```
  """)

  @doc """
  Get width of a codepoint or grapheme.

  ## Parameters

  * `codepoint_or_grapheme` - one Unicode grapheme or a unicode codepoint

      - an integer within valid unicode code range (`0..0x11ffff`)
      - a single grapheme, e.g `"c"`, `"\\u{3f0a1}"`

  * `ambiguous_as` - the treament of [ambiguous characters](https://www.unicode.org/reports/tr11/#ED6), by default `:narrow`

      - `:narrow` - treated as f they are narrow
      - `:wide` - treated as if they are wide

      For example:

      ```elixir
      iex> Ucwidth.width("\\u00a1", :narrow)
      1

      iex> Ucwidth.width("\\u00a1", :wide)
      2
      ```

  ## Return values

  Returns the width of the grapheme/codepoint:

  * `0` means this grapheme is **invisible** and takes no space on screen.
  * `1` means it takes **one cell** to display. For instance, English letters are one cell wide.
  * `2` means it takes **two cells** to display. This is quite common in East Asian charsets.


  ## Examples

      iex> Ucwidth.width(0)
      0

      iex> Ucwidth.width("5")
      1

      iex> Ucwidth.width("\u303f")
      1

      iex> Ucwidth.width("\u2329")
      2

      iex> Ucwidth.width("\u2e80")
      2

      iex> Ucwidth.width(255)
      1

  If string length is greater than 1, `{:error, :bad_arg}` will be returned:

      iex> Ucwidth.width("abc")
      {:error, :bad_arg}


  """
  @spec width(non_neg_integer | String.t(), :wide | :narrow) :: 0 | 1 | 2 | {:error, :bad_arg}

  def width(codepoint_or_grapheme, ambiguous_as \\ :narrow)

  def width(<<code::utf8>>, ambiguous_as), do: width(code, ambiguous_as)
  def width(0, _), do: 0

  def width(code, :wide) when is_valid_code(code) do
    cond do
      combining?(code) ->
        0

      wide_or_ambiguous?(code) ->
        2

      :otherwise ->
        1
    end
  end

  def width(code, :narrow) when is_valid_code(code) do
    cond do
      combining?(code) ->
        0

      wide?(code) ->
        2

      :otherwise ->
        1
    end
  end

  def width(_, _), do: {:error, :bad_arg}
end
