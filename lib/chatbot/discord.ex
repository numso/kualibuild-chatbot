defmodule Chatbot.Discord do
  use GenServer

  def start_link(token), do: GenServer.start_link(__MODULE__, token, name: __MODULE__)
  def init(token), do: {:ok, token}

  def handle_info({:discord, msg}, token) do
    case msg do
      %{"t" => "MESSAGE_CREATE", "d" => data} -> handle_message_create(data, token)
      _ -> nil
    end

    {:noreply, token}
  end

  defp handle_message_create(%{"author" => %{"bot" => true}}, _), do: nil

  defp handle_message_create(%{"content" => message, "channel_id" => channel_id}, token) do
    Chatbot.Messages.process(message)
    |> Enum.map(&send_image(&1, channel_id, token))
  end

  defp send_image(image, channel_id, token) do
    HTTPoison.post(
      "https://discord.com/api/v6/channels/#{channel_id}/messages",
      Jason.encode!(%{"embed" => %{"url" => image, "image" => %{"url" => image}}}),
      [
        {"Content-Type", "application/json"},
        {"Authorization", "Bot #{token}"},
        {"User-Agent", "DiscordBot (localhost, 1.0.0)"}
      ]
    )
  end
end
