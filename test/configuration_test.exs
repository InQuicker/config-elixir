defmodule ConfigurationTest do
  use ExUnit.Case, async: true

  Code.require_file "support/mock_vault.ex", __DIR__

  alias Configuration, as: C

  defp setup_env_var do
    System.put_env("CONFIGURATION_TEST_ENV_VAR", "env value")
  end

  defp setup_file_var do
    path = "#{C.file_path()}/abc"
    name = "#{path}/def"

    File.rm_rf name
    File.mkdir_p path
    File.write name, "file value"
  end

  defp clear_file_var do
    File.rm_rf "#{C.file_path()}/nonexistent/nothing"
  end

  describe "When not using a namespace" do
    test "returns nil when no key is found" do
      assert C.get(:configuration, :nonexistent) == nil
      assert Application.get_env(:configuration, :nonexistent) == nil
    end

    test "returns the non-dynamic value from a key" do
      value = "static value"
      assert C.get(:configuration, :static_key) == value
      assert Application.get_env(:configuration, :static_key) == value
    end

    test "resolves a dynamic ENV value" do
      setup_env_var()
      value = "env value"

      assert C.get(:configuration, :env_var) == value
      assert Application.get_env(:configuration, :env_var) == value
    end

    test "returns nil when environment variable does not exist" do
      assert C.get(:configuration, :nonexistent_env_var) == nil
      assert Application.get_env(:configuration, :nonexistent_env_var) == {:ENV, "CONFIGURATION_NON_ENV_VAR"}
    end

    test "resolves a dynamic FILE value" do
      setup_file_var()
      value = "file value"

      assert C.get(:configuration, :file_var) == value
      assert Application.get_env(:configuration, :file_var) == value
    end

    test "returns nil when a file does not exist" do
      clear_file_var()

      assert C.get(:configuration, :nonexistent_file_var) == nil
      assert Application.get_env(:configuration, :nonexistent_file_var) == {:FILE, {"nonexistent", "nothing"}}
    end

    test "resolves a dynamic VAULT value" do
      value = "vault value"
      assert C.get(:configuration, :vault_var) == value
      assert Application.get_env(:configuration, :vault_var) == value
    end

    test "returns nil when a Vault value does not exist" do
      assert C.get(:configuration, :nonexistent_vault_var) == nil
      assert Application.get_env(:configuration, :nonexistent_vault_var) == {:VAULT, {"pqr", "tuv"}}
    end

    test "resolves a dynamic DEFAULT value" do
      value = "default value"
      assert C.get(:configuration, :default_var) == value
      assert Application.get_env(:configuration, :default_var) == value
    end

    test "resolves a keyword list to the first non-nil value" do
      value = "vault value"
      assert C.get(:configuration, :config_list) == value
      assert Application.get_env(:configuration, :config_list) == value
    end

    test "resolves a keyword list of non-configuration values to the list" do
      value = [a: 1, b: 2, c: 3]
      assert C.get(:configuration, :key_list) == value
      assert Application.get_env(:configuration, :key_list) == value
    end

    test "resolves a non-keyword list to the list" do
      value = [nil, "abc", :value]
      assert C.get(:configuration, :nonkey_list) == value
      assert Application.get_env(:configuration, :nonkey_list) == value
    end

    test "returns an empty list" do
      assert C.get(:configuration, :empty_list) == []
      assert Application.get_env(:configuration, :empty_list) == []
    end
  end

  describe "When using a namespace" do
    test "returns nil when no key is found" do
      assert C.get(:configuration, Configuration, :nonexistent) == nil
      assert Application.get_env(:configuration, Configuration)[:nonexistent] == nil
    end

    test "returns the non-dynamic value from a key" do
      value = "static value"
      assert C.get(:configuration, Configuration, :static_key) == value
      assert Application.get_env(:configuration, Configuration)[:static_key] == value
    end

    test "resolves a dynamic ENV value" do
      setup_env_var()
      value = "env value"

      assert C.get(:configuration, Configuration, :env_var) == value
      assert Application.get_env(:configuration, Configuration)[:env_var] == value
    end

    test "returns nil when environment variable does not exist" do
      assert C.get(:configuration, Configuration, :nonexistent_env_var) == nil
      assert Application.get_env(:configuration, Configuration)[:nonexistent_env_var] == {:ENV, "CONFIGURATION_NON_ENV_VAR"}
    end

    test "resolves a dynamic FILE value" do
      setup_file_var()
      value = "file value"

      assert C.get(:configuration, Configuration, :file_var) == value
      assert Application.get_env(:configuration, Configuration)[:file_var] == value
    end

    test "returns nil when a file does not exist" do
      clear_file_var()

      assert C.get(:configuration, Configuration, :nonexistent_file_var) == nil
      assert Application.get_env(:configuration, Configuration)[:nonexistent_file_var] == {:FILE, {"nonexistent", "nothing"}}
    end

    test "resolves a dynamic VAULT value" do
      value = "vault value"
      assert C.get(:configuration, Configuration, :vault_var) == value
      assert Application.get_env(:configuration, Configuration)[:vault_var] == value
    end

    test "returns nil when a Vault value does not exist" do
      assert C.get(:configuration, Configuration, :nonexistent_vault_var) == nil
      assert Application.get_env(:configuration, Configuration)[:nonexistent_vault_var] == {:VAULT, {"pqr", "tuv"}}
    end

    test "resolves a dynamic DEFAULT value" do
      value = "default value"
      assert C.get(:configuration, Configuration, :default_var) == value
      assert Application.get_env(:configuration, Configuration)[:default_var] == value
    end

    test "resolves a keyword list to the first non-nil value" do
      value = "vault value"
      assert C.get(:configuration, Configuration, :config_list) == value
      assert Application.get_env(:configuration, Configuration)[:config_list] == value
    end

    test "resolves a keyword list of non-configuration values to the list" do
      value = [a: 1, b: 2, c: 3]
      assert C.get(:configuration, Configuration, :key_list) == value
      assert Application.get_env(:configuration, Configuration)[:key_list] == value
    end

    test "resolves a non-keyword list to the list" do
      value = [nil, "abc", :value]
      assert C.get(:configuration, Configuration, :nonkey_list) == value
      assert Application.get_env(:configuration, Configuration)[:nonkey_list] == value
    end

    test "returns an empty list" do
      assert C.get(:configuration, Configuration, :empty_list) == []
      assert Application.get_env(:configuration, Configuration)[:empty_list] == []
    end
  end
end
