----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/06/01 17:00:34
-- Design Name: 
-- Module Name: PSD_temp_subtraction - Behavioral
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

entity PSD_temp_subtraction is
  Port  (
        clk : in std_logic;    
        acq_start : in std_logic;
        Ch_temp1 : in STD_LOGIC_VECTOR (31 downto 0 );
        Ch_temp2 : in STD_LOGIC_VECTOR (31 downto 0 );
        K40_Pre_GC : in std_logic_vector(16 -1 downto 0);
        
        GC_Cal_out : out std_logic_vector(16 - 1 downto 0);
        Compare_rdy : in std_logic);
end PSD_temp_subtraction;

architecture Behavioral of PSD_temp_subtraction is
signal sub_result_valid : std_logic;
signal delta_result_valid : std_logic;
signal delta_result_valid2 : std_logic;
signal sub_result_data : std_logic_vector(31 downto 0);
signal delta_result_data :  STD_LOGIC_VECTOR(23 DOWNTO 0);

signal m_rdy_dk40 : std_logic;
signal m_rdy_pregc : std_logic;
--signal K40_a :std_logic_vector(31 downto 0):=X"c000939b";  --   -4.6126749006
signal K40_a :std_logic_vector(31 downto 0):=X"4000939b";  --   4.6126749006

COMPONENT floating_point_2
  PORT (
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT floating_point_3
  PORT (
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );
END COMPONENT;

signal GC_out : std_logic_vector(23 downto 0);
signal GC_out_pre : std_logic_vector(23 downto 0);
signal t_out_pre : std_logic_vector(31 downto 0);

signal GC_out_1d : std_logic_vector(23 downto 0);

signal g_pre : std_logic_vector(23 downto 0);
signal t_pre : std_logic_vector(31 downto 0);

signal result_cnt : integer range 0 to 10000000:= 0;
signal result_cnt_en : std_logic;
signal result_cnt_en_pipe : std_logic_vector(1 downto 0);
signal en_rdy : std_logic:='1';
signal en_rdy_cnt : integer range 0 to 200:= 0;
signal rdy_result : std_logic;
signal m_rdy_result : std_logic;
COMPONENT floating_point_0 -- fixed to float
  PORT (
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
signal PSD_delta_k40 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal fixed_preGC : STD_LOGIC_VECTOR(23 DOWNTO 0);
signal PSD_preGC : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal PSD_GC : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal change_rdy : std_logic:='0';
signal preGC_change : std_logic:='0';
signal preGC_change_pipe : std_logic_vector(1 downto 0);
signal preGC_change_on : std_logic:='0';
signal temp1_sel : std_logic_vector(31 downto 0);
signal temp1_1d : std_logic_vector(31 downto 0);
COMPONENT floating_point_1st_Order -- ax + b
   PORT (
    aclk : IN STD_LOGIC;
    aclken : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_c_tvalid : IN STD_LOGIC;
    s_axis_c_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
attribute mark_debug : string;
    attribute mark_debug of preGC_change : signal is "true";
    attribute mark_debug of GC_out : signal is "true";
    attribute mark_debug of GC_out_1d : signal is "true";
    attribute mark_debug of fixed_preGC : signal is "true";
    attribute mark_debug of temp1_sel : signal is "true";
  

begin


temp1_sel <= Ch_temp1;
fixed_preGC <= X"00"&K40_Pre_GC;

inst_t2_t1_subtraction : floating_point_2 -- a - b
  PORT map(
    aclk => clk,
    aclken => acq_start,
    s_axis_a_tvalid => Compare_rdy,
    s_axis_a_tdata => Ch_temp2,
    s_axis_b_tvalid => Compare_rdy,
    s_axis_b_tdata => temp1_sel,
    m_axis_result_tvalid => sub_result_valid,
    m_axis_result_tdata => PSD_delta_k40
  );

--inst_delta_k40 : floating_point_3
--  PORT map(
--   aclk => clk,
--    aclken => acq_start,
--    s_axis_a_tvalid => Compare_rdy,
--    s_axis_a_tdata => sub_result_data,
--    m_axis_result_tvalid => delta_result_valid,
--    m_axis_result_tdata => delta_result_data
--  );

--inst_floating_point_daltak40 : floating_point_0  -- x
--  PORT MAP (
--    aclk  => clk,
--    aclken => acq_start,
--    s_axis_a_tvalid =>  Compare_rdy,
--    s_axis_a_tdata => delta_result_data,
--    m_axis_result_tvalid => m_rdy_dk40,
--    m_axis_result_tdata => PSD_delta_k40
--  );
  
  
  
inst_floating_point_PreGC : floating_point_0  -- b
  PORT MAP (
    aclk  => clk,
    aclken => acq_start,
    s_axis_a_tvalid =>  Compare_rdy,
    s_axis_a_tdata => fixed_preGC,
    m_axis_result_tvalid => m_rdy_pregc,
    m_axis_result_tdata => PSD_preGC
  );


i_floating_point_t1_Order :floating_point_1st_Order -- ax + b
  PORT MAP (
    aclk => clk,
    aclken  => acq_start,
    s_axis_a_tvalid =>  Compare_rdy,
    s_axis_a_tdata => K40_a,
    s_axis_b_tvalid =>  Compare_rdy,
    s_axis_b_tdata => PSD_delta_k40,
    s_axis_c_tvalid =>  Compare_rdy,
    s_axis_c_tdata => PSD_preGC,
    m_axis_result_tvalid  => m_rdy_result,
    m_axis_result_tdata =>PSD_GC
  );

inst_delta_PSDGC_to_GC : floating_point_3
  PORT map(
   aclk => clk,
    aclken => acq_start,
    s_axis_a_tvalid => Compare_rdy,
    s_axis_a_tdata => PSD_GC,
    m_axis_result_tvalid => delta_result_valid2,
    m_axis_result_tdata => GC_out
  );
process(clk)
begin
    if(rising_edge(clk)) then
        GC_out_1d <= GC_out;
    end if;
end process;

GC_cal_out <= GC_out_1d(16 - 1 downto 0);
end Behavioral;
