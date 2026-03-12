defmodule RodarBpmnLua do
  @moduledoc """
  Lua script engine adapter for [RodarBpmn](https://hexdocs.pm/rodar_bpmn).

  Enables Lua 5.3 scripts in BPMN `<scriptTask>` elements by implementing the
  `RodarBpmn.Expression.ScriptEngine` behaviour. Uses
  [Luerl](https://github.com/rvirding/luerl) (pure-Erlang Lua 5.3 interpreter)
  as the runtime — no NIFs or external processes required.

  ## Quick Start

  Register the engine at application startup, then use `scriptFormat="lua"` in
  your BPMN diagrams:

      # In your Application.start/2 callback:
      RodarBpmn.Expression.ScriptRegistry.register("lua", RodarBpmnLua.Engine)

  The engine receives the current process data as Lua globals and returns the
  script result back to the BPMN context:

      <scriptTask id="calc" name="Calculate Total" scriptFormat="lua">
        <script>return price * quantity</script>
      </scriptTask>

  ## Configuration

  All settings are optional and have sensible defaults:

      config :rodar_bpmn_lua,
        max_time: 5_000,         # sandbox timeout in ms (default: 5_000)
        max_reductions: :none    # reduction limit (default: :none)

  ## Sandboxing

  Scripts execute in a sandboxed Lua state via `:luerl_sandbox`. The following
  Lua standard library functions are removed before execution:

    * `io` — all file/console I/O
    * `file` — file system access
    * `os.execute`, `os.exit`, `os.getenv`, `os.remove`, `os.rename`, `os.tmpname`
    * `require`, `load`, `loadfile`, `loadstring`, `dofile`, `package`

  ## Data Marshalling

  Elixir values are automatically converted to Lua and back:

  | Elixir              | Lua         | Notes                                      |
  |---------------------|-------------|--------------------------------------------|
  | integer / float     | number      | whole-number floats recovered as integers   |
  | binary (string)     | string      |                                             |
  | boolean             | boolean     |                                             |
  | nil                 | nil         |                                             |
  | map                 | table       | keys stringified; nested maps supported     |
  | list                | table       | 1-indexed; sequential-key tables → lists    |
  | atom key            | string key  | atom keys converted via `to_string/1`       |
  """
end
