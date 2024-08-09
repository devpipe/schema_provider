defmodule Provider do
  @moduledoc """
  The `Provider` module provides a macro for generating RESTful CRUD routes
  for a given Ecto schema in a Plug-based application.

  The `mount` macro automatically creates routes for listing, showing, creating,
  updating, and deleting resources. Custom routes can also be defined within the
  `do` block.
  """

  @doc """
  The `mount/2` macro is used to generate RESTful CRUD routes for a specified
  schema. It accepts the following options:

  - `:path`: The base path where the routes will be mounted.
  - `:schema`: The Ecto schema module for which the routes are being generated.
  - `:functions`: A keyword list of custom handler functions for specific routes.
    Available keys are `:list`, `:get`, `:create`, `:update`, and `:delete`.
  - `do`: The block where custom routes can be defined.

  ## Example

      mount "/users", schema: MyApp.Schema.User do
        get "/custom/endpoint" do
          send_resp(conn, 200, "Custom endpoint")
        end
      end

  This will generate the following routes:

  - `GET /users`       - Lists all users.
  - `GET /users/:id`   - Shows a specific user.
  - `POST /users`      - Creates a new user.
  - `PUT /users/:id`   - Updates an existing user.
  - `DELETE /users/:id` - Deletes a specific user.

  The `schema` module must implement the `Provider.Schema` behavior, which
  enforces the presence of a `changeset/2` function.
  """
  defmacro mount(path, opts) do
    schema = Keyword.fetch!(opts, :schema)
    functions = Keyword.get(opts, :functions, [])

    quote do
      # Ensure the schema module implements the Provider.Schema behavior
      if not Code.ensure_loaded?(unquote(schema)) or not function_exported?(unquote(schema), :behaviour_info, 1) or
           not unquote(schema).behaviour_info(:callbacks) |> Keyword.has_key?(:changeset) do
        raise "#{inspect(unquote(schema))} must implement the Provider.Schema behavior and define the changeset/2 function"
      end

      forward(unquote(path), to: __MODULE__)

      @schema unquote(schema)
      @functions unquote(functions)
      @repo Application.get_env(:schema_provider, :repo)

      if @repo == nil do
        raise "Ecto Repo not configured. Please set :repo in your application's config."
      end

      unquote(opts[:do])

      get "/" do
        if @functions[:list] do
          apply(__MODULE__, @functions[:list], [conn])
        else
          items = @repo.all(@schema)
          send_resp(conn, 200, Jason.encode!(items))
        end
      end

      get "/:id" do
        if @functions[:get] do
          apply(__MODULE__, @functions[:get], [conn, conn.params["id"]])
        else
          id = String.to_integer(conn.params["id"])
          item = @repo.get(@schema, id)

          case item do
            nil -> send_resp(conn, 404, "Item not found")
            _ -> send_resp(conn, 200, Jason.encode!(item))
          end
        end
      end

      post "/" do
        if @functions[:create] do
          apply(__MODULE__, @functions[:create], [conn])
        else
          {:ok, body, _} = Plug.Conn.read_body(conn)
          attrs = Jason.decode!(body)
          changeset = @schema.changeset(%@schema{}, attrs)

          case @repo.insert(changeset) do
            {:ok, item} -> send_resp(conn, 201, Jason.encode!(item))
            {:error, changeset} -> send_resp(conn, 422, Jason.encode!(changeset.errors))
          end
        end
      end

      put "/:id" do
        if @functions[:update] do
          apply(__MODULE__, @functions[:update], [conn, conn.params["id"]])
        else
          id = String.to_integer(conn.params["id"])
          item = @repo.get(@schema, id)

          case item do
            nil -> send_resp(conn, 404, "Item not found")
            _ ->
              {:ok, body, _} = Plug.Conn.read_body(conn)
              attrs = Jason.decode!(body)
              changeset = @schema.changeset(item, attrs)

              case @repo.update(changeset) do
                {:ok, item} -> send_resp(conn, 200, Jason.encode!(item))
                {:error, changeset} -> send_resp(conn, 422, Jason.encode!(changeset.errors))
              end
          end
        end
      end

      delete "/:id" do
        if @functions[:delete] do
          apply(__MODULE__, @functions[:delete], [conn, conn.params["id"]])
        else
          id = String.to_integer(conn.params["id"])
          item = @repo.get(@schema, id)

          case item do
            nil -> send_resp(conn, 404, "Item not found")
            _ ->
              @repo.delete!(item)
              send_resp(conn, 204, "")
          end
        end
      end
    end
  end
end
