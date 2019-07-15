defmodule ExMCP3xxx do
  @moduledoc """
  Documentation for ExMcp3xxx.
  """
  use GenServer
  alias Circuits.SPI

  @std_family 3002
  @spi_port "spidev0.0"

  def start_link(config \\ []) do
    GenServer.start_link(__MODULE__, config ++ [callback: self()], name: __MODULE__)
  end

  def init(config) do
    port = Keyword.get(config, :spi, @spi_port)
    family = Keyword.get(config, :family, @std_family)
    n_bits_family = Kernel.trunc(family/100)
    n_ch = rem(family, n_bits_family)

    {:ok, spi} = SPI.open(port)

    state = %{spi: spi, callback: config[:callback], bits: n_bits_family - 20, n_channels: n_ch}
    {:ok, state}
  end
  def read(channel), do: GenServer.call(__MODULE__, {:read, channel})
  def handle_call({:read, ch}, _from, state) do
    #TODO
    bits = state.bits
    start_bit = 96
    
    if state.n_channels > 2 do
      if ch > 0 do

        read_ch = start_bit + 4 * ch
    
        {:ok, <<_::size(6), resp::size(bits)>>} = SPI.transfer(state.spi, <<read_ch, 0x00>>)
        {:reply, {:ok, resp}, state}
      else
        {:ok, <<_::size(6), resp::size(bits)>>} = SPI.transfer(state.spi, <<start_bit, 0x00>>)
        {:reply, {:ok, resp}, state}
      end
    else
      read_ch = start_bit + 8 + (16 * ch)
    
      {:ok, <<_::size(6), resp::size(bits)>>} = SPI.transfer(state.spi, <<read_ch, 0x00>>)
      {:reply, {:ok, resp}, state}
    end
  end

end
