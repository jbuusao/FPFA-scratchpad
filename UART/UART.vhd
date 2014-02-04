-- UART unit
-- A fully functional UART with Rx, Tx, with Rx/Tx FIFOs and baud rate sensing
-- Jean-Paul Buu-Sao --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART is 
	
  generic (N: integer := 10; M: integer := 14);
  port (
    clk, reset, baudtick: in  std_logic;
    sdata: in std_logic_vector(7 downto 0);
    rdata: out std_logic_vector(7 downto 0);
    send, receive: in std_logic;
	 tx_busy, ready: out std_logic;
	 Rx: in std_logic;
	 Tx: out std_logic
    );
end entity UART;

architecture rtl of UART is
	signal rx_ready, rx_signal, sense_bauds_done: std_logic;
	signal sense_bauds_rate: unsigned(M-1 downto 0);
	signal rd_data_fifo_in, rd_data_fifo_out, tx_send_data: std_logic_vector(7 downto 0);
	signal fifo_read, fifo_write, fifo_empty, tx_send: std_logic;
begin

		RX_FIFO: entity work.MyFIFO
		port map
		(
			 clk=>clk, reset=>reset,
			 rd=>fifo_read,
			 wr=>fifo_write,
			 dataIn=>rd_data_fifo_in,
			 dataOut=> rd_data_fifo_out,
			 empty=>fifo_empty,
			 readptr_debug=>open, writeptr_debug=>open
		);
		
		Controler: entity work.Controler
		port map
		(
			 rd_fifo_ready => not fifo_empty,
			 rd_fifo_data => rd_data_fifo_in,
			 rd_fifo_read => fifo_read,
			 tx_send => tx_send,
			 tx_send_data => tx_send_data
		);
		
		RX_unit: entity work.UART_Rx
		generic map(M=>M)
		port map
		(
			 clk=>clk, reset=>reset, baudtick=>baudtick,
			 wdata=>rdata,
			 divisor=>sense_bauds_rate,
			 set=>sense_bauds_done,
			 ready=>rx_ready,
			 busy=>open,
			 bTick=>open,
			 Rx=>rx_signal
		 );
		 
		TX_unit: entity work.UART_Tx 
		generic map(M=>M)
		port map
		(
			 clk=>clk, reset=>reset, baudtick=>baudtick,
			 wdata=>sdata,
			 divisor=>sense_bauds_rate,
			 set=>sense_bauds_done,
			 wr=>rx_ready,			 
			 busy=>tx_busy,
			 bTick=>open,
			 Tx=>tx
		 );
		 
		Sense_bauds: entity work.SenseBauds
		generic map(N=>N, M=>M)		 
		port map
		 (
			 clk=>clk, reset=>reset, btick=>baudtick, Rx=>Rx_signal, done=>sense_bauds_done, rate=>sense_bauds_rate
		 );
		 
		 rx_signal <= rx;
		 ready <= rx_ready;
		
end architecture rtl;
