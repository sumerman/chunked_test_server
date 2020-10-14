defmodule ChunkedTestServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :chunked_test_server,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ChunkedTestServer, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.4"},
      {:faker, "~> 0.15"},
      {:jason, "~> 1.2"}
    ]
  end
end
