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

entity radiation_SCA14bit is
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
	dout_CH: out std_logic_vector(12 downto 0);
	flag_CH : out std_logic
	);	
end radiation_SCA14bit;

architecture Behavioral of radiation_SCA14bit is
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

Component Moving_Avr is
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
end Component;

Component c_addsub_0 IS
  PORT (
    A : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    CLK : IN STD_LOGIC;
    CE : IN STD_LOGIC;
    S : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
  );
end Component;

Component c_addsub_1 IS
  PORT (
    A : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    CLK : IN STD_LOGIC;
    CE : IN STD_LOGIC;
    S : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
  );
end Component;

signal CH_Signal: STD_LOGIC_VECTOR ( 13 downto 0 );
signal data_in_Baseline: STD_LOGIC_VECTOR ( 13 downto 0 );
signal F_T_Pileup : STD_LOGIC_VECTOR ( 13 downto 0 );
signal F_Pileup: STD_LOGIC_VECTOR ( 13 downto 0 );
signal D_Pileup: STD_LOGIC_VECTOR ( 13 downto 0 ); 
signal D_Pileup_Before :  std_logic_vector(13 downto 0);
signal D_Pileup_Before_Before :  std_logic_vector(13 downto 0);
signal D_Pileup_Before_Before_Before :  std_logic_vector(13 downto 0);
signal D_Pileup_Before_Before_Before_Before :  std_logic_vector(13 downto 0);
signal D_Pileup_Before_Before_Before_Before_Before :  std_logic_vector(13 downto 0);

signal Pileup_ce : std_logic:='0';	

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


signal Ch_Data_subtraction_all_Pre: std_logic_vector(13 downto 0):=(others => '0');

signal Ch_Data_subtraction_all_0 : std_logic_vector(13 downto 0):=(others => '0');
signal Ch_Data_subtraction_all_1 : std_logic_vector(13 downto 0):=(others => '0');
signal Ch_Data_subtraction_all_2 : std_logic_vector(15 downto 0):=(others => '0');
signal Ch_Data_subtraction_all_3 : std_logic_vector(15 downto 0):=(others => '0');
signal Ch_Data_subtraction_all : std_logic_vector(13 downto 0):=(others => '0');


signal Ch_Data_subtraction_Origin : std_logic_vector(13 downto 0):=(others => '0');
signal flag_Baseline : std_logic:='0';
signal flag_Find_Baseline : std_logic_vector(2 downto 0):="000";
Signal CH_Baseline : STD_LOGIC_VECTOR ( 19 downto 0 ):= (others => '0'); 
signal CH_Baseline_Pre : std_logic_VECTOR ( 19 downto 0 ):= (others => '0');  
--Signal CH_Signal_Baseline : STD_LOGIC_VECTOR ( 10 downto 0 ):= (others => '0'); 
signal CH_Baseline_Pre_1 : std_logic_VECTOR ( 13 downto 0 ):= (others => '0'); 
Signal CH_Baseline_2 : STD_LOGIC_VECTOR ( 19 downto 0 ):= (others => '0'); 
signal CH_Baseline_Pre_2 : std_logic_VECTOR ( 13 downto 0 ):= (others => '0');  
Signal CH_Baseline_3 : STD_LOGIC_VECTOR ( 19 downto 0 ):= (others => '0'); 
signal CH_Baseline_Pre_3 : std_logic_VECTOR ( 13 downto 0 ):= (others => '0');  
Signal CH_Baseline_4 : STD_LOGIC_VECTOR ( 19 downto 0 ):= (others => '0'); 
signal CH_Baseline_Pre_4 : std_logic_VECTOR ( 13 downto 0 ):= (others => '0');  

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
signal dout: std_logic_vector(21 downto 0);
signal pileup_out : std_logic_vector(10 downto 0); 

signal Pileup_p :  std_logic_vector(23 downto 0);
signal cnt_Noise_Fileup : std_logic_vector(10 downto 0):= (others => '0');
signal test_start : std_logic:='0';

signal cnt_Signal : STD_LOGIC_VECTOR ( 5 downto 0):= (others => '0');
signal cnt_Signal_2 : STD_LOGIC_VECTOR ( 5 downto 0):= (others => '0');
signal cnt_Signal_3 : STD_LOGIC_VECTOR ( 5 downto 0):= (others => '0');
signal cnt_Signal_4 : STD_LOGIC_VECTOR ( 5 downto 0):= (others => '0');


signal cnt_Signal_i : STD_LOGIC_VECTOR ( 7 downto 0):= (others => '0');
signal cnt_Signal_2_i : STD_LOGIC_VECTOR ( 6 downto 0):= (others => '0');
signal cnt_Signal_3_i : STD_LOGIC_VECTOR ( 6 downto 0):= (others => '0');
signal cnt_Signal_4_i : STD_LOGIC_VECTOR ( 6 downto 0):= (others => '0');

signal flag_Baseline_Avr : std_logic:='0';

signal cnt_Signal_S : STD_LOGIC_VECTOR ( 6 downto 0);
signal cnt_Signal_Before : STD_LOGIC_VECTOR ( 6 downto 0);
signal cnt_Signal_Before_Before : STD_LOGIC_VECTOR ( 6 downto 0);
signal cnt_Signal_Before_Before_Before : STD_LOGIC_VECTOR ( 6 downto 0);

signal cnt_Baseline_Count :  integer range 0 to 50000000:=0;

signal Baseline_Undershoot : std_logic:='0';
signal cnt_Baseline_Undershoot : std_logic_VECTOR ( 10 downto 0 ):= (others => '0');  

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
signal cnt_flag_Avr  : std_logic_vector(9 downto 0);

signal data_in_large : STD_LOGIC_VECTOR ( 17 downto 0):= (others => '0');
signal Baseline_Add : std_logic_vector(17 downto 0):=(others => '0');
signal CH_Signal_Add : std_logic_vector(17 downto 0):=(others => '0');
signal Ch_Data_subtraction_T : std_logic_vector(13 downto 0):=(others => '0');
signal CH_Signal_Baseline_T : STD_LOGIC_VECTOR ( 13 downto 0 ):= (others => '0');  
signal CH_Signal_Adder : std_logic_vector(20 downto 0):=(others => '0'); 
signal CH_Signal_Adder_Com : std_logic_vector(20 downto 0):=(others => '0'); 
signal CH_Signal_ADD_Pre: std_logic_vector(13 downto 0):=(others => '0');

signal Baseline_Search: std_logic:='0';
signal Baseline_Find: std_logic:='0';

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


i_Moving_Avr : Moving_Avr 
port map(  
  i_clk                     =>clk,
  i_rstb                     =>acq_start,
  i_sync_reset               =>'0',
  -- input
  i_data_ena                =>flag_Baseline_Avr,
  i_data                     =>data_in,
  -- output
  o_data_valid              =>open,
  o_data                     =>data_in_Baseline);

--i_c_addsub_0 : c_addsub_0 
--port map( 
--			a => data_in,
--			b => Ch_Data_subtraction_T,
--			clk => clk,
--			ce => flag_Baseline_true,
--			s => CH_Signal_Baseline_T);

--i_Adder : c_addsub_1 
--port map(
--			a => data_in_large,
--			b => Baseline_Add,
--			clk => clk,
--			ce => acq_start,
--			s => CH_Signal_Add);



process(acq_start,clk)
begin
	if acq_start = '0' then
	dout<= (others=>'0');
	Pileup_state<=Pileup_idle;
	T_flag_CH <= '0';
	flag_CH<='0';	
	flag_Find_Baseline<="000";
	flag_Noise_Baseline <= '0'; 
	flag_Baseline_true<='0';
--	flag_data_stop <='0';
   cnt_Baseline_Count<= 0;
	cnt_Signal<= (others=>'0');
	cnt_Signal_2<= (others=>'0');
	cnt_Signal_3<= (others=>'0');
	cnt_Signal_4<= (others=>'0');
	cnt_Signal_i<= (others=>'0');
	cnt_Signal_2_i<= (others=>'0');
	cnt_Signal_3_i<= (others=>'0');
	cnt_Signal_4_i<= (others=>'0');
	cnt_flag_subtraction<= (others=>'0');
	cnt_flag_Avr <= "0000000000";	
	 Baseline_Undershoot <='0';
 Baseline_Search<='0';
 Baseline_Find<='0';	 
	 cnt_Baseline_Undershoot<= (others=>'0');	
	
	elsif rising_edge(clk) then
	
				CH_Signal<=data_in;
--CH_Signal_Baseline<= CH_Signal_Baseline_T;
		data_in_large <=  "0000"&data_in(13 downto 0);
	if Baseline_Find ='0' then	
        if cnt_Baseline_Count = 50000000 then
            cnt_Baseline_Count<=0;
            Baseline_Search<='1';
            Baseline_Find<='1';
        else       	
            cnt_Baseline_Count<=cnt_Baseline_Count+1;
        end if;
    end if;
if flag_Baseline_true ='0' then

						if flag_Find_Baseline = "000" then
							if cnt_Signal_i="000000" then			
									cnt_Signal_i<=cnt_Signal_i+1;
									Baseline_Add<= (others=>'0');
									CH_Signal_Adder<=data_in+"000000000000000000000";
									CH_Signal_ADD_Pre<=data_in;						
--							elsif cnt_Signal_i="0000001" then
--									cnt_Signal_i<=cnt_Signal_i+1;
--									CH_Signal_Adder<=data_in+CH_Signal_Adder;			
--									
--							elsif cnt_Signal_i = "0001110" then
--									
--									CH_Signal_Adder<=data_in+CH_Signal_Adder;	
--									cnt_Signal_i<=cnt_Signal_i+1;
							elsif cnt_Signal_i = "0010000" then	
							CH_Signal_Adder_Com<=CH_Signal_Adder;
								--CH_Signal_Adder<=data_in+CH_Signal_Adder;	
								cnt_Signal_i<=cnt_Signal_i+1;
							elsif cnt_Signal_i = "0010001" then	
							cnt_Signal_i<=cnt_Signal_i+1;
								--CH_Signal_Adder_Com<=CH_Signal_Adder-max_Baseline_Add-min_Baseline_Add;
							--CH_Signal_Adder_Com<=CH_Signal_Adder;
							
							elsif cnt_Signal_i = "0010010" then	
								Ch_Data_subtraction_all<=CH_Signal_Adder_Com(17 downto 4);	
								flag_Find_Baseline <="000";
								cnt_Signal_i<= (others=>'0');
								flag_Baseline_true<='1';
								
								Baseline_Add<= (others=>'0');
							else
								
								cnt_Signal_i<=cnt_Signal_i+1;
								CH_Signal_ADD_Pre<=data_in;	
								Baseline_Add<=CH_Signal_Add;	
								CH_Signal_Adder<=data_in+CH_Signal_Adder;
--								max_Baseline_Add<=maximum(data_in,CH_Signal_Add_Pre);
--								min_Baseline_Add<=minimum(data_in,CH_Signal_Add_Pre);
							end if;		
					
						
						end if;	
				
		end if;
	
			if flag_Baseline_true = '1' then
			if flag_Find_Baseline = "000" then	
--					Ch_Data_subtraction_T<=Ch_Data_subtraction_all_1;
				if data_in >  Ch_Data_subtraction_all+Data_subtraction then
					CH_Signal_Baseline <= data_in - Ch_Data_subtraction_all-Data_subtraction;
				else
					CH_Signal_Baseline<="00000000000000";
				end if;
--				
--
			elsif flag_Find_Baseline = "001" then	
				--	Ch_Data_subtraction_T<=Ch_Data_subtraction_all_1;
				if data_in >  Ch_Data_subtraction_all_1+Data_subtraction then
					CH_Signal_Baseline <= data_in - Ch_Data_subtraction_all_1-Data_subtraction;
				else
					CH_Signal_Baseline<="00000000000000";
				end if;
--				
--				
			
--				
--				
			end if;
		else
			CH_Signal_Baseline<= (others=>'0');
		end if;		

		case Pileup_state is
		when Pileup_idle =>
		flag_CH<='0';
		if flag_Baseline_true = '1' then			
			if CH_Signal_Baseline> Threshold then				
				
					flag_start <= '1';
					Pileup_state  <= Pileup_peak;
					cnt_Signal_S<="0000001";
					CH_S<="0000000000000000000000"+CH_Signal_Baseline+CH_Baseline_Pre_1+CH_Baseline_Pre_2+CH_Baseline_Pre_3+CH_Baseline_Pre_4;
					CH_S_1<= (others=>'0');
				flag_Baseline_Avr<='0';
			else 
			flag_Baseline_Avr<='1';
			CH_Baseline_Pre_1<=CH_Signal_Baseline;
			CH_Baseline_Pre_2<=CH_Baseline_Pre_1;
			CH_Baseline_Pre_3<=CH_Baseline_Pre_2;
			CH_Baseline_Pre_4<=CH_Baseline_Pre_3;
		
			
				if Baseline_Undershoot = '1' then
					if cnt_Baseline_Undershoot = "10100000000" then
						cnt_Baseline_Undershoot<="00000000000";
						Baseline_Undershoot <='0';
					else
						cnt_Baseline_Undershoot<=cnt_Baseline_Undershoot+'1';
					end if;
				else		
				      if Baseline_Find ='1' then
						if flag_Find_Baseline = "000" then
							if cnt_Signal_i="0000000" then			
									cnt_Signal_i<=cnt_Signal_i+1;
									Baseline_Add<= (others=>'0');
									CH_Signal_Adder<=data_in+"000000000000000000000";
									CH_Signal_ADD_Pre<=data_in;						
--							
							elsif cnt_Signal_i = "10000000" then	
							CH_Signal_Adder_Com<=CH_Signal_Adder;
								--CH_Signal_Adder<=data_in+CH_Signal_Adder;	
								cnt_Signal_i<=cnt_Signal_i+1;
							elsif cnt_Signal_i = "10000001" then	
							cnt_Signal_i<=cnt_Signal_i+1;
							
								--CH_Signal_Adder_Com<=CH_Signal_Adder-max_Baseline_Add-min_Baseline_Add;
							
							  Ch_Data_subtraction_all_Pre<=Ch_Data_subtraction_all_1;
							elsif cnt_Signal_i = "10000010" then	
								
--								if CH_Signal_Adder_Com(20 downto 8)>Ch_Data_subtraction_all_Pre then
--								   Ch_Data_subtraction_all_1<=Ch_Data_subtraction_all_Pre;	 
--								else
							       Ch_Data_subtraction_all_1<=CH_Signal_Adder_Com(20 downto 7);
--								end if;
								flag_Find_Baseline <="001";
								Baseline_Find <='0';
								cnt_Signal_i<= (others=>'0');
								Baseline_Add<= (others=>'0');
								Baseline_Search <='0';
							else
							    CH_Signal_Adder<=data_in+CH_Signal_Adder;
								cnt_Signal_i<=cnt_Signal_i+1;
								CH_Signal_ADD_Pre<=data_in;	
								Baseline_Add<=CH_Signal_Add;	
--								max_Baseline_Add<=maximum(data_in,CH_Signal_Add_Pre);
--								min_Baseline_Add<=minimum(data_in,CH_Signal_Add_Pre);
							end if;		
						elsif flag_Find_Baseline = "001" then
							if cnt_Signal_i="000000000" then			
									cnt_Signal_i<=cnt_Signal_i+1;
									Baseline_Add<= (others=>'0');
									CH_Signal_Adder<=data_in+"000000000000000000000";
									CH_Signal_ADD_Pre<=data_in;						
--							
							elsif cnt_Signal_i = "10000000" then	
							CH_Signal_Adder_Com<=CH_Signal_Adder;
								--CH_Signal_Adder<=data_in+CH_Signal_Adder;	
								cnt_Signal_i<=cnt_Signal_i+1;
							elsif cnt_Signal_i = "10000001" then	
							cnt_Signal_i<=cnt_Signal_i+1;
								--CH_Signal_Adder_Com<=CH_Signal_Adder-max_Baseline_Add-min_Baseline_Add;
							
							Ch_Data_subtraction_all_Pre<=Ch_Data_subtraction_all;
							elsif cnt_Signal_i = "10000010" then	
--								if CH_Signal_Adder_Com(19 downto 6)>Ch_Data_subtraction_all_Pre then
--								    Ch_Data_subtraction_all<=Ch_Data_subtraction_all_Pre;
--								else
							     	Ch_Data_subtraction_all<=CH_Signal_Adder_Com(20 downto 7);	
--								end if;								
							
								--Ch_Data_subtraction_all<=CH_Signal_Adder_Com(17 downto 4);	
								flag_Find_Baseline <="000";
								Baseline_Find <='0';
								cnt_Signal_i<= (others=>'0');
								Baseline_Add<= (others=>'0');
								
							else
							    CH_Signal_Adder<=data_in+CH_Signal_Adder;
								cnt_Signal_i<=cnt_Signal_i+1;
								CH_Signal_ADD_Pre<=data_in;	
								Baseline_Add<=CH_Signal_Add;	
--								max_Baseline_Add<=maximum(data_in,CH_Signal_Add_Pre);
--								min_Baseline_Add<=minimum(data_in,CH_Signal_Add_Pre);
							end if;		
						end if;
						end if;	
				end if;	
			end if;	
		end if;	
		when Pileup_peak =>	
		flag_CH<='0';
			D_Pileup<=CH_Signal_Baseline;
			D_Pileup_Before<=D_Pileup;
		cnt_Signal_i<= (others=>'0');
		
		if cnt_Signal_S <= Signal_TIME then
					if CH_Signal_Baseline< Threshold  then
						Pileup_state<=Pileup_idle;
						cnt_Signal_S<="0000000";
						CH_S<="0000000000000000000000";	
						Baseline_Undershoot<='1';
						cnt_Baseline_Undershoot<="00000000000";			
					flag_Noise_Baseline <= '1'; 

					else
						
						cnt_Signal_S<=cnt_Signal_S+1;
						CH_S<=CH_S+CH_Signal_Baseline;
					end if;	
		else
			if D_Pileup>= CH_Signal_Baseline and D_Pileup_Before>= D_Pileup then 
							
				F_Pileup<=D_Pileup; -- save top value
					Pileup_state<=Pileup_normal;
					
			end if;
			CH_S<=CH_S+CH_Signal_Baseline;
			cnt_Signal_S<=cnt_Signal_S+1;
		end if;		

			
			

			
		
		when Pileup_Normal =>	
		flag_CH<='0';
			D_Pileup<=CH_Signal_Baseline;
			D_Pileup_Before<=D_Pileup;
			D_Pileup_Before_Before<=D_Pileup_Before;
			
			D_Pileup_Before_Before_Before<=D_Pileup_Before_Before;
			D_Pileup_Before_Before_Before_Before<=D_Pileup_Before_Before;
			
			cnt_Signal_Before_Before_Before<=cnt_Signal_Before;
			cnt_Signal_Before_Before<=cnt_Signal_Before;
			cnt_Signal_Before<=cnt_Signal_S;
					

			
			
				if D_Pileup< CH_Signal_Baseline and D_Pileup_Before< D_Pileup and D_Pileup_Before< D_Pileup_Before_Before then
			
				cnt_pileup<=cnt_Signal_S(5 downto 0); 
				
				D_Pileup<="00000000000000";
				D_Pileup_Before<="00000000000000";
				D_Pileup_Before_Before<="00000000000000";
				D_Pileup_Before_Before_Before<="00000000000000";
				Pileup_ce<='1';			
			Pileup_state<=Pileup_get;	
					F_T_Pileup<=CH_Signal_Baseline;	
					cnt_Signal_S <= "0000000";
			else
			
			
				if CH_Signal_Baseline<  Threshold  then
				    
					if cnt_Signal_S <= Signal_TIME then
						Pileup_state<=Pileup_idle;
						cnt_Signal_S<="0000000";
						CH_S<="0000000000000000000000";	
							flag_Noise_Baseline <= '1';
						Baseline_Undershoot<='1';
						cnt_Baseline_Undershoot<="00000000000";	
					else	
						    Baseline_Undershoot<='1';
						    cnt_Baseline_Undershoot<="00000000000";
							flag_start <= '0';
							Pileup_state<=Pileup_trans;
							dout<=CH_S;
							flag_Noise_Baseline <= '1'; 
							T_flag_CH<='1';
							cnt_Signal_S <= "0000000";
						end if;
				else	
				
							
					
						
						cnt_Signal_S<=cnt_Signal_S+1;
						CH_S<=CH_S+CH_Signal_Baseline;
						
				end if;	
			end if;
			
		
	

	when Pileup_get =>
flag_CH<='0';
			D_Pileup<=CH_Signal_Baseline;
			D_Pileup_Before<=D_Pileup;
			D_Pileup_Before_Before<=D_Pileup_Before;
			
		
		if F_T_Pileup< CH_Signal_Baseline then
			F_T_Pileup<=CH_Signal_Baseline;
			
		end if;	
				if CH_Signal_Baseline< Threshold  then
						if F_Pileup(12 downto 5) < F_T_Pileup then
							Pileup_state<=Pileup_idle;
							Pileup_ce<='0';
							cnt_Signal_S <= "0000000";
							Baseline_Undershoot<='1';
						    cnt_Baseline_Undershoot<="00000000000";
						else  
						    Pileup_ce<='0';  
							dout<=CH_S+CH_S_1;
							Pileup_state<=Pileup_trans;
							cnt_Signal_S <= "0000000";
							Baseline_Undershoot<='1';
					     	cnt_Baseline_Undershoot<="00000000000";
						end if;
					flag_Noise_Baseline <= '1'; 
				else	
				CH_S_1<=CH_S_1+CH_Signal_Baseline;
				cnt_Signal_S<=cnt_Signal_S+1;
				end if;
		
		
		when Pileup_exp =>
				flag_CH<='0';
				if CH_Signal_Baseline< Threshold  then	
				
					flag_start <= '0';
					Pileup_state<=Pileup_trans;
					cnt_Signal_S <= "0000000";
				else
					cnt_Signal_S<=cnt_Signal_S+1;
					CH_S<=CH_S+CH_Signal_Baseline;
				end if;	
		
		when Pileup_trans =>
		
		
		if dout > "00000000011111" and dout < "111111111111111111"  then
						
			if cnt_divide="101" then
					flag_CH<='0';
					T_flag_CH<='0';
					Pileup_state<=Pileup_idle;
					cnt_divide<="00000";
				    Baseline_Undershoot<='1';
					cnt_Baseline_Undershoot<="00000000000";
					cnt_Signal_i<= (others=>'0');				
				elsif cnt_divide="011" then
					flag_CH<='0';
					cnt_divide<=cnt_divide+'1';
				elsif cnt_divide="001" then
				--	dout_CH<=Ch_Data_subtraction_all;
					dout_CH<=dout(17 downto 5);
					cnt_divide<=cnt_divide+'1';
				elsif cnt_divide="000" then
					
					flag_CH<='1';
					cnt_divide<=cnt_divide+'1';
				else
					cnt_divide<=cnt_divide+'1';
				end if;
			else
		--		flag_data_stop<='0';
				dout<="0000000000000000000000";
				Pileup_state<=Pileup_idle;
				T_flag_CH<='0';
			end if;
		when others => Pileup_state <= Pileup_idle;
		end case;		
	end if;
 end process;
end Behavioral;
