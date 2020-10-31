defmodule Array.Mixfile do
  use Mix.Project

  def project do
    [app: :elixir_array,
     version: "1.0.1",
     elixir: ">= 1.0.0",
     description: "An elixir wrapper library for Erlang's array.",
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:earmark, ">= 0.0.0", only: :dev},
     {:ex_doc, "~> 0.6", only: :dev}]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     contributors: ["Kohei Takeda"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/takscape/elixir-array"}]
  end
end
