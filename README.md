# elixir_data_dog

[![Build Status](https://travis-ci.org/KamilLelonek/elixir_data_dog.svg?branch=master)](https://travis-ci.org/KamilLelonek/elixir_data_dog)

A simple library for sending metrics to DataDog

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elixir_data_dog` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:elixir_data_dog, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/elixir_data_dog](https://hexdocs.pm/elixir_data_dog).

# Configuration

Provide the following variables in your `config.exs`:

```elixir
config :elixir_data_dog,
  datadog_port:      8125,
  datadog_host:      "localhost",
  datadog_namespace: "YOUR_APP_NAME"

```

## Usage

```elixir
ElixirDataDog.increment("page.views")

ElixirDataDog.decrement("page.logins")

ElixirDataDog.count("page.visits", 10)

ElixirDataDog.gauge("users.online", 123)

ElixirDataDog.histogram("file.upload.size", 1234)

ElixirDataDog.timing("file.download.time", 1000)

ElixirDataDog.time("page.render") do
  render_page('home.html')
end

ElixirDataDog.set("users", "John Doe")

ElixirDataDog.event("An error occured!", "The server returned 500.")
```
