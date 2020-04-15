defmodule Ucwidth.CombinedEmoji do
  @moduledoc """
  A module for detecting combined Emoji graphemes.

  Combined Emoji graphemes are combined from codepoints with one or more ZWJ (Zero Width Joinner).

  ## Resources

  * [Unicode Emoji Data Files](https://www.unicode.org/reports/tr41/tr41-26.html#Data51) - [emoji-sequences.txt](https://unicode.org/Public/emoji/13.0/emoji-zwj-sequences.txt)
  """
  @external_resource emoji_zwj_seqs = Path.join(__DIR__, "../data/emoji_zwj_sequences.txt")

  @spec next_combined_emoji(String.t()) :: :none | {String.t(), String.t()}
  @doc """
  Retrieve next combined Emoji grapheme from the beginning of a string, also returning rest of the string.

  ## Examples

  The Emoji woman scientist \u{1F469}\u200D\u{1F52C} is a combined character, its codepoints are:

  `["\u{1F469}", ZWJ, "\u{1F52C}"]`, so it can be detected as:

  ```elixir
  iex> next_combined_emoji("\u{1F469}\u200D\u{1F52C} -> woman scientist")
  {"\u{1F469}\u200D\u{1F52C}", " -> woman scientist"}
  ```

  If no combined Emoji character detected at the beginning, `:none` will be returned:

  ```elixir
  iex> next_combined_emoji("\u{1F468} :)")
  :none
  ```

  Please note normal Emoji characters detecting is out of the scope.
  """
  def next_combined_emoji(string)

  for seq <- Ucwidth.ParseUnicode.parse_emoji_zwj_seqs(emoji_zwj_seqs) do
    emoji_ast = {
      :<<>>,
      [],
      for(codepoint <- seq, do: {:"::", [], [codepoint, {:utf8, [], Elixir}]})
    }

    emoji =
      seq
      |> Enum.map(&<<&1::utf8>>)
      |> Enum.join()

    def next_combined_emoji(unquote(emoji_ast) <> rest), do: {unquote(emoji), rest}
  end

  def next_combined_emoji(_), do: :none
end
