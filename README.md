# RodarBpmn Lua

Lua script engine adapter for [RodarBpmn](https://github.com/rodar-tech/rodar_bpmn).

Enables Lua scripts in BPMN `<scriptTask>` elements by implementing the
`RodarBpmn.Expression.ScriptEngine` behaviour. Uses
[Luerl](https://github.com/rvirding/luerl) — a Lua 5.3 implementation in pure
Erlang — as the runtime. No NIFs or external processes required.

## Installation

Add to your `mix.exs`:

```elixir
{:rodar_bpmn_lua, "~> 0.1.0"}
```

## Quick Start

Register the engine at application startup:

```elixir
# In your Application.start/2 callback:
RodarBpmn.Expression.ScriptRegistry.register("lua", RodarBpmnLua.Engine)
```

Then use `scriptFormat="lua"` in your BPMN diagrams:

```xml
<scriptTask id="calc" name="Calculate Total" scriptFormat="lua">
  <script>return price * quantity</script>
</scriptTask>
```

The current process data map is injected as Lua globals. The script's first
return value is stored in the BPMN context under the configured output variable.

## Usage

Call the engine directly for ad-hoc evaluation:

```elixir
{:ok, 3} = RodarBpmnLua.Engine.eval("return 1 + 2", %{})

{:ok, "hello"} = RodarBpmnLua.Engine.eval("return greeting", %{"greeting" => "hello"})

{:ok, 10} = RodarBpmnLua.Engine.eval("return data.count * 2", %{
  "data" => %{"count" => 5}
})
```

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

## Sandboxing

Scripts execute in a sandboxed Lua state. The following standard library
functions are removed before execution to prevent untrusted scripts from
accessing the host system:

- `io` — all file/console I/O
- `file` — file system access
- `os.execute`, `os.exit`, `os.getenv`, `os.remove`, `os.rename`, `os.tmpname`
- `require`, `load`, `loadfile`, `loadstring`, `dofile`, `package`

Safe functions like `string`, `table`, `math`, `os.time`, `os.date`,
`os.clock`, `os.difftime`, `tonumber`, `tostring`, `type`, `pairs`, `ipairs`,
`select`, `unpack`, `pcall`, and `xpcall` remain available.

## Configuration

All settings are optional:

```elixir
config :rodar_bpmn_lua,
  max_time: 5_000,         # sandbox timeout in ms (default: 5_000)
  max_reductions: :none    # reduction limit (default: :none)
```

## Development

```bash
mix deps.get          # Install dependencies
mix compile           # Compile the project
mix test              # Run all tests
mix format            # Format code
```

## License

Apache-2.0 — see [LICENSE](LICENSE).
