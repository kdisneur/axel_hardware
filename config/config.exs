use Mix.Config

config :axel_hardware, :api,
  username: System.get_env("API_USERNAME"),
  password: System.get_env("API_PASSWORD"),
  url: System.get_env("API_URL")

config :axel_hardware, :config,
  pee: [actions: [pee: true, poop: false],
        gpios: [button: 4, success: 22, error: 27, in_progress: 0]],
  poop: [actions: [pee: false, poop: true],
        gpios: [button: 5, success: 26, error: 19, in_progress: 0]],
  both: [actions: [pee: true, poop: true],
        gpios: [button: 6, success: 21, error: 20, in_progress: 0]]
