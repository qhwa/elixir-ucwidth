cases = [
  {2, "包", "full_width/cjk"},
  {2, "\u{ff50}", "full_width/full_width_forms"},
  {0, "\x00", "combining/0"},
  {0, "\u{e0100}", "combining/e0100"},
  {1, "Z", "half_width/ascii"}
]

for {expect, char, title} <- cases, into: %{} do
  {title, fn -> ^expect = Ucwidth.width(char) end}
end
|> Benchee.run()
