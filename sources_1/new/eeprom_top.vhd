----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/06/02 13:36:44
-- Design Name: 
-- Module Name: eeprom_top - Behavioral
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

entity eeprom_top is
generic (
  write_N                     : integer := 2);
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
end eeprom_top;

architecture Behavioral of eeprom_top is
signal wr_en : std_logic;
signal rd_en : std_logic;
signal wr_end : std_logic;
signal read_data_out : std_logic_vector(32 - 1 downto 0);
signal rd_end :  std_logic;
Component eeprom_wr_rd is
generic (
  write_N                     : integer := write_N);
 Port ( --rst  : in std_logic;
        clk  : in std_logic;
        cs_n : out std_logic;
        sclk : out std_logic;
        miso : in std_logic;
        mosi : out std_logic;
        write_addr : in std_logic_vector(24 - 1 downto 0);
        read_addr : in std_logic_vector(24 - 1 downto 0);
        write_data : in std_logic_vector(32 - 1 downto 0);
        read_data_out : out std_logic_vector(32 - 1 downto 0);
        rd_end : out std_logic;
        wr_end : out std_logic;
        wr_en : in std_logic;
        rd_en : in std_logic
         );
end Component;
signal write_addr :  std_logic_vector(24 - 1 downto 0);
signal read_addr :  std_logic_vector(24 - 1 downto 0);
signal write_data :  std_logic_vector(32 - 1 downto 0);
Component eeprom_wr_control is
generic (
  write_N                     : integer := write_N);
Port ( 
        clk : in std_logic;
        wr_end : in std_logic;
        wr_en : out std_logic;
        rd_en_start : in std_logic;
        rd_en : out std_logic;
        Cal_read_done : in std_logic;
        GC_Cal_data : in std_logic_vector(16 - 1 downto 0);
        Temp_Cal_data : in std_logic_vector(16 - 1 downto 0);
        write_addr : out std_logic_vector(24 - 1 downto 0);
        read_addr : out std_logic_vector(24 - 1 downto 0);
        read_data_out : in std_logic_vector(32 - 1 downto 0);
        rd_end : in std_logic;
        GC_Cal_data_read : out std_logic_vector(16 - 1 downto 0);
        Temp_Cal_data_read : out std_logic_vector(16 - 1 downto 0);
        write_data : out std_logic_vector(32 - 1 downto 0)
        );
end Component;

begin

inst_eeprom_wr_rd : eeprom_wr_rd 
 Port map( --rst  : in std_logic;
        clk  => clk,
        cs_n => cs_n,
        sclk => sclk,
        miso => miso,
        mosi => mosi,
        write_addr => write_addr,
        read_addr => read_addr,
        write_data => write_data,
        read_data_out => read_data_out,
        rd_end => rd_end,
        wr_end  => wr_end,
        wr_en => wr_en,
        rd_en => rd_en
         );

inst_eeprom_wr_control : eeprom_wr_control
Port map( 
        clk => clk,
        wr_end => wr_end,
        wr_en => wr_en,
        rd_en_start => rd_en_start,
        rd_en => rd_en,
        Cal_read_done => Cal_read_done,
        GC_Cal_data => GC_Cal_data,
        Temp_Cal_data => Temp_Cal_data,
        write_addr => write_addr,
        read_addr => read_addr,
        read_data_out => read_data_out,
        rd_end => rd_end,
        GC_Cal_data_read => GC_Cal_data_read,
        Temp_Cal_data_read => Temp_Cal_data_read,
        write_data => write_data
        );
end Behavioral;
