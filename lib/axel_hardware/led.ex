defmodule AxelHardware.LED do
  use GenServer

  defstruct gpio: nil, blinking_pid: nil

  def start_link(context, gpio_port) do
    GenServer.start_link(__MODULE__, gpio_port, name: via_tuple(context))
  end

  def init(gpio_port) do
    {:ok, gpio} = Gpio.start_link(gpio_port, :output)

    {:ok, %__MODULE__{gpio: gpio}}
  end

  def turn_off(context) do
    GenServer.call(via_tuple(context), :turn_on)
  end

  def turn_on(context) do
    GenServer.call(via_tuple(context), :turn_off)
  end

  def blink(context, rate \\ 500) do
    GenServer.call(via_tuple(context), {:blink, rate})
  end

  def handle_call({:blink, rate}, _from, state) do
    state
    |> turn_blinking_on(rate)
    |> build_reply
  end

  def handle_call(:turn_on, _from, state) do
    state
    |> turn_blinking_off
    |> turn_gpio_on
    |> build_reply
  end

  def handle_call(:turn_off, _from, state) do
    state
    |> turn_blinking_off
    |> turn_gpio_off
    |> build_reply
  end

  defp via_tuple(context) do
    {:via, :gproc, {:n, :l, {__MODULE__, context}}}
  end

  defp build_reply(state) do
    {:reply, :ok, state}
  end

  defp turn_blinking_off(state = %__MODULE__{blinking_pid: pid}) when is_pid(pid) do
    Process.exit(pid, :kill)

    %__MODULE__{state | blinking_pid: nil}
  end
  defp turn_blinking_off(state) do
    state
  end

  defp turn_blinking_on(state = %__MODULE__{blinking_pid: pid}, rate) when is_pid(pid) do
    state = turn_blinking_off(state)

    turn_blinking_on(state, rate)
  end
  defp turn_blinking_on(state, rate) do
    pid = spawn(fn -> do_blink(state, rate) end)

    %__MODULE__{state | blinking_pid: pid}
  end

  defp turn_gpio_off(state) do
    Gpio.write(state.gpio, 1)

    state
  end

  defp turn_gpio_on(state) do
    Gpio.write(state.gpio, 0)

    state
  end

  defp do_blink(state, rate) do
    turn_gpio_on(state)
    Process.sleep(rate)
    turn_gpio_off(state)
    Process.sleep(rate)

    do_blink(state, rate)
  end
end
