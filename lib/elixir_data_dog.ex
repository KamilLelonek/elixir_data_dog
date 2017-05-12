defmodule ElixirDataDog do
  def datadog_port,      do: Application.get_env(:elixir_data_dog, :datadog_port)
  def datadog_host,      do: Application.get_env(:elixir_data_dog, :datadog_host)
  def datadog_namespace, do: Application.get_env(:elixir_data_dog, :datadog_namespace)

  def event(text, opts \\ %{}) do
    text
    |> format_event(opts)
    |> send_to_socket()
  end

  defp format_event(text, opts),
    do: "_e{#{String.length(datadog_namespace())},#{String.length(text)}}:#{datadog_namespace()}|#{text}" |> add_tags(opts[:tags])

  def increment(stat, opts \\ %{}),
    do: count(stat, 1, opts)

  def decrement(stat, opts \\ %{}),
    do: count(stat, -1, opts)

  def count(stat, count, opts \\ %{}),
    do: send_stats(stat, count, :c, opts)

  def gauge(stat, value, opts \\ %{}),
    do: send_stats(stat, value, :g, opts)

  def histogram(stat, value, opts \\ %{}),
    do: send_stats(stat, value, :h, opts)

  def set(stat, value, opts \\ %{}),
    do: send_stats(stat, value, :s, opts)

  def timing(stat, ms, opts \\ %{}),
    do: send_stats(stat, ms, :ms, opts)

  defmacro time(stat, opts \\ Macro.escape(%{}), do_block) do
    quote do
      function = fn -> unquote do_block[:do] end

      {elapsed, result} = :timer.tc(ElixirDataDog, :_time_apply, [function])

      ElixirDataDog.timing(unquote(stat), trunc(elapsed / 1000), unquote(opts))

      result
    end
  end

  def _time_apply(function),
    do: function.()

  defp send_stats(stat, delta, type, opts) do
    stat
    |> format_stats(delta, type, opts)
    |> send_to_socket()
  end

  defp format_stats(stat, delta, type, opts),
    do: "#{datadog_namespace()}.#{format_stat(stat)}:#{delta}|#{type}" |> add_tags(opts[:tags])

  defp format_stat(stat),
    do: String.replace stat, ~r/[:|@]/, "_"

  def add_tags(event, nil), do: event
  def add_tags(event, []),  do: event
  def add_tags(event, tags) do
    tags = tags
           |> Enum.map(&String.replace(&1, "|", ""))
           |> Enum.join(",")

    "#{event}|##{tags}"
  end

  defp send_to_socket(nil), do: nil
  defp send_to_socket([]),  do: nil
  defp send_to_socket(message)
  when byte_size(message) > 8 * 1024,
    do: nil
  defp send_to_socket(message) do
    {:ok, socket} = :gen_udp.open(0)

    :gen_udp.send(
      socket,
      String.to_char_list(datadog_host()),
      datadog_port(),
      String.to_char_list(message)
    )

    :gen_udp.close(socket)
  end
end
