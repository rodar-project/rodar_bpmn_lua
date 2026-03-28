defmodule RodarLua.MixProject do
  use Mix.Project

  def project do
    [
      app: :rodar_lua,
      version: "0.2.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Lua script engine for Rodar BPMN execution engine",
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "guides/getting_started.md",
        "guides/lua_scripting.md"
      ],
      groups_for_extras: [
        Guides: ~r/guides\/.*/
      ]
    ]
  end

  defp deps do
    [
      {:rodar, github: "rodar-project/rodar"},
      {:rodar_release, "~> 1.2", only: :dev, runtime: false},
      {:luerl, "~> 1.2"}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/rodar-project/rodar_lua"}
    ]
  end
end
