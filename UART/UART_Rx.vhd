-- UART Receiver unit
-- Jean-Paul Buu-Sao --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Rx is 
	generic(M: integer := 14);	
  port (
    clk, reset, baudtick: in  std_logic;
    wdata: out std_logic_vector(7 downto 0);
    divisor: in unsigned(M-1 downto 0);
	 set: in std_logic;
    ready: out std_logic;
	 busy: buffer std_logic;
	 bTick: out std_logic;
	 Rx: in std_logic;
	 Rx_out: out std_logic
    );
end entity UART_Rx;

architecture rtl of UART_Rx is
	signal dataOut : std_logic_vector(7 downto 0);
	signal rd, empty, fifo_full: std_logic;
	type state_t is (idle, start, data0, data1, data2, data3, data4, data5, data6, data7, stop);
	signal state, state_next: state_t;
	signal btick_reg, btick_next: std_logic;
	signal wdata_reg, wdata_next: std_logic_vector(7 downto 0);
	signal tcount, tcount_next: unsigned(7 downto 0);
	signal divisor_reg, divisor_next: unsigned(M-1 downto 0);
begin
	
	-- Register: REG = NEXT
	process(clk, reset)
	begin
		if(reset = '1') then
			state <= idle;
			tcount <= (others => '0');
			btick_reg <= '0';
			wdata_reg <= (others => '0');
			divisor_reg <= "00000000010000";
		elsif rising_edge(clk) then
			state <= state_next;
			tcount <= tcount_next;
			btick_reg <= btick_next;
			wdata_reg <= wdata_next;
			divisor_reg <= divisor_next;
		end if;
	end process;
	
	
	process(state, Rx, rd, baudTick, tcount, wdata_reg, divisor_reg, divisor, set)
	begin
		-- Default
		state_next <= state;
		tcount_next <= tcount;
		wdata_next <= wdata_reg;
		btick_next <= '0';
		if(set='1') then
			divisor_next <= divisor;
		else
			divisor_next <= divisor_reg;
		end if;
		-- Now determine the next state
		case state is
			when idle =>
				if(Rx = '0') then
					state_next <= start;
					wdata_next <= (others => '0');
				end if;
			when start =>
					if(baudTick = '1') then
						if(tcount = '0' & divisor_reg(7 downto 1)) then
							btick_next <= '1';
							state_next <= data0;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data0 =>
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							wdata_next <= Rx & wdata_reg(7 downto 1);
							btick_next <= '1';
							state_next <= data1;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data1 =>
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							wdata_next <= Rx & wdata_reg(7 downto 1);
							btick_next <= '1';
							state_next <= data2;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data2 =>
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							wdata_next <= Rx & wdata_reg(7 downto 1);
							btick_next <= '1';
							state_next <= data3;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data3 =>
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							wdata_next <= Rx & wdata_reg(7 downto 1);
							btick_next <= '1';
							state_next <= data4;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data4 =>
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							wdata_next <= Rx & wdata_reg(7 downto 1);
							btick_next <= '1';
							state_next <= data5;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data5 =>
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							wdata_next <= Rx & wdata_reg(7 downto 1);
							btick_next <= '1';
							state_next <= data6;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data6 =>
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							wdata_next <= Rx & wdata_reg(7 downto 1);
							btick_next <= '1';
							state_next <= data7;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data7 =>
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							wdata_next <= Rx & wdata_reg(7 downto 1);
							btick_next <= '1';
							state_next <= stop;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when stop =>
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							state_next <= idle;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
		end case;
	end process;

	Rx_out <= Rx;
	wdata <= wdata_reg;
	ready <= '1' when state = stop else '0';
	busy <= '0' when state = idle else '1';
	bTick <= btick_reg;
	
end architecture rtl;
