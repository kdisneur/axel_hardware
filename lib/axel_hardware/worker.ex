defmodule AxelHardware.Worker do
  use GenServer

  defstruct pee: false, poop: false, feedback_pid: nil

  def start_link(context, {pee, poop}) do
    state = %__MODULE__{pee: pee, poop: poop, feedback_pid: context}

    GenServer.start_link(__MODULE__, state, name: via_tuple(context))
  end

  def call(context) do
    GenServer.call(via_tuple(context), :call, 20_000)
  end

  def handle_call(:call, _from, state) do
    state
    |> do_request
    |> handle_result
    |> build_reply
  end

  defp via_tuple(context) do
    {:via, :gproc, {:n, :l, {__MODULE__, context}}}
  end

  defp build_reply(state) do
    {:reply, :ok, state}
  end

  defp do_request(state) do
    AxelHardware.Feedback.in_progress(state.feedback_pid)

    authorization = "Basic " <> Base.encode64(config(:username) <> ":" <> config(:password))

    response = 
      api_url
      |> HTTPoison.post(json_body(state), [{"Content-Type", "application/json"}, 
                                           {"Authorization", authorization}])

    {state, response}
  end

  defp api_url do
    config(:url) <> "/diapers"
  end

  defp config(key) do
    Application.get_env(:axel_hardware, :api)[key]
  end

  defp json_body(state) do
    now =
      "Europe/Paris"
      |> Calendar.DateTime.now!
      |> Calendar.Strftime.strftime!("%Y-%m-%d %H:%M:%S")

    "{\"poop\": #{state.poop}, \"pee\": #{state.pee}, \"changed_at\": \"#{now}\"}"
  end

  defp handle_result({state, {:ok, %HTTPoison.Response{status_code: 201}}}) do
    AxelHardware.Feedback.success(state.feedback_pid)

    state
  end
  defp handle_result({state, _error}) do
    AxelHardware.Feedback.error(state.feedback_pid)

    state
  end
end
