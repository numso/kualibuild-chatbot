defmodule Chatbot.Datasource do
  defmacro __using__(prefix: prefix) do
    image_path = "lib/data/" <> prefix <> "-images.txt"
    trigger_path = "lib/data/" <> prefix <> "-triggers.txt"

    quote do
      @external_resource unquote(image_path)
      @external_resource unquote(trigger_path)
      @images File.read!(unquote(image_path)) |> String.split("\n", trim: true)
      @regex File.read!(unquote(trigger_path))
             |> String.split("\n", trim: true)
             |> Enum.join("|")
             |> Regex.compile!("i")
      def data, do: {@images, @regex}
    end
  end
end
