defmodule Ucwidth.ParseUnicode do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [def_ucwidth: 3]
      import Ucwidth.Util.BinSearch

      Module.register_attribute(__MODULE__, :unicode_maps, accumulate: true)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro def_ucwidth(name, data_file, doc) do
    quote do
      @unicode_maps {unquote(name), unquote(data_file), unquote(doc)}
    end
  end

  defmacro __before_compile__(%Macro.Env{module: module}) do
    for {name, data_file, doc} <- Module.get_attribute(module, :unicode_maps) do
      do_compile(name, data_file, doc)
    end
  end

  defp do_compile(name, data_file, doc) do
    {constants, ranges} = parse(data_file)

    def_const_ast =
      for code <- constants do
        quote do
          def unquote(name)(unquote(code)), do: true
        end
      end

    ranges =
      quote do
        List.to_tuple(unquote(ranges))
      end

    quote do
      @doc unquote(doc)
      @spec unquote(name)(non_neg_integer | String.t()) :: boolean
      def unquote(name)(codepoint_or_grapheme)

      def unquote(name)(<<code::utf8>>), do: unquote(name)(code)
      def unquote(name)(<<code::utf8, _::binary>>), do: {:error, :bad_arg}
      unquote(def_const_ast)
      def unquote(name)(code), do: bin_search(unquote(ranges), code)
    end
  end

  def parse(data_path) do
    data_path
    |> File.stream!()
    |> Stream.filter(&(&1 =~ ~r/^\w/))
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line ->
      case Regex.scan(~r/[[:xdigit:]]+/, line) do
        [[int]] ->
          hex(int)

        [[a], [b]] ->
          {hex(a), hex(b)}
      end
    end)
    |> Enum.split_with(&Kernel.is_integer/1)
  end

  defp hex(t), do: String.to_integer(t, 16)
end
