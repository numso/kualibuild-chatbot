defmodule Chatbot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    token = System.get_env("DISCORD_TOKEN")

    children = [
      {Chatbot.Discord, token},
      {Chatbot.Websocket, token}
    ]

    opts = [strategy: :rest_for_one, name: Chatbot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
