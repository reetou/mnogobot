defmodule Mnogobot.Dialog.Var do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :var, :string, null: false
    field :value
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [
      :var,
      :value
    ])
  end

  def format(changeset) do
    changeset
    |> apply_action!(:format)
  end

end