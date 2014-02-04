-- An adjustable clock divider
-- Jean-Paul Buu-Sao --

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity clk_div is
	port( clk, reset: in std_logic; mode: in std_logic_vector(2 downto 0); q: out std_logic);
end clk_div;

architecture a of clk_div is
	signal div10_count, div50_count: std_logic_vector(2 downto 0); 
	signal div4_count: std_logic_vector(1 downto 0); 
	signal div2_int, div4_int, div10_int, div50_int: std_logic; 
begin
	process(clk, reset)
	begin
		if(reset = '1') then
			div10_count <= "000";
			div50_count <= "000";
			div4_count <= "00";
			div2_int <= '0';
			div4_int <= '0';
			div10_int <= '0';
			div50_int <= '0';
		elsif rising_edge(clk) then
			div2_int <= not div2_int;
			div4_int <= div4_count(1);
			div4_count <= div4_count + 1;
			if div10_count < (5-1) then
				div10_count <= div10_count + 1;
			else
				div10_count <= "000";
				div10_int <= not div10_int;
				if div50_count < (5-1) then
					div50_count <= div50_count + 1;
					else
						div50_count <= "000";
						div50_int <= not div50_int;
					end if;				
			end if;
		end if;
	end process;
	
	q <= div2_int when mode = "001" else
		div4_int when mode = "010" else
		div10_int when mode = "011" else
		div50_int when mode = "100" else
		clk;
end a;