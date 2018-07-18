defmodule Reciever do
  def loop1() do
    receive do
      "scnenario1" <> _rest -> :ok
      "scnenario2" <> _rest -> :ok
      "scnenario3" <> _rest -> :ok
      "scnenario4" <> _rest -> :ok
      _ -> :not_found
    end

    # IO.puts("Resp #{inspect(resp)}")
    :timer.sleep(1000)
    loop1()
  end

  def test1() do
    pid = spawn(&loop1/0)

    # messages =
    #   [
    #     Enum.map(1..1000, fn _ -> "scnenario1_" <> EntropyString.random() end),
    #     Enum.map(1..1000, fn _ -> "scnenario2_" <> EntropyString.random() end),
    #     Enum.map(1..1000, fn _ -> "scnenario3_" <> EntropyString.random() end),
    #     Enum.map(1..1000, fn _ -> "scnenario4_" <> EntropyString.random() end)
    #   ]
    #   |> List.flatten()

    # Kernel.spawn(fn ->
    #   Task.async_stream(1..10_000, fn _ ->
    #     send(pid, "scnenario4_some_binary")
    #     :timer.sleep(1_000)
    #   end)
    #   |> Enum.map(fn x -> x end)
    # end)

    # IO.puts("Stream sent")

    # Task.async_stream(1..1000, fn -> send(pid, "scnenario1_" <> EntropyString.random()) end, :max_concurrency: 30)
    # Task.async_stream(1..1000, fn -> send(pid, "scnenario1_" <> EntropyString.random()) end, :max_concurrency: 30)
    # Task.async_stream(1..1000, fn -> send(pid, "scnenario1_" <> EntropyString.random()) end, :max_concurrency: 30)
    # Enum.each(messages, fn msg -> send(pid, msg) end)
    send_message(pid, "scnenario1", 100_000, 100)
    send_message(pid, "scnenario1", 100_0000, 10000)

    Enum.map(
      1..200,
      fn _ ->
        process_info = :erlang.process_info(pid, :message_queue_len)
        IO.puts("#{inspect(process_info)}")
        :timer.sleep(1000)
      end
    )
  end

  defp send_message(pid, msg, total_messages, delay) do
    Task.async_stream(1..total_messages, fn _ ->
      send(pid, msg <> "_some_binary")
      :timer.sleep(delay)
    end)
    |> Enum.map(fn x -> x end)
  end
end
