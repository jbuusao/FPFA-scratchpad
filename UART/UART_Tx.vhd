-- UART Transmitter unit
-- Jean-Paul Buu-Sao --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Tx is 
	
  generic (M: integer := 14);
  port (
    clk, reset, baudtick: in  std_logic;
    wdata: in std_logic_vector(7 downto 0);
    divisor: in unsigned(M-1 downto 0);
	 set: in std_logic;
    wr: in std_logic;
	 busy: buffer std_logic;
	 bTick: out std_logic;
	 Tx: out std_logic
    );
end entity UART_Tx;

architecture rtl of UART_Tx is
	signal baudCount: unsigned(2 downto 0);
	signal dataOut : std_logic_vector(7 downto 0);
	signal rd, empty, fifo_full: std_logic;
	type state_t is (idle, start, data0, data1, data2, data3, data4, data5, data6, data7, stop);
	signal state, state_next: state_t;
	signal btick_reg, btick_next: std_logic;
	signal wdata_reg: std_logic_vector(7 downto 0);
	signal tcount, tcount_next: unsigned(M-1 downto 0);
	signal divisor_reg, divisor_next: unsigned(M-1 downto 0);
begin
	
	-- Register: REG = NEXT
	process(clk, reset)
	begin
		if(reset = '1') then
			state <= idle;
			tcount <= (others => '0');
			btick_reg <= '0';
			divisor_reg <= "00000000010000";
		elsif rising_edge(clk) then
			state <= state_next;
			tcount <= tcount_next;
			btick_reg <= btick_next;
			divisor_reg <= divisor_next;
			if(wr = '1') then
				wdata_reg <= wdata;
			end if;
		end if;
	end process;
	
	-- Next state: NEXT = f(REG, wr)
	process(state, wr, baudTick, tcount, wdata_reg, divisor, set)
		variable bitIndex: integer range 7 downto 0;
	begin
		-- Default
		Tx <= '1';
		state_next <= state;
		tcount_next <= tcount;
		btick_next <= '0';
		divisor_next <= divisor_reg;
		if(set='1') then
			divisor_next <= divisor;
		else
			divisor_next <= divisor_reg;
		end if;
		-- Now determine the next state
		case state is
			when idle =>
				if(wr = '1' and not busy = '1') then
					state_next <= start;
				end if;
			when start =>
					Tx <= '0';
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							btick_next <= '1';
							state_next <= data0;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data0 =>
					Tx <= wdata_reg(0);
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							btick_next <= '1';
							state_next <= data1;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data1 =>
					Tx <= wdata_reg(1);
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							btick_next <= '1';
							state_next <= data2;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data2 =>
					Tx <= wdata_reg(2);
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							btick_next <= '1';
							state_next <= data3;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data3 =>
					Tx <= wdata_reg(3);
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							btick_next <= '1';
							state_next <= data4;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data4 =>
					Tx <= wdata_reg(4);
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							state_next <= data5;
							btick_next <= '1';
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data5 =>
					Tx <= wdata_reg(5);
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							state_next <= data6;
							btick_next <= '1';
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data6 =>
					Tx <= wdata_reg(6);
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							btick_next <= '1';
							state_next <= data7;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when data7 =>
					Tx <= wdata_reg(7);
					if(baudTick = '1') then
						if(tcount = divisor_reg) then
							btick_next <= '1';
							state_next <= stop;
							tcount_next <= (others => '0');
						else
							tcount_next <= tcount + 1;
						end if;
					end if;
			when stop =>
					Tx <= '1';
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

	busy <= '0' when state = idle else '1';
	bTick <= btick_reg;
	
end architecture rtl;
