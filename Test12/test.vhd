----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2019/03/05 16:58:42
-- Design Name: 
-- Module Name: Main_VHDL - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
--Library XilinxCoreLib;
--library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
	use UNISIM.vcomponents.all;
library xil_defaultlib;
    use xil_defaultlib.all;



entity Main_VHDL is
port(
clk : in std_logic;

w_TX_SERIAL : out std_logic;
r_RX_SERIAL : in std_logic;
r_RX_SERIAL_Bat : in std_logic;
--w_TX_SERIAL_Bat : out std_logic:='1';

 clk_ADC_p : out std_logic;
 
 ADC_CLK_OUT_P : out std_logic;
 ADC_CLK_OUT_N : out std_logic;
-- clk_ADC_n : out std_logic;
ADC_ORT : in std_logic; 
ADC_value : in std_logic_vector(11 downto 0); 
 
sclk :  out std_logic;
cs_n :   out std_logic_vector(0 downto 0);
mosi :  out std_logic;


sclk_2 :  out std_logic;
cs_n_2 :   out std_logic_vector(0 downto 0);
mosi_2 :  out std_logic;
--miso_2 :  in std_logic;
led_green  : out std_logic;
led_blue   : out std_logic;
led_red    : out std_logic;

adc_sda    : inout std_logic;
adc_scl    : inout std_logic;

m_dout  : out std_logic_vector(7 downto 0);

Neutron_Domino : in std_logic;

cpu_detect :  in std_logic;
cpu_phold  : out std_logic:='0';

--test1  : out std_logic:='0';
--test2  : in std_logic;
fpga_awake  : out std_logic;
Pin_Trig_signal : in std_logic; 

eeprom_cs_n : out std_logic;
eeprom_sclk : out std_logic;
eeprom_miso : in std_logic;
eeprom_mosi : out std_logic;
HV_Enable : out std_logic;
Adc_sleep : out std_logic;


VAUXP : in std_logic_vector(3 downto 0);
VAUXN : in std_logic_vector(3 downto 0)


--ADC_CS : out std_logic;
--ADC_Data : out std_logic;


);

end Main_VHDL;
