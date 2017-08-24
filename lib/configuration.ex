defmodule Configuration do
  @moduledoc """
  Read values from Elixir configuration file for a particular environment and
  potentially resolve those values that match distinguished patterns:

    1. {:ENV, "VARIABLE_NAME"} is resolved with System.get_env("VARIABLE_NAME").

    2. {:VAULT, {path, key}} is resolved by reading 'key' at 'path' from Vault.

    3. {:FILE, {path, key}} is resolved by reading a file at "file_path()/path/key",
          where file_path() is read from the configuration for this module.

    4. {:DEFAULT, value} is resolved to value.

    A configuration item may be a (keyword) list of these distinguished patterns
    and they will be resolved in order.

    When a configuration item is resolved to a value, the value is written back
    to the configuration so that subsequent fetches are effectively cached.
  """

  def get(application, key) do
    application
    |> Application.get_env(key)
    |> cache_configuration(key, application)
  end

  def get(application, namespace, key) do
    application
    |> Application.get_env(namespace, [])
    |> Keyword.get(key)
    |> cache_configuration(namespace, key, application)
  end

  def file_path do
    Application.get_env(:configuration, :file_path)
  end

  def vault do
    Application.get_env(:configuration, :vault)
  end

  defp cache_configuration([h | t] = list, key, application) do
    case cache_configuration(h, key, application) do
      ^h    -> list
      nil   -> cache_configuration(t, key, application)
      value -> value
    end
  end

  defp cache_configuration(list, _key, _application)
    when is_list(list), do: list

  defp cache_configuration({:ENV, name}, key, application) do
    put_env(application, key, System.get_env(name))
  end

  defp cache_configuration({:VAULT, {path, item}}, key, application) do
    case vault().read(path) do
      {:ok, %{^item => value}} -> put_env(application, key, value)
      _else -> nil
    end
  end

  defp cache_configuration({:FILE, {path, item}}, key, application) do
    case File.read("#{file_path()}/#{path}/#{item}") do
      {:ok, file} -> put_env(application, key, String.trim_trailing(file))
      _else -> nil
    end
  end

  defp cache_configuration({:DEFAULT, value}, key, application) do
    put_env(application, key, value)
  end

  defp cache_configuration(value, _key, _application), do: value

  defp cache_configuration([h | t] = list, namespace, key, application) do
    case cache_configuration(h, namespace, key, application) do
      ^h    -> list
      nil   -> cache_configuration(t, namespace, key, application)
      value -> value
    end
  end

  defp cache_configuration(list, _namespace, _key, _application)
    when is_list(list), do: list

  defp cache_configuration({:ENV, name}, namespace, key, application) do
    put_env(application, namespace, key, System.get_env(name))
  end

  defp cache_configuration({:VAULT, {path, item}}, namespace, key, application) do
    case vault().read(path) do
      {:ok, %{^item => value}} -> put_env(application, namespace, key, value)
      _else -> nil
    end
  end

  defp cache_configuration({:FILE, {path, item}}, namespace, key, application) do
    case File.read("#{file_path()}/#{path}/#{item}") do
      {:ok, file} -> put_env(application, namespace, key, String.trim_trailing(file))
      _else -> nil
    end
  end

  defp cache_configuration({:DEFAULT, value}, namespace, key, application) do
    put_env(application, namespace, key, value)
  end

  defp cache_configuration(value, _namespace, _key, _application), do: value

  defp put_env(_application, _key, nil), do: nil

  defp put_env(application, key, value) do
    Application.put_env(application, key, value)
    value
  end

  defp put_env(_application, _namespace, _key, nil), do: nil

  defp put_env(application, namespace, key, value) do
    keys = Keyword.put(Application.get_env(application, namespace, []), key, value)
    Application.put_env(application, namespace, keys)
    value
  end
end
