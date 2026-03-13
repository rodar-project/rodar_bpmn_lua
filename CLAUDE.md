# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lua script engine adapter for [Rodar](https://github.com/rodar-project/rodar). Implements the `Rodar.Expression.ScriptEngine` behaviour to enable Lua scripts in BPMN ScriptTask elements. Uses [Luerl](https://github.com/rvirding/luerl) (Lua 5.3 in pure Erlang) as the runtime — no NIFs or external processes.

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

- **`RodarLua`** — top-level module with overview documentation
- **`RodarLua.Engine`** — core module implementing `Rodar.Expression.ScriptEngine` behaviour with `eval(script, bindings)` callback
- Engine registration: `Rodar.Expression.ScriptRegistry.register("lua", RodarLua.Engine)`

## Key Dependencies

- `rodar ~> 1.0` — the BPMN execution engine this adapter plugs into
- `luerl ~> 1.2` — pure-Erlang Lua 5.3 interpreter

## Implementation Notes

- Lua tables ↔ Elixir maps/lists conversion requires careful marshalling
- Luerl numbers are floats; integers should be recovered when the float has no fractional part
- Consider restricting Lua stdlib access (`os`, `io`, `loadfile`) for sandboxing untrusted scripts
- Luerl is interpreted; for performance-sensitive paths, cache compiled Lua chunks
