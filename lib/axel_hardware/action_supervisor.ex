defmodule AxelHardware.ActionSupervisor do
  use Supervisor

  def start_link(context, config) do
    Supervisor.start_link(__MODULE__, {context, config})
  end

  def init({context, config}) do
    import Supervisor.Spec

    actions = config[:actions]
    gpios = config[:gpios]

    children = [
      supervisor(AxelHardware.FeedbackSupervisor, [context, [success: gpios[:success], error: gpios[:error]]]),
      worker(AxelHardware.Worker, [context, {actions[:pee], actions[:poop]}]),
      worker(AxelHardware.Button, [context, gpios[:button]])
    ]

    supervise(children, strategy: :one_for_all, name: build_supervisor_id(context))
  end

  defp build_supervisor_id(context) do
    Module.concat(__MODULE__, "#{String.capitalize(to_string(context))}ActionSupervisor")
  end
end
