library ieee;
use ieee.std_logic_1164.all; 

entity Main is 

port ( 
   clk         : IN    STD_LOGIC;  --system clock
	--for uart
	TX          : OUT    STD_LOGIC;
	--for ADC
	 wr : out std_logic := '1'; --start convert analog to digital 1->0 for start	
	 rd : out std_logic := '1'; --1--> 0 for data to D0-D7
	 data_adc: in std_logic_vector (7 downto 0);  --data
	 intr: in std_LOGIC := '1';  -- if the conversion is done, it 1-->0
	 clk_adc: out std_logic;
	--for LCD
	lcd_rw, lcd_rs, lcd_en : out std_logic := '0'; --read/write, setup/data, and enable for lcd
	data_to_display : out std_logic_vector(7 downto 0) := x"00" --data signals for lcd
);
end Main;

architecture behav of Main IS

	 signal start_tx : std_logic;
	 signal tens: std_logic_vector(7 downto 0);
	 signal unit: std_logic_vector(7 downto 0);
	 
-----COMPONENT LCD-------------------------------------
component LCD is
port(
	clk : in std_logic; --system cloc k
	tens: in std_logic_vector(7 downto 0) := (others => '0');
	unit: in std_logic_vector(7 downto 0) := (others => '0');
	lcd_rw, lcd_rs, lcd_en : out std_logic := '0'; --read/write, setup/data, and enable for lcd
	data_to_display : out std_logic_vector(7 downto 0) := x"00" --data signals for lcd
	);
	END component;
-----COMPONENT DATA -------------------------------------------
component CONV_DATA is
 port(
	data_in: in std_logic_vector(7 downto 0) := (others => '0'); -- 7 bits data from adc
	tens: out std_logic_vector(7 downto 0) := (others => '0');
	unit: out std_logic_vector(7 downto 0) := (others => '0')
 );
END component;
-----COMPONENT ADC-------------------------------------------
component ADC is
port(
	 clk_in : in std_LOGIC;
	 clk_adc : out std_logic;
	 wr : out std_logic := '1'; --start convert analog to digital 1->0 for start	
	 rd : out std_logic := '1'; --1--> 0 for data to D0-D7
	 data_adc: in std_logic_vector (7 downto 0);  --data
	 intr: in std_LOGIC := '1';  -- if the conversion is done, it 1-->0
	 start_tx : out std_logic  -- for transmit data to computer
 );
end component;
-----COMPONENT UART -------------------------------------------
component UART is 
port ( 
	start_tx: in std_logic;
	CLK: in std_logic;
	TX: out std_logic;
	tens: in std_logic_vector(7 downto 0) := (others => '0');
	unit: in std_logic_vector(7 downto 0) := (others => '0')
);
end component;
begin
		LCD_PORTMAP : LCD
			port map (clk,tens,unit,lcd_rw,lcd_rs,lcd_en,data_to_display);
		CONVERSION_DATA : CONV_DATA
			port map (data_adc,tens, unit);
		ADC_PORTMAP: ADC
			port map (clk,clk_adc,wr,rd,data_adc,intr,start_tx);
		UART_PORTMAP : UART
			port map (start_tx,clk,TX,tens,unit);
end behav;