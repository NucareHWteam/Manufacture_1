----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:25:42 10/31/2019 
-- Design Name: 
-- Module Name:    SCA_Module - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
Library XilinxCoreLib;
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use UNISIM.VComponents.all;

entity SCA_Module is
port(
	clk: in std_logic;	
	rst: in std_logic;
	acq_start: IN std_logic;	
    Ch_all : out std_logic_vector(31 downto 0);   
	flag_acq_in : in std_logic;
	flag_CH : in std_logic
	);	

end SCA_Module;

architecture Behavioral of SCA_Module is

	COMPONENT clk_100ms
	PORT(
		clk : IN std_logic;
		ACQ_Start : in std_logic;	
		clk_100ms : OUT std_logic
		);
	END COMPONENT;

signal clk_100ms_1 : std_logic:='0';
signal sum_ch_0 : std_logic_vector(31 downto 0):= (others => '0');   
signal sum_ch_1 : std_logic_vector(15 downto 0):= (others => '0');   
signal sum_ch_2 : std_logic_vector(15 downto 0):= (others => '0');   
signal sum_ch_3 : std_logic_vector(15 downto 0):= (others => '0');   
signal sum_ch_4 : std_logic_vector(15 downto 0):= (others => '0');   
signal sum_ch_5 : std_logic_vector(15 downto 0):= (others => '0');   
signal sum_ch_6 : std_logic_vector(15 downto 0):= (others => '0');   
signal sum_ch_7 : std_logic_vector(15 downto 0):= (others => '0');   


signal i_clk_100ms_1 : std_logic_vector(1 downto 0):= (others => '0'); 
signal i_flag_CH  : std_logic_vector(1 downto 0):= (others => '0'); 
signal i_flag_CH_1  : std_logic_vector(1 downto 0):= (others => '0'); 
signal i_flag_CH_2  : std_logic_vector(1 downto 0):= (others => '0'); 
signal i_flag_CH_3  : std_logic_vector(1 downto 0):= (others => '0'); 
signal flag_sum_count : std_logic_vector(2 downto 0):= (others => '0'); 

signal sum_count  : std_logic_vector(1 downto 0):= (others => '0'); 

signal flag_acq_sum : std_logic:='0';

begin


process(acq_start,clk)
begin
	if acq_start = '0'  then
		i_flag_CH <=(others => '0'); 

		flag_acq_sum <= '0';
		flag_sum_count<="000";
		Ch_all <=(others => '0');

	elsif rising_edge(clk) then
	
			i_clk_100ms_1( 0 ) <= flag_acq_in ;
			i_clk_100ms_1( 1 ) <= i_clk_100ms_1( 0 );	


			i_flag_CH( 0 ) <= flag_CH;
			i_flag_CH( 1 ) <= i_flag_CH( 0 );				
			



		if i_clk_100ms_1( 0 ) > i_clk_100ms_1( 1 ) then
		
				
				sum_count<="00";
				
				sum_ch_0 <=(others => '0'); 
		

 			
		else
			if i_flag_CH( 0 ) < i_flag_CH( 1 ) then
				sum_ch_0<=sum_ch_0+1;
				Ch_all <=sum_ch_0;
			end if;
			
		
		end if;
		
	end if;
	
end process;
end Behavioral;

