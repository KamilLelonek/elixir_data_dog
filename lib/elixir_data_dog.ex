defmodule ElixirDataDog do
  @datadog_port      Application.get_env(:elixir_data_dog, :datadog_port)
  @datadog_host      Application.get_env(:elixir_data_dog, :datadog_host)
  @datadog_namespace Application.get_env(:elixir_data_dog, :datadog_namespace)

  def event(text) do
    text
    |> format_event()
    |> send_to_socket()
  end

  defp format_event(text),
    do: "_e{#{String.length(@datadog_namespace)},#{String.length(text)}}:#{@datadog_namespace}|#{text}"

  def increment(stat),
    do: count(stat, 1)

  def decrement(stat),
    do: count(stat, -1)

  def count(stat, count),
    do: send_stats(stat, count, :c)

  def gauge(stat, value),
    do: send_stats(stat, value, :g)

  def histogram(stat, value),
    do: send_stats(stat, value, :h)

  def set(stat, value),
    do: send_stats(stat, value, :s)

  def timing(stat, ms),
    do: send_stats(stat, ms, :ms)

  defmacro time(stat, do_block) do
    quote do
      function = fn -> unquote do_block[:do] end

      {elapsed, _result} = :timer.tc(ElixirDataDog, :_time_apply, [function])

      ElixirDataDog.timing(unquote(stat), trunc(elapsed / 1000))
    end
  end

  def _time_apply(function),
    do: function.()

  defp send_stats(stat, delta, type) do
    stat
    |> format_stats(delta, type)
    |> send_to_socket()
  end

  defp format_stats(stat, delta, type),
    do: "#{@datadog_namespace}.#{format_stat(stat)}:#{delta}|#{type}"

  defp format_stat(stat),
    do: String.replace stat, ~r/[:|@]/, "_"

  defp send_to_socket(nil), do: nil
  defp send_to_socket([]),  do: nil
  defp send_to_socket(message)
  when byte_size(message) > 8 * 1024,
    do: nil
  defp send_to_socket(message) do
    {:ok, socket} = :gen_udp.open(0)

    :gen_udp.send(
      socket,
      String.to_char_list(@datadog_host),
      @datadog_port,
      String.to_char_list(message)
    )

    :gen_udp.close(socket)
  end
end
