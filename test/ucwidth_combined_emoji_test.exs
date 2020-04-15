defmodule UcwidthTest.CombinedEmojiTest do
  alias Ucwidth.CombinedEmoji

  use ExUnit.Case
  use Quixir

  import CombinedEmoji
  doctest CombinedEmoji

  test "empty text" do
    assert next_combined_emoji("") == :none
  end
end
