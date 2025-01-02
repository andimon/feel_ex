defmodule FeelEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :feel_ex,
      version: "0.1.1-dev",
      elixir: "~> 1.15",
      erlc_paths: ["priv"],
      description: description(),
      compilers: [:yecc, :leex] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
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
      {:tzdata, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Business oriented language based on FEEL in Elixir."
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib mix.exs README.md CHANGELOG.md),
      links: %{"GitHub" => "https://github.com/ExSemantic/feel_ex"},
      licenses: ["Apache-2.0"],
      source_url: "https://github.com/ExSemantic/feel_ex",
      homepage_url: "https://www.exsemantic.com"
    ]
  end
end
