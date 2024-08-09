
# Provider

The `Provider` module is designed to simplify the process of creating RESTful CRUD routes for Ecto schemas in a Plug-based Elixir application. It automatically generates routes for listing, showing, creating, updating, and deleting resources, and also allows for custom route definitions.

## Installation

To use `Provider` in your project, add it as a dependency in your `mix.exs`:

```elixir
defp deps do
  [
    {:provider, "~> 0.1.0"}
  ]
end
```

Then, run:

```bash
mix deps.get
```

## Configuration

You need to configure the Ecto Repo that `Provider` will use in your `config/config.exs` file:

```elixir
import Config

config :provider, repo: MyApp.Repo
```

## Usage

### Defining a Schema

To use the `Provider` module, your schema module must implement the `Provider.Schema` behavior, which requires defining a `changeset/2` function.

```elixir
defmodule MyApp.Schema.User do
  use Ecto.Schema
  use Provider.Schema

  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    timestamps()
  end

  @impl true
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
  end
end
```

### Using the `mount` Macro

The `mount/2` macro in the `Provider` module generates RESTful CRUD routes for a specified schema. It takes the following options:

- `:path` - The base path where the routes will be mounted.
- `:schema` - The Ecto schema module for which the routes are being generated.
- `:functions` - (Optional) A keyword list of custom handler functions for specific routes.

#### Example

```elixir
defmodule MyApp.Router do
  use Plug.Router
  use Provider

  plug :match
  plug :dispatch

  mount "/users", schema: MyApp.Schema.User do
    get "/custom/endpoint" do
      send_resp(conn, 200, "Custom endpoint")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
```

This will generate the following routes:

- `GET /users` - Lists all users.
- `GET /users/:id` - Shows a specific user.
- `POST /users` - Creates a new user.
- `PUT /users/:id` - Updates an existing user.
- `DELETE /users/:id` - Deletes a specific user.

You can also define custom routes inside the `do` block.

## License

This project is licensed under the MIT License.
