----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/06/02 13:36:44
-- Design Name: 
-- Module Name: eeprom_wr_control - Behavioral
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

entity eeprom_wr_control is
generic (
  write_N                     : integer := 2);
Port ( 
        clk : in std_logic;
        wr_end : in std_logic;
        wr_en : out std_logic;
        rd_en_start : in std_logic;
        rd_en : out std_logic:='0';
        Cal_read_done : in std_logic;
        GC_Cal_data : in std_logic_vector(16 - 1 downto 0);
        Temp_Cal_data : in std_logic_vector(16 - 1 downto 0);
        write_addr : out std_logic_vector(24 - 1 downto 0);
        read_addr : out std_logic_vector(24 - 1 downto 0);
        read_data_out : in std_logic_vector((16*write_N) - 1 downto 0);
        rd_end : in std_logic;
        GC_Cal_data_read : out std_logic_vector(16 - 1 downto 0);
        Temp_Cal_data_read : out std_logic_vector(16 - 1 downto 0);
        write_data : out std_logic_vector((16*write_N) - 1 downto 0)
        );
end eeprom_wr_control;

architecture Behavioral of eeprom_wr_control is

constant eeprom_idle : std_logic_vector(3 downto 0):="0000";
constant write_1st : std_logic_vector(3 downto 0):="0001";
constant write_1st_wait : std_logic_vector(3 downto 0):="0010";
constant write_2nd : std_logic_vector(3 downto 0):="0011";
constant write_2nd_wait : std_logic_vector(3 downto 0):="0100";
constant write_end : std_logic_vector(3 downto 0):="0101";

constant read_1st : std_logic_vector(3 downto 0):="0110";
constant read_1st_wait : std_logic_vector(3 downto 0):="0111";
constant read_2nd : std_logic_vector(3 downto 0):="1000";
constant read_2nd_wait : std_logic_vector(3 downto 0):="1001";
constant read_end : std_logic_vector(3 downto 0):="1010";


signal Cal_read_done_pipe : std_logic_vector(1 downto 0);
signal wr_end_pipe : std_logic_vector(1 downto 0);
signal rd_end_pipe : std_logic_vector(1 downto 0);
signal rd_en_pipe : std_logic_vector(1 downto 0);
signal Write_start : std_logic := '0';
signal eeprom_state : std_logic_vector(3 downto 0):= eeprom_idle;
signal wait_cnt : integer;
signal read_start : std_logic:='0';

--signal GC_Cal_data_read :  std_logic_vector(16 - 1 downto 0);
--signal Temp_Cal_data_read :  std_logic_vector(16 - 1 downto 0);

attribute mark_debug : string;
    attribute mark_debug of GC_Cal_data_read : signal is "true";
    attribute mark_debug of Temp_Cal_data_read : signal is "true";

begin
process(clk)
begin
    if(rising_edge(clk))then
        Cal_read_done_pipe <= Cal_read_done_pipe(0) & Cal_read_done;
        wr_end_pipe <= wr_end_pipe(0) & wr_end;
        rd_end_pipe <= rd_end_pipe(0) & rd_end;
        rd_en_pipe <= rd_en_pipe(0) & rd_en_start;
    end if;
end process;


process(clk)
begin
    if(rising_edge(clk))then
        if( Cal_read_done_pipe = "01") then
            Write_start <= '1';          
        end if;
        
        if( rd_en_pipe = "01") then
            read_start <= '1';          
        end if;
        case eeprom_state is
            when eeprom_idle =>
               wait_cnt <= 0;
                if(Write_start = '1') then
                     write_addr <= X"000008";
                     wr_en <= '1';
                     write_data <= Temp_Cal_data & GC_Cal_data;
                     eeprom_state <= write_1st;
                elsif read_start = '1' then
                    read_start <= '0';
                    rd_en <= '1';     
                    eeprom_state <= read_1st;
                    read_addr <= X"000008";
                else  
                    --Write_start <= '1'; 
                    write_addr <= (others => '0');
                     wr_en <= '0';
                     write_data <= (others => '0');
                end if;
            when write_1st => 
                Write_start <= '0';  
                wr_en <= '1';
                eeprom_state <= write_1st_wait;
            when write_1st_wait => 
               
                if( wr_end_pipe = "01") then  
                     eeprom_state <= write_end;
                else   
                     wr_en <= '0';  
                end if; 
            when write_end => 
                    
                 if(wait_cnt = 1000) then
                    eeprom_state <= eeprom_idle;     
                    --read_start <= '1';
                else
                    wait_cnt <= wait_cnt+1;
                end if; 
             when read_1st =>  
                rd_en <= '1';
                eeprom_state <= read_1st_wait;
            when read_1st_wait => 
               
                if( rd_end_pipe = "01") then  
                     eeprom_state <= read_end;
                     GC_Cal_data_read <= read_data_out(16 - 1 downto 0);
                     Temp_Cal_data_read <= read_data_out(32 -1 downto 16);
                else   
                     rd_en <= '0';  
                end if;
           
            when read_end => 
                 eeprom_state <= eeprom_idle;     
            
            when others =>  eeprom_state <= eeprom_idle;
        end case;        
    end if;
end process;

end Behavioral;
