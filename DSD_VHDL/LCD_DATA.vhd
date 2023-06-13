library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.std_logic_arith.all;

entity LCD_DATA is 
port (
	data : in  std_logic_vector(7 downto 0);
	start_alarm : in  std_logic;
	line1_buffer : out std_logic_vector(127 downto 0);
	line2_buffer : out std_logic_vector(127 downto 0)
);
end LCD_DATA ;

architecture bhv_data of LCD_DATA IS

signal data_integer,data_temp : integer := 0 ;
signal chuc1,dv1 : integer range 0 to 9 :=0;

begin
--convert data---------------------
	line1_buffer(127 downto 24) <=x"4C4F414920313A202020202020";
	line2_buffer(127 downto 24) <=x"4C4F414920323A202020202020";
	--data_us <= unsigned(data);
	--data_integer <= to_integer(data_us);
	data_temp <= data_integer/256;
	chuc1 <= data_temp / 10;
	dv1 <= data_temp - chuc1;
	process(start_alarm,data)
	begin
	if(start_alarm = '0') then
		line2_buffer(23 downto 16) <= "0011"& CONV_STD_LOGIC_VECTOR(chuc1,4);
		line2_buffer(15 downto 8) <= "0011"& CONV_STD_LOGIC_VECTOR(dv1,4);
	else 
		line2_buffer(23 downto 16) <= "0011"& CONV_STD_LOGIC_VECTOR(chuc1,4);
		line2_buffer(15 downto 8) <= "0011"& CONV_STD_LOGIC_VECTOR(dv1,4);
		line2_buffer (7 downto 0) <= "0011"&"0010";
	end if;
	end process;
end bhv_data;