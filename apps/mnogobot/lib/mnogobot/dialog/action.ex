defmodule Mnogobot.Dialog.Action do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder
  embedded_schema do
    field :action, :string, null: false
    field :store_to
    field :args, {:array, :string}
    field :opts, :map, default: %{}
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [
      :action,
      :store_to,
      :args,
      :opts
    ])
    |> validate_required([:action])
  end


  def apply_vars(%__MODULE__{args: nil}, _), do: []
  def apply_vars(%__MODULE__{action: action, args: args}, %{vars: vars, dialog: %{vars: dialog_vars}}) when is_binary(action) do
    vars = vars ++ dialog_vars
    args
    |> Enum.map(fn x ->
      case x do
        x when is_list(x) ->
          x
          |> Enum.random()
          |> apply_var(vars)
        x -> apply_var(x, vars)
      end
    end)
  end

  def apply_var("__VAR__" <> var, vars) do
    vars
    |> Enum.find(fn %{var: var_name} -> var_name == var end)
    |> parse_var_value()
  end
  def apply_var(x, _), do: x

  def parse_var_value(nil), do: "__UNDEFINED_VAR__"
  def parse_var_value(%{value: value}), do: "#{value}"

  def by_index(%{actions: actions}, index) do
    Enum.at(actions, index)
  end

end