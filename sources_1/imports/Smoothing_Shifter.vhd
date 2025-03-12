----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:04:07 11/09/2018 
-- Design Name: 
-- Module Name:    Smoothing_Shifter - Behavioral 
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

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Smoothing_Shifter is
port(
	clk: in std_logic;
	rst: in std_logic;
	acq_start: IN std_logic;	
	data_in: in std_logic_vector(13 downto 0);	
	Trapezoidal_out : out std_logic_vector(13 downto 0)
	
	);	
end Smoothing_Shifter;

architecture Behavioral of Smoothing_Shifter is


COMPONENT Moving_Avr is
generic (
  G_NBIT                     : integer := 14;
  G_AVG_LEN_LOG              : integer := 7 );
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

signal i_clk : std_logic;
signal i_sync_reset : std_logic;
COMPONENT delay_line is
generic(
  W                 : integer := 14;    -- data width
  L                 : integer := 128);  -- delay length, shall be > 3
port(
  i_clk             : in  std_logic;
  i_sync_reset      : in  std_logic;
  i_data            : in  std_logic_vector(W-1 downto 0);
  o_data            : out std_logic_vector(W-1 downto 0));
end COMPONENT;

function maximum (
    left, right : STD_LOGIC_VECTOR)                      -- inputs
    return STD_LOGIC_VECTOR is
  begin  -- function max
    if LEFT > RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end function maximum;

type ARRAY_data is array(0 to 63) of std_logic_vector(12 downto 0);
signal	mylatches	:	ARRAY_data := ((others=> (others=>'0')));


type Array_Buffer   is array (0 to 32) of std_logic_vector(12 downto 0);           --------------------------------------------------------------- ring ring start
signal CH_Signal_Ring_Buffer: Array_Buffer:= ((others=> (others=>'0')));
signal ring_cnt : integer range 0 to 32:=0;                             --------------------------------------------------------------- ring ring end
signal ring_Second_cnt : integer range 0 to 32:=1;

signal Trapezoidal_out_buf : std_logic_vector(13 downto 0);


signal old_data : std_logic_vector(13 downto 0);
signal now_data : std_logic_vector(13 downto 0);
signal cal_data : std_logic_vector(13 downto 0);

signal sum_count : integer range 0 to 64:= 0; 

signal en_reg : std_logic;



signal sum     : std_logic_vector(18 downto 0);
signal Buf_data_out : std_logic_vector(13 downto 0);

signal Delay_data_out : std_logic_vector(13 downto 0); 	
signal max_val: std_logic_vector(12 downto 0); 

signal en_avr : std_logic;

signal moving_avr_data : std_logic_vector(13 downto 0);

begin
--

i_clk   <= not(clk);
i_sync_reset <= not acq_start;
i_delay_line : delay_line 
--generic map(
  --W                 : integer := 13,    -- data width
  --L                 : integer := 30);  -- delay length, shall be > 3
port map(
  i_clk            => i_clk,
  i_sync_reset      =>i_sync_reset,
  i_data            =>Buf_data_out,
  o_data            =>Delay_data_out);


i_Moving_Avr : Moving_Avr 

port map(  
  i_clk                      => clk,
  i_rstb                     => acq_start,
  i_sync_reset               =>'0',
  -- input
  i_data_ena                 =>en_reg,
  i_data                      => data_in,
  -- output
  o_data_valid               =>en_avr,
  o_data                     =>moving_avr_data);



process(acq_start,clk)
begin
	if acq_start = '0' or rst = '0' then
	en_reg<='0';
	sum_count<=0;
	max_val<=data_in(12 downto 0);
    ring_cnt<=0;
    ring_Second_cnt<=1;
	elsif rising_edge(clk) then

	if sum_count = 64 then
		en_reg <='1';
	else
		sum_count<=sum_count+1;
	end if;	

     
                
                if ring_cnt = 32 then
                    ring_cnt <= 0;
                else
                    ring_cnt<=ring_cnt+1;   
                end if;
                ring_Second_cnt<=ring_Second_cnt+1;
                    old_data <= Delay_data_out;
                    now_data <= Buf_data_out;
                    cal_data<=now_data - old_data;
                    IF NOW_DATA > 0 THEN
					if now_data > old_data then		
						Trapezoidal_out_buf<= std_logic_vector(cal_data);
					else
						Trapezoidal_out_buf<="00000000000000";
					end if;	
                    END IF;
                    Trapezoidal_out<=Trapezoidal_out_buf(13 downto 0);
				--
						--
   --
	--
         --else
            --sum <= (others => '0');
         --end if;
    if en_avr = '1' then
        Buf_data_out <= moving_avr_data; 
    else
         Buf_data_out<="00000000000000";
    end if;
		
	end if;



end process;

end Behavioral;

