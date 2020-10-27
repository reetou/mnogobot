defmodule Mnogobot.Api do
  alias Mnogobot.Dialog.State
  alias Mnogobot.Dialog.Action
  alias Mnogobot.Dialog

  # TODO:
  # Добавить метод для проверки был ли стриггерен какой то диалог или ставить дефолтный, если есть
  # Типа has_state?()
  # Если true то вызывать next_state, следующий экшен и записать ответ если нужно
  # Если false то вызывать init_state

  def init_state(user_id, channel_id, platform, text) do
    # TODO: init state
    # Должен создавать новый стейт если был стриггерен диалог или дефолтный диалог
    State.get(user_id, channel_id, platform)
  end

  def get_state(user_id, channel_id, platform) do
    State.get(user_id, channel_id, platform)
  end

  def next_state(state, message_text) do
    State.next(state, message_text)
  end

  def current_action(state) do
    Action.by_index(state.dialog, state.current_action_index)
  end
end