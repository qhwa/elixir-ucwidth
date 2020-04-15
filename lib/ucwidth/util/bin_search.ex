defmodule Ucwidth.Util.BinSearch do
  def bin_search(ranges, target) when is_tuple(ranges) do
    do_bin_search(ranges, target, 0, tuple_size(ranges) - 1)
  end

  defp do_bin_search(_ranges, _target, min, max) when min > max, do: false

  defp do_bin_search(ranges, target, min, max) do
    half = div(min + max, 2)

    case elem(ranges, half) do
      {a, b} when target >= a and target <= b ->
        true

      {a, _} when target < a ->
        do_bin_search(ranges, target, min, half - 1)

      {_, b} when target > b ->
        do_bin_search(ranges, target, half + 1, max)
    end
  end
end
