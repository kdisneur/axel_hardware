defmodule AxelHardware.Feedback do
  use GenServer

  defstruct error_pid: nil, success_pid: nil

  def start_link(context) do
    state = %__MODULE__{error_pid: {context, :error}, success_pid: {context, :success}, in_progress_pid: {context, :in_progress}}

    GenServer.start_link(__MODULE__, state, name: via_tuple(context))
  end

  def success(context, time \\ 3_000) do
    GenServer.call(via_tuple(context), {:success, time})
  end

  def error(context, time \\ 3_000) do
    GenServer.call(via_tuple(context), {:error, time})
  end

  def in_progress(context) do
    GenServer.call(via_tuple(context), :in_progress)
  end

  def handle_call({:error, time}, _from, state) do
    state
    |> turn_off(state.in_progress_pid)
    |> turn_off(state.success_pid)
    |> turn_on(state.error_pid, time)
    |> build_reply
  end
  def handle_call(:in_progress, _from, state) do
    state
    |> turn_on_blinking
    |> build_reply
  end
  def handle_call({:success, time}, _from, state) do
    state
    |> turn_off(state.in_progress_pid)
    |> turn_off(state.error_pid)
    |> turn_on(state.success_pid, time)
    |> build_reply
  end

  defp via_tuple(context) do
    {:via, :gproc, {:n, :l, {__MODULE__, context}}}
  end

  defp build_reply(state) do
    {:reply, :ok, state}
  end

  defp turn_off(state, pid) do
    AxelHardware.LED.turn_off(pid)

    state
  end

  defp turn_on(state, pid, time) do
    AxelHardware.LED.turn_on(pid)
    Process.sleep(time)
    turn_off(state, pid)
  end

  defp turn_on_blinking(state) do
    AxelHardware.LED.blink(state.in_progress_pid)

    state
  end

  defp turn_off_blinking(state) do
    state
  end
end
