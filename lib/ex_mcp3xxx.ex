defmodule ExMCP3xxx do
  @moduledoc """
  Documentation for ExMCP3xxx.
  """
  use GenServer
  alias Circuits.SPI

  @std_family 3002
  @spi_port "spidev0.0"
  @v_ref 3.3

  def start_link(config \\ []) do
    GenServer.start_link(__MODULE__, config ++ [callback: self()], name: __MODULE__)
  end

  def init(config) do
    port = Keyword.get(config, :spi, @spi_port)
    family = Keyword.get(config, :family, @std_family)
    v_ref = Keyword.get(config, :v_ref, @v_ref)
    
    n_bits_family = Kernel.trunc(family/100)
    n_ch = rem(family, n_bits_family)

    {:ok, spi} = SPI.open(port)

    state = %{spi: spi, callback: config[:callback], bits: n_bits_family - 20, n_channels: n_ch, v_ref: v_ref}
    {:ok, state}
  end
  
  def read(channel) when (channel >= 0 and channel <= 7), do: GenServer.call(__MODULE__, {:read, channel})

  def voltage(channel)  when (channel >= 0 and channel <= 7), do: GenServer.call(__MODULE__, {:voltage, channel})

  def handle_call({:read, ch}, _from, state) do
    #TODO
    {:reply, read_channel(ch, state), state}
  end

  def handle_call({:voltage, ch}, _from, state) do
    #TODO
    {:ok, counts} = read_channel(ch, state)
    resp = counts / (:math.pow(2, state.bits) - 1) * state.v_ref
    {:reply, {:ok, resp}, state}
  end

  defp read_channel(ch, state) do
    start_bit = 96
    bits = state.bits
    if state.n_channels > 2 do
      if ch > 0 do

        read_ch = start_bit + 4 * ch
    
        {:ok, <<_::size(6), resp::size(bits)>>} = SPI.transfer(state.spi, <<read_ch, 0x00>>)
        {:ok, resp}
      else
        {:ok, <<_::size(6), resp::size(bits)>>} = SPI.transfer(state.spi, <<start_bit, 0x00>>)
        {:ok, resp}
      end
    else
      read_ch = start_bit + 8 + (16 * ch)
    
      {:ok, <<_::size(6), resp::size(bits)>>} = SPI.transfer(state.spi, <<read_ch, 0x00>>)
      {:ok, resp}
    end
  end
end
