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

  test "it does not work with long string" do
    assert Ucwidth.width("ab") == {:error, :bad_arg}
  end

  test "it works with conjoined graphemes" do
    assert Ucwidth.width("\u{3000}") == 2
  end

  test "it works with emoji" do
    assert Ucwidth.width("\u{1f468}") == 2
  end

  defp assert_width(codepoint, width) do
    assert Ucwidth.width(codepoint) == width
    assert Ucwidth.width(<<codepoint::utf8>>) == width
  end

  defp combining?(code) do
    Ucwidth.combining?(code)
  end
end
