defmodule AxelHardware.FeedbackSupervisor do
  use Supervisor

  def start_link(context, gpios) do
    Supervisor.start_link(__MODULE__, {context, gpios})
  end

  def init({context, gpios}) do
    import Supervisor.Spec


    children = [
      worker(AxelHardware.LED, [{context, :success}, gpios[:success]], id: :success_led),
      worker(AxelHardware.LED, [{context, :error}, gpios[:error]], id: :error_led),
      worker(AxelHardware.LED, [{context, :in_progress}, gpios[:in_progress]], id: :in_progress_led),
      worker(AxelHardware.Feedback, [context])
    ]

    supervise(children, strategy: :one_for_all, name: build_supervisor_id(context))
  end

  defp build_supervisor_id(context) do
    Module.concat(__MODULE__, "#{String.capitalize(to_string(context))}FeedbackSupervisor")
  end
end
