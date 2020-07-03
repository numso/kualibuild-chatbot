defmodule Chatbot.Messages do
  defmodule Soon, do: use(Chatbot.Datasource, prefix: "soon")
  defmodule Business, do: use(Chatbot.Datasource, prefix: "business")
  defmodule Security, do: use(Chatbot.Datasource, prefix: "security")

  @data [
    Soon.data(),
    Business.data(),
    Security.data()
  ]

  def process(message) do
    @data
    |> Enum.filter(fn {_, regex} -> Regex.match?(regex, message) end)
    |> Enum.map(fn {images, _} -> Enum.random(images) end)
  end
end
