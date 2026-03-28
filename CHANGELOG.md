# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added `ex_doc` dependency for documentation generation
- Enhanced docs config with `source_url`, `homepage_url`, and `groups_for_modules`

## [0.2.2] - 2026-03-28

### Changed

- Switched `rodar` dependency from GitHub source to Hex package (`~> 1.4`)

## [0.2.1] - 2026-03-28

### Changed

- Switched `rodar_release` dependency from GitHub source to Hex package (`~> 1.2`)

## [0.2.0] - 2026-03-13

### Changed

- Renamed project from `rodar_bpmn_lua` to `rodar_lua`, aligning with core project
  rename from `rodar_bpmn` to `rodar` — modules, app name, file paths, and docs updated
- Switched `rodar` dependency from local path to GitHub source

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
