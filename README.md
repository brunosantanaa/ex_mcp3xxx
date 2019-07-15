# ExMcp3xxx

Library to use MCP family A / D converters microchip with Nerves.

## Example

```elixir
iex> ExMCP3xxx.start_link([family: 3208])
{:ok, #PID}
# ExMCP3xxx.read(channel_number)
iex> ExMCP3xxx.read(7)
342
```
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_mcp3xxx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_mcp3xxx, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_mcp3xxx](https://hexdocs.pm/ex_mcp3xxx).

