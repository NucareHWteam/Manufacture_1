----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/04/11 13:45:09
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

entity eeprom_wr_rd is
generic (
  write_N                     : integer := 2);
 Port ( --rst  : in std_logic;
        clk  : in std_logic;
        cs_n : out std_logic;
        sclk : out std_logic;
        miso : in std_logic;
        mosi : out std_logic;
        write_addr : in std_logic_vector(24 - 1 downto 0);
        read_addr : in std_logic_vector(24 - 1 downto 0);
        write_data : in std_logic_vector((16*write_N) - 1 downto 0);
        read_data_out : out std_logic_vector((16*write_N) - 1 downto 0);
        rd_end : out std_logic;
        wr_end : out std_logic;
        
        wr_en : in std_logic;
        rd_en : in std_logic
         );
end eeprom_wr_rd;


architecture Behavioral of eeprom_wr_rd is
constant clk_counter            : integer := 100;
constant Write_Data_num : integer := write_N;
constant eeprom_idle            : std_logic_vector(3 downto 0):="0000";
constant eeprom_write_start     : std_logic_vector(3 downto 0):="0001";
constant eeprom_write_address   : std_logic_vector(3 downto 0):="0010";
constant eeprom_write_data      : std_logic_vector(3 downto 0):="0011";
constant eeprom_write_end       : std_logic_vector(3 downto 0):="0100";
constant eeprom_read_start      : std_logic_vector(3 downto 0):="0101";
constant eeprom_read_address     : std_logic_vector(3 downto 0):="0110";
constant eeprom_read_data       : std_logic_vector(3 downto 0):="0111";
constant eeprom_read_end        : std_logic_vector(3 downto 0):="1000";
constant eeprom_write_en        : std_logic_vector(3 downto 0):="1001";
constant eeprom_write_en_end    : std_logic_vector(3 downto 0):="1010";
constant eeprom_write_wait    : std_logic_vector(3 downto 0):="1011";

signal eeprom_state : std_logic_vector(3 downto 0):=eeprom_idle;

signal rst : std_logic:='0';
signal wr_en_pipe : std_logic_vector(1 downto 0);
--signal rd_en : std_logic;
signal rd_en_pipe : std_logic_vector(1 downto 0);
signal spi_cs : std_logic:='1';
signal spi_sclk : std_logic:='0';
signal spi_miso : std_logic;
signal spi_mosi : std_logic:='0';
signal int_sclk : std_logic:='0';
signal clk_toggle_en : std_logic;
signal clk_date_toggle_en : std_logic;
signal clk_counter_cnt : integer:=0;
signal write_set : std_logic_vector(7 downto 0):="00000010";
signal read_set : std_logic_vector(7 downto 0):="00000011";


signal read_data : std_logic_vector((16*Write_Data_num) - 1 downto 0);
signal write_buf : std_logic_vector(32 - 1 + (16*Write_Data_num) downto 0);
signal read_buf : std_logic_vector(32 - 1 + (16*Write_Data_num) downto 0);
signal write_enable : std_logic_vector(8 - 1 downto 0):="00000110";
signal cnt : integer;
signal en_cnt : integer range 0 to 7:=7;
signal int_sclk_pipe : std_logic_vector(1 downto 0);
--signal clk : std_logic;
signal clk_dbg : std_logic;
signal clk_cnt_en : std_logic;
signal write_en_check : std_logic:='0';

constant write_cnt : integer := 31 + (16*Write_Data_num); --2
attribute mark_debug : string;
    attribute mark_debug of spi_cs : signal is "true";
    attribute mark_debug of mosi : signal is "true";
    attribute mark_debug of int_sclk : signal is "true";
    attribute mark_debug of miso : signal is "true";
    attribute mark_debug of write_data : signal is "true";
    attribute mark_debug of read_data : signal is "true";
    attribute mark_debug of read_data_out : signal is "true";
    attribute mark_debug of wr_en : signal is "true";
    attribute mark_debug of rd_en : signal is "true";
    attribute mark_debug of eeprom_state : signal is "true";
    
    
    
COMPONENT clk_wiz_0 
PORT(
       clk_out1  : OUT std_logic;
       clk_out2  : OUT std_logic;

       reset  : In std_logic;
       locked : OUT std_logic;
        clk_in1 : In std_logic
        );
 END COMPONENT;

begin

        
write_buf <= (write_set)&(write_addr)&(write_data);

cs_n <= spi_cs;
--mosi <= spi_mosi;
sclk <= int_sclk;
read_buf <= (read_set)&(read_addr)&X"00000000";
process(rst,clk)
begin
    if(rst = '1')then
        int_sclk_pipe <= "00";
    elsif(rising_edge(clk))then
        int_sclk_pipe <= int_sclk_pipe(0)&int_sclk;   
    end if;
end process;

process(rst,clk)  -- data_cnt
begin
    if(rst = '1')then
        cnt <= write_cnt;
    elsif(rising_edge(clk))then
        if(clk_date_toggle_en = '0')then
            cnt <= write_cnt;
        else
            if(int_sclk_pipe = "10")then
                if( cnt = 0)then
                    cnt <= 0;
                else
                    cnt <= cnt - 1;
                end if;     
            end if;
        end if;   
    end if;
end process;

process(rst,clk)  -- data_cnt
begin
    if(rst = '1')then
        en_cnt <= 7;
    elsif(rising_edge(clk))then
        if(clk_toggle_en = '0')then
            en_cnt <= 7;
        else
            if(int_sclk_pipe = "10")then
                if( en_cnt = 0)then
                    en_cnt <= 0;
                else
                    en_cnt <= en_cnt - 1;
                end if;     
            end if;
        end if;   
    end if;
end process;

process(rst,clk) --clk_count
begin
    if(rst = '1')then
        clk_counter_cnt <= 0;
    elsif(rising_edge(clk))then
        if(clk_cnt_en = '0')then
            clk_counter_cnt <= 0;
        else
            
               if(clk_counter_cnt = clk_counter) then
                    clk_counter_cnt <= 0;
                else    
                    clk_counter_cnt <= clk_counter_cnt + 1;
                end if;    
    
        end if;
    end if;        
end process;

process(rst,clk)   --sclk_gen
begin
    if(rst = '1')then
        int_sclk <= '0';    
    elsif(rising_edge(clk))then
         if(clk_cnt_en = '0')then
            int_sclk <='0';
        else
            if((eeprom_state = eeprom_write_end)or(eeprom_state = eeprom_read_end)or(eeprom_state = eeprom_idle)or(eeprom_state = eeprom_write_en_end)or(eeprom_state = eeprom_write_wait))then
                int_sclk <= '0';
            else
                if(clk_counter_cnt = clk_counter) then
                    int_sclk <= not int_sclk;
                end if;
            end if;        
        end if;
    end if;        
end process;
process(rst,clk)
begin
    if(rst = '1')then
        eeprom_state <= eeprom_idle;
        clk_toggle_en <= '0';
        clk_date_toggle_en <= '0';
    elsif(rising_edge(clk))then
        wr_en_pipe <= wr_en_pipe(0)&wr_en;
        rd_en_pipe <= rd_en_pipe(0)&rd_en;
        case eeprom_state is
            
            when eeprom_idle =>
                wr_end        <= '0';
                rd_end        <= '0';
                clk_cnt_en    <= '0';
                clk_toggle_en <= '0';
                clk_date_toggle_en <= '0';
                mosi <= 'Z';
                if(wr_en_pipe = "01") then
                    if(write_en_check = '0') then
                        eeprom_state <= eeprom_write_en;
                    else
                        eeprom_state    <= eeprom_write_start;
                    end if;    
                elsif(rd_en_pipe = "01")then
                    eeprom_state <= eeprom_read_start;
                else
                    eeprom_state <= eeprom_idle;
                end if;
            when eeprom_write_en =>
                clk_cnt_en    <= '1';
                spi_cs        <= '0';
                clk_toggle_en <= '1';
                if( en_cnt = 0 )then 
                    mosi        <= write_enable(en_cnt);
                     if(int_sclk_pipe = "10")then
                        eeprom_state    <= eeprom_write_en_end;
                     end if;                   
                else
                    mosi        <= write_enable(en_cnt);
                end if;
            when eeprom_write_en_end =>
                 if(clk_counter_cnt = clk_counter) then 
                    clk_toggle_en   <= '0';
                    eeprom_state    <= eeprom_write_wait; 
                    spi_cs <= '1';
                    write_en_check <= '1';
                    mosi <= 'Z';
                end if;
            when eeprom_write_wait =>
                 if(clk_counter_cnt = clk_counter) then 
                    eeprom_state    <= eeprom_write_start; 
                    mosi <= 'Z';
                end if;             
            when eeprom_write_start =>
                if(write_en_check = '1') then
                    clk_cnt_en    <= '1';
                    
                    clk_toggle_en <= '1';
                end if;    
                spi_cs        <= '0';
                clk_date_toggle_en <= '1';
              --  if(int_sclk_pipe = "10")then
                    if( cnt = write_cnt -  7 )then 
                        mosi        <= write_buf(cnt);
                        eeprom_state    <= eeprom_write_address;                
                    else
                        mosi <= write_buf(cnt);
                    end if;    
              --  end if;
            when eeprom_write_address =>  
              
                    if( cnt = write_cnt - (16*Write_Data_num - 1))then 
                        mosi        <= write_buf(cnt);
                        eeprom_state    <= eeprom_write_data;
                    else
                        mosi <= write_buf(cnt);
                    end if;    
                
            when eeprom_write_data =>  
              
                    if( cnt = 0 )then 
                        mosi        <= write_buf(cnt);
                        if(int_sclk_pipe = "10")then
                            eeprom_state    <= eeprom_write_end;
                        end if;
                    else
                        mosi <= write_buf(cnt);
                    end if; 
                      
            when eeprom_write_end => 
                if(clk_counter_cnt = clk_counter) then 
                    clk_date_toggle_en   <= '0';
                    clk_cnt_en    <= '0';
                    eeprom_state    <= eeprom_idle; 
                    spi_cs <= '1';
                    wr_end <= '1';
                    mosi <= 'Z';
                end if;  
            when eeprom_read_start =>
                spi_cs        <= '0';
                clk_date_toggle_en <= '1';
                clk_cnt_en    <= '1';
                    if( cnt = write_cnt - 7 )then 
                        mosi        <= read_buf(cnt);
                        eeprom_state    <= eeprom_read_address;
                    else
                        mosi        <= read_buf(cnt);
                    end if;
                   
            when eeprom_read_address =>  
 
                    if( cnt = write_cnt - (16*Write_Data_num - 1) )then 
                        mosi        <= read_buf(cnt);
                        if(int_sclk_pipe = "10")then
                            mosi <= 'Z';
                            eeprom_state    <= eeprom_read_data;
                        end if;    
                    else
                        mosi        <= read_buf(cnt);
                    end if;
           
            when eeprom_read_data =>  
                if( cnt = 0 )then 
                    if(int_sclk_pipe = "01")then
                        read_data(cnt)      <= miso;
                    elsif(int_sclk_pipe = "10")then
                        eeprom_state    <= eeprom_read_end;
                    end if;    
                else
                    if(int_sclk_pipe = "01")then
                        read_data(cnt)      <= miso;
                    end if;     
                end if;    
            when eeprom_read_end => 
                if(clk_counter_cnt = clk_counter) then
                    read_data_out <= read_data; 
                    clk_date_toggle_en   <= '0';
                    clk_cnt_en    <= '0';
                    rd_end <= '1';
                    eeprom_state    <= eeprom_idle; 
                    spi_cs <= '1';
                end if;          
            when others =>
        end case;
    
    end if;


end process;



end Behavioral;
