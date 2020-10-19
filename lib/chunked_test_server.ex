defmodule ChunkedTestServer do
  require Logger
  use Application

  defmodule Router do
    use Plug.Router

    plug(:allow_origin)
    plug(:match)
    plug(:dispatch)

    def allow_origin(conn, _opts) do
      [
        {"Access-Control-Allow-Origin", "*"},
        {"Access-Control-Allow-Methods", "GET"},
        {"Access-Control-Allow-Credentials", "true"},
        {"Access-Control-Allow-Headers", "application/json"}
      ]
      |> Enum.reduce(conn, fn {h, v}, c -> put_resp_header(c, h, v) end)
    end

    defp maybe_limit(stream, conn) do
      if Map.has_key?(conn.query_params, "rows") do
        count =
          conn.query_params
          |> Map.get("rows")
          |> String.to_integer()

        Stream.take(stream, count)
      else
        stream
      end
    end

    options "/chunks" do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, "")
    end

    get "/chunks" do
      conn =
        conn
        |> fetch_query_params()
        |> put_resp_content_type("application/json")
        |> send_chunked(200)

      Stream.iterate(0, fn x -> x + 1 end)
      |> maybe_limit(conn)
      |> Stream.map(fn idx ->
        [idx, Faker.random_between(1, idx), Faker.DateTime.backward(1000), Faker.Superhero.name()]
      end)
      |> Stream.chunk_every(100)
      |> Enum.reduce_while(conn, fn rows, conn ->
        chunk = Jason.encode!(%{rows: rows}) <> "\n"

        case chunk(conn, chunk) do
          {:ok, conn} ->
            Process.sleep(Faker.random_between(0, 500))
            {:cont, conn}

          {:error, :closed} ->
            {:halt, conn}
        end
      end)
    end

    match "/ping" do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "pong")
    end

    match _ do
      send_resp(conn, 404, "oops")
    end
  end

  def start(_type, _args) do
    port = System.get_env("PORT", "4001") |> String.to_integer()

    children = [
      {Plug.Cowboy, scheme: :http, plug: Router, options: [port: port]}
    ]

    ret =
      {:ok, _} =
      Supervisor.start_link(children, strategy: :one_for_one, name: ChunkedTestServer.Supervisor)

    Logger.info("Listening on port #{port}...")

    Logger.info("""
    Try fetching http://localhost:#{port}/chunks
    or http://localhost:#{port}/chunks?rows=200
    """)

    ret
  end
end
