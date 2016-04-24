defmodule Thothd.Server do
    use Application
    require Logger
    require Thothd.Handler

    @doc false
    def start(_type, _args) do
        import Supervisor.Spec
        children = [
            supervisor(Task.Supervisor, [[name: Thothd.Server.TaskSupervisor]]),
            worker(Task, [Thothd.Server, :accept, [4040]])
        ]

        opts = [strategy: :one_for_one, name: Thothd.Server.Supervisor]
        Supervisor.start_link(children, opts)
    end

    @doc """
    Starts accepting connections on the given `port`.
    """
    def accept(port) do
        {:ok, socket} = :gen_tcp.listen(port,
                                            [:binary, active: false, reuseaddr: true])
        Logger.info "Accepting connections on port #{port}"
        loop_acceptor(socket)
    end

    defp loop_acceptor(socket) do
        {:ok, client} = :gen_tcp.accept(socket)
        {:ok, pid} = Task.Supervisor.start_child(Thothd.Server.TaskSupervisor, fn -> serve(client) end)
        :ok = :gen_tcp.controlling_process(client, pid)
        Logger.info "Connection received"
        loop_acceptor(socket)
    end

    defp serve(socket) do
        case read_line(socket) do
            :closed -> Logger.info "Connection closed"
            line ->
                Thothd.Handler.handle(line, socket)
                serve(socket)
        end
    end

    defp read_line(socket) do
        case :gen_tcp.recv(socket, 0) do
            {:ok, data} -> data
            {:error, :closed} -> :closed    
        end
    end
end