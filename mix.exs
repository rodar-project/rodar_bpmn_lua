defmodule RodarLua.MixProject do
  use Mix.Project

  def project do
    [
      app: :rodar_lua,
      version: "0.1.0",
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
      {:rodar, path: "../rodar_bpmn"},
      {:rodar_release, github: "rodar-project/rodar_release", only: :dev, runtime: false},
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
