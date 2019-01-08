defmodule Phase4word.Hash do

  def h(bin, 0) when is_binary(bin) do
    bin
  end

  def h(bin, 1) when is_binary(bin) do
    :crypto.hash(:sha256, bin)
    |> Base.encode16(case: :lower)
  end

  def h(bin, n) when is_binary(bin) and is_integer(n) and n > 0 do
    acc = :crypto.hash(:sha256, bin)
          |> Base.encode16(case: :lower)
    h(acc, n - 1)
  end

end
