library ieee;
use ieee.std_logic_1164.all; 

entity UART_tx is 
port ( 
	start: in std_logic;
	CLK: in std_logic;
	TX: out std_logic;
	reg_buffer : in std_logic_vector(7 downto 0)
);
end UART_tx;

architecture behav of UART_tx IS

	type STATE is (IDLE, START_BIT, DATA_BITS, STOP_BIT, TERMINATE);
	signal state_uart: STATE := IDLE;
	
begin
	process(CLK)
		variable cnt : integer range 0 to 10000 := 0;
		variable index : integer range 0 to 8 := 0;
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
					if(cnt >= 5208) then
						cnt := 0;
						index := 0; 
						state_uart <= DATA_BITS;
					end if;
					
			when DATA_BITS =>
					if(index >= 8) then
						index := 0;
						state_uart <= STOP_BIT;
					else
						TX <= reg_buffer(index);
						cnt:= cnt + 1;
						if(cnt >= 5208) then
							cnt := 0;
							index := index + 1; 
						end if;
					end if;
					
			when STOP_BIT =>
					TX <= '1';
					cnt := cnt + 1;
					if(cnt >= 5208) then
						cnt := 0;
						index := 0; 
						state_uart <= TERMINATE;
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