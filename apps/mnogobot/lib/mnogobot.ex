defmodule Mnogobot do
  @moduledoc """
  Mnogobot keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  import MnogobotDSL.Dialog

  bot do
    dialog Hey do
      say "hey"
      say ["hello #{h}", "привет #{h}", "здравствуй #{h}"]
      name = ask "Your name?"
      balance = 12
      ask "Hey #{name}, how are you?"
      reply "Yo bro"
      say "Hello #{name}, your balance is #{balance}"
      image "https://imgur.com/123"
      sticker ":yo:", only: [:slack]
    end

    dialog privet, [trigger: "!elo"] do
      say "Your elo is"
    end

    dialog buy, [trigger: starts_with("buy")] do
      say "You are buying..."
    end

    dialog sell, each: [120, :message] do
      say "Купите че то плиз"
    end
  end
end