----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/05/08 14:11:21
-- Design Name: 
-- Module Name: adc_protocol - Behavioral
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

entity adc_protocol is
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
end adc_protocol;

architecture Behavioral of adc_protocol is




signal reset : std_logic;
constant i2c_idle : std_logic_vector(3 downto 0):= "0000";
constant i2c_command : std_logic_vector(3 downto 0):= "0001";
constant i2c_read : std_logic_vector(3 downto 0):= "0010";
constant i2c_read2_wait : std_logic_vector(3 downto 0):= "0011";
constant i2c_read2 : std_logic_vector(3 downto 0):= "0100";
constant i2c_config_read_wait : std_logic_vector(3 downto 0):= "0101";
constant i2c_config_read : std_logic_vector(3 downto 0):= "0110";
constant i2c_stop : std_logic_vector(3 downto 0):= "0111";
constant i2c_write_opcode : std_logic_vector(3 downto 0):= "1000";
constant i2c_write_reg : std_logic_vector(3 downto 0):= "1001";
constant i2c_write_data : std_logic_vector(3 downto 0):= "1010";
constant i2c_read_start : std_logic_vector(3 downto 0):= "1011";
constant i2c_stop2 : std_logic_vector(3 downto 0):= "1100";

signal i2c_state : std_logic_vector(3 downto 0):=i2c_idle;
signal data_rd_sel_pipe : std_logic_vector(1 downto 0);
signal data_rd_sel_pipe2 : std_logic_vector(1 downto 0);
signal adc_data : std_logic_vector(15 downto 0);
signal adc_stop_cnt : integer:=0;
signal config_data : std_logic_vector(7 downto 0);
signal rst_n : std_logic:='1';
signal ena_buf : std_logic;
signal ena_pipe : std_logic_vector(1 downto 0);
--signal adc_data_out : std_logic_vector(16 - 1 downto 0);

attribute mark_debug : string;
    attribute mark_debug of i2c_state : signal is "true";
    attribute mark_debug of adc_data : signal is "true";
    attribute mark_debug of config_data : signal is "true";
    attribute mark_debug of data_rd_sel_pipe : signal is "true";
    attribute mark_debug of adc_stop_cnt : signal is "true";
    attribute mark_debug of adc_data_out : signal is "true";


begin
reset <= not(rst);
ena   <= ena_buf;
process(reset,clk)
begin
    if(reset = '1')then
    elsif(rising_edge(clk))then
        data_rd_sel_pipe <= data_rd_sel_pipe(0)&data_rd_sel;
        data_rd_sel_pipe2 <= data_rd_sel_pipe2(0)&data_rd_sel_pipe(0);
        case i2c_state is
            when i2c_idle =>
                adc_stop_cnt <= 0;
                ena_buf         <= '1';
                i2c_state   <= i2c_write_opcode;
                addr <= "0010111";
                data_wr <= "00001000";
                wr <= '0';
            when i2c_write_opcode =>
                if (data_rd_sel_pipe = "01") then
                    i2c_state   <= i2c_write_reg;
                    data_wr <= X"11";
                end if; 
             when i2c_write_reg =>
                if (data_rd_sel_pipe = "01") then
                    i2c_state   <= i2c_write_data;
                    data_wr <= X"01";
                end if;
            when i2c_write_data =>
                if (data_rd_sel_pipe = "01") then
                    i2c_state   <= i2c_stop;     
                    ena_buf <= '0';  
                end if;                            
            when i2c_stop =>
                 if(adc_stop_cnt = 1000) then  
                    i2c_state   <= i2c_read_start;    
                    adc_stop_cnt <= 0;   
                 else
                    adc_stop_cnt <= adc_stop_cnt + 1;
                 end if;
            when i2c_read_start =>
                adc_stop_cnt <= 0;
                ena_buf         <= '1';
                i2c_state   <= i2c_command;
                addr <= "0010111";
                wr <= '1';
            when i2c_command =>
                if (data_rd_sel_pipe = "01") then
                    i2c_state   <= i2c_read;
                end if;     
            when i2c_read => 
                    i2c_state   <= i2c_read2_wait;
                    adc_data(15 downto 8) <= data_rd;
            when i2c_read2_wait =>
                if (data_rd_sel_pipe = "01") then 
                    i2c_state   <= i2c_read2; 
                    ena_buf <= '0';                      
                end if;
            when i2c_read2 =>
                    adc_data(7 downto 0) <= data_rd;
                    i2c_state   <= i2c_stop2;   
             when i2c_stop2 =>
                 if(adc_stop_cnt = 10000000) then    -- 0.2s
                    i2c_state   <= i2c_idle;    
                    adc_stop_cnt <= 0;   
                 else
                    adc_stop_cnt <= adc_stop_cnt + 1;
                 end if;                  
            when others =>
            
            end case;
    end if;
end process;

process(reset,clk)
begin
    if(reset = '1')then
    elsif(rising_edge(clk))then
        ena_pipe <= ena_pipe(0) & ena_buf;
        if(ena_pipe = "10") then
            adc_data_out <= adc_data;
        end if;
    end if;
end process;


end Behavioral;
