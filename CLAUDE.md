# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lua script engine adapter for [RodarBpmn](https://github.com/rodar-tech/rodar_bpmn). Implements the `RodarBpmn.Expression.ScriptEngine` behaviour to enable Lua scripts in BPMN ScriptTask elements. Uses [Luerl](https://github.com/rvirding/luerl) (Lua 5.3 in pure Erlang) as the runtime — no NIFs or external processes.

**Status:** Not yet implemented — currently a placeholder with the planned approach documented in README.md.

## Build & Development Commands

```bash
mix deps.get          # Install dependencies
mix compile           # Compile the project
mix test              # Run all tests
mix test path/to/test.exs          # Run a single test file
mix test path/to/test.exs:42       # Run a specific test by line number
mix format            # Format code
mix format --check-formatted       # Check formatting without changes
```

## Architecture

- **`RodarBpmnLua`** — top-level module (currently a placeholder)
- **`RodarBpmnLua.Engine`** — (to be implemented) the main module implementing `RodarBpmn.Expression.ScriptEngine` behaviour with an `eval(script, bindings)` callback
- Engine registration: `RodarBpmn.Expression.ScriptRegistry.register("lua", RodarBpmnLua.Engine)`

## Key Dependencies

- `rodar_bpmn ~> 1.0` — the BPMN execution engine this adapter plugs into
- `luerl ~> 1.2` — pure-Erlang Lua 5.3 interpreter

## Implementation Notes

- Lua tables ↔ Elixir maps/lists conversion requires careful marshalling
- Luerl numbers are floats; integers should be recovered when the float has no fractional part
- Consider restricting Lua stdlib access (`os`, `io`, `loadfile`) for sandboxing untrusted scripts
- Luerl is interpreted; for performance-sensitive paths, cache compiled Lua chunks
