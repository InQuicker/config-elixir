use Mix.Config

config :configuration,
	file_path: "test/configuration",
  vault: Configuration.MockVault

config :configuration,
  static_key: "static value",
  env_var: {:ENV, "CONFIGURATION_TEST_ENV_VAR"},
  nonexistent_env_var: {:ENV, "CONFIGURATION_NON_ENV_VAR"},
  file_var: {:FILE, {"abc", "def"}},
  nonexistent_file_var: {:FILE, {"nonexistent", "nothing"}},
  vault_var: {:VAULT, {"abc", "def"}},
  nonexistent_vault_var: {:VAULT, {"pqr", "tuv"}},
  default_var: {:DEFAULT, "default value"},
  config_list: [ENV: "CONFIGURATION_NON_ENV_VAR",
                VAULT: {"abc", "def"},
                FILE: {"abc", "def"}],
  key_list: [a: 1, b: 2, c: 3],
  nonkey_list: [nil, "abc", :value],
  empty_list: []

config :configuration, Configuration,
  static_key: "static value",
  env_var: {:ENV, "CONFIGURATION_TEST_ENV_VAR"},
  nonexistent_env_var: {:ENV, "CONFIGURATION_NON_ENV_VAR"},
  file_var: {:FILE, {"abc", "def"}},
  nonexistent_file_var: {:FILE, {"nonexistent", "nothing"}},
  vault_var: {:VAULT, {"abc", "def"}},
  nonexistent_vault_var: {:VAULT, {"pqr", "tuv"}},
  default_var: {:DEFAULT, "default value"},
  config_list: [ENV: "CONFIGURATION_NON_ENV_VAR",
                VAULT: {"abc", "def"},
                FILE: {"abc", "def"}],
  key_list: [a: 1, b: 2, c: 3],
  nonkey_list: [nil, "abc", :value],
  empty_list: []
