# TODO should this be moved to application.ex or todoer_app.. or todoer/app..?
defmodule Todoer.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Todoer.Registry},
      {Todoer, []}
    ]

    opts = [strategy: :one_for_one, name: Todoer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
