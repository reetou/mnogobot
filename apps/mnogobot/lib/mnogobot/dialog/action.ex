defmodule Mnogobot.Dialog.Action do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :action
    field :store_to
    field :args, {:array, :string}
  end

  def changeset(module, attrs) do
    module
    |> cast(attrs, [
      :action,
      :store_to,
      :args
    ])
  end

  def apply_vars(%__MODULE__{action: action, args: args}, vars) do
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

  def parse_var_value(nil), do: "__UNDEFINED_VAR"
  def parse_var_value(%{value: value}), do: "#{value}"

  def by_index(%{actions: actions}, index) do
    Enum.at(actions, index)
  end

end