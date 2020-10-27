defmodule MnogobotDSL do
  alias Mnogobot.Dialog

  defmacro __using__(_) do
    Module.register_attribute(__MODULE__, :dialogs, persist: true)
  end

  defmacro bot(do: {_, _, blocks}) do
    dialogs =
      Enum.map(blocks, fn b ->
        Macro.expand(b, __ENV__)
      end)
    encoded = Jason.encode!(%{data: dialogs})
    quote do
      def actions do
        unquote(Macro.escape(dialogs))
      end

      def actions_encoded do
        unquote(encoded)
      end

      def save_actions do
        File.write!("actions_encoded.json", unquote(encoded))
      end
    end
  end

  defmacro dialog(name, do: code) do
    create_dialog(name, code, [])
  end

  defmacro dialog(name, opts, do: code) do
    create_dialog(name, code, opts)
  end

  defp create_dialog(name, code, opts) do
    name =
      name
      |> parse_string_val()
      |> String.downcase()
    dialog = code_to_dialog(code, dialog_name(name), opts)
    [:green, "Created dialog with name", :cyan, " #{dialog.name}, ", :green, "containing #{length(dialog.actions)} actions, #{length(dialog.vars)} variables and trigger: #{inspect dialog.trigger}"]
    |> IO.ANSI.format()
    |> IO.puts()
    dialog
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
    %{
      action: from_atom(name),
      args: args,
      store_to: parse_var_name(store_to)
    }
    |> filter_opts_from_args()
  end

  def filter_opts_from_args(%{args: args} = action) do
    opts =
      args
      |> Enum.filter(fn a -> Keyword.keyword?(a) end)
      |> case do
          [] -> []
          k -> Enum.reduce(k, fn x, acc -> Keyword.merge(acc, x) end)
         end
      |> Map.new()
    other_args = Enum.filter(args, fn a -> Keyword.keyword?(a) == false end)
    action
    |> put_in([:args], other_args)
    |> put_in([:opts], opts)
  end

  def parse_var(name, value) do
    %{var: from_atom(name), value: from_atom(value)}
  end

  def parse_var_name(nil), do: nil
  def parse_var_name(x), do: Atom.to_string(x)

  def get_dialog(defs, fun_name, opts) do
    fun_name = action_fun_name(fun_name)
    trigger = parse_trigger(opts[:trigger])
    each = parse_each(opts[:each])
    dialog = %{
      name: from_atom(fun_name),
      each: from_atom(each),
      trigger: from_atom(trigger),
      actions: filter_actions(defs),
      vars: filter_vars(defs)
    }
    %Dialog{}
    |> Dialog.changeset(dialog)
    |> Dialog.format()
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
    "#{x}"
  end

  def parse_each(nil), do: nil
  def parse_each([x, k]) when is_integer(x) and k in [:message, :seconds], do: [x, k]

  def action_fun_name(fun_name), do: "#{fun_name}_actions"
  def dialog_name(name), do: "dialog_#{name}"

  def parse_binary_arg({:<<>>, _, args}) do
    Enum.map(args, &parse_binary_arg/1)
  end
  def parse_binary_arg([{:<<>>, _, args} | t] = x) do
    Enum.map(x, &parse_binary_arg/1)
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

  defp from_atom(nil), do: nil
  defp from_atom(x) when is_list(x) do
    Enum.map(x, &from_atom/1)
  end
  defp from_atom(x) when is_atom(x), do: "#{x}"
  defp from_atom(x), do: x
end