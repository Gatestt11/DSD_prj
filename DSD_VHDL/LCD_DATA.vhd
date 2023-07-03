library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity LCD_DATA is 
port (
	data : in  std_logic_vector(7 downto 0);
	start_alarm : in  std_logic;
	line1_buffer : out std_logic_vector(127 downto 0);
	line2_buffer : out std_logic_vector(127 downto 0);
	chuc1 : out integer range 0 to 9 :=0;
	dv1 : out integer range 0 to 9 :=0
);
end LCD_DATA ;

architecture bhv_data of LCD_DATA IS

signal data_integer,data_temp : integer range 0 to 200 := 0 ;
signal temp_tram,temp_chuc,temp_dv : integer range 0 to 9 :=0;
signal signed_1 : signed(7 downto 0);

begin
--convert data---------------------
	line1_buffer(127 downto 0) <=x"7E2050524F4A4543542020445344207E";
	line2_buffer(127 downto 64) <=x"54656D7020203D20";
	line2_buffer(39 downto 24) <= x"6F43";

	data_integer <= to_integer(unsigned(data));
	data_temp <= data_integer*5*100/256 + 13;
	temp_tram <= data_temp/100;
	temp_chuc <= (data_temp - temp_tram*100)/10;
	chuc1 <= temp_chuc;
	temp_dv <= data_temp - temp_tram*100-temp_chuc*10;
	dv1 <= temp_dv;
	process(start_alarm,data)
	begin
	--line2_buffer(63 downto 56) <= "0010"&"0000";
	if(start_alarm = '0') then
		line2_buffer(63 downto 56) <= "0010"&"0000";
		line2_buffer(55 downto 48) <= "0011"& std_logic_vector(to_unsigned(temp_chuc,4));
		line2_buffer(47 downto 40) <= "0011"& std_logic_vector(to_unsigned(temp_dv,4));
		line2_buffer(23 downto 16) <= "0010"&"0000";
		line2_buffer(15 downto 8)  <= "0010"&"0000";
		line2_buffer (7 downto 0)  <= "0010"&"0000";
	else 
		line2_buffer(63 downto 56) <= "0011"& std_logic_vector(to_unsigned(1,4));
		line2_buffer(55 downto 48) <= "0011"& std_logic_vector(to_unsigned(temp_chuc,4));
		line2_buffer(47 downto 40) <= "0011"& std_logic_vector(to_unsigned(temp_dv,4));
		line2_buffer(23 downto 16) <= "0010"&"0001";
		line2_buffer(15 downto 8) <= "0010"&"0001";
		line2_buffer (7 downto 0) <= "0010"&"0001";
	end if;
	end process;
end bhv_data;