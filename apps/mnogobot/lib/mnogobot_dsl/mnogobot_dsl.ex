defmodule MnogobotDSL do
  alias Mnogobot.Dialog
  alias Mnogobot.Dialog.Action
  alias Mnogobot.Dialog.Var

  defmacro __using__(_) do
    Module.register_attribute(__MODULE__, :dialogs, persist: true)
  end

  defmacro bot(do: {_, _, blocks}) do
    IO.inspect(blocks, label: "Bot code")
    Module.get_attribute(__CALLER__.module, :dialogs)
    |> IO.inspect(label: "Bot attributes")
    dialogs =
      Enum.map(blocks, fn b ->
        Macro.expand(b, __ENV__)
      end)
      |> IO.inspect(label: "Unquoted code")
    encoded = Jason.encode!(%{data: dialogs})
    quote do
      def actions do
        unquote(Macro.escape(dialogs))
      end

      def actions_encoded do
        unquote(encoded)
      end
    end
  end

  defmacro dialog(name, do: code) do
    IO.inspect(name, label: "Dialog compiling")
    create_dialog(name, code, [])
  end

  defmacro dialog(name, opts, do: code) do
    IO.inspect(name, label: "Dialog compiling")
    create_dialog(name, code, opts)
  end

  defp create_dialog(name, code, opts) do
    name =
      name
      |> parse_string_val()
      |> String.downcase()
    code_to_dialog(code, dialog_name(name), opts)
    |> IO.inspect(label: "Created dialog")
  end

  defmacro starts_with(text) do
    [:starts_with, text]
  end

  defmacro ends_with(text) do
    [:ends_with, text]
  end

  defmacro say(text) do
  end

  defmacro reply(text) do
  end

  defmacro welcome(text) do
  end

  defmacro ask(text) do
  end

  defmacro image(url) do
  end

  defmacro sticker(text, opts \\ []) do
  end

  defp code_to_dialog(_, _, opts \\ [])

  defp code_to_dialog({:__block__, _, lines}, fun_name, opts) do
    lines
    |> Enum.map(&parse_fun/1)
    |> get_dialog(fun_name, opts)
  end

  defp code_to_dialog(line, fun_name, opts) do
    code_to_dialog({:__block__, [], List.wrap(line)}, fun_name, opts)
  end

  def parse_string_val({:__aliases__, _, [x]}), do: "#{x}"
  def parse_string_val({x, _, _}), do: "#{x}"
  def parse_string_val(x), do: "#{x}"

  def parse_action(name, args, store_to \\ nil) do
    %{action: name, args: args, store_to: parse_var_name(store_to)}
  end

  def parse_var(name, value) do
    %{var: name, value: value}
  end

  def parse_var_name(nil), do: nil
  def parse_var_name(x), do: Atom.to_string(x)

  def get_dialog(defs, fun_name, opts) do
    fun_name =
      fun_name
      |> action_fun_name()
      |> String.to_atom()
    trigger = parse_trigger(opts[:trigger])
    each = parse_each(opts[:each])
    dialog = %{
      name: fun_name,
      each: each,
      trigger: trigger,
      actions: filter_actions(defs),
      vars: filter_vars(defs)
    }
    %Dialog{}
    |> Dialog.changeset(dialog)
    |> Dialog.format()
    |> IO.inspect(label: "Dialog for #{fun_name} is")
  end

  def def_dialog(%{name: name} = dialog) do
    escaped_dialog = Macro.escape(dialog)
    quote do
      def unquote(name)() do
        unquote(escaped_dialog)
      end
    end
  end

  def parse_fun({fun, _, [{:<<>>, _, args} = a]}) do
    parse_action(fun, parse_binary_arg(a), nil)
  end

  def parse_fun({:=, _, [{var_name, _, _}, {fun, _, args}]}) do
    parse_action(fun, args, var_name)
  end

  def parse_fun({:=, _, [{var_name, _, _}, val]}) when not is_tuple(val) do
    parse_var(var_name, val)
  end

  def parse_fun({fun, _, args}) do
    case args do
      [a | _] when is_list(a) ->
        parse_action(fun, parse_binary_arg(a))
      a ->
        parse_action(fun, a)
    end
  end

  def parse_trigger({:__aliases__, _, [x]}), do: "#{x}"
  def parse_trigger({key, _, args}) when key in [:starts_with, :ends_with] and length(args) == 1 do
    [key, Enum.at(args, 0)]
  end
  def parse_trigger({x, _, _}), do: "#{x}"
  def parse_trigger(nil), do: nil
  def parse_trigger(x) do
    IO.inspect(x, label: "Trigger is")
    "#{x}"
  end

  def parse_each(nil), do: nil
  def parse_each([x, k]) when is_integer(x) and k in [:message, :seconds], do: [x, k]

  def action_fun_name(fun_name), do: "#{fun_name}_actions"
  def dialog_name(name), do: "dialog_#{name}"

  def parse_binary_arg({:<<>>, _, args}) do
    Enum.map(args, &parse_binary_arg/1)
    |> IO.inspect(label: "Parsed binary value")
  end
  def parse_binary_arg([{:<<>>, _, args} | t] = x) do
    Enum.map(x, &parse_binary_arg/1)
    |> IO.inspect(label: "Parsed binary value array")
  end
  def parse_binary_arg({:"::", _, [{{:., _, _}, _, [{var, _, _}]}, {:binary, _, _}]}), do: "__VAR__#{var}"
  def parse_binary_arg(x) when is_binary(x), do: x

  def filter_actions(actions) do
    Enum.filter(actions, fn x ->
      case x do
        %{action: type} when not is_nil(type) -> true
        _ -> false
      end
    end)
  end

  def filter_vars(vars) do
    Enum.filter(vars, fn x ->
      case x do
        %{var: var} when not is_nil(var) -> true
        _ -> false
      end
    end)
  end
end