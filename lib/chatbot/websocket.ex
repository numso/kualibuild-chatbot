defmodule Chatbot.Websocket do
  @behaviour :websocket_client

  @endpoint "wss://gateway.discord.gg/?v=6&encoding=json"

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(token) do
    state = %{token: token, s: nil}
    :websocket_client.start_link(@endpoint, __MODULE__, state, [])
  end

  def init(state), do: {:once, state}
  def onconnect(_ws_req, state), do: {:ok, state}
  def ondisconnect(_reason, state), do: {:reconnect, state}

  def websocket_handle({:text, msg}, _conn_state, state) do
    %{"s" => s} = json = Jason.decode!(msg)
    handle_discord_message(json)
    {:ok, %{state | s: s}}
  end

  def websocket_info({:heartbeat, interval}, _conn_state, state) do
    Process.send_after(self(), {:heartbeat, interval}, interval)
    {:reply, {:text, Jason.encode!(%{op: 1, d: state.s})}, state}
  end

  def websocket_info(:identify, _conn_state, state) do
    props = %{"$os" => "linux", "$browser" => "chatbot", "$device" => "chatbot"}
    message = %{"op" => 2, "d" => %{"token" => state.token, "properties" => props}}
    {:reply, {:text, Jason.encode!(message)}, state}
  end

  def websocket_terminate(reason, _conn_state, state) do
    IO.inspect(msg: "crashing", reason: reason, state: state)
    :ok
  end

  def handle_discord_message(%{"op" => 10, "d" => %{"heartbeat_interval" => interval}}) do
    Process.send_after(self(), {:heartbeat, interval}, interval)
    Process.send(self(), :identify, [])
  end

  # TODO:: time this. if you stop receiving them something is wrong
  def handle_discord_message(%{"op" => 11}), do: nil

  def handle_discord_message(msg) do
    Process.send(Chatbot.Discord, {:discord, msg}, [])
  end
end
