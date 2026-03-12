# Getting Started

This guide walks through setting up the Lua script engine for RodarBpmn.

## Installation

Add `rodar_bpmn_lua` to your dependencies in `mix.exs`:

```elixir
defp deps do
  [
    {:rodar_bpmn, "~> 1.0"},
    {:rodar_bpmn_lua, "~> 0.1.0"}
  ]
end
```

Then fetch dependencies:

```bash
mix deps.get
```

## Registration

Register the Lua engine at application startup so that RodarBpmn can find it
when a `<scriptTask>` specifies `scriptFormat="lua"`:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    RodarBpmn.Expression.ScriptRegistry.register("lua", RodarBpmnLua.Engine)

    children = [
      # ... your supervision tree
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

## Your First Lua Script Task

Define a BPMN process with a Lua script task:

```xml
<process id="greeting_process">
  <startEvent id="start" />
  <sequenceFlow sourceRef="start" targetRef="greet" />

  <scriptTask id="greet" name="Build Greeting" scriptFormat="lua">
    <script>return "Hello, " .. name .. "!"</script>
  </scriptTask>

  <sequenceFlow sourceRef="greet" targetRef="done" />
  <endEvent id="done" />
</process>
```

Execute it with process data:

```elixir
{:ok, context} = RodarBpmn.execute(process, %{"name" => "Alice"})
```

The script receives `name` as a Lua global variable and returns
`"Hello, Alice!"`, which is stored in the BPMN context.

## Direct Evaluation

You can also call the engine directly outside of a BPMN process:

```elixir
{:ok, 15} = RodarBpmnLua.Engine.eval("return x * y", %{"x" => 3, "y" => 5})
```

This is useful for testing scripts or integrating Lua evaluation in other
parts of your application.
