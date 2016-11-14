defmodule AxelHardware.Button do
  use GenServer

  defstruct [button_pid: nil, worker_pid: nil, state: :available]
  
  def start_link(context, button_gpio) do
    state = %__MODULE__{worker_pid: context}
    GenServer.start_link(__MODULE__, {state, button_gpio}, name: via_tuple(context))
  end 

  def init({state, button_gpio}) do
    {:ok, button_pid} = Gpio.start_link(button_gpio, :input)

    Gpio.set_int(button_pid, :falling) 

    {:ok, %__MODULE__{state | button_pid: button_pid}}
  end

  def handle_cast(:call, state) do
    current_pid = self

    spawn(fn ->
      AxelHardware.Worker.call(state.worker_pid)
      send(current_pid, :button_available)
    end)

    {:noreply, %__MODULE__{state | state: :working}}
  end

  def handle_info({:gpio_interrupt, _gpio, :falling}, state = %__MODULE__{state: :available}) do
    GenServer.cast(self, :call)

    {:noreply, %__MODULE__{state | state: :working}}
  end
  def handle_info(:button_available, state) do
    {:noreply, %__MODULE__{state | state: :available}}
  end
  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp via_tuple(context) do
    {:via, :gproc, {:n, :l, {__MODULE__, context}}}
  end
end
