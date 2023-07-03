library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

LiBRARY std; 
USE std.standard.all; 

entity ADC is
port(
	 clk_in : in std_LOGIC;
	 clk_adc : out std_logic;
	 wr : out std_logic := '1'; --start convert analog to digital 1->0 for start	
	 rd : out std_logic := '1'; --1--> 0 for data to D0-D7
	 data_adc: in std_logic_vector (7 downto 0);  --data
	 intr: in std_LOGIC := '1';  -- if the conversion is done, it 1-->0
	 start_tx : out std_logic  -- for transmit data to computer
 );
end ADC;

architecture behav of ADC is
	signal flag : std_logic;
	signal temp : std_logic := '0';
	signal clk : std_logic;
begin	
	process(clk_in)
		variable cnt : integer range 0 to 101 := 0;
		
	begin
		if(rising_edge(clk_in)) then
			cnt := cnt + 1;
			if(cnt >= 100) then	-- tan so 250KHz
				temp <= not temp;
				cnt := 0;
			end if;
		end if;
	end process;
	clk <= temp;
	process(clk)
		variable cnt: integer range 0 to 500001 := 0;
	begin
	CLK_adc <= clk;
		if(rising_edge(clk)) then
			cnt := cnt +1;
			if(cnt = 1) then 	
				wr <='0';		
			end if;
			
			if(cnt = 3) then	
				wr <= '1';		
				flag <= '1';
			end if;
			
			if((cnt > 3) and (intr = '0') and (flag = '1')) then
				
				rd <= '0';	
				start_tx <= '1';		-- start TX
				flag <= '0';
			
			end if;
			
			
			if(cnt >= 500000) then		-- cycle time to recives data
				rd <= '1';	
				start_tx <= '0';
				cnt:= 0;
			end if;
			
		end if;
	end process;
end behav;