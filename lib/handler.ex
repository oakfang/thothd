defmodule Thothd.Handler do
    require Poison
    require Thoth.Model
    require Thoth.Query
    require Thoth.Entities
    require Thoth.Persistence

    defp respond(socket, data) do
        :gen_tcp.send(socket, data)
    end

    def handle(line, socket) do
        respond(socket, (line |> String.split |> handle_command))
    end

    defp get_graph do
        Agent.get(:thoth_db, fn state -> state end)
    end

    defp handle_command(["USE", path]) do
        graph = Thoth.Persistence.load(to_char_list(path), 5000)
        case Process.whereis(:thoth_db) do
            nil ->
                {:ok, agent} = Agent.start_link(fn -> graph end)
                Process.register(agent, :thoth_db)
                "OK"
            _ ->
                :ok = Agent.update(:thoth_db, fn _ -> graph end)
                "OK"
        end
    end

    defp handle_command(["REQUIRE", path]) do
        Code.require_file(path)
        "OK"
    end

    defp handle_command(words) do
        {result, _} = words |> Enum.join(" ") |> Code.eval_string([graph: get_graph])
        Poison.encode! result
    end
end