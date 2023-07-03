----------------- Convert data_inary to BCD -----------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CONV_DATA is
 port(
	data_in: in std_logic_vector(7 downto 0) := (others => '0'); -- 7 bits data from adc
	tens: out std_logic_vector(7 downto 0) := (others => '0');
	unit: out std_logic_vector(7 downto 0) := (others => '0')
 );
end CONV_DATA;

architecture converter of CONV_DATA is

begin
 process(data_in)
	variable i : integer range 0 to 8 := 0;
	variable bcd_temp : std_logic_vector(15 downto 0); -- 16 = 8bit(in)+ 4bit(tens) +4 bit(unit)
 begin
	bcd_temp := (others => '0');
	bcd_temp(7 downto 0) := data_in;
	for i in 0 to 7 loop  
		bcd_temp( 15 downto 0 ) := bcd_temp( 14 downto 0 )  & '0'; -- << 1
			
		if (i<7 and bcd_temp(11 downto 8) > "0100") then
			bcd_temp(11 downto 8) := bcd_temp(11 downto 8) + "0011";
		end if;
		 
		if (i<7 and bcd_temp(15 downto 12) > "0100") then 
			bcd_temp(15 downto 12) := bcd_temp(15 downto 12) + "0011";
		end if;	 
	end loop;

	tens <= (bcd_temp(15 downto 12)) + X"00";
	unit <= (bcd_temp(11 downto 8)) + X"00";
	
 end process;
 
end converter;
