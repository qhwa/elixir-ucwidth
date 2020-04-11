defmodule Ucwidth.MixProject do
  use Mix.Project

  def project do
    [
      app: :ucwidth,
      description:
        "A port of ucwidth from C to Elixir, for determining the width (full-width or half-width) of an Unicode character.",
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: docs(),
      package: package(),
      source_url: "https://github.com/qhwa/elixir-ucwidth"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:quixir, "~> 0.9", only: :test},
      {:excoveralls, "~> 0.12", only: :test},
      {:benchee, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: [:dev, :doc], runtime: false},
      {:credo, "~> 1.3", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Ucwidth",
      extras: ~w[README.md]
    ]
  end

  defp package do
    [
      name: "ucwidth",
      files: ~w[lib mix.exs],
      licenses: ["MIT"],
      links: %{
        "github" => "https://github.com/qhwa/elixir-ucwidth"
      }
    ]
  end
end
