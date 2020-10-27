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
    field :finished, :boolean, default: false
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
    case :ets.lookup(:states, table_key(user_id, channel_id, platform)) do
      [] -> nil
      x ->
        x
        |> Enum.at(0)
        |> Tuple.to_list()
        |> Enum.at(1)
    end
  end

  def write_or_delete_finished(state, user_id, channel_id, platform) do
    case finished?(state) do
      true -> delete(state, user_id, channel_id, platform)
      false -> write(state, user_id, channel_id, platform)
    end
  end

  def delete(state, user_id, channel_id, platform) do
    :ets.delete(:states, table_key(user_id, channel_id, platform))
    :deleted
  end

  def write(state, user_id, channel_id, platform) do
    :ets.insert(:states, {table_key(user_id, channel_id, platform), state})
    :updated
  end

  def table_key(user_id, channel_id, platform) do
    "#{user_id}_#{channel_id}_#{platform}"
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

  def update_state_vars(%{vars: vars} = state, var_name, value) do
    new_var = %Var{var: "#{var_name}", value: "#{value}"}
    new_vars =
      vars
      |> Enum.find_index(fn %{var: name} -> name == var_name end)
      |> case do
          nil -> vars ++ List.wrap(new_var)
          x ->
            List.replace_at(vars, x, new_var)
         end
    put_in(state.vars, new_vars)
  end

  def store_reply(state, text) do
    case store_to(state) do
      nil -> state
      x -> update_state_vars(state, store_to(state), text)
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