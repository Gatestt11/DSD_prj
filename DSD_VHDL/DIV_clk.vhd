library ieee;
use ieee.std_logic_1164.all;
LiBRARY std; 
USE std.standard.all;
LIBRARY work;
USE work.all;

entity DIV_clk is
port(
	clk_in: IN STD_LOGIC;
	clk_out: OUT STD_LOGIC
);
end DIV_clk;

architecture LogicFunction of DIV_clk is
	signal temp: STD_LOGIC := '0';
begin	
	process(clk_in)
		variable cnt : integer range 0 to 130 := 0;
		
	begin
		if(rising_edge(clk_in)) then
			cnt := cnt + 1;
			if(cnt >= 125) then	-- tan so 200KHz
				temp <= not temp;
				cnt := 0;
			end if;
		end if;
	end process;
	clk_out <= temp;
	
end LogicFunction;
