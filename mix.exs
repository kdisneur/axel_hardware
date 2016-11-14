defmodule AxelHardware.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi2"

  def project do
    [app: :axel_hardware,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.1.4"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps ++ system(@target)]
  end

  def application do
    [mod: {AxelHardware, []},
     applications: [:calendar, :gproc, :httpoison, :logger]]
  end

  def deps do
    [{:calendar, "~> 0.16.1"},
     {:elixir_ale, "~> 0.5.5"},
     {:gproc, "~> 0.5.0"},
     {:httpoison, "~> 0.9.0"},
     {:nerves, "~> 0.3.0"}]
  end

  def system(target) do
    [{:"nerves_system_#{target}", ">= 0.0.0"}]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
