defmodule UeberauthIBMId.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/ibm-skills-network/ueberauth_ibmid"

  def project do
    [
      app: :ueberauth_ibmid,
      version: @version,
      elixir: "~> 1.3",
      name: "Ueberauth IBMId",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: @url,
      homepage_url: @url,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:logger, :oauth2, :ueberauth]]
  end

  defp deps do
    [
      {:oauth2, "~> 2.0"},
      {:ueberauth, "~> 0.6"},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "An Überauth strategy for using IBMId to authenticate your users."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Ben Honda"],
      licenses: ["MIT"],
      links: %{GitHub: @url}
    ]
  end
end
