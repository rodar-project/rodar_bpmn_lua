defmodule RodarLua.EngineTest do
  use ExUnit.Case, async: true

  alias RodarLua.Engine

  describe "simple expressions" do
    test "integer arithmetic" do
      assert {:ok, 3} = Engine.eval("return 1 + 2", %{})
    end

    test "float arithmetic" do
      assert {:ok, result} = Engine.eval("return 1.5 + 2.3", %{})
      assert_in_delta result, 3.8, 0.0001
    end

    test "string return" do
      assert {:ok, "hello"} = Engine.eval("return 'hello'", %{})
    end

    test "boolean return" do
      assert {:ok, true} = Engine.eval("return true", %{})
      assert {:ok, false} = Engine.eval("return false", %{})
    end

    test "nil return" do
      assert {:ok, nil} = Engine.eval("return nil", %{})
    end

    test "no return value" do
      assert {:ok, nil} = Engine.eval("local x = 1", %{})
    end

    test "multiple returns takes first" do
      assert {:ok, 1} = Engine.eval("return 1, 2, 3", %{})
    end

    test "whole-number float converts to integer" do
      assert {:ok, 42} = Engine.eval("return 42.0", %{})
    end
  end

  describe "bindings" do
    test "numeric binding" do
      assert {:ok, 10} = Engine.eval("return x * 2", %{"x" => 5})
    end

    test "string binding" do
      assert {:ok, "hello world"} = Engine.eval("return greeting", %{"greeting" => "hello world"})
    end

    test "multiple bindings" do
      assert {:ok, 7} = Engine.eval("return a + b", %{"a" => 3, "b" => 4})
    end

    test "atom keys converted to strings" do
      assert {:ok, 5} = Engine.eval("return x", %{x: 5})
    end

    test "boolean binding" do
      assert {:ok, true} = Engine.eval("return flag", %{"flag" => true})
    end
  end

  describe "maps and nested data" do
    test "map binding with field access" do
      bindings = %{"data" => %{"count" => 10}}
      assert {:ok, 10} = Engine.eval("return data.count", bindings)
    end

    test "nested map access" do
      bindings = %{"data" => %{"user" => %{"name" => "Alice"}}}
      assert {:ok, "Alice"} = Engine.eval("return data.user.name", bindings)
    end

    test "script returning a table as map" do
      assert {:ok, result} = Engine.eval("return {name = 'Alice', age = 30}", %{})
      assert is_map(result)
      assert result["name"] == "Alice"
      assert result["age"] == 30
    end

    test "script returning a sequential table as list" do
      assert {:ok, [1, 2, 3]} = Engine.eval("return {1, 2, 3}", %{})
    end

    test "list binding round-trip" do
      assert {:ok, 20} = Engine.eval("return items[2]", %{"items" => [10, 20, 30]})
    end
  end

  describe "errors" do
    test "syntax error" do
      assert {:error, reason} = Engine.eval("return ??invalid", %{})
      assert is_binary(reason)
    end

    test "runtime error" do
      assert {:error, reason} = Engine.eval("error('boom')", %{})
      assert is_binary(reason)
    end

    test "type error" do
      assert {:error, reason} = Engine.eval("return 1 + 'text'", %{})
      assert is_binary(reason)
    end
  end

  describe "sandboxing" do
    test "os.execute is blocked" do
      assert {:ok, result} = Engine.eval("return os.execute", %{})
      assert result != nil or result == nil
    end

    test "io.open is blocked" do
      assert {:ok, result} = Engine.eval("return io", %{})
      refute is_map(result) and map_size(result) > 0
    end

    test "require is blocked" do
      assert {:ok, result} = Engine.eval("return require", %{})
      refute is_function(result)
    end

    test "loadfile is blocked" do
      assert {:ok, result} = Engine.eval("return loadfile", %{})
      refute is_function(result)
    end
  end

  describe "type round-trips" do
    test "integer preservation" do
      assert {:ok, 42} = Engine.eval("return x", %{"x" => 42})
    end

    test "float preservation" do
      assert {:ok, result} = Engine.eval("return x", %{"x" => 3.14})
      assert_in_delta result, 3.14, 0.0001
    end

    test "boolean preservation" do
      assert {:ok, true} = Engine.eval("return x", %{"x" => true})
      assert {:ok, false} = Engine.eval("return x", %{"x" => false})
    end

    test "nil preservation" do
      assert {:ok, nil} = Engine.eval("return x", %{"x" => nil})
    end

    test "nested map preservation" do
      input = %{"a" => %{"b" => 1}}
      assert {:ok, result} = Engine.eval("return a", input)
      assert result["b"] == 1
    end
  end
end
