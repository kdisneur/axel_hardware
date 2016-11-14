defmodule AxelHardware do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = Enum.map(config, fn {context, config} ->
      supervisor(AxelHardware.ActionSupervisor, [context, config], id: context)
    end)

    opts = [strategy: :one_for_one, name: AxelHardware.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp config do
    Application.get_env(:axel_hardware, :config)
  end
end
