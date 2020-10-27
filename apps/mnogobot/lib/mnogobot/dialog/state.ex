defmodule Mnogobot.Dialog.State do
  use Ecto.Schema
  alias Mnogobot.Dialog
  alias Mnogobot.Dialog.Var
  alias Mnogobot.Dialog.Action
  import Ecto.Changeset

  embedded_schema do
    field :user_id, :string, null: false
    field :platform, :string, null: false
    field :channel_id, :string
    field :current_action_index, :integer, null: false
    field :finished, :boolean
    embeds_one :dialog, Dialog
    embeds_many :vars, Var
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [
      :user_id,
      :platform,
      :current_action_index
    ])
    |> cast_embed(:dialog)
    |> cast_embed(:vars)
    |> validate_required([:user_id, :platform, :current_action_index])
    |> validate_inclusion(:platform, ["discord"])
  end

  def format(changeset) do
    changeset
    |> apply_action!(:format)
  end

  def get(user_id, channel_id, platform) do
    # Get by user id and platform

  end

  def next(old_state, message_text) do
    finished?(old_state)
    |> case do
      true -> finish(old_state)
      false -> old_state
    end
    |> store_reply(message_text)
    |> iterate()
  end

  def finished?(%{dialog: %{actions: actions}, current_action_index: index}) do
    length(actions) - 1 <= index
  end

  def should_store?(%{store_to: nil}), do: false
  def should_store?(%{store_to: x}) when is_binary(x), do: true

  def store_value(state, var_name, value) do
    %Var{}
    |> Var.changeset(%{var: var_name, value: value})
    |> Var.format()
    |> IO.inspect(label: "Storing variable")
    state
  end

  def store_reply(state, text) do
    case store_to(state) do
      nil -> state
      x -> store_value(state, store_to(state), text)
    end
  end

  def finish(state) do
    %__MODULE__{state | finished: true}
  end

  def iterate(state) do
    case finished?(state) do
      true -> state
      false -> %__MODULE__{state | current_action_index: state.current_action_index + 1}
    end
  end

  defp store_to(state) do
    state.dialog
    |> Action.by_index(state.current_action_index)
    |> Map.fetch!(:store_to)
  end

end