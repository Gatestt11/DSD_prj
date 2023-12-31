-------------------------------------------
-----PRJ_DSD-------------------------------
-------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 

entity PRJ_DSD is 

port ( 
	--
   clk         : IN    STD_LOGIC;  --system clock
	--for uart
	start_TX		: IN    STD_LOGIC;  --start transmit data
	TX          : OUT    STD_LOGIC;
	--for ADC
	start_ADC   : OUT    STD_LOGIC;  --start ADC_0808
	ale   : OUT    STD_LOGIC;
	oe 	: OUT    STD_LOGIC;
	data_adc_in: IN std_logic_vector (7 downto 0);
	eoc	: IN std_LOGIC;
	clk_adc :  OUT    STD_LOGIC;
	--for warring alarm
	--start_alarm_light : OUT std_LOGIC;
	led_warring : out std_LOGIC_VECTOR(17 downto 0);
	led_bin : out std_LOGIC_VECTOR (7 downto 0);
	--for LCD
	 tt : out std_LOGIC;
	 tt2 : out std_LOGIC;
    reset_n    : IN    STD_LOGIC;  --active low reinitializes lcd
    rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
    lcd_data_x   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0) --data signals for lcd
);
end PRJ_DSD;

architecture behav of PRJ_DSD IS
	 signal line1_buffer :  STD_LOGIC_VECTOR(127 downto 0); -- Data for the top line of the LCD
	 signal line2_buffer :  STD_LOGIC_VECTOR(127 downto 0); -- Data for the bottom line of the LCD
	 signal start_alarm : STD_LOGIC;
	 signal CLK_200 : STD_LOGIC;
	 signal START_TX_2 : STD_LOGIC;
	 signal tram1,chuc1,dv1 : integer range 0 to 9 :=0;
	 
-----COMPONENT LCD CONTROLLER-------------------------------------
component LCD_CT IS
  PORT(
    clk        : IN    STD_LOGIC;  --system clock
    reset_n    : IN    STD_LOGIC;  --active low reinitializes lcd
    rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
    lcd_data_x   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0); --data signals for lcd
	 line1_buffer : IN STD_LOGIC_VECTOR(127 downto 	0); -- Data for the top line of the LCD
	 line2_buffer : IN STD_LOGIC_VECTOR(127 downto 0)); -- Data for the bottom line of the LCD
	END component;
-----COMPONENT LCD DATA -------------------------------------------
component LCD_DATA is 
port (
	data : in  std_logic_vector(7 downto 0);
	start_alarm : in  std_logic;
	line1_buffer : out std_logic_vector(127 downto 0);
	line2_buffer : out std_logic_vector(127 downto 0);
	tram1 : out integer range 0 to 9 :=0;
	chuc1 : out integer range 0 to 9 :=0;
	dv1 : out integer range 0 to 9 :=0
);
END component;
-----COMPONENT ADC_0808 -------------------------------------------
component ADC_0808 is
port(
	 clk : in std_LOGIC;
	 start : out std_logic;
	 ale : out std_logic;
	 oe : out std_logic;
	 data_adc_in: in std_logic_vector (7 downto 0);
	 eoc: in std_LOGIC;
	 start_tx : out std_logic;
	 start_alarm : out std_logic
 );
end component;
-----COMPONENT UART_tx -------------------------------------------
component UART_tx is 
port ( 
	start: in std_logic;
	CLK: in std_logic;
	TX: out std_logic;
	tram1 : in integer range 0 to 9 :=0;
	chuc1 : in integer range 0 to 9 :=0;
	dv1 : in integer range 0 to 9 :=0
);
end component;
-----COMPONENT DIV_clk -------------------------------------------
component DIV_clk is
port(
	clk_in: IN STD_LOGIC;
	clk_out: OUT STD_LOGIC
);
end component;
	
begin
	tt <= '1';
	tt2 <= '1';
	clk_adc <= clk_200;
-----PORT MAP-----------------------------------------------------
	LCD_CT_PORTMAP : LCD_CT
		port map (clk,reset_n,rw,rs,e,lcd_data_x,line1_buffer,line2_buffer);
		
	LCD_CONVERT_DATA : LCD_DATA
		port map (data_adc_in, start_alarm,line1_buffer,line2_buffer,tram1,chuc1,dv1);
		
	UART_PORTMAP : UART_tx
		port map (start_TX,CLK,TX,tram1,chuc1,dv1);
		
	ADC_PORTMAP : ADC_0808
		port map (CLK_200,start_ADC,ale,oe,data_adc_in,eoc,START_TX_2, start_alarm);
		
	DIV_CLK_PORTMAP : DIV_clk
		port map (CLK,CLK_200);
		
	--start_alarm_light <= start_alarm;
	led_bin <= data_adc_in;
	process(start_alarm)
	begin
	      IF(start_alarm = '1') THEN  
				led_warring <= "111111111111111111";
          ELSE       
				led_warring <= "000000000000000000";
          END IF;
	end process;
end behav;