defmodule Reciever do
  def loop() do
    receive do
      "scnenario1" <> _rest -> :ok
      "scnenario2" <> _rest -> :ok
      "scnenario3" <> _rest -> :ok
      "scnenario4" <> _rest -> :ok
      _ -> :ok
    end

    {_, len} = Process.info(self(), :message_queue_len)
    send(:stats, len)
    loop()
  end

  def test1() do
    loop_pid = spawn(&Reciever.loop/0)
    Process.register(spawn(fn -> stats(50_000) end), :stats)
    send_messages(loop_pid, "scnenario1_test", 50000)
  end

  defp send_messages(pid, msg, total_messages) do
    Task.async_stream(
      1..total_messages,
      fn _ ->
        send(pid, msg <> "_some_binary")
      end,
      max_concurrency: 500
    )
    |> Enum.map(fn x -> x end)

    IO.puts("Sent all...")
  end

  def stats(num) do
    ts1 = Time.utc_now()
    {:ok, fd} = File.open("/tmp/bench", [:delayed_write, :append])

    details =
      Enum.map(1..num, fn _ ->
        receive do
          length -> IO.puts(fd, "#{length}")
        end
      end)

    File.close(fd)
    ts2 = Time.utc_now()
    diff = Time.diff(ts2, ts1, :microsecond)
    IO.puts("Time spent #{diff}")
  end
end
