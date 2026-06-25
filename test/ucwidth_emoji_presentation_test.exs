defmodule UcwidthTest.EmojiPresentationTest do
  alias Ucwidth.EmojiPresentation

  use ExUnit.Case

  import EmojiPresentation
  doctest EmojiPresentation

  test "empty text" do
    assert next_emoji_presentation("") == :none
  end

  test "matches a base + U+FE0F sequence and returns the rest" do
    assert next_emoji_presentation("\u{2699}\u{FE0F}!") == {"\u{2699}\u{FE0F}", "!"}
  end

  test "does not match a base + U+FE0E (text style) sequence" do
    assert next_emoji_presentation("\u{2699}\u{FE0E}") == :none
  end

  test "does not match a bare base without a variation selector" do
    assert next_emoji_presentation("\u{2699}") == :none
  end
end
