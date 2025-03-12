----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2016/10/25 14:57:57
-- Design Name: 
-- Module Name: radiation_detect14bit_1024 - Behavioral
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
Library XilinxCoreLib;
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use UNISIM.VComponents.all;

entity radiation_RisingEdgeC is
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
end radiation_RisingEdgeC;

architecture Behavioral of radiation_RisingEdgeC is
--component Pileup_ROM
--	port (
--	clka: IN std_logic;
--	addra: IN std_logic_VECTOR(5 downto 0);
--	douta: OUT std_logic_VECTOR(10 downto 0));
--end component;
--
--component Pileup_Multiple
--	port (
--	clk: IN std_logic;
--	a: IN std_logic_VECTOR(10 downto 0);
--	b: IN std_logic_VECTOR(10 downto 0);
--	ce: IN std_logic;
--	p: OUT std_logic_VECTOR(21 downto 0));
--end component;
--attribute syn_black_box : boolean;
--attribute syn_black_box of Pileup_Multiple: component is true;

--Component Moving_Avr is
--generic (
--  G_NBIT                     : integer := 14;
--  G_AVG_LEN_LOG              : integer := 6 );
--port (  
--  i_clk                      : in  std_logic;
--  i_rstb                     : in  std_logic;
--  i_sync_reset               : in  std_logic;
--  -- input
--  i_data_ena                 : in  std_logic;
--  i_data                     : in  std_logic_vector(G_NBIT-1 downto 0);
--  -- output
--  o_data_valid               : out std_logic;
--  o_data                     : out std_logic_vector(G_NBIT-1 downto 0));
--end Component;

function maximum (
    left, right : STD_LOGIC_VECTOR)                      -- inputs
    return STD_LOGIC_VECTOR is
  begin  -- function max
    if LEFT > RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end function maximum;


signal CH_Signal: STD_LOGIC_VECTOR ( 13 downto 0 );
signal data_in_Baseline: STD_LOGIC_VECTOR ( 13 downto 0 );
signal F_T_Pileup : STD_LOGIC_VECTOR ( 12 downto 0 );
signal F_Pileup: STD_LOGIC_VECTOR ( 12 downto 0 );
signal D_Pileup: STD_LOGIC_VECTOR ( 12 downto 0 ); 
signal D_Pileup_Before :  std_logic_vector(12 downto 0);
signal D_Pileup_Before_Before :  std_logic_vector(12 downto 0);
signal D_Pileup_Before_Before_Before :  std_logic_vector(12 downto 0);
signal D_Pileup_Before_Before_Before_Before :  std_logic_vector(12 downto 0);
signal D_Pileup_Before_Before_Before_Before_Before :  std_logic_vector(12 downto 0);


signal CH_Signal_Baseline: STD_LOGIC_VECTOR ( 13 downto 0 );
signal Ch_Data_subtraction : std_logic_vector(13 downto 0):=(others => '0');
signal Ch_Data_subtraction_2 : std_logic_vector(13 downto 0):=(others => '0');
signal Ch_Data_subtraction_3 : std_logic_vector(13 downto 0):=(others => '0');
signal Ch_Data_subtraction_4 : std_logic_vector(13 downto 0):=(others => '0');

signal Ch_Data_subtraction_i : std_logic_vector(13 downto 0):=(others => '0');
signal Ch_Data_subtraction_2_i : std_logic_vector(13 downto 0):=(others => '0');
signal Ch_Data_subtraction_3_i : std_logic_vector(13 downto 0):=(others => '0');
signal Ch_Data_subtraction_4_i : std_logic_vector(13 downto 0):=(others => '0');

signal Ch_Data_subtraction_min: std_logic_vector(13 downto 0):=(others => '0');
signal Ch_Data_subtraction_min_j : std_logic_vector(13 downto 0):=(others => '0');



signal Ch_Data_subtraction_all_0 : std_logic_vector(15 downto 0):=(others => '0');
signal Ch_Data_subtraction_all_1 : std_logic_vector(15 downto 0):=(others => '0');
signal Ch_Data_subtraction_all_2 : std_logic_vector(15 downto 0):=(others => '0');
signal Ch_Data_subtraction_all_3 : std_logic_vector(15 downto 0):=(others => '0');
signal Ch_Data_subtraction_all : std_logic_vector(16 downto 0):=(others => '0');
signal ch_Data_subtraction_all_Pre : std_logic_vector(15 downto 0):=(others => '0');

signal Ch_Data_subtraction_Origin : std_logic_vector(13 downto 0):=(others => '0');
signal flag_Baseline : std_logic:='0';
signal flag_Find_Baseline : std_logic_vector(2 downto 0):="000";
Signal CH_Baseline : STD_LOGIC_VECTOR ( 19 downto 0 ):= (others => '0'); 
signal CH_Baseline_Pre : std_logic_VECTOR ( 19 downto 0 ):= (others => '0');  
--Signal CH_Signal_Baseline : STD_LOGIC_VECTOR ( 10 downto 0 ):= (others => '0'); 

Signal CH_Baseline_2 : STD_LOGIC_VECTOR ( 19 downto 0 ):= (others => '0'); 
signal CH_Baseline_Pre_2 : std_logic_VECTOR ( 19 downto 0 ):= (others => '0');  
Signal CH_Baseline_3 : STD_LOGIC_VECTOR ( 19 downto 0 ):= (others => '0'); 
signal CH_Baseline_Pre_3 : std_logic_VECTOR ( 19 downto 0 ):= (others => '0');  
Signal CH_Baseline_4 : STD_LOGIC_VECTOR ( 19 downto 0 ):= (others => '0'); 
signal CH_Baseline_Pre_4 : std_logic_VECTOR ( 19 downto 0 ):= (others => '0');  

signal flag_Noise_Baseline: std_logic:='0'; 

Signal CH_Signal_Baseline_2 : STD_LOGIC_VECTOR ( 12 downto 0 ):= (others => '0');  


signal CH_0: STD_LOGIC_VECTOR ( 12 downto 0 );
signal CH_1: STD_LOGIC_VECTOR ( 12 downto 0 );
signal CH_2: STD_LOGIC_VECTOR ( 12 downto 0 );
signal CH_3: STD_LOGIC_VECTOR ( 12 downto 0 );

signal CH_S: STD_LOGIC_VECTOR ( 21 downto 0 ):= (others => '0');
signal CH_S_1: STD_LOGIC_VECTOR ( 21 downto 0 ):= (others => '0');
Signal flag_1: std_logic:='0';
Signal flag_2:std_logic:='0'; 
Signal T_flag_CH:std_logic:='0';
signal dout: std_logic_vector(13 downto 0);
signal pileup_out : std_logic_vector(10 downto 0); 
signal Pileup_ce : std_logic:='0';
signal Pileup_p :  std_logic_vector(23 downto 0);
signal cnt_Noise_Fileup : std_logic_vector(10 downto 0):= (others => '0');
signal test_start : std_logic:='0';

signal cnt_Signal : STD_LOGIC_VECTOR ( 5 downto 0):= (others => '0');
signal cnt_Signal_2 : STD_LOGIC_VECTOR ( 5 downto 0):= (others => '0');
signal cnt_Signal_3 : STD_LOGIC_VECTOR ( 5 downto 0):= (others => '0');
signal cnt_Signal_4 : STD_LOGIC_VECTOR ( 5 downto 0):= (others => '0');
signal max_val : std_logic_vector(13 downto 0):=(others => '0');

signal cnt_Signal_i : STD_LOGIC_VECTOR ( 6 downto 0):= (others => '0');
signal cnt_Signal_2_i : STD_LOGIC_VECTOR ( 6 downto 0):= (others => '0');
signal cnt_Signal_3_i : STD_LOGIC_VECTOR ( 6 downto 0):= (others => '0');
signal cnt_Signal_4_i : STD_LOGIC_VECTOR ( 6 downto 0):= (others => '0');

signal flag_Baseline_Avr : std_logic:='0';

signal cnt_Signal_S : STD_LOGIC_VECTOR ( 6 downto 0);
signal cnt_Signal_Before : STD_LOGIC_VECTOR ( 6 downto 0);
signal cnt_Signal_Before_Before : STD_LOGIC_VECTOR ( 6 downto 0);
signal cnt_Signal_Before_Before_Before : STD_LOGIC_VECTOR ( 6 downto 0);

signal cnt_init : std_logic:='0';

signal cnt_flag_subtraction : STD_LOGIC_VECTOR ( 2 downto 0):= (others => '0');

signal max_Ch_Data_subtraction: std_logic_vector(13 downto 0):=(others => '0'); 
signal min_Ch_Data_subtraction: std_logic_vector(13 downto 0):=(others => '0');

signal cnt_pileup : std_logic_vector( 5 downto 0);
signal cnt_divide : STD_LOGIC_VECTOR ( 4 downto 0):= (others => '0');
signal cnt_pileup_sequence : std_logic_vector( 2 downto 0);
signal flag_Baseline_true : std_logic:='0';
signal D_Pileup_Before_pre : std_logic_vector(10 downto 0);
signal flag_Thresh_Flot : std_logic_vector(2 downto 0):="000";
signal flag_Pileup_get : STD_LOGIC :='0';

--------------------------------------------------------------------------------
--signal Threshold :  STD_LOGIC_VECTOR( 10 downto 0) := "00000001000";
--
--signal Signal_TIME: STD_LOGIC_Vector( 6 downto 0) := "0010010";
--
--signal Data_subtraction :  STD_LOGIC_VECTOR( 10 downto 0) := "00000000000";

--------------------------------------------------------------------------------
type Master_state is ( Pileup_idle , Pileup_peak , Pileup_normal , Pileup_get , Pileup_exp, Pileup_trans);
signal Pileup_state : Master_state;
begin


--i_Moving_Avr : Moving_Avr 
--port map(  
--  i_clk                     =>clk,
--  i_rstb                     =>acq_start,
--  i_sync_reset               =>'0',
--  -- input
--  i_data_ena                =>flag_Baseline_Avr,
--  i_data                     =>data_in,
--  -- output
--  o_data_valid              =>open,
--  o_data                     =>data_in_Baseline);





process(acq_start,clk)
begin
	if acq_start = '0' then
	dout<= (others=>'0');
	Pileup_state<=Pileup_idle;
	T_flag_CH <= '0';
	flag_CH<='0';
	CH_Signal_Baseline<="00000000000000";
	flag_Find_Baseline<="000";
	flag_Noise_Baseline <= '0'; 
	flag_Baseline_true<='0';
--	flag_data_stop <='0';
	cnt_Signal<= (others=>'0');
	cnt_Signal_2<= (others=>'0');
	cnt_Signal_3<= (others=>'0');
	cnt_Signal_4<= (others=>'0');
	cnt_Signal_i<= (others=>'0');
	cnt_Signal_2_i<= (others=>'0');
	cnt_Signal_3_i<= (others=>'0');
	cnt_Signal_4_i<= (others=>'0');
	cnt_flag_subtraction<= (others=>'0');
	max_val<=(others => '0');
	 
	elsif rising_edge(clk) then
	       
	       
	
	if flag_Baseline_true ='0' then
	   flag_Baseline_Avr<='1';
		if flag_Find_Baseline = "000" then
							if cnt_Signal_i="000000" then			
									cnt_Signal_i<=cnt_Signal_i+1;
									CH_Baseline_Pre<="00000000000000000000"+CH_Signal;	
							elsif cnt_Signal_i="0111111" then
									cnt_Signal_i<=cnt_Signal_i+1;
									CH_Baseline<=CH_Baseline_Pre+CH_Signal;									
							elsif cnt_Signal_i = "1000000" then
									
									
										Ch_Data_subtraction_i <= Ch_Baseline(19 downto 6);
										
									cnt_Signal_i<=cnt_Signal_i+1;
							elsif cnt_Signal_i = "1000001" then	
									
									
									
								cnt_Signal_i<="0000000";
								flag_Find_Baseline <="001";
							else	
									cnt_Signal_i<=cnt_Signal_i+1;
									CH_Baseline_Pre<=CH_Baseline_Pre+CH_Signal;	
									
							end if;		
				elsif flag_Find_Baseline = "001" then
							if cnt_Signal_2_i="0000000" then			
									cnt_Signal_2_i<=cnt_Signal_2_i+1;
									CH_Baseline_Pre_2<="00000000000000000000"+CH_Signal;							
							elsif cnt_Signal_2_i="0111111" then
									cnt_Signal_2_i<=cnt_Signal_2_i+1;
									CH_Baseline_2<=CH_Baseline_Pre_2+CH_Signal;
							elsif cnt_Signal_2_i = "1000000" then
									
										Ch_Data_subtraction_2_i <= Ch_Baseline_2(19 downto 6);
										
									cnt_Signal_2_i<=cnt_Signal_2_i+1;									
							elsif cnt_Signal_2_i = "1000001" then	
								cnt_Signal_2_i<="0000000";
								flag_Find_Baseline <="010";

							else	
									cnt_Signal_2_i<=cnt_Signal_2_i+1;
									CH_Baseline_Pre_2<=CH_Baseline_Pre_2+CH_Signal;
									
							end if;	
				elsif flag_Find_Baseline = "010" then
							if cnt_Signal_3_i="0000000" then			
									cnt_Signal_3_i<=cnt_Signal_3_i+1;
									CH_Baseline_Pre_3<="00000000000000000000"+CH_Signal;							
							elsif cnt_Signal_3_i="0111111" then
									cnt_Signal_3_i<=cnt_Signal_3_i+1;
									CH_Baseline_3<=CH_Baseline_Pre_3+CH_Signal;
							elsif cnt_Signal_3_i = "1000000" then
									
										Ch_Data_subtraction_3_i <= Ch_Baseline_3(19 downto 6);
										
									cnt_Signal_3_i<=cnt_Signal_3_i+1;									
							elsif cnt_Signal_3_i = "1000001" then	
								cnt_Signal_3_i<="0000000";
								flag_Find_Baseline <="011";
							else	
									cnt_Signal_3_i<=cnt_Signal_3_i+1;
									CH_Baseline_Pre_3<=CH_Baseline_Pre_3+CH_Signal;
									
							end if;	
					elsif flag_Find_Baseline = "011" then
							if cnt_Signal_4_i="0000000" then			
									cnt_Signal_4_i<=cnt_Signal_4_i+1;
									CH_Baseline_Pre_4<="00000000000000000000"+CH_Signal;							
							elsif cnt_Signal_4_i="0111111" then
									cnt_Signal_4_i<=cnt_Signal_4_i+1;
									CH_Baseline_4<=CH_Baseline_Pre_4+CH_Signal;
							elsif cnt_Signal_4_i = "1000000" then
							
										Ch_Data_subtraction_4_i <= Ch_Baseline_4(19 downto 6);
										
									cnt_Signal_4_i<=cnt_Signal_4_i+1;									
							elsif cnt_Signal_4_i = "1000001" then	
								
									
								
								cnt_Signal_4_i<="0000000";
								flag_Find_Baseline <="100";
							else	
									cnt_Signal_4_i<=cnt_Signal_4_i+1;
									CH_Baseline_Pre_4<=CH_Baseline_Pre_4+CH_Signal;
									
							end if;	
					else
						
							
                                        if cnt_flag_subtraction = "111" then
                                            cnt_flag_subtraction <= "000";
                                            flag_Find_Baseline <="000";    
                                            flag_Baseline_true<='1';
                                           -- Ch_Data_subtraction_all<="00000000000000000"+Ch_Data_subtraction+Ch_Data_subtraction_2+Ch_Data_subtraction_3+Ch_Data_subtraction_4;
                                          --  Ch_Data_subtraction_all<=data_in_Baseline&"00";
                                        else
                                            cnt_flag_subtraction<=cnt_flag_subtraction+1;
                                        end if;
                                        
                                    
                                        
                                        if Ch_Data_subtraction_i < Ch_Data_subtraction_2_i then
                                            Ch_Data_subtraction_min <= Ch_Data_subtraction_i;
                                        else
                                            Ch_Data_subtraction_min<= Ch_Data_subtraction_2_i;
                                        end if;
                
                                        if Ch_Data_subtraction_3_i < Ch_Data_subtraction_4_i then
                                            Ch_Data_subtraction_min_j <= Ch_Data_subtraction_3_i;
                                        else
                                            Ch_Data_subtraction_min_j<= Ch_Data_subtraction_4_i;
                                        end if;        
                                        
                                        if Ch_Data_subtraction_min <Ch_Data_subtraction_min_j then
                                            Ch_Data_subtraction<=Ch_Data_subtraction_min;
                                            Ch_Data_subtraction_2<=Ch_Data_subtraction_min;
                                            Ch_Data_subtraction_3<=Ch_Data_subtraction_min;
                                            Ch_Data_subtraction_4<=Ch_Data_subtraction_min;
                                        else
                                            Ch_Data_subtraction<=Ch_Data_subtraction_min_j;
                                            Ch_Data_subtraction_2<=Ch_Data_subtraction_min_j;
                                            Ch_Data_subtraction_3<=Ch_Data_subtraction_min_j;
                                            Ch_Data_subtraction_4<=Ch_Data_subtraction_min_j;
                                        end if;    
                                        
                                        
                                    end if;    
		end if;       
	       
				
		case Pileup_state is
		when Pileup_idle =>
		flag_CH<='0';
		if flag_Baseline_true = '1' then			
			if Trapezoidal_out> "0000000010100" then		
				
					flag_CH<='0';
					Pileup_state  <= Pileup_peak;
					cnt_Signal_S<="0000001";
				CH_S<="0000000000000000000000"+Trapezoidal_out;
					
					max_val<=Trapezoidal_out;
				flag_Baseline_Avr<='0';
			else 
			    flag_Baseline_Avr<='1'; 
			end if;
		end if;
	when Pileup_peak =>	
		flag_CH<='0';

		
		max_val<=Trapezoidal_out;
		if cnt_Signal_S <= "100" then
					if Trapezoidal_out< "0000000010100"   then
						Pileup_state<=Pileup_idle;
						cnt_Signal_S<="0000000";
						
						
					flag_Noise_Baseline <= '1'; 

					else
						
						cnt_Signal_S<=cnt_Signal_S+1;
						CH_S<=CH_S+CH_Signal_Baseline;
					end if;	
		else
			
					Pileup_state<=Pileup_normal;
				
		end if;		
			
		
		when Pileup_Normal =>	
		
--			D_Pileup<=CH_Signal_Baseline;
--			D_Pileup_Before<=D_Pileup;
--			D_Pileup_Before_Before<=D_Pileup_Before;
			
--			D_Pileup_Before_Before_Before<=D_Pileup_Before_Before;
--			D_Pileup_Before_Before_Before_Before<=D_Pileup_Before_Before;
			
--			cnt_Signal_Before_Before_Before<=cnt_Signal_Before;
--			cnt_Signal_Before_Before<=cnt_Signal_Before;
--			cnt_Signal_Before<=cnt_Signal_S;
					

			
			
--				if D_Pileup< CH_Signal_Baseline and D_Pileup_Before< D_Pileup and D_Pileup_Before< D_Pileup_Before_Before then
			
--				cnt_pileup<=cnt_Signal_S(5 downto 0); 
				
--				D_Pileup<="0000000000000";
--				D_Pileup_Before<="0000000000000";
--				D_Pileup_Before_Before<="0000000000000";
--				D_Pileup_Before_Before_Before<="0000000000000";
								
--			Pileup_state<=Pileup_get;	
--					F_T_Pileup<=CH_Signal_Baseline;	
--					Pileup_ce<= '1';	

--				cnt_Signal_S <= "0000000";
--			else
			max_val<=maximum(max_val,Trapezoidal_out);
			
				if Trapezoidal_out<  "0000000010100" then
					
							flag_CH<='1';
							
							dout<=max_val;
							flag_Noise_Baseline <= '1'; 
							T_flag_CH<='1';							
                            Pileup_state<=Pileup_idle;
				else	
					
						cnt_Signal_S<=cnt_Signal_S+1;
						CH_S<=CH_S+Trapezoidal_out;
						
				end if;	
				
							

		
	

	when Pileup_get =>
--flag_CH<='0';
--			D_Pileup<=CH_Signal_Baseline;
--			D_Pileup_Before<=D_Pileup;
--			D_Pileup_Before_Before<=D_Pileup_Before;
		
		
--		if F_T_Pileup< CH_Signal_Baseline then
--			F_T_Pileup<=CH_Signal_Baseline;
			
--		end if;	
--				if CH_Signal_Baseline< Threshold  then
--						if F_Pileup(10 downto 3) < F_T_Pileup then
--							Pileup_state<=Pileup_idle;
--							cnt_Signal_S <= "0000000";
--						else
							
--							dout<=CH_S+CH_S_1;
--							Pileup_state<=Pileup_trans;
--							cnt_Signal_S <= "0000000";
--						end if;
--					flag_Noise_Baseline <= '1'; 
--				else	
--				CH_S_1<=CH_S_1+CH_Signal_Baseline;
--				cnt_Signal_S<=cnt_Signal_S+1;
--				end if;
		
		
		when Pileup_exp =>
--				flag_CH<='0';
--				if CH_Signal_Baseline< Threshold  then	
				
--					flag_start <= '0';
--					Pileup_state<=Pileup_trans;
--					cnt_Signal_S <= "0000000";
--				else
--					cnt_Signal_S<=cnt_Signal_S+1;
--					CH_S<=CH_S+CH_Signal_Baseline;
--				end if;	
		when Pileup_trans =>
		
		
		if dout>"111" and dout < "1111111111111"  then
						
			if cnt_divide="101" then
					flag_CH<='0';
					T_flag_CH<='0';
					Pileup_state<=Pileup_idle;
					cnt_divide<="00000";
					 
				elsif cnt_divide="011" then
					flag_CH<='0';
					cnt_divide<=cnt_divide+'1';
				elsif cnt_divide="001" then
				--	dout_CH<=Ch_Data_subtraction_all;
					
					cnt_divide<=cnt_divide+'1';
				elsif cnt_divide="000" then
					
					flag_CH<='1';
					cnt_divide<=cnt_divide+'1';
				else
					cnt_divide<=cnt_divide+'1';
				end if;
			else
		--		flag_data_stop<='0';
				dout<="00000000000000";
				Pileup_state<=Pileup_idle;
				T_flag_CH<='0';
			end if;
		when others => Pileup_state <= Pileup_idle;
		end case;		
	end if;
 end process;
end Behavioral;
