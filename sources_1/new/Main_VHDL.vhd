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


architecture Behavioral of Main_VHDL is

signal Ch_temp_t1 :  STD_LOGIC_VECTOR ( 23 downto 0 );
signal Ch_temp_t2 :  STD_LOGIC_VECTOR ( 23 downto 0 );
signal GC_Cal_out : std_logic_vector( 16 - 1 downto 0);
component floating_point_top is
  Port ( 
        clk : in std_logic;    
        acq_start : in std_logic;
        Ch_temp_t1 : in STD_LOGIC_VECTOR ( 23 downto 0 );
        Ch_temp_t2 : in STD_LOGIC_VECTOR ( 23 downto 0 );
        K40_Pre_GC : in std_logic_vector(16 -1 downto 0);
        GC_Cal_out : out std_logic_vector( 16 - 1 downto 0);
        Compare_rdy : in std_logic);
end component;

signal Cal_read_done : std_logic:= '0';
signal rd_en_start : std_logic:='0';
signal GC_Cal_data_read :  std_logic_vector(16 - 1 downto 0);
signal Temp_Cal_data_read : std_logic_vector(16 - 1 downto 0);
signal eeprom_test_write_en : std_logic;
Component eeprom_top is
  Port (
        clk  : in std_logic;
        cs_n : out std_logic;
        sclk : out std_logic;
        miso : in std_logic;
        rd_en_start : in std_logic;
        GC_Cal_data : in std_logic_vector(16 - 1 downto 0);
        Temp_Cal_data : in std_logic_vector(16 - 1 downto 0);
        Cal_read_done : in std_logic;
        GC_Cal_data_read : out std_logic_vector(16 - 1 downto 0);
        Temp_Cal_data_read : out std_logic_vector(16 - 1 downto 0);
        mosi : out std_logic
         );
end Component;

signal r_RX_SERIAL_buf : std_logic;
COMPONENT UART_RX
   generic (
      g_CLKS_PER_BIT : integer := 43   -- Needs to be set correctly
      );
	PORT(
		i_Clk : IN std_logic;
		i_RX_Serial : IN std_logic;          
		o_RX_DV : OUT std_logic;
		o_RX_Byte : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;	
signal miso : std_logic;	
signal miso_2 : std_logic;
COMPONENT SPI_MASTER is
        Generic (
            CLK_FREQ    : natural := 10e6; -- set system clock frequency in Hz
            SCLK_FREQ   : natural := 1e6;  -- set SPI clock frequency in Hz (condition: SCLK_FREQ <= CLK_FREQ/10)
            SLAVE_COUNT : natural := 1     -- count of SPI slaves
        );
        Port (
            CLK      : in  std_logic; -- system clock
            RST      : in  std_logic; -- high active synchronous reset
            -- SPI MASTER INTERFACE
            SCLK     : out std_logic; -- SPI clock
            CS_N     : out std_logic_vector(SLAVE_COUNT-1 downto 0); -- SPI chip select, active in low
            MOSI     : out std_logic; -- SPI serial data from master to slave
            MISO     : in  std_logic; -- SPI serial data from slave to master
            -- INPUT USER INTERFACE
            ADDR     : in  std_logic_vector(0 downto 0); -- SPI slave address
            DIN      : in  std_logic_vector(7 downto 0); -- input data for SPI slave
            DIN_LAST : in  std_logic; -- when DIN_LAST = 1, after transmit these input data is asserted CS_N
            DIN_VLD  : in  std_logic; -- when DIN_VLD = 1, input data are valid
            READY    : out std_logic; -- when READY = 1, valid input data are accept
            -- OUTPUT USER INTERFACE
            DOUT     : out std_logic_vector(7 downto 0); -- output data from SPI slave
            DOUT_VLD : out std_logic  -- when DOUT_VLD = 1, output data are valid
        );
	END COMPONENT;	
	
	
	


COMPONENT Moving_Avr is
generic (
  G_NBIT                     : integer := 14;
  G_AVG_LEN_LOG              : integer := 6 );
port (  
  i_clk                      : in  std_logic;
  i_rstb                     : in  std_logic;
  i_sync_reset               : in  std_logic;
  -- input
  i_data_ena                 : in  std_logic;
  i_data                     : in  std_logic_vector(G_NBIT-1 downto 0);
  -- output
  o_data_valid               : out std_logic;
  o_data                     : out std_logic_vector(G_NBIT-1 downto 0));
end COMPONENT;

signal w_TX_SERIAL_buf : std_logic;
	COMPONENT UART_TX
	generic (
      g_CLKS_PER_BIT : integer := 43   -- Needs to be set correctly
      );
	PORT(
		i_Clk : IN std_logic;
		i_TX_DV : IN std_logic;
		i_TX_Byte : IN std_logic_vector(7 downto 0);          
		o_TX_Active : OUT std_logic;
		o_TX_Serial : OUT std_logic;
		o_TX_Done : OUT std_logic
		);
	END COMPONENT;

COMPONENT clk_wiz_0 
PORT(
       clk_out1  : OUT std_logic;
       clk_out2  : OUT std_logic;
       clk_out3  : OUT std_logic;
--       clk_XADC : OUT std_logic;
       reset  : In std_logic;
       locked : OUT std_logic;
        clk_in1 : In std_logic
        );
 END COMPONENT;

COMPONENT  Xilinx_serial_I2C
port (
	CLK: IN std_logic;
	rst : in std_logic;	
	Phase_sync_skew : in std_logic_vector(1 downto 0);
	
	CS: out std_logic:='1';	
	
	SDATA: out std_logic;	
	
	Phase_sync_skew_test : out std_logic_vector(1 downto 0):="00"
	
	);
 END COMPONENT;
 
COMPONENT ADC_invert 
port(
	clk : in std_logic;
	ADC_ORT : IN std_logic;  
	ADC_value : in std_logic_vector(11 downto 0);
	inva : out std_logic_vector(11 downto 0));
end COMPONENT; 

COMPONENT ug480 
   port
   (
    DCLK               : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
    RESET              : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
    VAUXP, VAUXN       : in  STD_LOGIC_VECTOR (3 downto 0);    -- Input data bus for the dynamic reconfiguration port
    VP, VN             : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port

    MEASURED_TEMP      : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    MEASURED_VCCAUX    : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    MEASURED_VCCINT    : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    MEASURED_VCCBRAM   : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    MEASURED_AUX0      : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    MEASURED_AUX1      : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    MEASURED_AUX2      : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    MEASURED_AUX3      : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port

    ALM                : out  STD_LOGIC_VECTOR (7 downto 0);   -- Output data bus for dynamic reconfiguration port
    CHANNEL            : out  STD_LOGIC_VECTOR (4 downto 0);   -- Output data bus for dynamic reconfiguration port
    OT                 : out  STD_LOGIC;   -- Output data bus for dynamic reconfiguration port
    EOC         : out  STD_LOGIC;   -- Output data bus for dynamic reconfiguration port
    EOS         : out  STD_LOGIC   -- Output data bus for dynamic reconfiguration port
);
 END COMPONENT;
signal ADC_data : std_logic_vector(16 - 1 downto 0);                                             
signal Crystal_Temp : std_logic_vector(16 - 1 downto 0);
signal rst_n : std_logic:='1';
Component adc_protocol_top is
  Port ( 
        rst_n : in std_logic;
        clk : in std_logic;
        sda : inout std_logic;
        scl : inout std_logic;
        adc_data_out : out std_logic_vector(16 - 1 downto 0)
  );
end Component;

COMPONENT Radiation_detect14bit_8192 
port(
	clk: in std_logic;
	rst: in std_logic;
	acq_start: IN std_logic;	
	--CH_ACQ: In std_logic;
	--ADC_ORT : in std_logic;
	--flag_data_stop : inout std_logic;
	Trapezoidal_out : in std_logic_vector(13 downto 0); 
	flag_start : out std_logic;
	Threshold : In STD_LOGIC_VECTOR( 12 downto 0);
	Signal_TIME: In STD_LOGIC_Vector( 6 downto 0);
	Data_subtraction : In STD_LOGIC_VECTOR( 12 downto 0) ;
	--Ch_Data_subtraction_all : in std_logic_vector(11 downto 0);
	data_in: in std_logic_vector(13 downto 0);
	dout_CH: out std_logic_vector(12 downto 0);
	flag_CH : out std_logic
	);	
end COMPONENT;

COMPONENT radiation_SCA14bit 
port(
	clk: in std_logic;
	rst: in std_logic;
	acq_start: IN std_logic;	
	--CH_ACQ: In std_logic;
	--ADC_ORT : in std_logic;
	--flag_data_stop : inout std_logic;
	flag_start : out std_logic;
	 
	Threshold : In STD_LOGIC_VECTOR( 12 downto 0);
	Signal_TIME: In STD_LOGIC_Vector( 6 downto 0);
	Data_subtraction : In STD_LOGIC_VECTOR( 12 downto 0) ;
	--Ch_Data_subtraction_all : in std_logic_vector(11 downto 0);
	data_in: in std_logic_vector(13 downto 0);	
	flag_CH : out std_logic
	);	
end COMPONENT;

COMPONENT radiation_RisingEdgeC 
port(
	clk: in std_logic;
	rst: in std_logic;
	acq_start: IN std_logic;	

	Trapezoidal_out : in std_logic_vector(13 downto 0); 
	
	Threshold : In STD_LOGIC_VECTOR( 12 downto 0);
	Signal_TIME: In STD_LOGIC_Vector( 6 downto 0);
	Data_subtraction : In STD_LOGIC_VECTOR( 12 downto 0) ;	
	flag_CH : out std_logic
	);	
end COMPONENT;

COMPONENT SCA_Module 
port(
	clk: in std_logic;	
	rst: in std_logic;
	acq_start: IN std_logic;	
    Ch_all : out std_logic_vector(31 downto 0);   
    flag_acq_in : in std_logic;
	flag_CH : in std_logic
	);	
end COMPONENT;
signal Gm_count_out : std_logic_vector(16 downto 0);
signal Gm_count : std_logic_vector(7 downto 0);
signal Gm_count_read : std_logic;
signal Gm_count_read_pipe : std_logic_vector(1 downto 0);
COMPONENT RAM_Spectrum 
	port( clk: in std_logic;		
			clk_RAM : in std_logic;
			rst: in std_logic;
			Swich_mode : in std_logic_vector(3 downto 0);
			GM_count : in std_logic;
			laser_count : in std_logic;
			neutron_count : in std_logic;
			flag_check : out std_logic;
			flag_init:out std_logic;
			acq_done : out std_logic:='1';
			flag_out: out std_logic;
			acq_take : in std_logic; -- Read Start
			acq_count : in std_logic; -- Read RAM Addr
			acq_start : in std_logic; -- Func Start
			flag_aq_1 : in std_logic; -- Write Start
            Bat_ADC_In : in std_logic_vector(7 downto 0);
			Pileup_sp_T : in std_logic;
		    R_Counter_RAM : in std_logic;    
		    GM_En : in std_logic;
		    Neutron_En : in std_logic;
		    Det_label  : in std_logic_vector(15 downto 0);
            MEASURED_TEMP_in : in std_logic_vector(15 downto 0);
            MEASURED_VCCAUX_in : in std_logic_vector(15 downto 0);
            MEASURED_VCCINT_in : in std_logic_vector(15 downto 0);
            MEASURED_VCCBRAM_in : in std_logic_vector(15 downto 0);
            MEASURED_AUX0_in : in std_logic_vector(15 downto 0);
            MEASURED_AUX1_in : in std_logic_vector(15 downto 0);
            MEASURED_AUX2_in : in std_logic_vector(15 downto 0);  
            MEASURED_AUX3_in : in std_logic_vector(15 downto 0);  
            GC : in std_logic_vector(15 downto 0); 
            HV_DAC : in std_logic_vector(15 downto 0); 
			HV_buf_Sm : in std_logic_vector(11 downto 0);
			Bat_Status_in : in  std_logic_vector(3 downto 0);
			flag_ram: out std_logic;
			
			data_in_1 : in std_logic_vector(12 downto 0);
    
			
			Spec_out : out std_logic_vector(15 downto 0):= "0100010000110000"--D0
		);	
end COMPONENT;

Component Smoothing_Shifter 
port(
	clk: in std_logic;
	rst: in std_logic;
	acq_start: IN std_logic;	
	data_in: in std_logic_vector(13 downto 0);	
	Trapezoidal_out : out std_logic_vector(13 downto 0)
	
	);	
end Component;


Component Clk_1ns is
port(clk: in std_logic;
	clk_1ns: out std_logic);
end Component;

Component clk_100ms is
port(clk: in std_logic;	
   clk_100ms: out std_logic:='0');
end Component;

signal temp : std_logic_vector(11 downto 0);

signal  Data_Byte: std_logic_vector(7 downto 0);
signal        Rdy_Tx  : std_logic               := '0';
constant c_CLKS_PER_BIT : integer := 43;
constant  c_CLKS_PER_BIT_Bat : integer := 1042;

signal             Bat_ADC_In :  std_logic_vector(7 downto 0);
signal Bat_Status_in :  std_logic_vector(3 downto 0);

signal r_TX_DV     : std_logic                    := '0';
signal r_TX_BYTE   : std_logic_vector(7 downto 0) := (others => '0');

signal w_TX_DONE   : std_logic;
signal w_RX_DV     : std_logic;
signal w_RX_BYTE   : std_logic_vector(7 downto 0);

signal cnt_dv : integer range 0 to 10000000:=0;
signal cnt_DV_T : integer range 0 to 10000000:=0; 
 signal cnt_DV_T_1 : integer range 0 to 10000000:=0;
  signal cnt_DV_GC_T_1 : integer range 0 to 10000000:=0;
  signal cnt_DV_HV_T_1 : integer range 0 to 10000000:=0;
signal clk_uart  : std_logic;
signal clk_Main  : std_logic;
signal Temp_data : std_logic_vector(12 - 1 downto 0);


signal Phase_sync_skew_test: std_logic_vector(1 downto 0);


signal  clk_ADC : std_logic;
signal SW_Write_init : std_logic:='0';

type t_Memory is array (0 to 11) of std_logic_vector(7 downto 0);
signal w_RX_BYTE_out : t_Memory;



signal  Data_Byte_Bat: std_logic_vector(7 downto 0);
signal        Rdy_Tx_Bat : std_logic               := '0';

signal r_TX_DV_Bat     : std_logic                    := '0';
signal r_TX_BYTE_Bat   : std_logic_vector(7 downto 0) := (others => '0');

signal w_TX_DONE_Bat   : std_logic;
signal w_RX_DV_Bat     : std_logic;
signal w_RX_BYTE_Bat   : std_logic_vector(7 downto 0);
signal w_RX_BYTE_out_Bat_H   : std_logic_vector(7 downto 0);
signal w_RX_BYTE_out_Bat_M   : std_logic_vector(7 downto 0);
signal w_RX_BYTE_out_Bat_L   : std_logic_vector(7 downto 0);

    signal Power_kill_flag : std_logic:='0';
    signal Power_kill_flag_buf : std_logic_vector(1 downto 0):="00";
    signal Power_kill_en : std_logic:='0';
    signal Power_kill_on : std_logic:='0'; 
    
    
    signal GC_flag : std_logic:='0';      
    signal  GC_flag_buf: std_logic_vector(1 downto 0):="00";   
    signal GC_en : std_logic:='0';   
    
     signal HV_flag : std_logic:='0';      
    signal  HV_flag_buf: std_logic_vector(1 downto 0):="00";   
     signal HV_Contr_Write_HV_flag : std_logic:='0';      
    signal HV_Contr_Write_HV_flag_buf: std_logic_vector(1 downto 0):="00";       
    
    
    signal HV_en : std_logic:='0';      
    signal HV_Buf : std_logic_vector(11 downto 0):="000000000000";
    signal HV_buf_Sm  : std_logic_vector(11 downto 0):="000000000000";
signal Hold_cnt   : std_logic_vector(1 downto 0):="00";

signal SC_Start : std_logic:='0';     
signal Ch_all : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal flag_acq_out  : std_logic:='0';   
signal Pileup_ce_T : std_logic;
signal R_Counter_RAM : std_logic;
-----------------------------------------------------------------------------
   signal m_addr     : std_logic_vector(0 downto 0);
    signal m_din      : std_logic_vector(7 downto 0);
    signal m_din_last : std_logic;
    signal m_din_vld  : std_logic;
    signal m_ready    : std_logic;

    signal m_dout_vld : std_logic;

    signal s_din      : std_logic_vector(7 downto 0);
    signal s_din_vld  : std_logic;
    signal s_ready    : std_logic;
    signal s_dout     : std_logic_vector(7 downto 0);
    signal s_dout_vld : std_logic;
    
   signal m_addr_2     : std_logic_vector(0 downto 0);
     signal m_din_2      : std_logic_vector(7 downto 0);
     signal m_din_last_2 : std_logic;
     signal m_din_vld_2  : std_logic;
     signal m_ready_2    : std_logic;
 
     signal m_dout_vld_2 : std_logic;
 
     signal s_din_2      : std_logic_vector(7 downto 0);
     signal s_din_vld_2  : std_logic;
     signal s_ready_2    : std_logic;
     signal s_dout_2     : std_logic_vector(7 downto 0);
     signal s_dout_vld_2 : std_logic;    
    
    signal m_dout_2  : std_logic_vector(7 downto 0);
    constant SLAVE_COUNT : integer := 1;
     signal Trape_in : std_logic_vector(13 downto 0);
  -- signal GC_High : std_logic_vector(7 downto 0):=X"4A";

  ------------------------------------------------------------ ------------------------------------------------------------  ------------------------------------------------------------
 signal GM_En : std_logic:='0';
   signal Domino_En :  std_logic:='1';
   
      
     --signal GC : std_logic_vector(15 downto 0):=X"6978";  --27000
    signal GC : std_logic_vector(15 downto 0):=X"84D0";  --33000 V/V 

--  signal HV_DAC : std_logic_vector(15 downto 0):=X"7D00"; -- HV ���� ��    32000 
--signal HV_DAC : std_logic_vector(15 downto 0):=X"7530"; -- HV ���� ��    30000
   --signal HV_DAC : std_logic_vector(15 downto 0):=X"6978"; -- HV ���� ��    26400
   signal HV_DAC : std_logic_vector(15 downto 0):=X"8A80"; -- HV ���� ��    39300
   
   
      signal HV_ADC : std_logic_vector(11 downto 0):=X"9B0"; -- HV �ʱ� ��

      signal Cs137_32KeV : std_logic_vector(15 downto 0):=X"000F"; -- Cs137_32KeV �ʱ� ��     15
      signal Cs137_662KeV : std_logic_vector(15 downto 0):=X"018A"; -- Cs137_662KeV �ʱ� ��    394    
      signal K40_1460KeV : std_logic_vector(15 downto 0):=X"036B"; -- K40 �ʱ� ��     875
      
       signal Det_label : std_logic_vector(15 downto 0):=X"002E"; -- Detector ���� �ʱ� ��         
            
      signal HV_Gap : std_logic_vector(11 downto 0):=X"000";

      signal Serial_1 :  std_logic_vector(7 downto 0):=X"48";  --H
      signal Serial_2 :  std_logic_vector(7 downto 0):=X"48";  --H
      signal Serial_3 :  std_logic_vector(7 downto 0):=X"33";  --3
      signal Serial_4 :  std_logic_vector(7 downto 0):=X"41";  --A
      signal Serial_5 :  std_logic_vector(7 downto 0):=X"41";  --A
      signal Serial_6 :  std_logic_vector(7 downto 0):=X"32";  --2
      signal Serial_7 :  std_logic_vector(7 downto 0):=X"34";  --4 
  
  
      signal BNC_Serial_1 :  std_logic_vector(7 downto 0):=X"47";  --G
      signal BNC_Serial_2 :  std_logic_vector(7 downto 0):=X"33";  --3
      signal BNC_Serial_3 :  std_logic_vector(7 downto 0):=X"41";  --A
      signal BNC_Serial_4 :  std_logic_vector(7 downto 0):=X"41";  --A
      signal BNC_Serial_5 :  std_logic_vector(7 downto 0):=X"34";  --4
      signal BNC_Serial_6 :  std_logic_vector(7 downto 0):=X"38";  --8
       
 ------------------------------------------------------------  ------------------------------------------------------------  ------------------------------------------------------------

    signal     Write_GC_flag  : std_logic:='0';     
        signal     Write_HV_flag  : std_logic:='0';  
        signal      HV_Fix : std_logic:='0'; 
        signal XADC_Rst : std_logic:='1';
    signal RaspberryPi_Power_Kill_Buf : std_logic:='0';     
  
            signal HV_Contr_Rdy : std_logic:='0';
---------------------------------------------------------------------------
    signal  clk_XADC : std_logic;

        
    signal MEASURED_TEMP      : std_logic_vector(15 downto 0);
    signal MEASURED_VCCAUX      : std_logic_vector(15 downto 0);
    signal MEASURED_VCCINT      : std_logic_vector(15 downto 0);    
    signal MEASURED_VCCBRAM      : std_logic_vector(15 downto 0);
    signal MEASURED_AUX0      : std_logic_vector(15 downto 0);
    signal MEASURED_AUX1      : std_logic_vector(15 downto 0);
    signal MEASURED_AUX2      : std_logic_vector(15 downto 0);            
    signal MEASURED_AUX3      : std_logic_vector(15 downto 0);    
    
    signal ALM : std_logic_vector(7 downto 0);
    signal CHANNEL  : std_logic_vector(4 downto 0);
    
     signal   OT   : std_logic;
   signal EOC      : std_logic;
      signal    EOS : std_logic;
  
     signal MEASURED_TEMP_buf      : std_logic_vector(15 downto 0);   

   signal     MEASURED_VCCAUX_buf      :  std_logic_vector(15 downto 0);
   signal     MEASURED_VCCINT_buf      :  std_logic_vector(15 downto 0);    
   signal      MEASURED_VCCBRAM_buf      :  std_logic_vector(15 downto 0);
    signal MEASURED_AUX0_buf      : std_logic_vector(15 downto 0);
  signal      MEASURED_AUX1_buf      :  std_logic_vector(15 downto 0);
  signal      MEASURED_AUX2_buf      :  std_logic_vector(15 downto 0);            
  signal       MEASURED_AUX3_buf      :  std_logic_vector(15 downto 0);    
        
  signal      ALM_buf :  std_logic_vector(7 downto 0);
   signal     CHANNEL_buf  :  std_logic_vector(4 downto 0);
        
  signal         OT_buf   :  std_logic;
   signal     EOC_buf      :  std_logic;
   signal          EOS_buf :  std_logic;   
      
   signal clk_1ns_T : std_logic;
   signal o_data_valid_buf : std_logic;
  signal Time_counter : integer range 0 to 1000000000:=0;    
  signal TX_count: integer range 0 to 1000000:=0;
  signal TX_Hold_count: integer range 0 to 1000000:=0;
    signal  w_RX_Test : std_logic;
  signal cnt_HV_Contr : integer range 0 to 1000000:=0;    
---------------------------------------------------------------------------
signal SC_Stamp : std_logic_vector(15 downto 0):="0000000000000000";
signal SC_time : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal SC_CH : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal SC_Counter  : std_logic_vector(4 downto 0):="00000";
signal SC_take: std_logic:='0';
signal SC_Time_counter: std_logic_vector(31 downto 0):="00000000000000000000000000000000";
---------------------------------------------------------------------------
signal i_GS_on  : std_logic_vector(1 downto 0):="00";
signal GS_on : std_logic:='0';
signal GS_Counter : std_logic_vector(5 downto 0):="000000";
---------------------------------------------------------------------------
signal ADC_inv :  std_logic_vector(11 downto 0);
signal ADC_inv_BUF :  std_logic_vector(13 downto 0);
signal rst : std_logic:='0';
signal acq_start : std_logic:='0';
signal Trapezoidal_out : std_logic_vector(13 downto 0);
signal Trapezoidal_out_SC : std_logic_vector(13 downto 0);
signal dout_CH: std_logic_vector(12 downto 0);
signal  flag_CH : std_logic;
signal flag_CH_SCA : std_logic;


signal  RaspberryPi_Power_Timer  : integer range 0 to  100000:=0;  	  
signal	RaspberryPi_Power_Timer_on : std_logic:='0';

signal 	 led_on_Timer_on  : std_logic:='1';
signal	 led_on_Timer  : integer range 0 to 1600000000:=0;
                                             


signal cnt_on  : std_logic:='1';
signal	 cnt  : integer range 0 to 10000:=0; 

signal clk_100ms_T  : std_logic:='0';

signal Header_counter: std_logic_vector(2 downto 0):="000";
signal Tail_counter: std_logic_vector(2 downto 0):="000";

---------------------------------------------------------------------------
         signal Main_Threshold : std_logic_vector(12 downto 0):="0000000101000"; --21
         --constant Main_Threshold : std_logic_vector(12 downto 0):="0000000001010"; --21
        -- constant Main_Threshold : std_logic_vector(12 downto 0):="0000000000011"; --3
         constant Main_Signal_TIME_1 : std_logic_vector(6 downto 0):="0001110";
         --constant    Main_Data_subtraction_1 : std_logic_vector(12 downto 0):="0000000000100"; --4
         constant    Main_Data_subtraction_1 : std_logic_vector(12 downto 0):="0000000000000";
---------------------------------------------------------------------------
         signal flag_out : std_logic;
         signal flag_init : std_logic;
         signal flag_check : std_logic;
         SIGNAL flag_ram : std_logic;
         signal  Swich:  std_logic_vector(3 downto 0);
                signal            acq_done :  std_logic:='0'; --SLCS
                 
               signal          acq_take :  std_logic:='0';
               signal          acq_take_pipe :  std_logic_vector:="00";
                     
              signal           acq_rd_clk :  std_logic;       
          signal     Spec_out:  std_logic_vector(15 downto 0);  
          signal     uart_wait_cnt : integer range 0 to 10000000 := 0;
 ---------------------------------------------------------------------------        
         
type Master_state_1 is (UART_idle , UART_1st_Trans , UART_1st_Trans_Hold, UART_2nd_Trans ,UART_2nd_Trans_Hold,UART_Header_Trans, UART_Header_Trans_Hold,
UART_2nd_Header_Trans, UART_Tail_Trans,UART_Tail_Trans_Hold,UART_2nd_Tail_Trans, UART_Hold_Timer,UART_SC_Trans,UART_SC_Trans_Hold,UART_GS_Trans,UART_GS_Trans_Hold, UART_end);
signal UART_state : Master_state_1;

type Master_state_2 is (UART_RX_idle , UART_1st_Command_RX, UART_RX_1st , UART_RX_2nd, UART_RX_3rd, UART_RX_4th, UART_RX_5th, UART_RX_6th, UART_RX_7th,  
UART_RX_8th, UART_RX_9th,  UART_RX_10th, UART_RX_end, UART_RX_Command,UART_RX_cl_1st ,UART_RX_cl_2nd ,UART_RX_cl_3rd ,UART_RX_cl_4th ,UART_RX_cl_5th ,UART_RX_cl_6th
 ,UART_RX_cl_7th ,UART_RX_cl_8th ,UART_RX_cl_9th  ,UART_RX_cl_10th ,UART_RX_cl_11th ,UART_RX_cl_12th ,UART_RX_cl_13th ,UART_RX_cl_14th 
 ,UART_RX_cl_15th ,UART_RX_cl_16th ,UART_RX_cl_17th ,UART_RX_cl_18th ,UART_RX_cl_19th ,UART_RX_cl_20th ,UART_RX_cl_21th ,UART_RX_cl_22th ,UART_RX_cl_23th 
 ,UART_RX_cl_24th ,UART_RX_cl_25th ,UART_RX_cl_26th ,UART_RX_cl_27th ,UART_RX_cl_28th   );
signal UART_RX_state : Master_state_2;


type Master_state_3 is (UART_idle_Bat , UART_1st_Recv_Bat , UART_1st_Recvs_Hold_Bat,UART_2st_Recv_Bat , UART_2st_Recvs_Hold_Bat, UART_end_Bat);
signal UART_Bat_state : Master_state_3;

type Master_state_4 is (UART_idle_Trans_Bat , UART_1st_Trans_Bat , UART_1st_Trans_Hold_Bat, UART_end_Bat);
signal UART_Bat_Trans_state : Master_state_4;

type Master_state_5 is (HV_Contr_idle , HV_Contr_comp , HV_Contr_Incr , HV_Contr_dicr, HV_Contr_Incr_short,HV_Contr_dicr_short,
HV_Contr_hold,HV_Contr_Watch, HV_Contr_Incr_short_LPF,HV_Contr_dicr_short_LPF);

signal HV_Contr_state : Master_state_5;



   
type Master_GC_SPI_state is (SPI_GC_idle , SPI_GC_1st_Trans , SPI_GC_1st_Trans_Hold, SPI_GC_2nd_Trans ,SPI_GC_2nd_Trans_Hold, SPI_GC_3rd_Trans, SPI_GC_end);
signal SPI_GC_state : Master_GC_SPI_state;

type Master_HV_SPI_state is (SPI_HV_idle , SPI_HV_1st_Trans , SPI_HV_1st_Trans_Hold, SPI_HV_2nd_Trans ,SPI_HV_2nd_Trans_Hold, SPI_HV_3rd_Trans, SPI_HV_end);
signal SPI_HV_state : Master_HV_SPI_state;

signal  cpu_detect_pipe    : std_logic_vector(1 downto 0);
signal  power_switching_en : std_logic;
signal  power_switching_end : std_logic;
signal  cpu_phold_buf : std_logic := '0';
signal  power_down_cnt : integer:=0;
signal led_cnt : integer:=0;
signal GC_Cal_data : std_logic_vector(16 - 1 downto 0);
signal Temp_Cal_data : std_logic_vector(16 - 1 downto 0);
signal peak32_Cal_data : std_logic_vector(16 - 1 downto 0);
signal peak662_Cal_data : std_logic_vector(16 - 1 downto 0);
signal peak1460_Cal_data : std_logic_vector(16 - 1 downto 0);
signal GC_Change_cnt : integer range 0 to 10000000:= 0;
type led_state_con is (led_idle , led_led_on , led_green_on, led_blue_on, led_finish);
signal led_state : led_state_con;
signal Gm_count_pre_1s : std_logic_vector(7 downto 0) := "00000000";
signal Gm_count_pre_2s : std_logic_vector(7 downto 0) := "00000000";
signal Gm_count_pre_3s : std_logic_vector(7 downto 0) := "00000000";
signal Gm_count_pre_4s : std_logic_vector(7 downto 0) := "00000000";
signal Gm_count_pre_5s : std_logic_vector(7 downto 0) := "00000000";
signal Gm_count_pre_6s : std_logic_vector(7 downto 0) := "00000000";
signal Gm_count_pre_7s : std_logic_vector(7 downto 0) := "00000000";
signal Gm_count_pre_8s : std_logic_vector(7 downto 0) := "00000000";
signal Gm_count_pre_9s : std_logic_vector(7 downto 0) := "00000000";
signal Gm_count_pre_10s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_11s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_12s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_13s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_14s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_15s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_16s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_17s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_18s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_19s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_20s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_21s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_22s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_23s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_24s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_25s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_26s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_27s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_28s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_29s : std_logic_vector(7 downto 0):= "00000000";
signal Gm_count_pre_30s : std_logic_vector(7 downto 0):= "00000000";

signal Gm_count_pre_sum : std_logic_vector(7 downto 0):= "00000000";

signal i_Gm_count : std_logic_vector(1 downto 0):= "00";
signal Sleep_en : std_logic:='0';
signal Gm_time_count : integer;

attribute mark_debug : string;
attribute keep : string;
attribute mark_debug of r_RX_SERIAL : signal is "true";
attribute mark_debug of w_TX_SERIAL : signal is "true";
attribute mark_debug of peak32_cal_data : signal is "true";
attribute mark_debug of peak662_cal_data : signal is "true";
attribute mark_debug of peak1460_cal_data : signal is "true";
attribute mark_debug of GC_cal_data : signal is "true";
attribute mark_debug of write_gc_flag : signal is "true";
attribute mark_debug of GC_Cal_out : signal is "true";

begin

--test1 <= '1' when cpu_detect ='1' else '0';
--cpu_phold <= '0' when cpu_detect ='1' else '1';
cpu_phold <= cpu_phold_buf;
--test1 <= cpu_phold_buf;

--HV_Enable <= '0';
--adc_sleep <= '1';

process(clk_Main)
begin
    if(rising_edge(clk_Main))then
        Temp_data <= Adc_data(15 downto 4);     
    end if;
end process;

process(clk_Main)
begin
    if(rising_edge(clk_Main))then
        if((Temp_data > 1365))then
            Main_Threshold <= "0000001001100";
        elsif (( 1365 >= Temp_data )and(Temp_data > 1220)) then
            Main_Threshold <= "0000000111100";
        elsif(1220 >= Temp_data)then
            Main_Threshold <= "0000000101000";   -- 20
        end if;     
    end if;
end process;



process(clk_Main)
begin
    if(rising_edge(clk_Main))then
        if(led_cnt = 100000000) then
            led_cnt <= 0;
        else
            led_cnt <= led_cnt + 1;
        end if;     
    end if;
end process;

process(clk_Main)
begin
    if(rising_edge(clk_Main))then
        case led_state is
            when led_idle => 
                    led_red <= '0'; led_blue <= '0'; --led_green <= '0';
                     rd_en_start <= '0';
                    if ( led_cnt = 100000000 ) then led_state <= led_led_on; end if;
            when led_led_on => 
                    led_red <= '1'; led_blue <= '0'; --led_green <= '0';
                    if ( led_cnt = 100000000 ) then led_state <= led_green_on; end if;
            when led_green_on => 
                    led_red <= '0'; led_blue <= '0'; --led_green <= '1';
                    if ( led_cnt = 100000000 ) then led_state <= led_blue_on; end if;
            when led_blue_on => 
                    led_red <= '0'; led_blue <= '1'; --led_green <= '0';
                    if ( led_cnt = 100000000 ) then led_state <= led_finish; end if;   
                    rd_en_start <= '1';
            when led_finish => 
                    led_red <= '0'; led_blue <= '0'; --led_green <= '0';   
                    rd_en_start <= '0';                      
            when others => led_state <= led_idle;
        end case;    
    end if;
end process;
--rd_en_start <= power_switching_en


process(clk_Main)
begin
    if(rising_edge(clk_Main))then
        cpu_detect_pipe <= cpu_detect_pipe(0) &  cpu_detect;
    end if;
end process;

        


fpga_awake <= '0';

--test2 <= r_RX_SERIAL_buf;

process(clk_Main)
begin
    if(rising_edge(clk_uart))then    
       r_RX_SERIAL_buf <= r_RX_SERIAL;
 
    end if;
end process;
	i_UART_RX: UART_RX 

  generic map (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )

	PORT MAP(
		i_Clk => clk_uart,
      i_rx_serial => r_RX_SERIAL,
--      i_rx_serial => test2,
      o_rx_dv     => w_RX_DV,
      o_rx_byte   => w_RX_BYTE
	);
--w_TX_SERIAL <= w_TX_SERIAL_buf;
--test1 <= w_TX_SERIAL_buf;
  	i_UART_TX: UART_TX 
    generic map (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )
	PORT MAP(
		i_Clk => clk_uart,
      i_tx_dv     => r_TX_DV,
      i_tx_byte   => r_TX_BYTE,
      o_tx_active => open,
      o_tx_serial => w_TX_SERIAL,
      o_tx_done   => w_TX_DONE
	);



	ii_UART_RX: UART_RX 

  generic map (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT_Bat
      )

	PORT MAP(
		i_Clk => clk_uart,
      i_rx_serial => r_RX_SERIAL_Bat,
      o_rx_dv     => w_RX_DV_Bat,
      o_rx_byte   => w_RX_BYTE_Bat
	);

--  	ii_UART_TX: UART_TX 
--    generic map (
--      g_CLKS_PER_BIT => c_CLKS_PER_BIT_Bat
--      )
--	PORT MAP(
--		i_Clk => clk_uart,
--      i_tx_dv     => r_TX_DV_Bat,
--      i_tx_byte   => r_TX_BYTE_Bat,
--      o_tx_active => open,
--      o_tx_serial => w_TX_SERIAL_Bat,
--      o_tx_done   => w_TX_DONE_Bat
--	);

    master_i : SPI_MASTER
    generic map(
        CLK_FREQ    => 10e6,
        SCLK_FREQ   => 1e6,
        SLAVE_COUNT => SLAVE_COUNT
    )
    port map (
        CLK      => clk_Uart,
        RST      => '0',
        -- SPI MASTER INTERFACE
        SCLK     => sclk,
        CS_N     => cs_n,
        MOSI     => mosi,
        MISO     => miso,
        -- USER INTERFACE
        ADDR     => m_addr,
        DIN      => m_din,
        DIN_LAST => m_din_last,
        DIN_VLD  => m_din_vld,
        READY    => m_ready,
        DOUT     => m_dout,
        DOUT_VLD => m_dout_vld
    );

   master_iI : SPI_MASTER
    generic map(
        CLK_FREQ    => 10e6,
        SCLK_FREQ   => 1e6,
        SLAVE_COUNT => SLAVE_COUNT
    )
    port map (
        CLK      => clk_uart,
        RST      => '0',
        -- SPI MASTER INTERFACE
        SCLK     => sclk_2,
        CS_N     => cs_n_2,
        MOSI     => mosi_2,
        MISO     => miso_2,
        -- USER INTERFACE
        ADDR     => m_addr_2,
        DIN      => m_din_2,
        DIN_LAST => m_din_last_2,
        DIN_VLD  => m_din_vld_2,
        READY    => m_ready_2,
        DOUT     => m_dout_2,
        DOUT_VLD => m_dout_vld_2
    );

i_clk_wiz_0 : clk_wiz_0 
PORT map(
       clk_out1  => clk_Main,
       clk_out2  => clk_uart,
        clk_out3 => clk_ADC,
--         clk_XADC=> clk_XADC,
       reset  => '0',
       locked => open,
        clk_in1 => clk
        );
        
i_Clk_1ns  :  Clk_1ns 
PORT map(
        clk=> clk_uart,
	clk_1ns=> clk_1ns_T
	);

i_clk_100ms  :  clk_100ms 
PORT map(
        clk=> clk_Main,
	clk_100ms=> clk_100ms_T
	);




i_ADC_invert : ADC_invert 
PORT map(
	clk => clk_Main,
	ADC_ORT=>ADC_ORT,
	ADC_value => ADC_value,
	inva =>ADC_inv
        ); 

i_SCA_Module : SCA_Module
PORT map(
	clk=> clk_Main,
	rst=> rst,
	acq_start=>SC_Start,
    Ch_all=>Ch_all,  
	flag_acq_in =>SC_take,
	flag_CH=>flag_CH_SCA
	);	

ADC_inv_BUF <= ADC_inv & "00";
i_Radiation_detect14bit_8192 : Radiation_detect14bit_8192 
PORT map(
	clk=> clk_Main,
	rst=> rst,
	acq_start=>acq_start,
	--CH_ACQ: In std_logic;
	--ADC_ORT : in std_logic;
	--flag_data_stop : inout std_logic;
	flag_start=>open,
	Trapezoidal_out=>Trapezoidal_out, 
	Threshold =>Main_Threshold,
	Signal_TIME=>Main_Signal_TIME_1,
	Data_subtraction=>Main_Data_subtraction_1,

		--Pileup_ce =>Pileup_ce_T,
	--Ch_Data_subtraction_all : in std_logic_vector(11 downto 0);
	data_in=>ADC_inv_BUF,
	dout_CH=>dout_CH,
	flag_CH=>flag_CH
    );


i_Radiation_SCA14bit : Radiation_SCA14bit
PORT map(
	clk=> clk_Main,
	rst=> rst,
	acq_start=>SC_Start,
	--CH_ACQ: In std_logic;
	--ADC_ORT : in std_logic;
	--flag_data_stop : inout std_logic;
	flag_start=>open,	
	Threshold =>Main_Threshold,
	Signal_TIME=>Main_Signal_TIME_1,
	Data_subtraction=>Main_Data_subtraction_1,
	--Ch_Data_subtraction_all : in std_logic_vector(11 downto 0);
	data_in=>ADC_inv_BUF,
	flag_CH=>flag_CH_SCA
    ); 
    

i_RAM_Spectrum_H  : RAM_Spectrum 
PORT map(
            clk=> clk_Main,	
			clk_RAM => clk_ADC,
			rst=> rst,
			Swich_mode=> Swich,
			GM_count=> Pin_Trig_signal,
			laser_count => '0',
			neutron_count => '0',
			flag_check =>flag_check,
			flag_init=>flag_init,
			acq_done => acq_done,
			flag_out=>flag_out,
			acq_take=> acq_take, -- Read Start
			acq_count  => acq_rd_clk, -- Read RAM Addr
			acq_start=> acq_start,
			flag_aq_1  => flag_CH,
            bat_adc_in=> bat_adc_in,
            Pileup_sp_T =>Pileup_ce_T,
            GM_En=>GM_En,
            Neutron_En=>Domino_En,
            Det_label=>Det_label,
            R_Counter_RAM =>R_Counter_RAM,            
            MEASURED_TEMP_in=> MEASURED_TEMP_Buf,
            MEASURED_VCCAUX_in=>MEASURED_VCCAUX_Buf, 
            MEASURED_VCCINT_in=> MEASURED_VCCINT_Buf,
            MEASURED_VCCBRAM_in=>  MEASURED_VCCBRAM_Buf,
            MEASURED_AUX0_in=> MEASURED_AUX0_Buf,
            MEASURED_AUX1_in=> MEASURED_AUX1_Buf,
            MEASURED_AUX2_in=> MEASURED_AUX2_Buf,
            MEASURED_AUX3_in=> Adc_data,
            GC=>GC, 
            HV_DAC=>HV_DAC,

			HV_buf_Sm =>HV_buf_Sm,
			Bat_Status_in =>Bat_Status_in,
			flag_ram=>flag_ram,
			
			data_in_1  => dout_CH,
     
			Spec_out =>Spec_out 
		);	

process(clk_main)
begin
    if(rising_edge(clk_main))then
        i_GM_count <= i_GM_count(0)&pin_trig_signal;
    end if;
end process;

process(clk_main)
begin
    if(rising_edge(clk_main))then
        if(sleep_en = '1') then
        --------------------time-----------
            if(gm_time_count = 50000000) then  --1s
                Gm_count_read <= '1';
                gm_time_count <= 0;
            elsif(gm_time_count = 5) then
                Gm_count_out <= (others => '0');
                gm_time_count <= gm_time_count + 1;
            else
                Gm_count_read <= '0';
                gm_time_count <= gm_time_count + 1;
                if(i_GM_count = "01") then
                    Gm_count_out <= Gm_count_out + 1;
                end if;
            end if;        
           
        else --------------------sleep_en = '0'--------------------
            Gm_count_read <= '0';
            gm_time_count <= 0;
            Gm_count_out <= (others => '0');
        end if;    
    end if;
end process;

process(clk_main)
begin
    if(rising_edge(clk_main))then
        if(Gm_count_out > 2)then
            Gm_count <= "00000011";
        elsif(Gm_count_out = 2) then
             Gm_count <= "00000010";
        elsif(Gm_count_out = 1) then
             Gm_count <= "00000001";
        elsif(Gm_count_out = 0) then
             Gm_count <= "00000000";            
        end if;    
    end if;
end process;		
process(clk_main)
begin
    if(rising_edge(clk_main))then
        Gm_count_read_pipe <= Gm_count_read_pipe(0) & Gm_count_read;
    end if;
end process;

process(clk_main)
begin
    if(rising_edge(clk_main))then
        if(sleep_en = '1') then
            if(Gm_count_read_pipe = "01")then
                Gm_count_pre_1s <= Gm_count;
                Gm_count_pre_2s <= Gm_count_pre_1s;
                Gm_count_pre_3s <= Gm_count_pre_2s;
                Gm_count_pre_4s <= Gm_count_pre_3s;
                Gm_count_pre_5s <= Gm_count_pre_4s;
                Gm_count_pre_6s <= Gm_count_pre_5s;
                Gm_count_pre_7s <= Gm_count_pre_6s;
                Gm_count_pre_8s <= Gm_count_pre_7s;
                Gm_count_pre_9s <= Gm_count_pre_8s;
                Gm_count_pre_10s <= Gm_count_pre_9s;
                Gm_count_pre_11s <= Gm_count_pre_10s;
                Gm_count_pre_12s <= Gm_count_pre_11s;
                Gm_count_pre_13s <= Gm_count_pre_12s;
                Gm_count_pre_14s <= Gm_count_pre_13s;
                Gm_count_pre_15s <= Gm_count_pre_14s;
                Gm_count_pre_16s <= Gm_count_pre_15s;
                Gm_count_pre_17s <= Gm_count_pre_16s;
                Gm_count_pre_18s <= Gm_count_pre_17s;
                Gm_count_pre_19s <= Gm_count_pre_18s;
                Gm_count_pre_20s <= Gm_count_pre_19s;
                Gm_count_pre_21s <= Gm_count_pre_20s;
                Gm_count_pre_22s <= Gm_count_pre_21s;
                Gm_count_pre_23s <= Gm_count_pre_22s;
                Gm_count_pre_24s <= Gm_count_pre_23s;
                Gm_count_pre_25s <= Gm_count_pre_24s;
                Gm_count_pre_26s <= Gm_count_pre_25s;
                Gm_count_pre_27s <= Gm_count_pre_26s;
                Gm_count_pre_28s <= Gm_count_pre_27s;
                Gm_count_pre_29s <= Gm_count_pre_28s;
                Gm_count_pre_30s <= Gm_count_pre_29s;
          
            end if;   
        else
             Gm_count_pre_1s <= (others =>'0');
             Gm_count_pre_2s <= (others =>'0');
             Gm_count_pre_3s <= (others =>'0');
             Gm_count_pre_4s <= (others =>'0');
             Gm_count_pre_5s <= (others =>'0');
             Gm_count_pre_6s <= (others =>'0');
             Gm_count_pre_7s <= (others =>'0');
             Gm_count_pre_8s <= (others =>'0');
             Gm_count_pre_9s <= (others =>'0');
             Gm_count_pre_10s <= (others =>'0');
             Gm_count_pre_11s <= (others =>'0');
             Gm_count_pre_12s <= (others =>'0');
             Gm_count_pre_13s <= (others =>'0');
             Gm_count_pre_14s <= (others =>'0');
             Gm_count_pre_15s <= (others =>'0');
             Gm_count_pre_16s <= (others =>'0');
             Gm_count_pre_17s <= (others =>'0');
             Gm_count_pre_18s <= (others =>'0');
             Gm_count_pre_19s <= (others =>'0');
             Gm_count_pre_20s <= (others =>'0');
             Gm_count_pre_21s <= (others =>'0');
             Gm_count_pre_22s <= (others =>'0');
             Gm_count_pre_23s <= (others =>'0');
             Gm_count_pre_24s <= (others =>'0');
             Gm_count_pre_25s <= (others =>'0');
             Gm_count_pre_26s <= (others =>'0');
             Gm_count_pre_27s <= (others =>'0');
             Gm_count_pre_28s <= (others =>'0');
             Gm_count_pre_29s <= (others =>'0');
             Gm_count_pre_30s <= (others =>'0');
             
        end if;     
    end if;
end process;

process(clk_main)
begin
    if(rising_edge(clk_main))then
        Gm_count_pre_sum <=    Gm_count_pre_1s + Gm_count_pre_2s + Gm_count_pre_3s + Gm_count_pre_4s + Gm_count_pre_5s 
                              +Gm_count_pre_6s + Gm_count_pre_7s + Gm_count_pre_8s + Gm_count_pre_9s + Gm_count_pre_10s
                              +Gm_count_pre_11s+Gm_count_pre_12s+Gm_count_pre_13s+Gm_count_pre_14s+Gm_count_pre_15s
                              +Gm_count_pre_16s+Gm_count_pre_17s+Gm_count_pre_18s+Gm_count_pre_19s+Gm_count_pre_20s
                              +Gm_count_pre_21s+Gm_count_pre_22s+Gm_count_pre_23s+Gm_count_pre_24s+Gm_count_pre_25s
                              +Gm_count_pre_26s+Gm_count_pre_27s+Gm_count_pre_28s+Gm_count_pre_29s+Gm_count_pre_30s;
    end if;
end process;
process(clk_main)
begin
    if(rising_edge(clk_main))then
        if(sleep_en = '1') then
            if(Gm_count_pre_sum > 1) then
--                led_green <= '1';
            else
--                led_green <= '0';
            end if; 
        else
--            led_green <= '0';
        end if;    
    end if;
end process;


i_Smoothing_Shifter  : Smoothing_Shifter 
PORT map(
	 clk=> clk_Main,	
	rst=>'1',
	acq_start=>acq_start,
	data_in=>ADC_inv_buf,
	Trapezoidal_out =>Trapezoidal_out	
	);


--i_ug480 : ug480 
--PORT map
--   (
--    DCLK               =>  clk_XADC,                         -- Clock input for the dynamic reconfiguration port
--    RESET             => XADC_Rst,                        -- Reset signal for the System Monitor control logic
--    VAUXP => VAUXP,
--    VAUXN => VAUXN,
    
--    VP =>'0',
--    VN =>'0',

--    MEASURED_TEMP     =>MEASURED_TEMP, 
--    MEASURED_VCCAUX   =>MEASURED_VCCAUX,
--    MEASURED_VCCINT   =>MEASURED_VCCINT,
--    MEASURED_VCCBRAM  =>MEASURED_VCCBRAM,
--    MEASURED_AUX0    => MEASURED_AUX0,
--    MEASURED_AUX1     =>MEASURED_AUX1, -- HV
--    MEASURED_AUX2     =>MEASURED_AUX2,
--    MEASURED_AUX3     =>MEASURED_AUX3, --Temp

--    ALM               => ALM,
--    CHANNEL            => CHANNEL,
--    OT                 => OT,
--    EOC        => EOC,
--    EOS         => EOS
--);

--i_xadc_wiz_0 : xadc_wiz_0 
--  PORT map
--   (
--    dclk_in         =>  clk_XADC,                         -- Clock input for the dynamic reconfiguration port
--    reset_in        => '0',                          -- Reset signal for the System Monitor control logic
--    vauxp0           => VAUXP(0),                     -- Auxiliary Channel 0
--    vauxn0           => VAUXN(0),
--    vauxp1          => VAUXP(1),                         -- Auxiliary Channel 1
--    vauxn1           => VAUXN(1),
--    vauxp2         => VAUXP(2),                          -- Auxiliary Channel 2
--    vauxn2          => VAUXN(2),
--    vauxp3          => VAUXP(3),                         -- Auxiliary Channel 3
--    vauxn3          => VAUXN(3),
--    busy_out        => open,                      -- ADC Busy signal
--    channel_out      => open,    -- Channel Selection Outputs
--    eoc_out          => open,                        -- End of Conversion Signal
--    eos_out          => open,                       -- End of Sequence Signal
--    ot_out           => open,                       -- Over-Temperature alarm output
--    vccaux_alarm_out  => open,                      -- VCCAUX-sensor alarm output
--    vccint_alarm_out  => open,                      -- VCCINT-sensor alarm output
--    user_temp_alarm_out  => open,                        -- Temperature-sensor alarm output
--    alarm_out        => open,                        -- OR'ed output of all the Alarms
--    vp_in           =>'0',                    -- Dedicated Analog Input Pair
--    vn_in            =>'0'
--);





process(clk_100ms_T)
	begin
		if rising_edge(clk_100ms_T) then
			
	--	if acq_start = '1' then
			if cnt = 10 then
		
				cnt_on <= '0';
				cnt<=0;	
                 MEASURED_TEMP_Buf <=    MEASURED_TEMP;
                MEASURED_VCCAUX_Buf  <=   MEASURED_VCCAUX;
                MEASURED_VCCINT_Buf  <=   MEASURED_VCCINT;
                MEASURED_VCCBRAM_Buf <=   MEASURED_VCCBRAM;
                MEASURED_AUX0_Buf  <=    MEASURED_AUX0;
                MEASURED_AUX1_Buf  <=   MEASURED_AUX1; -- HV
                MEASURED_AUX2_Buf   <=   MEASURED_AUX2;
                MEASURED_AUX3_Buf    <=   MEASURED_AUX3;--Temp			
                   
                   		
			elsif cnt = 9 then	
			     XADC_Rst<='0';
			     cnt<=cnt+1;
			else
		      
                cnt<=cnt+1;				
		        XADC_Rst<='1';
			end if;
	--	end if;
		end if;
end process;






process(clk_uart) --UART_TX
begin
    
	if rising_edge(clk_uart) then
		
	case UART_state is
     when UART_idle =>		
		cnt_DV <= 0;
         r_TX_DV   <= '0';
		acq_rd_clk<='0';
          Header_Counter <="000"; 
          Tail_counter<="000";
          TX_Hold_count<=0;  
          
         SC_Counter<="00000";  
         GS_Counter<="000000";  
         i_GS_on(0)<=GS_on;
         i_GS_on(1)<=i_GS_on(0);
         
		if  acq_start = '1' then
            if Time_counter = 10000000 then
                  UART_state  <= UART_Header_Trans;
                  Time_counter<=0;
                       
                   acq_take<='1';
	         else
	           Time_counter <= Time_counter + 1;
	           acq_take<='0';
	         end if;   
	     elsif  SC_start = '1' then
            if Time_counter = 1000000 then
                  UART_state  <= UART_SC_Trans;
                  Time_counter<=0;
                  SC_CH<=Ch_all;     
                   SC_take<='1';
                  if SC_Stamp = "1111111111111111" then
                     SC_Stamp<= "0000000000000000";
                   else  
                    SC_Stamp<=SC_Stamp+'1';
                  end if;  
                   SC_Time<=SC_Time_counter;
                   SC_Time_counter<="00000000000000000000000000000000";
	         else
	        
	         
	           Time_counter <= Time_counter + 1;
	           SC_take<='0';
	           SC_Time_counter<=SC_Time_counter + '1';
	         end if;   	         
	         
         else
          if i_GS_on(0) > i_GS_on(1) then
	           UART_state  <= UART_GS_Trans;
	         end if;  
           acq_take<='0';  
           SC_take<='0';              
            Time_counter<=0;
            SC_Stamp<="0000000000000000";
            SC_Time_counter<="00000000000000000000000000000000";
         end if;
		
	 when Uart_1st_Trans =>		
		 r_TX_DV   <= '1';     
       
          r_TX_BYTE<=Spec_out(15 downto 8);
            
          UART_state  <=UART_1st_Trans_Hold;
         Time_counter <= Time_counter + 1;
    when UART_1st_Trans_Hold =>	  
           r_TX_DV   <= '0';    
          if  w_TX_DONE = '1' then
               acq_rd_clk<='0';
              UART_state  <= UART_2nd_Trans;
           
          end if;
          Time_counter <= Time_counter + 1;
     when UART_2nd_Trans =>       
  		 r_TX_DV   <= '1';     
       
          r_TX_BYTE<=Spec_out(7 downto 0);
            
          UART_state  <=UART_2nd_Trans_Hold;
         Time_counter <= Time_counter + 1;                         

		 
	    when UART_2nd_Trans_Hold =>	  	 
           r_TX_DV   <= '0';    
     
          if  w_TX_DONE = '1' then
          
            if TX_count = 2082 then
                
                TX_count<=0;
                UART_state  <= UART_Tail_Trans;    
                --XADC_Rst<='0';    
                                           
            elsif TX_count = 0 then
                 TX_count<=TX_count+1;
                 UART_state  <= UART_1st_Trans;
                                         
            else       
                acq_rd_clk <='1';
                 TX_count<=TX_count+1;
                 UART_state  <= UART_1st_Trans;
            end if;
          end if;
	     Time_counter <= Time_counter + 1; 
	when UART_Header_Trans =>
	       r_TX_DV   <= '1';     
       
          r_TX_BYTE<=X"55";--ASCII "U"
            
          UART_state  <=UART_Header_Trans_Hold;
         Time_counter <= Time_counter + 1;
         
	when UART_Header_Trans_Hold =>	
		r_TX_DV   <= '0';    
          if  w_TX_DONE = '1' then
              
              UART_state  <= UART_2nd_Header_Trans;
           
          end if;
          Time_counter <= Time_counter + 1;
          
 	when UART_2nd_Header_Trans =>         
	       r_TX_DV   <= '1';     
	       r_TX_BYTE<=X"55";--ASCII "U"
--       if Header_Counter ="000" then
--          r_TX_BYTE<=X"30";--ASCII "0"
--       elsif Header_Counter ="001" then    
--          r_TX_BYTE<=X"31";--ASCII "1"  
--       elsif Header_Counter ="010" then    
--          r_TX_BYTE<=X"32";--ASCII "2"            
--       elsif Header_Counter ="011" then    
--          r_TX_BYTE<=X"33";--ASCII "3"            
--        elsif Header_Counter ="100" then    
--          r_TX_BYTE<=X"34";--ASCII "4"   
--        end if;   
                        
         UART_state  <=UART_2nd_Trans_Hold;
         Time_counter <= Time_counter + 1;  
         Header_Counter<=Header_Counter +'1';   
    
	when UART_Tail_Trans =>	 	
	       r_TX_DV   <= '1';     
       
          r_TX_BYTE<=X"46"; --ASCII "F"
            
          UART_state  <=UART_Tail_Trans_Hold;
         Time_counter <= Time_counter + 1;
         
 	when UART_Tail_Trans_Hold =>	
		r_TX_DV   <= '0';    
          if  w_TX_DONE = '1' then
              
              UART_state  <= UART_2nd_Tail_Trans;
           
          end if;
          Time_counter <= Time_counter + 1;        	
	when UART_2nd_Tail_Trans =>	 	
	       r_TX_DV   <= '1';     
       
          r_TX_BYTE<=X"46"; --ASCII "F"
 
            Tail_counter<="000";
             UART_state  <=UART_end;
   
         
         Time_counter <= Time_counter + 1;	 
     when UART_Hold_Timer=>
           Time_counter <= Time_counter + 1;	
--          if TX_Hold_count =  10000 then -- 1ms --TEST
          if TX_Hold_count =  50000 then -- 5ms -- SPRD
             TX_Hold_count<=0;
             UART_state  <=UART_Header_Trans;
          else
             TX_Hold_count<=TX_Hold_count+1;
          end if;   

 when UART_SC_Trans=>
       r_TX_DV   <= '1';     
       if SC_Counter ="0000" then
          r_TX_BYTE<=X"4C";--ASCII "L"
          UART_state  <=UART_SC_Trans_Hold;         
       elsif SC_Counter ="0001" then    
          r_TX_BYTE<=X"53";--ASCII "S" 
          UART_state  <=UART_SC_Trans_Hold;   
       elsif SC_Counter ="0010" then    
          r_TX_BYTE<=SC_CH(31 downto 24);  
          UART_state  <=UART_SC_Trans_Hold;             
       elsif SC_Counter ="0011" then    
          r_TX_BYTE<=SC_CH(23 downto 16);  
          UART_state  <=UART_SC_Trans_Hold;            
        elsif SC_Counter ="0100" then    
          r_TX_BYTE<=SC_CH(15 downto 8);  
          UART_state  <=UART_SC_Trans_Hold;    
        elsif SC_Counter ="0101" then    
          r_TX_BYTE<=SC_CH(7 downto 0);    
          UART_state  <=UART_SC_Trans_Hold;          
         elsif SC_Counter ="0110" then    
          r_TX_BYTE<=SC_time(31 downto 24);   
          UART_state  <=UART_SC_Trans_Hold;            
       elsif SC_Counter ="0111" then    
          r_TX_BYTE<=SC_time(23 downto 16);  
          UART_state  <=UART_SC_Trans_Hold;            
        elsif SC_Counter ="1000" then    
          r_TX_BYTE<=SC_time(15 downto 8);    
          UART_state  <=UART_SC_Trans_Hold;  
        elsif SC_Counter ="1001" then    
          r_TX_BYTE<=SC_time(7 downto 0);   
          UART_state  <=UART_SC_Trans_Hold;  
        elsif SC_Counter ="1010" then    
          r_TX_BYTE<=SC_stamp(15 downto 8); 
          UART_state  <=UART_SC_Trans_Hold;     
        elsif SC_Counter ="1011" then    
          r_TX_BYTE<=SC_stamp(7 downto 0);   
          UART_state  <=UART_SC_Trans_Hold;            
        elsif SC_Counter ="1100" then    
          r_TX_BYTE<=X"36";--ASCII "6"   
          UART_state  <=UART_SC_Trans_Hold;  
        elsif SC_Counter ="1101" then    
          r_TX_BYTE<=X"36";--ASCII "6"    
          UART_state  <=UART_end;          
        end if;   
                        
        SC_Time_counter<=SC_Time_counter + '1';
         Time_counter <= Time_counter + 1;  
         SC_Counter<=SC_Counter +'1';   

	when UART_SC_Trans_Hold =>	
		r_TX_DV   <= '0';    
          if  w_TX_DONE = '1' then
              
              UART_state  <= UART_SC_Trans;
           
          end if;
          Time_counter <= Time_counter + 1;
         SC_Time_counter<=SC_Time_counter + '1';    
         
     when UART_GS_Trans=>       
        r_TX_DV   <= '1';     
       if GS_Counter ="0000" then
          r_TX_BYTE<=X"47";--ASCII "G"
          UART_state  <=UART_GS_Trans_Hold;         
       elsif GS_Counter ="0001" then    
          r_TX_BYTE<=X"44";--ASCII "D" 
          UART_state  <=UART_GS_Trans_Hold;   
       elsif GS_Counter ="0010" then    
          r_TX_BYTE<=GC(15 downto 8);--GC
          UART_state  <=UART_GS_Trans_Hold;             
       elsif GS_Counter ="0011" then    
          r_TX_BYTE<=GC(7 downto 0);--GC
          UART_state  <=UART_GS_Trans_Hold;             
       elsif GS_Counter ="0100" then    
          r_TX_BYTE<=K40_1460KeV(15 downto 8);--K40_1460KeV
          UART_state  <=UART_GS_Trans_Hold;   
       elsif GS_Counter ="0101" then    
          r_TX_BYTE<=K40_1460KeV(7 downto 0);--K40_1460KeV
          UART_state  <=UART_GS_Trans_Hold;                 
       elsif GS_Counter ="0110" then    
          r_TX_BYTE<=Det_label(15 downto 8);--Det_label
          UART_state  <=UART_GS_Trans_Hold;   
       elsif GS_Counter ="0111" then    
          r_TX_BYTE<=Det_label(7 downto 0);--Det_label
          UART_state  <=UART_GS_Trans_Hold;     
       elsif GS_Counter ="1000" then    
          r_TX_BYTE<=Cs137_32KeV(15 downto 8);--Cs137_32KeV
          UART_state  <=UART_GS_Trans_Hold;   
       elsif GS_Counter ="1001" then    
          r_TX_BYTE<=Cs137_32KeV(7 downto 0);--Cs137_32KeV
          UART_state  <=UART_GS_Trans_Hold;                 
       elsif GS_Counter ="1010" then    
          r_TX_BYTE<=Cs137_662KeV(15 downto 8);--Cs137_662KeV
          UART_state  <=UART_GS_Trans_Hold;   
       elsif GS_Counter ="1011" then    
          r_TX_BYTE<=Cs137_662KeV(7 downto 0);--Cs137_662KeV
          UART_state  <=UART_GS_Trans_Hold;  
          
       elsif GS_Counter ="1100" then    
          r_TX_BYTE<=Serial_1;
          UART_state  <=UART_GS_Trans_Hold;  
          elsif GS_Counter ="1101" then    
          r_TX_BYTE<=Serial_2;
          UART_state  <=UART_GS_Trans_Hold;
          elsif GS_Counter ="1110" then    
          r_TX_BYTE<=Serial_3;
          UART_state  <=UART_GS_Trans_Hold;
          elsif GS_Counter ="1111" then    
          r_TX_BYTE<=Serial_4;
          UART_state  <=UART_GS_Trans_Hold;
          elsif GS_Counter ="10000" then    
          r_TX_BYTE<=X"54"; -- T(ASCII)
          UART_state  <=UART_GS_Trans_Hold;
          elsif GS_Counter ="10001" then    
          r_TX_BYTE<="0000"&Adc_data(15 downto 12);--temp
          UART_state  <=UART_GS_Trans_Hold;
          elsif GS_Counter ="10010" then    
          r_TX_BYTE<=Adc_data(11 downto 4); --temp
          UART_state  <=UART_GS_Trans_Hold;
          elsif GS_Counter ="10011" then    
          r_TX_BYTE<=BNC_Serial_1;
          UART_state  <=UART_GS_Trans_Hold;        
           elsif GS_Counter ="10100" then    
          r_TX_BYTE<=BNC_Serial_2;
          UART_state  <=UART_GS_Trans_Hold;             
           elsif GS_Counter ="10101" then    
          r_TX_BYTE<=BNC_Serial_3;
          UART_state  <=UART_GS_Trans_Hold;             
          elsif GS_Counter ="10110" then    
          r_TX_BYTE<=BNC_Serial_4;
          UART_state  <=UART_GS_Trans_Hold;              
           elsif GS_Counter ="10111" then    
          r_TX_BYTE<=BNC_Serial_5;
          UART_state  <=UART_GS_Trans_Hold;             
            elsif GS_Counter ="11000" then    
          r_TX_BYTE<=BNC_Serial_6;
          UART_state  <=UART_GS_Trans_Hold;    
          
                    
          elsif GS_Counter ="11001" then    
          r_TX_BYTE<=X"00";
          UART_state  <=UART_GS_Trans_Hold;           
          
            
       elsif GS_Counter ="11010" then
          r_TX_BYTE<=X"36";--ASCII "6"
          UART_state  <=UART_GS_Trans_Hold;         
       elsif GS_Counter ="11011" then    
          r_TX_BYTE<=X"36";--ASCII "6" 
          UART_state  <=UART_end;          
           
        end if;   
                         
         GS_Counter<=GS_Counter +'1'; 
            
            
	when UART_GS_Trans_Hold =>	
		r_TX_DV   <= '0';    
          if  w_TX_DONE = '1' then
              
              UART_state  <= UART_GS_Trans;
           
          end if;              
         
                        	 
	 when UART_end =>         
	     		r_TX_DV   <= '0';    
          if  w_TX_DONE = '1' then
              
              UART_state  <= UART_idle;
           
          end if;
          Time_counter <= Time_counter + 1;  
   SC_Time_counter<=SC_Time_counter + '1';         
	  end case;             

--            if  w_RX_BYTE_out  = X"00" then
--                  MEASURED_TEMP_buf_H<="0000"&MEASURED_TEMP(15 downto 12);
--                  MEASURED_TEMP_buf_L<=MEASURED_TEMP(11 downto 4);
--              elsif   w_RX_BYTE_out  = X"01" then
--                   MEASURED_TEMP_buf_H<="0000"&MEASURED_VCCINT(15 downto 12);
--                  MEASURED_TEMP_buf_L<=MEASURED_VCCINT(11 downto 4);          
--              elsif   w_RX_BYTE_out  = X"02" then
--                   MEASURED_TEMP_buf_H<="0000"&MEASURED_VCCBRAM(15 downto 12);
--                  MEASURED_TEMP_buf_L<=MEASURED_VCCBRAM(11 downto 4); 
--              elsif   w_RX_BYTE_out  = X"03" then
--                   MEASURED_TEMP_buf_H<="0000"&MEASURED_AUX0(15 downto 12);
--                  MEASURED_TEMP_buf_L<=MEASURED_AUX0(11 downto 4);
--               elsif   w_RX_BYTE_out  = X"04" then
--                   MEASURED_TEMP_buf_H<="0000"&MEASURED_AUX1(15 downto 12);
--                  MEASURED_TEMP_buf_L<=MEASURED_AUX1(11 downto 4);
--              elsif   w_RX_BYTE_out  = X"05" then
--                   MEASURED_TEMP_buf_H<="0000"&MEASURED_AUX2(15 downto 12);
--                  MEASURED_TEMP_buf_L<=MEASURED_AUX2(11 downto 4);    
--              elsif   w_RX_BYTE_out  = X"A2" then      
--                      acq_start<='1';
--              elsif     w_RX_BYTE_out  = X"A4" then     
--                    acq_start<='0';   
--               else
--                   MEASURED_TEMP_buf_H<="0000"&MEASURED_AUX3(15 downto 12);
--                  MEASURED_TEMP_buf_L<=MEASURED_AUX3(11 downto 4);
                            
--               end if;          	
	
	
	
	end if;
	
	
	
	
end process;

process(clk_uart) --UART_RX
begin
    
	if rising_edge(clk_uart) then
	    if( cpu_detect_pipe = "10" ) then
            power_switching_en <= '1';
            eeprom_test_write_en <= '1';
        elsif( cpu_detect_pipe = "01") then 
            eeprom_test_write_en <= '0';   
        elsif(  cpu_detect_pipe = "00" ) then
            if( power_switching_end = '1') then
                power_switching_en <= '0';
            else
                
                power_switching_en <= '1';
            end if;     
        else
            power_switching_end <= '0';
            power_switching_en <= '0';  
        end if;
    
    
          if(power_switching_en  = '1' ) then   
            if( cpu_phold_buf = '0') then
                if(power_down_cnt = 10000000 - 1)then
                    power_down_cnt <= 0;
                    cpu_phold_buf <= '1';
                    power_switching_end <= '1';
                else
                    power_down_cnt <= power_down_cnt + 1;
                end if;  
            else    
                if(power_down_cnt = 200000000 - 1)then
                    power_down_cnt <= 0;
                    cpu_phold_buf <= '0';
                    power_switching_end <= '1';
                else
                    power_down_cnt <= power_down_cnt + 1;
                end if;  
            end if;            
           else
             
              power_down_cnt <= 0;
           end if;
	    	
	
		
    case UART_RX_state is
     when UART_RX_idle =>		
--            Write_GC_flag <='0';
            Write_HV_flag <='0'; 
            uart_wait_cnt <= 0;  
            Cal_read_done <= '0';         
		if  w_RX_DV = '1' then
		
		  w_RX_BYTE_out(0)<=w_RX_BYTE;
		  UART_RX_state  <= UART_1st_Command_RX;		
        end if;
     when UART_1st_Command_RX =>	  
          if  w_RX_DV = '1' then
              w_RX_BYTE_out(1)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_Command;		
          else
              if uart_wait_cnt = 10000000 then
                 w_RX_BYTE_out(0) <= (others => '0');
                 w_RX_BYTE_out(1) <= (others => '0'); 	
                 UART_RX_state  <= UART_RX_idle;
              else
                 uart_wait_cnt <= uart_wait_cnt + 1;
              end if;     
          end if;
     when  UART_RX_Command=>
           if w_RX_BYTE_out(0) = X"41" and w_RX_BYTE_out(1) = X"32" then -- ASCII "A2"
                acq_start <='1';
                --rst <= '1';
                HV_Enable <= '1';          
                Adc_sleep <= '0';
                sleep_en <= '0';
                UART_RX_state  <= UART_RX_end;
           elsif    w_RX_BYTE_out(0) = X"41" and w_RX_BYTE_out(1) = X"34" then -- ASCII "A4"   
                 acq_start <='0';
                -- rst <= '1';
                 UART_RX_state  <= UART_RX_end;
           elsif  w_RX_BYTE_out(0) = X"47" and w_RX_BYTE_out(1) = X"43" then -- ASCII "GC" 
                 UART_RX_state  <= UART_RX_1st;
           elsif  w_RX_BYTE_out(0) = X"43" and w_RX_BYTE_out(1) = X"4C" then -- ASCII "CL" 
                 UART_RX_state  <= UART_RX_cl_1st;           
           elsif  w_RX_BYTE_out(0) = X"53" and w_RX_BYTE_out(1) = X"55" then -- ASCII "SU" 
                 UART_RX_state  <=  UART_RX_1st;   
                 SW_Write_init<='1';
         
           elsif  w_RX_BYTE_out(0) = X"47" and w_RX_BYTE_out(1) = X"50" then -- ASCII "GP"
                 UART_RX_state  <=  UART_RX_end; 
           elsif  w_RX_BYTE_out(0) = X"50" and w_RX_BYTE_out(1) = X"50" then -- ASCII "PP" 
                 
                 UART_RX_state  <=  UART_RX_end;  
        
            elsif  w_RX_BYTE_out(0) = X"53" and w_RX_BYTE_out(1) = X"4C" then -- ASCII "SL"
                 UART_RX_state  <=  UART_RX_end;     
                 --rst <= '1';       
                 sleep_en <= '1';
                 acq_start <='0';     
                   HV_Enable <= '0';          
                   Adc_sleep <= '1';
             elsif  w_RX_BYTE_out(0) = X"41" and w_RX_BYTE_out(1) = X"4B" then -- ASCII "AK" 
                acq_start <='1';
                 UART_RX_state  <=  UART_RX_end;   
                 HV_Enable <= '1';          
                   Adc_sleep <= '0';      
                   sleep_en <= '0';
            elsif  w_RX_BYTE_out(0) = X"53" and w_RX_BYTE_out(1) = X"43" then -- ASCII "SC"
                 UART_RX_state  <=  UART_RX_end;                 
                  SC_Start<='1';       
                               
            elsif  w_RX_BYTE_out(0) = X"53" and w_RX_BYTE_out(1) = X"50" then -- ASCII "SP"
                 UART_RX_state  <=  UART_RX_end;                 
                   SC_Start<='0';                      
 
             elsif  w_RX_BYTE_out(0) = X"47" and w_RX_BYTE_out(1) = X"53" then -- ASCII "GS"
                 UART_RX_state  <=  UART_RX_end;                 
                 GS_on <= '1';     
                                 
           elsif  w_RX_BYTE_out(0) = X"50" and w_RX_BYTE_out(1) = X"44" then -- ASCII "PD" 
             --    w_TX_SERIAL_Bat <= '0'; 
                 cpu_phold_buf  <= '0';    
                 UART_RX_state  <=  UART_RX_end;  
           else
             UART_RX_state  <= UART_RX_end;	
           end if;    
            		
     when  UART_RX_1st=>           
             if  w_RX_DV = '1' then
		
              w_RX_BYTE_out(2)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_2nd;		
            end if;
    when  UART_RX_2nd=>  
             if  w_RX_DV = '1' then
		
              w_RX_BYTE_out(3)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_3rd;		
            end if;
     when  UART_RX_3rd=>  
             if  w_RX_DV = '1' then
		
              w_RX_BYTE_out(4)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_4th;		
            end if;   
     when  UART_RX_4th=>  
             if  w_RX_DV = '1' then
		
              w_RX_BYTE_out(5)<=w_RX_BYTE;
              if SW_Write_init = '1' then
                  UART_RX_state  <= UART_RX_5th;
                  
              else
                UART_RX_state  <= UART_RX_end;
             
                if 	w_RX_BYTE = X"01" then
--                    GC(15 downto 8)<=w_RX_BYTE_out(2);
--                    GC(7 downto 0)<=w_RX_BYTE_out(3);
--                    Write_GC_flag <='1';
                    
               else
                    HV_DAC(15 downto 8)<=w_RX_BYTE_out(2);
                    HV_DAC(7 downto 0)<=w_RX_BYTE_out(3);
                    Write_HV_flag <='1';                           
                 end if;   
              end if;  		
            end if;   
            
     when  UART_RX_5th=>  
             if  w_RX_DV = '1' then
		
              w_RX_BYTE_out(6)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_6th;		
            end if;                 
      when  UART_RX_6th=>  
             if  w_RX_DV = '1' then
		
              w_RX_BYTE_out(7)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_7th;		
            end if;                
      when  UART_RX_7th=>  
             if  w_RX_DV = '1' then
		
              w_RX_BYTE_out(8)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_8th;		
            end if;                
            
      when  UART_RX_8th=>  
             if  w_RX_DV = '1' then
		
              w_RX_BYTE_out(9)<=w_RX_BYTE;
              UART_RX_state  <=UART_RX_9th;		
            end if;                
        when  UART_RX_9th=>  
             if  w_RX_DV = '1' then
		
              w_RX_BYTE_out(10)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_10th;		
            end if;                
         when  UART_RX_10th=>  
             if  w_RX_DV = '1' then
		
              w_RX_BYTE_out(11)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_end;		
--               Write_GC_flag <='1';
               Write_HV_flag <='1';
                if 	w_RX_BYTE = X"36" then
--                    GC(15 downto 8)<=w_RX_BYTE_out(6);
--                    GC(7 downto 0)<=w_RX_BYTE_out(7);
--                    if HV_Fix = '0' then
                        HV_DAC(15 downto 8)<=w_RX_BYTE_out(4);
                        HV_DAC(7 downto 0)<=w_RX_BYTE_out(5);        
--                    elsif HV_Fix = '1' then         
--                        HV_ADC(11 downto 8)<= w_RX_BYTE_out(8)(3 downto 0);             
--                        HV_ADC(7 downto 0)<= w_RX_BYTE_out(9);                     
--                    end if;       
                 end if;    
            end if;                         
      when  UART_RX_cl_1st=>     
             Cal_read_done <= '0';     
             if  w_RX_DV = '1' then
		
              GC_cal_data(15 downto 8)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_cl_2nd;		
            end if;
      when  UART_RX_cl_2nd=>   
       Cal_read_done <= '0';        
             if  w_RX_DV = '1' then
		
              GC_cal_data(7 downto 0)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_cl_3rd;		
            end if;
      when  UART_RX_cl_3rd=>           
       Cal_read_done <= '0';
             if  w_RX_DV = '1' then
		
              temp_cal_data(15 downto 8)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_cl_4th;		
            end if;
      when  UART_RX_cl_4th=>   
       Cal_read_done <= '0';        
             if  w_RX_DV = '1' then
		
              temp_cal_data(7 downto 0)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_cl_5th;		
            end if;  
      when  UART_RX_cl_5th=>    
       Cal_read_done <= '0';       
             if  w_RX_DV = '1' then
		
              peak32_cal_data(15 downto 8)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_cl_6th;		
            end if;
      when  UART_RX_cl_6th=>  
       Cal_read_done <= '0';         
             if  w_RX_DV = '1' then
		
              peak32_cal_data(7 downto 0)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_cl_7th;		
            end if; 
      when  UART_RX_cl_7th=>     
       Cal_read_done <= '0';      
             if  w_RX_DV = '1' then
		
              peak662_cal_data(15 downto 8)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_cl_8th;		
            end if;
      when  UART_RX_cl_8th=> 
       Cal_read_done <= '0';          
             if  w_RX_DV = '1' then
		
              peak662_cal_data(7 downto 0)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_cl_9th;		
            end if; 
      when  UART_RX_cl_9th=>  
       Cal_read_done <= '0';         
             if  w_RX_DV = '1' then
		
              peak1460_cal_data(15 downto 8)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_cl_10th;		
            end if;
      when  UART_RX_cl_10th=>     
       Cal_read_done <= '0';      
             if  w_RX_DV = '1' then
		
              peak1460_cal_data(7 downto 0)<=w_RX_BYTE;
              UART_RX_state  <= UART_RX_cl_11th;		
              
            end if;
      when  UART_RX_cl_11th=>  
              Cal_read_done <= '1';         
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_12th;    --reserve
             end if; 
      when  UART_RX_cl_12th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_13th;    --reserve
             end if;
      when  UART_RX_cl_13th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_14th;    --reserve
             end if;
      when  UART_RX_cl_14th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_15th;    --reserve
             end if;
      when  UART_RX_cl_15th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_16th;    --reserve
             end if;
      when  UART_RX_cl_16th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_17th;    --reserve
             end if;
      when  UART_RX_cl_17th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_18th;    --reserve
             end if;
      when  UART_RX_cl_18th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_19th;    --reserve
             end if;
      when  UART_RX_cl_19th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_20th;    --reserve
             end if;
      when  UART_RX_cl_20th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_21th;    --reserve
             end if;
      when  UART_RX_cl_21th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_22th;    --reserve
             end if;
      when  UART_RX_cl_22th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_23th;    --reserve
             end if;
      when  UART_RX_cl_23th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_24th;    --reserve
             end if;
      when  UART_RX_cl_24th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_25th;    --reserve
             end if;
      when  UART_RX_cl_25th=>           
             if  w_RX_DV = '1' then
              UART_RX_state  <= UART_RX_cl_26th;    --reserve
             end if;
      when  UART_RX_cl_26th=>       
                 
             if  w_RX_DV = '1' then
               Cal_read_done <= '1';
              UART_RX_state  <= UART_RX_end;    --reserve
             end if;
                                                                                                                                                          
      when   UART_RX_end=>
            SW_Write_init <='0'; 
            GS_on <= '0';
            UART_RX_state  <= UART_RX_idle;                             
	when others => UART_RX_state  <= UART_RX_idle;
	end case;
	
	
   
 
  case HV_Contr_state is
     when  HV_Contr_idle =>	
       if HV_Contr_Rdy='1' then 
           if cnt_HV_Contr = 500000 then 
            -- HV_Contr_state<= HV_Contr_comp;
               cnt_HV_Contr <= 0;
            elsif  cnt_HV_Contr = 400000 then              
            cnt_HV_Contr<=cnt_HV_Contr +1;             
         --   XADC_Rst<='0';    
             elsif  cnt_HV_Contr = 0 then              
            cnt_HV_Contr<=cnt_HV_Contr +1;             
         --   XADC_Rst<='1';              
                       
            else

            cnt_HV_Contr<=cnt_HV_Contr +1;
           end if;    
       end if;
          
       when  HV_Contr_comp =>	    
      
        if HV_ADC > HV_buf + "101000" then
            HV_Contr_state<= HV_Contr_Incr;
            HV_Gap <= HV_ADC - HV_buf;
        elsif HV_buf  > HV_ADC + "101000" then
             HV_Contr_state<= HV_Contr_dicr;
             HV_Gap <= HV_buf - HV_ADC;
        else
            if HV_ADC > HV_buf then
             HV_Contr_state<= HV_Contr_Incr_short;
             HV_Gap <= HV_ADC - HV_buf;
            elsif  HV_ADC < HV_buf then
             HV_Contr_state<= HV_Contr_dicr_short;
              HV_Gap <= HV_buf - HV_ADC;            
            elsif  HV_ADC = HV_buf then
              HV_Contr_state<= HV_Contr_Watch;  
  
            end if;   
        end if;
     
          
     when  HV_Contr_Incr =>	       
            HV_DAC <= HV_DAC + (HV_Gap&"0000");  
            HV_Contr_Write_HV_flag<='1';    
             HV_Contr_state<= HV_Contr_hold;
     when   HV_Contr_dicr =>	  
           HV_DAC <= HV_DAC - (HV_Gap&"0000");      
            HV_Contr_Write_HV_flag<='1';     
            HV_Contr_state<= HV_Contr_hold;
     when   HV_Contr_Incr_short =>

            HV_DAC <= HV_DAC + ("00"&HV_Gap&"00");  
            HV_Contr_Write_HV_flag<='1';   
            HV_Contr_state<= HV_Contr_hold;
     when   HV_Contr_dicr_short =>            
            HV_DAC<= HV_DAC - ("00"&HV_Gap&"00");             
            HV_Contr_Write_HV_flag<='1';  
            HV_Contr_state<= HV_Contr_hold;                
     when   HV_Contr_Incr_short_LPF =>
            HV_DAC <= HV_DAC + ("000"&HV_Gap&"0");  
            HV_Contr_Write_HV_flag<='1';   
            HV_Contr_state<= HV_Contr_hold;
     when   HV_Contr_dicr_short_LPF =>            
            HV_DAC<= HV_DAC - ("000"&HV_Gap&"0");             
            HV_Contr_Write_HV_flag<='1';  
            HV_Contr_state<= HV_Contr_hold;               
                            
      when   HV_Contr_hold =>     
        if cnt_HV_Contr = 500000 then
           HV_Contr_state<= HV_Contr_comp;
           cnt_HV_Contr <= 0;
           HV_Contr_Write_HV_flag<='0';
        elsif  cnt_HV_Contr = 400000 then              
            cnt_HV_Contr<=cnt_HV_Contr +1;             
         --   XADC_Rst<='0';            
         elsif cnt_HV_Contr = 0 then  
            cnt_HV_Contr<=cnt_HV_Contr +1;             
        --    XADC_Rst<='1';         
         else
           cnt_HV_Contr<=cnt_HV_Contr +1;
        end if;
      when  HV_Contr_Watch =>   
        if HV_ADC > HV_buf + "101000"  then        
            HV_Contr_state<= HV_Contr_Incr;
            HV_Gap <= HV_ADC - HV_buf;
        elsif HV_buf  > HV_ADC + "101000" then
             HV_Contr_state<= HV_Contr_dicr;
             HV_Gap <= HV_buf - HV_ADC;  
        else
           if HV_ADC > HV_buf + "10100"  then        
            HV_Contr_state<= HV_Contr_Incr_short_LPF;
            HV_Gap <= "000000000001";
        elsif HV_buf  > HV_ADC + "10100" then
             HV_Contr_state<= HV_Contr_dicr_short_LPF;
             HV_Gap <= "000000000001";    
        end if;        
         end if;    
       
      end case;
   
     
	
	
end if;
end process;	




process(clk_uart) -- UART Bat Recv - Test
begin
    if rising_edge(clk_uart) then
              
               
                          
--    case UART_Bat_Trans_state is
--     when UART_idle_Trans_Bat =>	   
--          r_TX_DV_Bat   <= '0';
--          if acq_start = '1' then
--                UART_Bat_Trans_state <= Uart_1st_Trans_Bat;    
--         end if;
--      when  UART_1st_Trans_Bat =>   
--		 r_TX_DV_Bat   <= '1';     
		 
--       if  Power_kill_on = '1' then
--          r_TX_BYTE_Bat<=X"BD";
--       else
--          r_TX_BYTE_Bat<=X"BF";   
--       end if;
          
--          UART_Bat_Trans_state <=UART_1st_Trans_Hold_Bat;  
          
--    when UART_1st_Trans_Hold_Bat =>	  
--           r_TX_DV_Bat   <= '0';    
--          if  w_TX_DONE_Bat = '1' then
              
--              UART_Bat_Trans_state  <= UART_end_Bat;
           
--          end if;  
--        Power_kill_en <= '0';      
--        Power_kill_on<='0';      
--   	 when UART_end_Bat =>   
--   	    if Power_kill_en = '1' then
--   	        UART_Bat_Trans_state<=UART_idle_Trans_Bat;
--   	        Power_kill_on <='1';
--   	     end if;   
--   	end case;        
    
   	case UART_Bat_state is
     when UART_idle_Bat =>	    
       if  w_RX_DV_Bat = '1' then
		  w_RX_BYTE_out_Bat_H<=w_RX_BYTE_Bat;
		  UART_Bat_state<=UART_1st_Recv_Bat;
		end if;
		 Hold_cnt<="00";
    when UART_1st_Recv_Bat =>	
    	if Hold_cnt = "11" then
    	    UART_Bat_state<= UART_1st_Recvs_Hold_Bat;
    	    Hold_cnt <= "00";
    	 else
    	    Hold_cnt <= Hold_cnt + '1';  	
    	 end if;   
    when UART_1st_Recvs_Hold_Bat =>	    
    	 if  w_RX_DV_Bat = '1' then
		  w_RX_BYTE_out_Bat_M<=w_RX_BYTE_Bat;
		  UART_Bat_state<=UART_2st_Recv_Bat;
		 end if; 
		  Hold_cnt <= "00";
    when UART_2st_Recv_Bat =>	
    	if Hold_cnt = "11" then
    	    UART_Bat_state<= UART_2st_Recvs_Hold_Bat;
    	    Hold_cnt <= "00";
    	 else
    	    Hold_cnt <= Hold_cnt + '1';  	
    	 end if;   
    when UART_2st_Recvs_Hold_Bat =>	    
    	 if  w_RX_DV_Bat = '1' then
		  w_RX_BYTE_out_Bat_L<=w_RX_BYTE_Bat;
		  UART_Bat_state<=UART_end_Bat;
		 end if; 		 
		  Hold_cnt <= "00";
     when UART_end_Bat =>
     	if Hold_cnt = "11" then
    	    UART_Bat_state<=UART_idle_Bat;
    	    Hold_cnt <= "00";
    	 else
    	    Hold_cnt <= Hold_cnt + '1';    
    	  end if;
    end case;	        
    
    if w_RX_BYTE_out_Bat_H > w_RX_BYTE_out_Bat_L then
        w_RX_Test <= '0';
    elsif w_RX_BYTE_out_Bat_H > w_RX_BYTE_out_Bat_M then
         w_RX_Test <= '1';           
    end if;
    
    if w_RX_BYTE_out_Bat_H = X"5A" then  
        Power_kill_flag <='1';
    else
        Power_kill_flag <='0';     
     end if;   
     
  
     
     
end if;
end process;		

process(clk_uart)
begin
    if (rising_edge(clk_uart)) then
        if(acq_start = '1')then
            if(GC_Change_cnt = 5000000) then
                GC_Change_cnt <= 0;
                GC <= GC_Cal_out;
                Write_GC_flag <= '1';
            else
                GC_Change_cnt <= GC_Change_cnt + 1;
                Write_GC_flag <= '0';
            end if;
        end if;
    end if;

end process;


process(clk_uart) --SPI - GC
begin
    
	if rising_edge(clk_uart) then
		
    GC_flag_buf(0)<=Write_GC_flag ;
    GC_flag_buf(1)<=GC_flag_buf(0);                 
                          
    if GC_flag_buf(0) > GC_flag_buf(1) then
       GC_en <= '1';
    end if;           		
		
		



		
	case SPI_GC_state is
     when SPI_GC_idle =>		
         m_din <= X"00";
         m_din_vld<='0';	
		m_addr<="0";
		 m_din_last<='0';
		         
		
		if cnt_DV_GC_T_1 = 1000 then
                SPI_GC_state  <= SPI_GC_1st_Trans;
         else
            cnt_DV_GC_T_1 <= cnt_DV_GC_T_1  + 1;
         end if;
		
	 when SPI_GC_1st_Trans =>		
		 -- m_din <= X"A0";
		  m_din <= GC(15 downto 8);
          m_din_vld<='1';
 		             
          SPI_GC_state  <=SPI_GC_1st_Trans_Hold;
         
    when SPI_GC_1st_Trans_Hold =>	  
                         
          if  m_ready = '1' then
             m_din_vld<='0';  
            
             SPI_GC_state  <= SPI_GC_2nd_Trans;
          end if;
          
     when SPI_GC_2nd_Trans =>       
         --   m_din <= X"00";
             m_din <= GC(7 downto 0);
             m_din_vld<='1';
             m_din_last<='1';    
        
		 SPI_GC_state  <= SPI_GC_end;
	    		 GC_en<= '0';	  
	 when SPI_GC_end =>  	 
	         if  m_ready = '1' then
	             m_din_vld<='0';
	               m_din_last<='0';
	        
	           if GC_en = '1' then
	               SPI_GC_state  <= SPI_GC_1st_Trans;
	           end if;    
	               
	            
	          end if;
	  when others =>        
	  end case;             


	end if;
end process;	
		
process(clk_uart) --SPI - GC
begin
    
	if rising_edge(clk_uart) then    
    
 HV_flag_buf(0)<=Write_HV_flag ;
    HV_flag_buf(1)<=HV_flag_buf(0);                 
  
  HV_Contr_Write_HV_flag_buf(0)<=HV_Contr_Write_HV_flag ;
    HV_Contr_Write_HV_flag_buf(1)<=HV_Contr_Write_HV_flag_buf(0);   
               
   
                          
    if HV_flag_buf(0) > HV_flag_buf(1) then
       HV_en <= '1';
    end if;   

    if HV_Contr_Write_HV_flag_buf(0) > HV_Contr_Write_HV_flag_buf(1) then
       HV_en <= '1';
    end if; 


	case SPI_HV_state is
     when SPI_HV_idle =>		
		
                m_din_2 <= X"00";
                 m_din_vld_2<='0';    
                m_addr_2<="0";
                 m_din_last_2<='0';		
		
		if cnt_DV_HV_T_1 = 1000 then
                SPI_HV_state  <= SPI_HV_1st_Trans;
               
         else
            cnt_DV_HV_T_1 <= cnt_DV_HV_T_1  + 1;
         end if;
		
	 when SPI_HV_1st_Trans =>		

 		  m_din_2 <=  HV_DAC(15 downto 8);-- Write to and Update DAC Register
          m_din_vld_2<='1';         
          
          SPI_HV_state  <=SPI_HV_1st_Trans_Hold;
         
    when SPI_HV_1st_Trans_Hold =>	  
                         
          if  m_ready_2 = '1' then
             
             m_din_vld_2<='0';
             SPI_HV_state  <= SPI_HV_2nd_Trans;
          end if;
          
     when SPI_HV_2nd_Trans =>       
 
             
             m_din_2 <=  HV_DAC(7 downto 0);
              m_din_vld_2<='1';
              m_din_last_2<='1';
    		 SPI_HV_state  <= SPI_HV_end;    
    		 HV_en<= '0';  
    		   
	 when SPI_HV_end =>  	 
	         if  m_ready_2 = '1' then
	        	    HV_Contr_Rdy<='1';              
	               	 m_din_vld_2<='0';
                     m_din_last_2<='0';
                  if HV_en = '1' then
	               SPI_HV_state  <= SPI_HV_1st_Trans;   
                   end if;  
	          end if;
	   when others =>       
	  end case;             
	end if;
end process;	
--process(clk_uart) --Uart Test
--begin
--	if rising_edge(clk_uart) then
    
--     MEASURED_VCCAUX_buf   <=MEASURED_VCCAUX;
--     MEASURED_VCCINT_buf   <=MEASURED_VCCINT;
--     MEASURED_VCCBRAM_buf  <=MEASURED_VCCBRAM;
--     MEASURED_AUX0_buf    <= MEASURED_AUX0;
--     MEASURED_AUX1_buf     <=MEASURED_AUX1;
--     MEASURED_AUX2_buf     <=MEASURED_AUX2;
--     MEASURED_AUX3_buf     <=MEASURED_AUX3;
 
--     ALM_buf               <= ALM;
--     CHANNEL_buf            <= CHANNEL;
--     OT_buf                 <= OT;
--     EOC_buf        <= EOC;
--     EOS_buf         <= EOS;
--	end if;
--end process;	
Ch_temp_t1 <= X"00" & Temp_Cal_data_read;
Ch_temp_t2 <= X"000"&ADC_data(15 downto 4);
inst_floating_point_top :floating_point_top 
  Port map( 
        clk => clk_main,    
        acq_start => acq_start,
        Ch_temp_t1 => Ch_temp_t1,
        Ch_temp_t2  => Ch_temp_t2,
        GC_Cal_out => GC_Cal_out,
        K40_Pre_GC => GC_Cal_data_read,
        Compare_rdy => '1');

inst_eeprom_top : eeprom_top 
  Port map(
        clk  => clk_Main,
        cs_n => eeprom_cs_n,
        sclk => eeprom_sclk,
        miso => eeprom_miso,
        rd_en_start => rd_en_start,
        GC_Cal_data => GC_Cal_data,
        Temp_Cal_data => Temp_Cal_data,
         Cal_read_done => Cal_read_done,
        GC_Cal_data_read => GC_Cal_data_read, 
        Temp_Cal_data_read => Temp_Cal_data_read,
        mosi => eeprom_mosi
         );
rst_n <= not(rst);
inst_adc_protocol_top : adc_protocol_top
Port map(
      rst_n => rst_n,
      clk => clk_Main,
      sda => adc_sda,
      scl => adc_scl,
      adc_data_out =>  Adc_data    );

  
clk_ADC_p<=clk_ADC;
 Bat_ADC_In<=w_RX_BYTE_out_Bat_M;
Bat_Status_in <= w_RX_BYTE_out_Bat_H(3 downto 0);

HV_Buf<=MEASURED_AUX1(15 downto 4);

end Behavioral;
