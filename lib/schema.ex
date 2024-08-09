defmodule Provider.Schema do
  @callback changeset(struct(), map()) :: Ecto.Changeset.t()

  @doc """
  Ensures that the schema implements the `changeset/2` function.
  """
  defmacro __using__(_) do
    quote do
      @behaviour Provider.Schema

      @doc """
      You need to implement this function in your schema.
      """
      @impl true
      def changeset(struct, params), do: raise "changeset/2 not implemented"
    end
  end
end
