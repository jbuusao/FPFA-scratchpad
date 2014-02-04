-- SenseBauds
-- UART Baudrate sensor unit

library IEEE;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
library work;
use work.Utils.all;

entity SenseBauds is
	generic(N: integer := 6; M: integer := 14);
  port (
    clk, reset, btick, Rx: in  std_logic;
	 done: out std_logic;
    rate: out unsigned(M-1 downto 0)
    );
end entity SenseBauds;

architecture rtl of SenseBauds is
	constant nine: unsigned(M-1 downto 0) := "00000000001001";
	type state_t is (waitStart, waitStop, finished);
	signal state, state_next: state_t;
	signal guard_reg, guard_next: unsigned(N-1 downto 0);
	signal count_reg, count_next: unsigned(M-1 downto 0);
	signal lastc_reg, lastc_next: unsigned(M-1 downto 0);
	signal done_reg, done_next: std_logic;
begin
	
	-- Register: REG = NEXT
	process(clk, reset)
	begin
		if(reset = '1') then
			state <= waitStart;
			count_reg <= (others => '0');
			lastc_reg <= (others => '0');
			guard_reg <= (others => '0');
			done_reg <= '0';
		elsif rising_edge(clk) then
			state <= state_next;
			count_reg <= count_next;
			lastc_reg <= lastc_next;
			guard_reg <= guard_next;
			done_reg <= done_next;
		end if;
	end process;
	
	-- Next state: NEXT = f(REG, rd)
	process(state, Rx, bTick, count_reg, done_reg, guard_reg, lastc_reg, guard_next)
	begin
		-- Default
		state_next <= state;
		guard_next <= guard_reg;
		count_next <= count_reg;
		lastc_next <= lastc_reg;
		done_next <= done_reg;
		
		-- Free running count
		if(bTick = '1') then
			count_next <= count_reg + 1;
		end if;
		-- Now determine the next state
		
		case state is
			when waitStart =>
				done_next <= '0';
				if(Rx = '0') then
					guard_next <= (others => '1');
					count_next <= (others => '0');
					state_next <= waitStop;
					done_next <= '0';
				end if;
			when waitStop =>
				if(Rx = '0') then
					if(bTick = '1') then
						lastc_next <= count_reg;
						guard_next <= (others => '1');
					end if;
				else
					if(bTick = '1') then
						guard_next <= guard_reg - 1;
						if(guard_next = 0) then
							state_next <= finished;
							done_next <= '1';
						end if;
					end if;
				end if;
			when finished =>
				state_next <= waitStart;
		end case;
	end process;

	rate <= divide(lastc_reg, nine);
	done <= done_reg;
	
end architecture rtl;
