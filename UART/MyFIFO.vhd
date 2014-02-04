-- FIFO
-- Jean-Paul Buu-Sao --

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity MyFIFO is 
	-- Parameters of the FIFO
	-- a) FSIZE = size of the FIFO, in words. Actual # of words = 2**FSIZE
	-- b) WSIZE = size of one word, in bits
	
  generic (
    FSIZE : positive := 7;		-- Default: FIFO size is 128 words
	 WSIZE : positive := 8);   -- Default: each word in the FIFO has 8 bits size
  port (
    clk, reset: in  std_logic;
    dataIn: in std_logic_vector(WSIZE-1 downto 0);
    dataOut: out std_logic_vector(WSIZE-1 downto 0);	 
    wr, rd: in std_logic;
    full, empty: buffer std_logic;
	 readptr_debug, writeptr_debug: out unsigned(FSIZE-1 downto 0)
    );
end entity MyFIFO;

architecture rtl of MyFIFO is
	type MyFIFO_buffer is array((2**FSIZE)-1 downto 0) of std_logic_vector(WSIZE-1 downto 0);
	signal MyFIFO: MyFIFO_buffer;	
begin
	process(clk, reset) is
		variable readptr, writeptr: unsigned(FSIZE-1 downto 0);
	begin
		if(reset = '1') then
			readptr := (others => '0');
			writeptr := (others => '0');
		elsif(rising_edge(clk)) then
			dataOut <= (others => 'Z');
			if(wr = '1' and full = '0') then
				MyFIFO(to_integer(unsigned(writeptr))) <= dataIn;
				writeptr := writeptr + 1;						
			end if;
			if(rd = '1' and empty='0') then
				dataOut <= MyFIFO(to_integer(unsigned(readptr)));
				readptr := readptr + 1;
			end if;
			if readptr = writeptr then
				empty <= '1';
			else
				empty <= '0';
			end if;
			if writeptr=readptr-1 then
				full <= '1';
			else
				full <= '0';
			end if;
		end if;
		readptr_debug <= readptr;
		writeptr_debug <= writeptr;
	end process;
end architecture rtl;
