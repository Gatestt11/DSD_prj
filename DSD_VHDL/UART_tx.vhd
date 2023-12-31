library ieee;
use ieee.std_logic_1164.all; 
USE ieee.numeric_std.ALL;

entity UART_tx is 
port ( 
	start: in std_logic;
	CLK: in std_logic;
	TX: out std_logic;
	tram1 : in integer range 0 to 9 :=0;
	chuc1 : in integer range 0 to 9 :=0;
	dv1 : in integer range 0 to 9 :=0
);
end UART_tx;

architecture behav of UART_tx IS

	type STATE is (IDLE, START_BIT, DATA_BITS, STOP_BIT, TERMINATE);
	signal state_uart: STATE := IDLE;
	signal reg_buffer0 : std_logic_vector(7 downto 0);
	signal reg_buffer1 : std_logic_vector(7 downto 0);
	signal reg_buffer2 : std_logic_vector(7 downto 0);
	signal reg_buffer3 : std_logic_vector(7 downto 0);
	signal reg_buffer4 : std_logic_vector(7 downto 0);
	signal reg_buffer5 : std_logic_vector(7 downto 0);

	
begin
	reg_buffer0 <= "0011"& std_logic_vector(to_unsigned(tram1,4));
	reg_buffer1 <= "0011"& std_logic_vector(to_unsigned(chuc1,4));
	reg_buffer2 <= "0011"& std_logic_vector(to_unsigned(dv1,4));
	reg_buffer3 <= x"6F";
	reg_buffer4 <= x"43";
	reg_buffer5 <= x"20";
	process(CLK)
		variable cnt : integer range 0 to 10000 := 0;
		variable index : integer range 0 to 8 := 0;
		variable temp : integer range 0 to 5 := 0;
	begin
	if(rising_edge(clk)) then
		case state_uart is
			when IDLE => 
					cnt := 0;
					TX <= '1';
					if(start = '0') then
						state_uart <= START_BIT;
					end if;
					
			when START_BIT =>
					TX <= '0';
					cnt := cnt + 1;
					if(cnt >= 434) then
						cnt := 0;
						index := 0; 
						state_uart <= DATA_BITS;
					end if;
					
			when DATA_BITS =>
					if(index >= 8) then
						index := 0;
						state_uart <= STOP_BIT;
					else
						if(temp = 0) then
						TX <= reg_buffer0(index);
						cnt:= cnt + 1;
						if(cnt >= 433) then
							cnt := 0;
							index := index + 1; 
						end if;
						elsif(temp = 1) then
						TX <= reg_buffer1(index);
						cnt:= cnt + 1;
						if(cnt >= 433) then
							cnt := 0;
							index := index + 1; 
						end if;
						
						elsif(temp = 2) then
						TX <= reg_buffer2(index);
						cnt:= cnt + 1;
						if(cnt >= 433) then
							cnt := 0;
							index := index + 1; 
						end if;
						
						elsif(temp = 3) then
						TX <= reg_buffer3(index);
						cnt:= cnt + 1;
						if(cnt >= 433) then
							cnt := 0;
							index := index + 1; 
						end if;
						
						elsif(temp = 4) then
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
			when STOP_BIT =>
					TX <= '1';
					cnt := cnt + 1;
					if(cnt >= 433) then
						cnt := 0;
						index := 0; 
						if(temp = 0 or temp = 1 or temp = 2 or temp = 3 or temp = 4) then
						--
						state_uart <= START_BIT;
						temp := temp + 1;
						else
						temp := 0;
						state_uart <= TERMINATE;
						end if;
					end if;
					
			when TERMINATE =>
					TX <= '1';
					if(start = '1') then
						state_uart <= IDLE;
					end if;	
		end case;
	end if;
	end process;
	
end behav;