defmodule ElixirDataDog.Mixfile do
  use Mix.Project

  def project do
    [
      app:             :elixir_data_dog,
      version:         "0.1.0",
      elixir:          "~> 1.4",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description:     description(),
      package:         package(),
      deps:            deps()
   ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", runtime: false},
    ]
  end

  defp description do
    """
      A simple library for sending metrics to DataDog
    """
  end

  defp package do
    [
     name:        :elixir_data_dog,
     files:       ["lib", "config", "mix.exs", "README.md"],
     maintainers: ["Kamil Lelonek"],
     licenses:    ["Apache 2.0"],
     links: %{
       "GitHub" => "https://github.com/KamilLelonek/elixir_data_dog",
       "Docs"   => "https://hexdocs.pm/elixir_data_dog/"
     }
    ]
  end
end
