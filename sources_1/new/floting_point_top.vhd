----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/06/01 14:24:10
-- Design Name: 
-- Module Name: floating_point_top - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity floating_point_top is
  Port ( 
        rst : in std_logic;
        clk : in std_logic;    
        acq_start : in std_logic;
        Ch_temp_t1 : in STD_LOGIC_VECTOR ( 23 downto 0 );
        Ch_temp_t2 : in STD_LOGIC_VECTOR ( 23 downto 0 );
        K40_Pre_GC : in std_logic_vector(16 -1 downto 0);
        GC_Cal_out : out std_logic_vector( 16 - 1 downto 0);
        Compare_rdy : in std_logic);
end floating_point_top;

architecture Behavioral of floating_point_top is

Component PSD_temp_equation is
 Port ( 
        clk : in std_logic;    
        acq_start : in std_logic;
        Ch_temp : in STD_LOGIC_VECTOR ( 23 downto 0 );
        Compare_rdy : in std_logic;
        PSD_T_result_out : out STD_LOGIC_VECTOR ( 31 downto 0 ));
end Component;


--signal Ch_temp_t1_t : STD_LOGIC_VECTOR ( 23 downto 0 ):=X"00046B";
--signal K40_Pre_GC_t :  std_logic_vector(16 -1 downto 0):=X"84d0";


signal Ch_temp_t1_result : STD_LOGIC_VECTOR ( 31 downto 0 );
signal Ch_temp_t2_result : STD_LOGIC_VECTOR ( 31 downto 0 );


Component PSD_temp_subtraction is
  Port  (
        clk : in std_logic;    
        acq_start : in std_logic;
        K40_Pre_GC : in std_logic_vector(16 -1 downto 0);
        Ch_temp1 : in STD_LOGIC_VECTOR (31 downto 0 );
        Ch_temp2 : in STD_LOGIC_VECTOR (31 downto 0 );
        
        GC_Cal_out : out std_logic_vector(16 - 1 downto 0);
        Compare_rdy : in std_logic);
end Component;

attribute mark_debug : string;
    attribute mark_debug of Ch_temp_t1 : signal is "true";
    attribute mark_debug of K40_Pre_GC : signal is "true";

begin


inst_PSD_temp_equation_t1: PSD_temp_equation 
 Port map ( 
        clk => clk,   
        acq_start => acq_start,
        Ch_temp => Ch_temp_t1,
        Compare_rdy => Compare_rdy,
        PSD_T_result_out => Ch_temp_t1_result);

inst_PSD_temp_equation_t2: PSD_temp_equation 
 Port map ( 
        clk => clk,   
        acq_start => acq_start,
        Ch_temp => Ch_temp_t2,
        Compare_rdy => Compare_rdy,
        PSD_T_result_out => Ch_temp_t2_result);


inst_PSD_temp_subtraction : PSD_temp_subtraction
  Port  map(
        clk => clk,   
        acq_start => acq_start,
        Ch_temp1 => Ch_temp_t1_result,
        Ch_temp2 => Ch_temp_t2_result,
        K40_Pre_GC => K40_Pre_GC,
        GC_Cal_out => GC_Cal_out,
        Compare_rdy => Compare_rdy);
end Behavioral;