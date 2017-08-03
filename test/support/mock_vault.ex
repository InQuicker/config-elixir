defmodule Configuration.MockVault do
  def read(path) do
    case path do
      "abc" -> {:ok, %{"def" => "vault value"}}
      _else -> {:error, "not found"}
    end
  end
end
