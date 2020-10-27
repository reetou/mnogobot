defmodule Mnogobot do
  @moduledoc """
  Mnogobot keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  import MnogobotDSL

  bot do
    dialog Hey do
      say "heyyy!"
      reply "Yo bro"
      name = ask "Whats your name?"
      balance = 12
      say "Hello #{name}, your balance is #{balance}"
      image "https://i.imgur.com/qo9nKso.jpeg"
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