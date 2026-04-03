defmodule RodarLua.Engine do
  @moduledoc """
  Core engine implementing `Rodar.Expression.ScriptEngine` for Lua.

  Evaluates Lua 5.3 scripts in a sandboxed Luerl state. The BPMN process data
  map is injected as Lua globals, the script executes, and the first return
  value is converted back to an Elixir term.

  ## Execution Flow

  1. A sandboxed Lua state is initialised via `:luerl_sandbox.init/0`
  2. Each entry in the `bindings` map is encoded and set as a Lua global
  3. The script runs inside `:luerl_sandbox.run/3` with time/reduction limits
  4. The first Lua return value is decoded and normalised (floats → integers,
     tables → maps or lists)
  5. Errors at any stage are caught and returned as `{:error, reason}`

  ## Return Values

    * `{:ok, value}` — the decoded first return value (`nil` when no value is returned)
    * `{:error, reason}` — a human-readable error string

  ## Examples

      iex> RodarLua.Engine.eval("return 1 + 2", %{})
      {:ok, 3}

      iex> RodarLua.Engine.eval("return greeting", %{"greeting" => "hello"})
      {:ok, "hello"}

      iex> RodarLua.Engine.eval("return data.count * 2", %{"data" => %{"count" => 5}})
      {:ok, 10}

      iex> RodarLua.Engine.eval("return ??bad", %{})
      {:error, _reason}
  """

  @behaviour Rodar.Expression.ScriptEngine

  @default_max_time 5_000
  @default_max_reductions :none

  @doc """
  Evaluate a Lua script with the given bindings.

  The `bindings` map is injected as Lua globals — each key (stringified if an
  atom) becomes a global variable and each value is encoded into its Lua
  representation. Maps become tables, lists become 1-indexed tables, and atom
  keys are converted to strings.

  Returns `{:ok, result}` with the first Lua return value decoded back to
  Elixir, or `{:error, reason}` for compile/runtime errors.

  ## Examples

      iex> RodarLua.Engine.eval("return a + b", %{"a" => 3, "b" => 4})
      {:ok, 7}

      iex> RodarLua.Engine.eval("return {1, 2, 3}", %{})
      {:ok, [1, 2, 3]}

      iex> RodarLua.Engine.eval("error('boom')", %{})
      {:error, _reason}
  """
  @impl true
  @spec eval(String.t(), map()) :: {:ok, any()} | {:error, any()}
  def eval(script, bindings) when is_binary(script) and is_map(bindings) do
    state = :luerl_sandbox.init()
    state = remove_dangerous_os_functions(state)
    state = inject_bindings(bindings, state)

    flags = [
      max_time: max_time(),
      max_reductions: max_reductions()
    ]

    case :luerl_sandbox.run(script, flags, state) do
      {:ok, result, new_state} ->
        {:ok, unwrap_result(result, new_state)}

      {:error, reason} ->
        {:error, format_error(reason)}

      {:lua_error, reason, _state} ->
        {:error, format_error(reason)}
    end
  catch
    kind, reason when kind in [:error, :exit, :throw] ->
      {:error, format_error(reason)}
  end

  @dangerous_os_functions ["getenv", "remove", "rename", "tmpname"]

  defp remove_dangerous_os_functions(state) do
    Enum.reduce(@dangerous_os_functions, state, fn func, st ->
      {nil_val, st} = :luerl.encode(nil, st)
      {:ok, st} = :luerl.set_table_keys(["os", func], nil_val, st)
      st
    end)
  end

  defp inject_bindings(bindings, state) do
    Enum.reduce(bindings, state, fn {key, value}, st ->
      key_str = to_string(key)
      {encoded, st} = :luerl.encode(value, st)
      {:ok, st} = :luerl.set_table_keys([key_str], encoded, st)
      st
    end)
  end

  defp unwrap_result([], _state), do: nil
  defp unwrap_result([single], state), do: from_lua(single, state)
  defp unwrap_result([first | _], state), do: from_lua(first, state)

  defp from_lua(value, state) do
    decoded = :luerl.decode(value, state)
    normalize(decoded)
  end

  defp normalize(n) when is_float(n) do
    truncated = trunc(n)
    if n == truncated, do: truncated, else: n
  end

  defp normalize(list) when is_list(list) do
    if table_is_list?(list) do
      list
      |> Enum.sort_by(fn {k, _v} -> k end)
      |> Enum.map(fn {_k, v} -> normalize(v) end)
    else
      Map.new(list, fn {k, v} -> {normalize(k), normalize(v)} end)
    end
  end

  defp normalize(other), do: other

  defp table_is_list?(pairs) do
    keys = Enum.map(pairs, fn {k, _} -> k end)

    Enum.all?(keys, &is_integer/1) and
      Enum.sort(keys) == Enum.to_list(1..length(keys))
  end

  defp format_error({:lua_error, reason, _state}), do: format_error(reason)

  defp format_error(binary) when is_binary(binary), do: binary

  defp format_error(%{__exception__: true} = e), do: Exception.message(e)

  defp format_error(reason), do: inspect(reason)

  defp max_time do
    Application.get_env(:rodar_lua, :max_time, @default_max_time)
  end

  defp max_reductions do
    Application.get_env(:rodar_lua, :max_reductions, @default_max_reductions)
  end
end
