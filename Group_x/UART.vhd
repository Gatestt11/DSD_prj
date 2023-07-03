library ieee;
use ieee.std_logic_1164.all; 
USE ieee.numeric_std.ALL;

entity UART is 
port ( 
	start_tx: in std_logic;
	CLK: in std_logic;
	TX: out std_logic;
	tens: in std_logic_vector(7 downto 0) := (others => '0');
	unit: in std_logic_vector(7 downto 0) := (others => '0')
);
end UART;

architecture behav of UART IS

	type STATE is (INIT, bit_start, bit_data, bit_stop, stop_ok);
	signal state_uart: STATE := INIT;
	signal reg_buffer1 : std_logic_vector(7 downto 0);
	signal reg_buffer2 : std_logic_vector(7 downto 0);
	signal reg_buffer3 : std_logic_vector(7 downto 0);
	signal reg_buffer4 : std_logic_vector(7 downto 0);
	signal reg_buffer5 : std_logic_vector(7 downto 0);

	
begin
	reg_buffer1 <= std_logic_vector(unsigned(tens));
	reg_buffer2 <= std_logic_vector(unsigned(unit));
	reg_buffer3 <= x"6F";
	reg_buffer4 <= x"43";
	reg_buffer5 <= x"20";
	process(CLK)
		variable cnt : integer range 0 to 10000 := 0;
		variable index : integer range 0 to 8 := 0;
		variable temp : integer range 0 to 4 := 0;
	begin
	if(rising_edge(clk)) then
		case state_uart is
			when INIT => 
					cnt := 0;
					TX <= '1';
					if(start_tx = '0') then
						state_uart <= bit_start;
					end if;
					
			when bit_start =>
					TX <= '0';
					cnt := cnt + 1;
					if(cnt >= 433) then
						cnt := 0;
						index := 0; 
						state_uart <= bit_data;
					end if;
					
			when bit_data =>
					if(index >= 8) then
						index := 0;
						state_uart <= bit_stop;
					else
						if(temp = 0) then
						TX <= reg_buffer1(index);
						cnt:= cnt + 1;
						if(cnt >= 433) then
							cnt := 0;
							index := index + 1; 
						end if;
						
						elsif(temp = 1) then
						TX <= reg_buffer2(index);
						cnt:= cnt + 1;
						if(cnt >= 433) then
							cnt := 0;
							index := index + 1; 
						end if;
						
						elsif(temp = 2) then
						TX <= reg_buffer3(index);
						cnt:= cnt + 1;
						if(cnt >= 433) then
							cnt := 0;
							index := index + 1; 
						end if;
						
						elsif(temp = 3) then
						TX <= reg_buffer4(index);
						cnt:= cnt + 1;
						if(cnt >= 433) then
							cnt := 0;
							index := index + 1; 
						end if;
						
						else
						TX <= reg_buffer5(index);
						cnt:= cnt + 1;
						if(cnt >= 433) then
							cnt := 0;
							index := index + 1; 
						end if;
						
						end if;
					end if;
			when bit_stop =>
					TX <= '1';
					cnt := cnt + 1;
					if(cnt >= 433) then
						cnt := 0;
						index := 0; 
						if(temp = 0 or temp = 1 or temp = 2 or temp = 3) then
						--
						state_uart <= bit_start;
						temp := temp + 1;
						else
						temp := 0;
						state_uart <= stop_ok;
						end if;
					end if;
					
			when stop_ok =>
					TX <= '1';
					if(start_tx = '1') then
						state_uart <= INIT;
					end if;	
		end case;
	end if;
	end process;
	
end behav;