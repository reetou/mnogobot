defmodule Mnogobot.Dialog do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mnogobot.Dialog.Action
  alias Mnogobot.Dialog.Var

  @derive Jason.Encoder
  embedded_schema do
    field :name, :string, null: false
    field :trigger, Ecto.Any
    field :each, Ecto.Any
    embeds_many :actions, Action
    embeds_many :vars, Var
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [
      :name,
      :trigger,
      :each
    ])
    |> cast_embed(:actions)
    |> cast_embed(:vars)
    |> validate_required([:name])
    |> validate_length(:actions, min: 1)
  end

  def format(changeset) do
    changeset
    |> apply_changes()
  end

  def without_trigger?(%{trigger: nil}), do: true
  def without_trigger?(%{}), do: false

  def check_trigger(text, trigger) when is_binary(trigger), do: text == trigger
  def check_trigger(text, ["starts_with", trigger]), do: String.starts_with?(text, trigger)
  def check_trigger(text, ["ends_with", trigger]), do: String.ends_with?(text, trigger)
  def check_trigger(text, nil), do: false

  def for_message(text, dialogs) do
    dialogs
    |> triggered_dialog(text)
    |> put_default_dialog_if_not_triggered(dialogs)
  end

  def put_default_dialog_if_not_triggered(nil, dialogs) do
    default_dialog(dialogs)
  end

  def put_default_dialog_if_not_triggered(x, _), do: x

  def triggered_dialog(dialogs, text) do
    Enum.find(dialogs, fn dialog -> check_trigger(text, dialog.trigger) end)
  end

  def default_dialog(dialogs) do
    Enum.find(dialogs, fn dialog -> without_trigger?(dialog) end)
  end

end