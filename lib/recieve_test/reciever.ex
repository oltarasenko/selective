defmodule Reciever do
  def selective_receive() do
    receive do
      "scnenario1" <> _rest -> :ok
      "scnenario2" <> _rest -> :ok
      "scnenario3" <> _rest -> :ok
      "scnenario4" <> _rest -> :ok
      _ -> :ok
    end

    message_queue_len = Process.info(self(), :message_queue_len)
    send(:stats, message_queue_len)
    selective_receive()
  end

  def test1(msg_head, total_messages) do
    loop_pid = spawn(&Reciever.selective_receive/0)
    Process.register(spawn(fn -> stats(total_messages) end), :stats)
    spawn(fn -> send_messages(loop_pid, msg_head, total_messages) end)
  end

  defp send_messages(pid, msg, total_messages) do
    Task.async_stream(
      1..total_messages,
      fn _ ->
        send(pid, msg <> EntropyString.token())
      end,
      max_concurrency: 1000
    )
    |> Enum.map(fn x -> x end)

    IO.puts("Sent all...")
  end

  def stats(num) do
    ts1 = Time.utc_now()

    queue_sizes =
      Enum.map(1..num, fn _ ->
        receive do
          {:message_queue_len, len} -> len
        end
      end)

    ts2 = Time.utc_now()
    diff = Time.diff(ts2, ts1, :microsecond)
    sum = Enum.sum(queue_sizes)

    IO.puts(
      "Time spent #{diff}. Avg queue size: #{sum / num}. Max queue size: #{Enum.max(queue_sizes)}"
    )
  end
end
