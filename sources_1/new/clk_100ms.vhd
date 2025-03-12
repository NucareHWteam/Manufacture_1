----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:48:28 10/25/2011 
-- Design Name: 
-- Module Name:    clk_20us - Behavioral 
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
--Library XilinxCoreLib;
--library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use UNISIM.VComponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_100ms is
port(clk: in std_logic;	
   clk_100ms: out std_logic:='0');
end clk_100ms;

architecture Behavioral of clk_100ms is
signal D : integer range 0 to 5000000:=0;


begin
process(clk)
begin
  if rising_edge(clk) then
		if D = 5000000 then
			clk_100ms <= '1';

			D <= 0;
		elsif D= 2500000 then
			clk_100ms <= '0';
			D <= D + 1;
			
		else
			D <= D + 1;
			
		end if;
	end if;
end process;

end Behavioral;
