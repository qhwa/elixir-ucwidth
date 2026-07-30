defmodule UcwidthTest do
  use ExUnit.Case
  use Quixir

  doctest Ucwidth

  test "it works with combining codepoints" do
    path = Path.join(__DIR__, "../lib/data/combining.txt")
    {constants, ranges} = Ucwidth.ParseUnicode.parse(path)

    for code <- constants do
      assert Ucwidth.width(code) == 0
      assert Ucwidth.combining?(code)
      assert Ucwidth.combining?(<<code::utf8>>)
    end

    for {min, max} <- ranges do
      ptest code: int(min: min, max: max) do
        assert Ucwidth.width(code) == 0
        assert Ucwidth.combining?(code)
        assert Ucwidth.combining?(<<code::utf8>>)
      end
    end
  end

  test "it works with wide/full-width codepoints" do
    path = Path.join(__DIR__, "../lib/data/wide.txt")
    {constants, ranges} = Ucwidth.ParseUnicode.parse(path)

    for code <- constants do
      unless combining?(code) do
        assert Ucwidth.width(code) == 2
        assert Ucwidth.wide?(code)
        assert Ucwidth.wide?(<<code::utf8>>)
      end
    end

    for {min, max} <- ranges do
      ptest code: int(min: min, max: max) do
        unless combining?(code) do
          assert Ucwidth.width(code) == 2
          assert Ucwidth.wide?(code)
          assert Ucwidth.wide?(<<code::utf8>>)
        end
      end
    end
  end

  test "special cases work" do
    assert assert_width(0x2329, 2)
    assert assert_width(0x232A, 2)
    assert assert_width(0x303F, 1)
  end

  test "it does not work with unexpected integer" do
    assert Ucwidth.width(-50) == {:error, :bad_arg}
    assert Ucwidth.width(0x110000) == {:error, :bad_arg}
  end

  test "it works with long string" do
    assert Ucwidth.width("ab") == 2
    assert Ucwidth.width("ab公") == 4
  end

  test "it works with conjoined graphemes" do
    assert Ucwidth.width("\u{3000}") == 2
  end

  test "it works with emoji" do
    assert Ucwidth.width("\u{1f468}") == 2
    assert Ucwidth.width("\u{1F469}\u{200D}\u{1F52C}") == 2
  end

  test "emoji presentation sequences (base + U+FE0F) are 2 cells wide" do
    # acceptance-criteria table: base + VS16 must report 2, not 1
    assert Ucwidth.width("\u{2699}\u{FE0F}") == 2
    assert Ucwidth.width("\u{1F3D7}\u{FE0F}") == 2
    assert Ucwidth.width("\u{270F}\u{FE0F}") == 2
    assert Ucwidth.width("\u{2764}\u{FE0F}") == 2
  end

  test "cases unaffected by the VS16 fix stay correct" do
    assert Ucwidth.width("\u{2699}") == 1
    assert Ucwidth.width("\u{1F4E6}") == 2
    assert Ucwidth.width("\u{4F60}") == 2
    assert Ucwidth.width("a") == 1
    assert Ucwidth.width("\u{1F469}\u{200D}\u{1F52C}") == 2
  end

  test "text presentation sequences (base + U+FE0E) stay narrow" do
    # the text selector requests narrow presentation: base (1) + VS15 (0) = 1
    assert Ucwidth.width("\u{2699}\u{FE0E}") == 1
    assert Ucwidth.width("\u{2764}\u{FE0E}") == 1
  end

  test "a ZWJ sequence embedding a VS16 emoji stays 2" do
    # man health worker: U+1F468 U+200D U+2695 U+FE0F
    assert Ucwidth.width("\u{1F468}\u{200D}\u{2695}\u{FE0F}") == 2
  end

  test "it works with multiple codepoint graphemes" do
    assert Ucwidth.width("நி") == 2
    assert Ucwidth.width("ą́") == 1
  end

  test "it accpets `:ambi_as` argument with :narrow" do
    assert Ucwidth.width("\u00e8", :narrow) == 1
  end

  test "it accpets `:ambi_as` argument with :wide" do
    assert Ucwidth.width("\u00ea", :wide) == 2
  end

  test "it reject `:ambi_as` argument with other values" do
    assert Ucwidth.width("\u00ea", :any) == {:error, :bad_arg}
  end

  defp assert_width(codepoint, width) do
    assert Ucwidth.width(codepoint) == width
    assert Ucwidth.width(<<codepoint::utf8>>) == width
  end

  defp combining?(code) do
    Ucwidth.combining?(code)
  end
end
