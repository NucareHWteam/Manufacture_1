----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/05/08 15:25:57
-- Design Name: 
-- Module Name: adc_protocol_top - Behavioral
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

entity adc_protocol_top is
  Port ( 
        rst_n : in std_logic;
        clk : in std_logic;
        sda : inout std_logic;
        scl : inout std_logic;
        adc_data_out : out std_logic_vector(16 - 1 downto 0)
  );
end adc_protocol_top;

architecture Behavioral of adc_protocol_top is

signal ena : std_logic; 
signal addr: std_logic_vector(6 downto 0);  
signal wr: std_logic; 
signal data_rd_sel: std_logic; 
signal data_wr: std_logic_vector(7 downto 0);
signal data_rd: std_logic_vector(7 downto 0);

signal clk_Main : std_logic;
signal clk_debug : std_logic;
-- signal sda : std_logic;
-- signal scl : std_logic;
attribute mark_debug : string;
--    attribute mark_debug of sda : signal is "true";
--    attribute mark_debug of scl : signal is "true";
    attribute mark_debug of ena : signal is "true";
    attribute mark_debug of addr : signal is "true";
    attribute mark_debug of wr : signal is "true";
    attribute mark_debug of data_rd : signal is "true";
    attribute mark_debug of data_rd_sel : signal is "true";


COMPONENT clk_wiz_0 
PORT(
       clk_out1  : OUT std_logic;
       clk_out2  : OUT std_logic;

       reset  : In std_logic;
       locked : OUT std_logic;
        clk_in1 : In std_logic
        );
 END COMPONENT;

component i2c_master IS
  GENERIC(
    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 800_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    data_rd_sel      : out std_logic;
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
END component;

component adc_protocol is
  Port ( 
        rst  : in std_logic;
        clk  : in std_logic;
        ena  : out std_logic:='0';
        addr : out std_logic_vector(6 downto 0);
        wr   : out std_logic;
        data_rd_sel : in std_logic;
        data_wr : out std_logic_vector(7 downto 0);
        data_rd : in std_logic_vector(7 downto 0);
        adc_data_out : out std_logic_vector(16 - 1 downto 0)
  );
end component;
--signal rst_n : std_logic := '1';

begin

inst_i2c_master :i2c_master 
  PORT map(
    clk       => clk,
    reset_n   => rst_n,
    ena       => ena,
    addr      => addr,
    rw        => wr,
    data_wr   => data_wr,
    busy      => open,
    data_rd   => data_rd,
    ack_error => open,
    data_rd_sel  => data_rd_sel,
    sda       => sda,
    scl       => scl
);

inst_adc_protocol : adc_protocol 
  Port map( 
        rst  => rst_n,
        clk  => clk,
        ena  => ena,
        addr => addr,
        wr   => wr,
        data_rd_sel => data_rd_sel,
        data_wr => data_wr,
        data_rd => data_rd,
        adc_data_out => adc_data_out
  );

--i_clk_wiz_0 : clk_wiz_0 
--PORT map(
--       clk_out1  => clk_Main,
--       clk_out2  => clk_debug,
----         clk_XADC=> clk_XADC,
--       reset  => '0',
--       locked => open,
--        clk_in1 => clk
--        );


end Behavioral;
