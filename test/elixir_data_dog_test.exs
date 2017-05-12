defmodule ElixirDataDogTest do
  use ExUnit.Case

  @datadog_port      Application.get_env(:elixir_data_dog, :datadog_port)
  @datadog_namespace Application.get_env(:elixir_data_dog, :datadog_namespace)
  @counter           "foobar"
  @tags              ~w(tag1 tag2)

  setup do
    {:ok, listener} = :gen_udp.open(@datadog_port)

    on_exit fn ->
      :gen_udp.close(listener)
    end

    :ok
  end

  test "increment" do
    message = "#{@datadog_namespace}.#{@counter}:1|c" |> String.to_char_list()

    ElixirDataDog.increment(@counter)

    assert_receive_message(message)
  end

  test "decrement" do
    message = "#{@datadog_namespace}.#{@counter}:-1|c" |> String.to_char_list()

    ElixirDataDog.decrement(@counter)

    assert_receive_message(message)
  end

  test "count" do
    value   = 2
    message = "#{@datadog_namespace}.#{@counter}:#{value}|c" |> String.to_char_list()

    ElixirDataDog.count(@counter, value)

    assert_receive_message(message)
  end

  test "gauge" do
    value   = 4
    message = "#{@datadog_namespace}.#{@counter}:#{value}|g" |> String.to_char_list()

    ElixirDataDog.gauge(@counter, 3)
    ElixirDataDog.gauge(@counter, value)

    assert_receive_message(message)
  end

  test "histogram" do
    value   = 500
    message = "#{@datadog_namespace}.#{@counter}:#{value}|h" |> String.to_char_list()

    ElixirDataDog.histogram(@counter, value)

    assert_receive_message(message)
  end

  test "set" do
    value   = 600
    message = "#{@datadog_namespace}.#{@counter}:#{value}|s" |> String.to_char_list()

    ElixirDataDog.set(@counter, value)

    assert_receive_message(message)
  end

  test "timing" do
    value   = 700
    message = "#{@datadog_namespace}.#{@counter}:#{value}|ms" |> String.to_char_list()

    ElixirDataDog.timing(@counter, value)

    assert_receive_message(message)
  end

  test "time" do
    value   = 0
    message = "#{@datadog_namespace}.#{@counter}:#{value}|ms" |> String.to_char_list()
    result  = "test"

    require ElixirDataDog

    assert ^result = (ElixirDataDog.time(@counter) do
       :timer.sleep(value)
       result
     end)

    assert_receive_message(message)
  end

  test "event" do
    message = "_e{15,6}:#{@datadog_namespace}|#{@counter}" |> String.to_char_list()

    ElixirDataDog.event(@counter)

    assert_receive_message(message)
  end

  describe "tags" do
    test "should allow to send tags" do
      message = "_e{15,6}:#{@datadog_namespace}|#{@counter}|##{Enum.join(@tags, ",")}" |> String.to_char_list()

      ElixirDataDog.event(@counter, tags: @tags)

      assert_receive_message(message)
    end
  end

  defp assert_receive_message(message),
    do: assert_receive {:udp, _port, _from_ip, _from_port, ^message}
end
