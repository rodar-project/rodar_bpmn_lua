# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-12

### Added

- `RodarLua.Engine` implementing `Rodar.Expression.ScriptEngine` behaviour
- Sandboxed Lua execution via `:luerl_sandbox` — blocks `io`, `file`, `os.execute`,
  `require`, `load`, `loadfile`, `loadstring`, `dofile`, and `package`
- Automatic data marshalling between Elixir and Lua types (maps, lists, numbers,
  strings, booleans, nil)
- Whole-number float recovery (e.g. `42.0` → `42`)
- Sequential-key Lua table detection — returned as Elixir lists instead of maps
- Configurable `max_time` and `max_reductions` sandbox limits
- Nested map/table support for bindings and return values
