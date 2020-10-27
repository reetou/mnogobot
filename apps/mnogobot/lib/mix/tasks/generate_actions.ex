defmodule Mix.Tasks.GenerateActions do
  use Mix.Task

  @shortdoc "Generates json file containing actions data based on code in lib/mnogobot.ex"
  def run(_) do
    # calling our Hello.say() function from earlier
    :ok = Mnogobot.save_actions()
    IO.ANSI.format([:green, "File generated: actions_encoded.json"])
    |> IO.puts()
  end
end