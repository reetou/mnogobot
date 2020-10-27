# Mnogobot

Elixir-based DSL for writing bots 

## Usage

```elixir
# apps/mnogobot/lib/mnogobot.ex

defmodule Mnogobot do
  import MnogobotDSL

  bot do
    dialog Hey do
      say "heyyy!" # Send message and wait for user response
      reply "Yo bro" # Reply with mention: @user, Yo bro
      name = ask "Whats your name?" # Store user answers
      balance = 12 # Define custom variable
      say "Hello #{name}, your balance is #{balance}" # Use your variables in messages
      image "https://i.imgur.com/qo9nKso.jpeg" # Send media
      sticker ":yo:", only: [:slack] # Define platform-specific logic
    end

    dialog privet, [trigger: "!elo"] do # Trigger dialogs by user message
      say "Your elo is"
    end

    dialog buy, [trigger: starts_with("buy")] do # Much flexible
      say "You are buying..."
    end

    dialog sell, each: [120, :message] do
      say "I am selling something to you"
    end
  end
end
``` 

## Get started

- Install deps: `mix deps.get`
- Write some code in `apps/mnogobot/lib/mnogobot.ex`
- Execute: `mix generate_actions`
- You will have something like that in terminal:
```
Created dialog with name dialog_hey_actions, containing 6 actions, 1 variables and trigger: nil
Created dialog with name dialog_privet_actions, containing 1 actions, 0 variables and trigger: "!elo"
Created dialog with name dialog_buy_actions, containing 1 actions, 0 variables and trigger: ["starts_with", "buy"]
Created dialog with name dialog_sell_actions, containing 1 actions, 0 variables and trigger: nil
File generated: actions_encoded.json
```
- Then move generated `.json` file to `apps/mnogobot_DESIRED_INTEGRATION/priv/`
- Configure your bot in `config.exs`
- Start your integration app and enjoy