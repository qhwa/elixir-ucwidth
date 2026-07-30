defmodule Ucwidth.EmojiPresentation do
  @moduledoc """
  A module for detecting emoji **presentation** (variation) sequences.

  An emoji presentation sequence is a base character followed by the variation
  selector **U+FE0F (VARIATION SELECTOR-16, "VS16")**, e.g. `⚙️` is `U+2699
  U+FE0F` (GEAR + VS16). VS16 requests the emoji (color, full-width)
  presentation of the preceding character, which virtually all modern terminals
  render as **two cells wide**.

  Without this, such a sequence is mis-measured one column too narrow: the base
  is scored by its East-Asian-Width (often 1) and VS16 is treated as a
  zero-width combining mark (0), summing to 1 instead of 2.

  Only the `<base> U+FE0F` (`emoji style`) sequences are matched. The
  `<base> U+FE0E` (`text style`) sequences request narrow, text presentation
  and are intentionally left to fall through to the per-codepoint path (width 1).

  ## Resources

  * [Unicode TR51 - Unicode Emoji](https://www.unicode.org/reports/tr51/)
  * [emoji-variation-sequences.txt](https://www.unicode.org/Public/13.0.0/ucd/emoji/emoji-variation-sequences.txt)
  """
  @external_resource seqs = Path.join(__DIR__, "../data/emoji_variation_sequences.txt")

  @spec next_emoji_presentation(String.t()) :: :none | {String.t(), String.t()}
  @doc """
  Retrieve the next emoji presentation sequence from the beginning of a string,
  also returning rest of the string.

  ## Examples

  The gear `⚙️` is `U+2699 U+FE0F` (GEAR + VS16), so it can be detected as:

  ```elixir
  iex> next_emoji_presentation("\u{2699}\u{FE0F} -> gear")
  {"\u{2699}\u{FE0F}", " -> gear"}
  ```

  A base character carrying the **text** selector `U+FE0E` is not an emoji
  presentation sequence, so `:none` is returned:

  ```elixir
  iex> next_emoji_presentation("\u{2699}\u{FE0E}")
  :none
  ```

  If no emoji presentation sequence is detected at the beginning, `:none` will
  be returned:

  ```elixir
  iex> next_emoji_presentation("\u{1F468} :)")
  :none
  ```
  """
  def next_emoji_presentation(string)

  for seq <- Ucwidth.ParseUnicode.parse_emoji_variation_seqs(seqs) do
    emoji_ast = {
      :<<>>,
      [],
      for(codepoint <- seq, do: {:"::", [], [codepoint, {:utf8, [], Elixir}]})
    }

    emoji =
      seq
      |> Enum.map(&<<&1::utf8>>)
      |> Enum.join()

    def next_emoji_presentation(unquote(emoji_ast) <> rest), do: {unquote(emoji), rest}
  end

  def next_emoji_presentation(_), do: :none
end
