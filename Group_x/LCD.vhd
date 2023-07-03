---- DISPLAY TO LCD-----

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity LCD is
port(
	clk : in std_logic; --system cloc k
	----- d = tensunitd0
	tens: in std_logic_vector(7 downto 0) := (others => '0');
	unit: in std_logic_vector(7 downto 0) := (others => '0');
	lcd_rw, lcd_rs, lcd_en : out std_logic := '0'; --read/write, setup/data, and enable for lcd
	data_to_display : out std_logic_vector(7 downto 0) := x"00" --data signals for lcd
	);
end LCD;
architecture controller of LCD is
	--state machine 
	type lcd_sm is(lcd_power_up, lcd_init, lcd_display);
	signal state : lcd_sm := lcd_power_up;

	type lcd_cmd_array is array (integer range 0 to 4) of std_logic_vector(7 downto 0);
	constant lcd_cmd: lcd_cmd_array := (
												0	=>	x"38",	--function set
												1	=>	x"0c",	--display on/off control
												2	=>	x"01",	--clear display
												3	=>	x"06",	--entry mode set
												4	=>	x"80"		--set ddram address
												);
	type lcd_data_array is array (0 to 15) of std_logic_vector( 7 downto 0 );
	signal data_display : lcd_data_array := (x"44",x"49",x"53",x"54",x"41",x"4e",x"43",x"45",x"3a",x"20",x"43",x"43",x"43",x"20",x"43",x"4d"); --distance: tensunitd0 cm----
												
	signal ptr: integer range 0 to 15 := 0;
	signal clk_count : integer range 0 to 2500000:= 0; --event counter for timing
begin
	data_display(10) <= tens + x"30";
	data_display(11) <= unit + x"30";
	lcd_rw <= '0';
	process(clk)	
	begin
	if (rising_edge(clk)) then
		case state is
		when lcd_power_up =>
			if(clk_count < 1250000) then --wait 25 ms
				clk_count <= clk_count + 1;
				state <= lcd_power_up;
			else --power-up complete
				clk_count <= 0;
				state <= lcd_init;
			end if;
		when lcd_init =>
			lcd_rs <= '0';
			data_to_display <= lcd_cmd(ptr);
			clk_count <= clk_count + 1;
			if(clk_count = 10)	then lcd_en <= '1';
			elsif(clk_count = 30)	then lcd_en <= '0';
			elsif(clk_count = 164000)	then clk_count <= 0;
				if ptr = 4 then	
					state <= lcd_display;
					ptr <= 0;
				else					
					ptr <= ptr + 1;
				end if;
			end if;
		when lcd_display =>	
			lcd_rs <= '1';
			clk_count <= clk_count + 1;
			data_to_display <= data_display(ptr);
			if(clk_count = 10)	then lcd_en <= '1';
			elsif(clk_count = 30)	then lcd_en <= '0';
			elsif(clk_count = 2000)	then clk_count <= 0;
				if ptr = 15 then	
					state <= lcd_init;
					ptr <= 4;
				else					
					ptr <= ptr + 1;
				end if;
			end if;
	end case;
	end if;
	end process;
end controller;
 
