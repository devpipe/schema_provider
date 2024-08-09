defmodule Provider.MixProject do
  use Mix.Project

  @version "0.0.1"
  @description "Provider to create endpoints from Ecto schema"
  @repo "https://github.com/wess/schema_provider"

  def project do
    [
      app: :schema_provider,
      version: @version,
      description: @description,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: [
        main: "SchemaProvider",
        source_ref: "v#{@version}",
        source_url: @repo,
        extras: ["README.md"]
      ],

    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Wess Cope"],
      links: %{"Github" => @repo}
    }
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
      {:plug_cowboy, "~> 2.7"},
      {:ecto_sql, "~> 3.11"},
      {:jason, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
    ]
  end
end
