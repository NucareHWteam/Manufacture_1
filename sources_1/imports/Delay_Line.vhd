library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity delay_line is
generic(
  W                 : integer := 14;    -- data width
  L                 : integer := 128);  -- delay length, shall be > 3
port(
  i_clk             : in  std_logic;
  i_sync_reset      : in  std_logic;
  i_data            : in  std_logic_vector(W-1 downto 0);
  o_data            : out std_logic_vector(W-1 downto 0));
end delay_line;
architecture rtl of delay_line is
type t_ram is array (L-2 downto 0) of std_logic_vector(W-1 downto 0);
signal m_ram : t_ram;
signal r_addr_wr         : integer range 0 to L-2;
signal r_addr_rd         : integer range 0 to L-2;
signal r_enable_read     : std_logic;
begin
p_write : process (i_clk)
begin
  if rising_edge(i_clk) then
    if(i_sync_reset='1') then
      r_addr_wr      <= 0;
      r_enable_read  <= '0';
    else
      m_ram(r_addr_wr) <= i_data;
      if(r_addr_wr<L-2) then
        r_addr_wr      <= r_addr_wr + 1;
      else
        r_addr_wr      <= 0;
        r_enable_read  <= '1';       -- enable reading section
      end if;
    end if;
  end if;
end process p_write;
p_read : process (i_clk)
begin
  if rising_edge(i_clk) then
    if(i_sync_reset='1') then
      r_addr_rd      <= 0;
    else
      if(r_enable_read='1') then
        o_data         <= m_ram(r_addr_rd) ; -- additional delay
        if(r_addr_rd<L-2) then
          r_addr_rd      <= r_addr_rd + 1;
        else
          r_addr_rd      <= 0;
        end if;
      end if;
    end if;
  end if;
end process p_read; 
end rtl;