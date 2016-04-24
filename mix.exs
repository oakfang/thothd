defmodule Server.Mixfile do
  use Mix.Project

  def project do
    [app: :thothd,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     consolidate_protocols: false,
     # escript: [main_module: Thothd],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :crypto],
    mod: {Thothd.Server, []}]
  end

  defp deps do
    [
      {:thoth, "~> 0.0.5"},
      {:poison, "~> 2.0"}
    ]
  end
end
