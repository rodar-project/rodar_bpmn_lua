# Lua Scripting

This guide covers how to write Lua scripts for BPMN script tasks, including
data access patterns, return values, and limitations.

## Accessing Process Data

The BPMN process data map is injected as Lua global variables. Each key in the
map becomes a global:

```elixir
# Process data:
%{"order_total" => 150, "discount" => 0.1}
```

```lua
-- Lua script:
return order_total * (1 - discount)
-- Returns: 135.0
```

### Nested Data

Maps become Lua tables, accessed with dot notation:

```elixir
# Process data:
%{"customer" => %{"name" => "Alice", "tier" => "gold"}}
```

```lua
-- Lua script:
if customer.tier == "gold" then
  return customer.name .. " gets free shipping"
else
  return customer.name .. " pays standard rate"
end
```

### Lists

Elixir lists become 1-indexed Lua tables:

```elixir
# Process data:
%{"items" => [10, 20, 30]}
```

```lua
-- Lua script:
local total = 0
for i, v in ipairs(items) do
  total = total + v
end
return total
-- Returns: 60
```

## Return Values

The engine captures the **first** return value from the script:

```lua
-- Single return (most common):
return price * quantity

-- Multiple returns — only the first is used:
return "primary", "ignored"

-- No return — result is nil:
local x = 42
```

### Returning Tables

Lua tables are converted back to Elixir maps or lists:

```lua
-- Sequential integer keys → Elixir list:
return {10, 20, 30}
-- Result: [10, 20, 30]

-- String keys → Elixir map:
return {name = "Alice", age = 30}
-- Result: %{"name" => "Alice", "age" => 30}
```

## Type Conversions

| Lua type  | Elixir type | Notes                              |
|-----------|-------------|------------------------------------|
| number    | integer     | when value has no fractional part   |
| number    | float       | when value has a fractional part    |
| string    | binary      |                                    |
| boolean   | boolean     |                                    |
| nil       | nil         |                                    |
| table     | map         | with string or mixed keys          |
| table     | list        | with sequential integer keys 1..n  |

## Error Handling

Errors in Lua scripts are caught and returned as `{:error, reason}`:

```lua
-- Syntax errors:
return ??invalid
-- {:error, "..."}

-- Runtime errors:
error("something went wrong")
-- {:error, "\"something went wrong\""}

-- Type errors:
return 1 + "text"
-- {:error, "..."}
```

In a BPMN process, an `{:error, reason}` propagates as a process error that
can be caught by an error boundary event.

## Available Lua Standard Library

The engine runs in a sandboxed state. The following modules and functions are
**available**:

- `string` — `string.len`, `string.sub`, `string.format`, `string.find`, etc.
- `table` — `table.insert`, `table.remove`, `table.sort`, `table.concat`
- `math` — `math.floor`, `math.ceil`, `math.abs`, `math.max`, `math.min`, etc.
- `os.time`, `os.date`, `os.clock`, `os.difftime`
- Globals: `tonumber`, `tostring`, `type`, `pairs`, `ipairs`, `select`,
  `unpack`, `pcall`, `xpcall`, `next`, `rawget`, `rawset`, `rawequal`,
  `setmetatable`, `getmetatable`

### Blocked Functions

The following are **removed** for security:

- `io` (all functions)
- `file` (all functions)
- `os.execute`, `os.exit`, `os.getenv`, `os.remove`, `os.rename`, `os.tmpname`
- `require`, `load`, `loadfile`, `loadstring`, `dofile`
- `package` (all functions)

Attempting to call a blocked function will result in an error.

## Configuration

### Timeout

Set a maximum execution time (default: 5 seconds):

```elixir
config :rodar_bpmn_lua, max_time: 10_000  # 10 seconds
```

### Reduction Limit

Limit computational steps to prevent infinite loops (default: no limit):

```elixir
config :rodar_bpmn_lua, max_reductions: 1_000_000
```

When either limit is exceeded, the script is terminated and
`{:error, reason}` is returned.
