----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:19:54 09/21/2011 
-- Design Name: 
-- Module Name:    RAM_Spectrum - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: CH을 2개로 늘림
-- 1초동안 Data를 수집 후 1번 1024data전송후 바로 2번 1024data 전송
--
-- Dependencies: 
--
-- Revision: V1.3
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



entity RAM_Spectrum is
	port( clk: in std_logic;		
			clk_RAM : in std_logic;
			rst: in std_logic;
			Swich_mode : in std_logic_vector(3 downto 0);
			GM_count : in std_logic;
			laser_count : in std_logic;
			neutron_count : in std_logic;
			flag_check : out std_logic;
			flag_init:out std_logic;
			acq_done : out std_logic:='1';
			flag_out: out std_logic;
			acq_take : in std_logic; -- Read Start
			acq_count : in std_logic; -- Read RAM Addr
			acq_start : in std_logic; -- Func Start
			flag_aq_1 : in std_logic;  
            Bat_ADC_In : in std_logic_vector(7 downto 0);
            Det_label  : in std_logic_vector(15 downto 0);
            GC : in std_logic_vector(15 downto 0);
            HV_DAC : in std_logic_vector(15 downto 0);
            Pileup_sp_T : in std_logic;
            R_Counter_RAM : in std_logic;          
 		    GM_En : in std_logic;
		    Neutron_En : in std_logic;           
            MEASURED_TEMP_in : in std_logic_vector(15 downto 0);
            MEASURED_VCCAUX_in : in std_logic_vector(15 downto 0);
            MEASURED_VCCINT_in : in std_logic_vector(15 downto 0);
            MEASURED_VCCBRAM_in : in std_logic_vector(15 downto 0);
            MEASURED_AUX0_in : in std_logic_vector(15 downto 0);
            MEASURED_AUX1_in : in std_logic_vector(15 downto 0);
            MEASURED_AUX2_in : in std_logic_vector(15 downto 0);  
            MEASURED_AUX3_in : in std_logic_vector(15 downto 0);  
			HV_buf_Sm : in std_logic_vector(11 downto 0);  
			flag_ram: out std_logic;
			Bat_Status_in : in  std_logic_vector(3 downto 0);
			data_in_1 : in std_logic_vector(12 downto 0);
	
            
			Spec_out : out std_logic_vector(15 downto 0):= "0100010000110000"--D0
		);	
end RAM_Spectrum;


architecture Behavioral of RAM_Spectrum is

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG

component dist_mem_gen_0 IS
  PORT (
    a : IN STD_LOGIC_VECTOR(9 DOWNTO 0);--depth(addr)
    d : IN STD_LOGIC_VECTOR(15 DOWNTO 0);--width
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END component;

component dist_mem_gen_1 IS
  PORT (
    a : IN STD_LOGIC_VECTOR(12 DOWNTO 0);--depth(addr)
    d : IN STD_LOGIC_VECTOR(15 DOWNTO 0);--width
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END component;


COMPONENT clk_20us
	PORT(
		clk : IN std_logic;          
		clk_20us : OUT std_logic
		);
	END COMPONENT;

	COMPONENT clk_200ns
	PORT(
		clk : IN std_logic;          
		clk_200ns : OUT std_logic
		);
	END COMPONENT;


	




-- cnt flag
signal cnt_save_1_A: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_1_B: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_2_A: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_2_B: std_logic_vector(2 downto 0):="000";
signal cnt_save_3_A: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_3_B: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_4_A: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_4_B: std_logic_vector(2 downto 0):="000";
signal cnt_save_5_A: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_5_B: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_6_A: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_6_B: std_logic_vector(2 downto 0):="000";
signal cnt_save_7_A: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_7_B: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_8_A: std_logic_vector(2 downto 0):="000"; 
signal cnt_save_8_B: std_logic_vector(2 downto 0):="000";

signal cnt_addr_1_A : std_logic_vector(12 downto 0):="0000000000000"; 
signal cnt_addr_1_B : std_logic_vector(12 downto 0):="0000000000000"; 

signal cnt_addr_2_A : std_logic_vector(9 downto 0):="0000000000"; 
signal cnt_addr_2_B : std_logic_vector(9 downto 0):="0000000000"; 

signal cnt_addr_3_A : std_logic_vector(9 downto 0):="0000000000"; 
signal cnt_addr_3_B : std_logic_vector(9 downto 0):="0000000000"; 

signal cnt_addr_4_A : std_logic_vector(9 downto 0):="0000000000"; 
signal cnt_addr_4_B : std_logic_vector(9 downto 0):="0000000000"; 


signal flag_rd_count : std_logic_vector(2 downto 0):="000";
signal Ram_rd_count: std_logic_vector(13 downto 0):="00000000000000";
signal Ram_rd_count_1: std_logic_vector(13 downto 0):="00000000000000";
signal Ram_rd_count_2: std_logic_vector(10 downto 0):="00000000000";
signal Ram_rd_count_3: std_logic_vector(10 downto 0):="00000000000";
signal Ram_rd_count_4: std_logic_vector(10 downto 0):="00000000000";
signal Ram_rd_count_5: std_logic_vector(10 downto 0):="00000000000";
signal Ram_rd_count_6: std_logic_vector(10 downto 0):="00000000000";
signal Ram_rd_count_7: std_logic_vector(10 downto 0):="00000000000";
signal Ram_rd_count_8: std_logic_vector(10 downto 0):="00000000000";

signal Ram_rd_count_1_cut: std_logic_vector(12 downto 0):="0000000000000";
signal Ram_rd_count_2_cut: std_logic_vector(9 downto 0):="0000000000";
signal Ram_rd_count_3_cut: std_logic_vector(9 downto 0):="0000000000";
signal Ram_rd_count_4_cut: std_logic_vector(9 downto 0):="0000000000";
signal Ram_rd_count_5_cut: std_logic_vector(9 downto 0):="0000000000";
signal Ram_rd_count_6_cut: std_logic_vector(9 downto 0):="0000000000";
signal Ram_rd_count_7_cut: std_logic_vector(9 downto 0):="0000000000";
signal Ram_rd_count_8_cut: std_logic_vector(9 downto 0):="0000000000";

signal i_acq_start : std_logic_vector( 1 downto 0):="00";
signal i_acq_take : std_logic_vector( 1 downto 0):="00";


signal cnt_init_end : std_logic_vector(1 downto 0):="00"; 
signal cnt_R_L : std_logic_vector(3 downto 0):="0000"; 
signal cnt_rst : std_logic:='0';

signal real_time_ena : std_logic:='0';
signal real_time_count : std_logic_vector(47 downto 0):=(others => '0');
signal Real_Time : std_logic_vector(47 downto 0):=(others => '0');

signal i_laser_true_count :  integer range 0 to 1000000000:=0;
 
-- Ram 1_a flag
signal wea_1_a : std_logic;
signal addra_1_a : std_logic_vector(12 downto 0):=(others => '0');
signal din_1_a : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_1_a : std_logic_vector(15 downto 0):=(others => '0');
-- Ram 5_a flag
signal wea_5_a : std_logic;
signal addra_5_a : std_logic_vector(12 downto 0):=(others => '0');
signal din_5_a : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_5_a : std_logic_vector(15 downto 0):=(others => '0');
-- Ram 6_a flag
signal wea_6_a : std_logic;
signal addra_6_a : std_logic_vector(12 downto 0):=(others => '0');
signal din_6_a : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_6_a : std_logic_vector(15 downto 0):=(others => '0');
-- Ram 7_a flag
signal wea_7_a : std_logic;
signal addra_7_a : std_logic_vector(12 downto 0):=(others => '0');
signal din_7_a : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_7_a : std_logic_vector(15 downto 0):=(others => '0');
-- Ram 2_a flag
signal wea_2_a : std_logic;
signal addra_2_a : std_logic_vector(9 downto 0):=(others => '0');
signal din_2_a : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_2_a : std_logic_vector(15 downto 0):=(others => '0');
 
-- Ram 3_a flag
signal wea_3_a : std_logic;
signal addra_3_a : std_logic_vector(9 downto 0):=(others => '0');
signal din_3_a : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_3_a : std_logic_vector(15 downto 0):=(others => '0');

-- Ram 4_a flag
signal wea_4_a : std_logic;
signal addra_4_a : std_logic_vector(9 downto 0):=(others => '0');
signal din_4_a : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_4_a : std_logic_vector(15 downto 0):=(others => '0'); 


signal i_laser_count : std_logic_vector(1 downto 0):="00";
signal neutron_count_T: std_logic_vector(15 downto 0):="0000000000000000";
signal GM_count_T: std_logic_vector(15 downto 0):="0000000000000000";

signal i_rd_clk : std_logic_vector(1 downto 0):="00";
signal i_GM_count: std_logic_vector(1 downto 0):="00";
signal i_Neutron_count: std_logic_vector(1 downto 0):="00";
signal i_acq_Flag_B : std_logic_vector(1 downto 0):="00";

signal i_flag_aq_1 : std_logic_vector(1 downto 0):="00";
signal i_flag_aq_2 : std_logic_vector(1 downto 0):="00";
signal i_flag_aq_3 : std_logic_vector(1 downto 0):="00";
signal i_flag_aq_4 : std_logic_vector(1 downto 0):="00";
--signal i_flag_aq_5 : std_logic_vector(1 downto 0):="00";
--signal i_flag_aq_6 : std_logic_vector(1 downto 0):="00";
--signal i_flag_aq_7 : std_logic_vector(1 downto 0):="00";
--signal i_flag_aq_8 : std_logic_vector(1 downto 0):="00";


-- Ram 1_b flag
signal wea_1_b : std_logic;
signal addra_1_b : std_logic_vector(12 downto 0):=(others => '0');
signal din_1_b : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_1_b : std_logic_vector(15 downto 0):=(others => '0');
-- Ram 5_b flag
signal wea_5_b : std_logic;
signal addra_5_b : std_logic_vector(12 downto 0):=(others => '0');
signal din_5_b : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_5_b : std_logic_vector(15 downto 0):=(others => '0');
-- Ram 6_b flag
signal wea_6_b : std_logic;
signal addra_6_b : std_logic_vector(12 downto 0):=(others => '0');
signal din_6_b : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_6_b : std_logic_vector(15 downto 0):=(others => '0');
-- Ram 7_b flag
signal wea_7_b : std_logic;
signal addra_7_b : std_logic_vector(12 downto 0):=(others => '0');
signal din_7_b : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_7_b : std_logic_vector(15 downto 0):=(others => '0');

-- Ram 2_b flag
signal wea_2_b : std_logic;
signal addra_2_b : std_logic_vector(9 downto 0):=(others => '0');
signal din_2_b : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_2_b : std_logic_vector(15 downto 0):=(others => '0');

-- Ram 3_b flag
signal wea_3_b : std_logic;
signal addra_3_b : std_logic_vector(9 downto 0):=(others => '0');
signal din_3_b : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_3_b : std_logic_vector(15 downto 0):=(others => '0');

-- Ram 4_b flag
signal wea_4_b : std_logic;
signal addra_4_b : std_logic_vector(9 downto 0):=(others => '0');
signal din_4_b : std_logic_vector(15 downto 0):="0000000000000000";
signal dout_4_b : std_logic_vector(15 downto 0):=(others => '0');


signal flag_12 : std_logic:='0';
signal cnt_flag_12 : std_logic_vector(5 downto 0):="000000";

-- GM_Laser flag
signal R_GM_count_A : std_logic_vector(23 downto 0):="000000000000000000000000";
signal R_GM_count_B : std_logic_vector(23 downto 0):="000000000000000000000000";
signal R_laser_count_A: std_logic_vector(15 downto 0):="0000000000000000";
signal R_laser_count_B: std_logic_vector(15 downto 0):="0000000000000000";
signal R_Neutron_count_A  : std_logic_vector(23 downto 0):="000000000000000000000000";
signal R_Neutron_count_B  : std_logic_vector(23 downto 0):="000000000000000000000000";

signal GM_LS_Neutron_reset : std_logic:='0'; 
signal cnt_Ram_rd_count_A : std_logic_vector(6 downto 0):="0000000";

signal cnt_Ram_rd_count_B : std_logic_vector(6 downto 0):="0000000";

--signal NaI_Demension  : std_logic_vector(23 downto 0):="000000000000000000000001"; --for 2x3 NaI
signal NaI_Demension  : std_logic_vector(15 downto 0):="0000000000000000"; --for 2x2 NaI

signal slwr_streamIN : std_logic;
signal flag_laser : std_logic:='0';

signal flag_Write_1 : std_logic:='0';
signal flag_Write_2 : std_logic:='0';
signal flag_Write_3 : std_logic:='0';
signal flag_Write_4 : std_logic:='0';


signal flag_2 : std_logic:='0';
signal flag_3 : std_logic:='0';
signal flag_4 : std_logic:='0';

signal flag_Init_5_1 : std_logic:='0'; 
signal flag_Init_6_1 : std_logic:='0'; 
signal flag_Init_5_2 : std_logic:='0'; 
signal flag_Init_6_2 : std_logic:='0';
signal flag_Init_5_3 : std_logic:='0'; 
signal flag_Init_6_3 : std_logic:='0'; 
signal flag_Init_5_4 : std_logic:='0'; 
signal flag_Init_6_4 : std_logic:='0';
signal flag_Init_5_5 : std_logic:='0'; 
signal flag_Init_6_5 : std_logic:='0'; 
signal flag_Init_5_6 : std_logic:='0'; 
signal flag_Init_6_6 : std_logic:='0';
signal flag_Init_5_7 : std_logic:='0'; 
signal flag_Init_6_7 : std_logic:='0'; 
signal flag_Init_5_8 : std_logic:='0'; 
signal flag_Init_6_8 : std_logic:='0';

signal  RD_Flag_count : std_logic_vector(2 downto 0):="000";
signal  MCU_Flag_count : std_logic_vector(9 downto 0):="0000000000";
signal flag_7 : std_logic:='0'; 
signal flag_8 : std_logic:='0'; 
signal flag_9 : std_logic:='0'; 
signal flag_10 : std_logic:='0'; 
signal flag_11 : std_logic_vector(2 downto 0):="000";
signal flag_acq_take : std_logic:='0';
signal flag_em : std_logic:='0'; 
signal flag_rd_correct_A : std_logic:='0';
signal flag_rd_correct_B : std_logic:='0';
signal flag_GNL : std_logic:='0';
signal cnt_acq_done  : std_logic_vector(2 downto 0):="000";
signal clk_10us_1 : std_logic;
signal clk_20us_1 : std_logic;
signal clk_200ns_1 : std_logic;
signal MCU_Count : std_logic_vector(23 downto 0):="000000000000000000000000";
signal acq_done_flag : std_logic;
signal  flag_acq_FLag_B : std_logic:='0';
signal P_pileup_count : std_logic_vector(15 downto 0):=(others => '0');
signal i_Pileup_count : std_logic_vector(1 downto 0):="00";

signal R_Counter_RAM_T : std_logic_vector(31 downto 0):=(others => '0');
signal i_R_Counter_RAM : std_logic_vector(1 downto 0):="00";

signal flag_master_time : std_logic:='0';
 
signal laser_true_count:  integer range 0 to 1000000000:=0; 
signal i_laser_master_count:  integer range 0 to 1000000000:=0; 


signal flag_ack : std_logic:='1';
signal flag_ack_count : std_logic_vector(3 downto 0):="0000";



type N_state is ( idle , true_neutron , watch_neutron ,fault_neutron, end_neutron );
signal neutron_state : N_state;


type RAM_State is ( RD_Count_01 ,RD_Count_02);
signal RD_Count_State : RAM_State;
begin

	RAM_1_a : dist_mem_gen_1
	port map (
			clk => clk_RAM,
			
			--ena => ena_a,
			we => wea_1_a,
			a => addra_1_a,
			d => din_1_a,
			spo => dout_1_a);
	
			
			
	RAM_1_b : dist_mem_gen_1
		port map (
			clk => clk_RAM,
			
			--ena => ena_b,
			we => wea_1_b,
			a => addra_1_b,
			d => din_1_b,
			spo => dout_1_b);


		i_clk_20us: clk_20us PORT MAP(
		clk => clk,
		clk_20us => clk_20us_1
	);
	
	i_clk_200ns: clk_200ns PORT MAP(
		clk => clk,
		clk_200ns => clk_200ns_1
	);

process(clk,acq_take,acq_start,acq_count)
begin



	if rising_edge(clk) then 
		if acq_start = '0'  then --reset 
		
			flag_Write_1 <= '0';
			flag_Write_2 <= '0';
				flag_Write_3 <= '0';
					flag_Write_4 <= '0';
					flag_GNL<='0';
			--flag_2 <= '0';
			flag_3 <= '0';
			--flag_4<='0';
			flag_8 <= '0';
			flag_9 <= '0';
			flag_10 <= '0';
			flag_11 <="000";
			flag_12<='0';
			flag_out<='0';
		--	Spec_out<="010001000011000000110000"; --D00
			Spec_out<="0100010000110000"; --D0
			neutron_count_T<=(others => '0');
			GM_count_T<=(others => '0');
			acq_done <= '1';
			R_Counter_RAM_T<=(others => '0');
		 RD_Count_State <= RD_Count_01;  
			flag_check<='1';
					
			flag_init<='1';
			R_laser_count_A <="0000000000000000";
			
			if cnt_rst = '1' then
				wea_1_a <='0';
					wea_1_b <='0';
					wea_2_a <='0';
					wea_2_b <='0';
					wea_3_a <='0';
     wea_3_b <='0';						
   		wea_4_a <='0';
     wea_4_b <='0';
				--ena_a<='0';
				--ena_b<='0';
				flag_Init_5_1 <='1'; --reset Ram_1_A
				flag_Init_6_1 <='1'; --reset Ram_1_B
				flag_Init_5_2 <='1'; --reset Ram_2_A
				flag_Init_6_2 <='1'; --reset Ram_2_B
				flag_Init_5_3 <='1'; --reset Ram_3_A
				flag_Init_6_3 <='1'; --reset Ram_3_B
				flag_Init_5_4 <='1'; --reset Ram_4_A
				flag_Init_6_4 <='1'; --reset Ram_4_B
	
				
				cnt_rst <= '0';
			end if;
		else
			cnt_rst <= '1';
		end if;

	
		i_flag_aq_1( 0 ) <= flag_aq_1;
		i_flag_aq_1( 1 ) <= i_flag_aq_1( 0 );
 
		if i_flag_aq_1( 0 ) > i_flag_aq_1( 1 ) then --Data acq_1 start from unit
			flag_Write_1 <= '1';	
			R_Counter_RAM_T<=R_Counter_RAM_T + R_Counter_RAM;
		end if;
		
		i_Pileup_count( 0 ) <= Pileup_sp_T;
		i_Pileup_count( 1 ) <= i_Pileup_count( 0 );	
		
		
		if i_Pileup_count( 0 ) > i_Pileup_count( 1 ) then
			P_pileup_count<=P_Pileup_count+1;
			
		end if;
				
			i_R_Counter_RAM( 0 ) <= R_Counter_RAM;
		i_R_Counter_RAM( 1 ) <= i_R_Counter_RAM( 0 );	
		
		
		if i_R_Counter_RAM( 0 ) > i_R_Counter_RAM( 1 ) then
			R_Counter_RAM_T<=R_Counter_RAM_T+1;
			
		end if;			
				
			i_neutron_count( 0 ) <= neutron_count;
		i_neutron_count( 1 ) <= i_neutron_count( 0 );					
				
		if i_neutron_count( 1 ) > i_neutron_count( 0 ) then
			neutron_count_T<=neutron_count_T+1;
			
		end if;							
        	i_GM_count( 0 ) <= GM_count;
		i_GM_count( 1 ) <= i_GM_count( 0 );					
				
		if i_GM_count( 0 ) > i_GM_count( 1 ) then  -- rising
			GM_count_T<=GM_count_T+1;
			
		end if;			
				
			if acq_take = '1' then -- GM , Laser save, Ram1-Ram2 swich, Ram read ok
				
				--if flag_10 = '0' then
	
			--		flag_10 <='1';	
			--	else
			--		flag_10<='0';	
			--	end if;
			 
				
			else
		
			end if;

			
		if flag_Write_1 = '1' and flag_2 = '0' then --Ram 1_a write 
                        
                            if cnt_save_1_A = "111" then
                                cnt_save_1_A <= "000";
                                --flag_1<='0';                    
                                
                            elsif cnt_save_1_A = "000" then                    
                                --ena_a<='1';
                                addra_1_a <= data_in_1 + 1;
                                cnt_save_1_A<=cnt_save_1_A + 1 ;
                            elsif cnt_save_1_A = "001" then                        
                                wea_1_a <='1';        
                                din_1_a <= dout_1_a + 1;
                                    
                                cnt_save_1_A<=cnt_save_1_A +1 ;    
                            else
                                wea_1_a <='0';  
                                flag_Write_1 <= '0';
                                cnt_save_1_A <= "000";
                                cnt_save_1_B <= "000";
                                --ena_a<='0';    
                                --cnt_save_1_A<=cnt_save_1_A +1 ;                            
                            end if;
                            
        
                    elsif flag_Write_1 = '1' and flag_2 = '1' then --Ram 1_b write
                            
                                if cnt_save_1_B = "111" then
                                    cnt_save_1_B <= "000";
                                    --flag_1<='0';                    
                                    --
                                elsif cnt_save_1_B = "000" then                    
                                    --ena_b<='1';
                                    addra_1_b <= data_in_1 + 1;                 
                                    cnt_save_1_B<=cnt_save_1_B +1 ;
                                elsif cnt_save_1_B = "001" then                        
                                    wea_1_b <='1';  
                                    din_1_b <= dout_1_b + 1;  
                                                        
                                    cnt_save_1_B<=cnt_save_1_B +1 ;    
                                else
                                    wea_1_b <='0';    
                                    flag_Write_1 <= '0';
                                    cnt_save_1_A <= "000";
                                    cnt_save_1_B <= "000";
                                    --ena_b<='0';
                                    --cnt_save_1_B<=cnt_save_1_B +1 ;                            --
                                end if;
                    else
                                cnt_save_1_B<="000";
                                cnt_save_1_A<="000";
                    end if;
                

           		

		if flag_3 = '1' and flag_4 = '0'  then -- Ram 1 read
			
			if Ram_rd_count_1 = "00" & X"821"  then
	           flag_Init_5_1 <='1';
	            
				Spec_out<=X"3636"; --ASCII 66
				cnt_addr_1_A<="0000000000000";
			elsif Ram_rd_count_1 = "00" & X"820" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_A<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81f" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_A<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81e" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_A<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81d" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_A<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81c" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_A<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81b" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_A<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81a" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_A<="0000000000000";
                
             elsif Ram_rd_count_1 = "00" & X"819" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_A<="0000000000000";
                
             elsif Ram_rd_count_1 = "00" & X"818" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_A<="0000000000000";                 
                GM_count_T  <= (others => '0');   
 	
			 elsif Ram_rd_count_1 = "00" & X"817" then  -- GM count
                Spec_out<=GM_count_T; -- GM_count	
                cnt_addr_1_A<="0000000000000";
                
            elsif Ram_rd_count_1 = "00" & X"816" then  -- temp
                Spec_out<="0000"&MEASURED_AUX3_in(15 downto 4); -- temp
                
            elsif Ram_rd_count_1 = "00" & X"815" then  -- 1460KeV
                Spec_out<="0000010000000111"; --1460KeV
	
				cnt_addr_1_A<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"814" then  -- 662KeV
                Spec_out<="0000001000011010"; --662KeV
	
				cnt_addr_1_A<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"813" then  -- 32KeV
                Spec_out<="0000000000011111"; --32KeV
	
				cnt_addr_1_A<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"812" then  -- HVADC
                
            elsif Ram_rd_count_1 = "00" & X"811" then  -- GAin
                Spec_out<=GC; --Gain
	
				cnt_addr_1_A<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"810" then  -- HVDAC
                Spec_out<=HV_DAC; --HV_DAC
	
				cnt_addr_1_A<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"80F" then  -- LABAL
                Spec_out<=Det_label; --Det_Label
	           R_Counter_RAM_T<=(Others=>'0');
				cnt_addr_1_A<="0000000000000";
	       elsif Ram_rd_count_1 = "00" & X"805" then  -- real_time
                Spec_out<=Real_time(15 downto 0); --real_time
	           R_Counter_RAM_T<=(Others=>'0');
				cnt_addr_1_A<="0000000000000";	
			elsif Ram_rd_count_1 = "00" & X"804" then  -- real_time
                Spec_out<=Real_time(31 downto 16); --real_time
	           R_Counter_RAM_T<=(Others=>'0');
				cnt_addr_1_A<="0000000000000";	
			elsif Ram_rd_count_1 = "00" & X"803" then  -- real_time
                Spec_out<=Real_time(47 downto 32); --real_time
	           R_Counter_RAM_T<=(Others=>'0');
				cnt_addr_1_A<="0000000000000";					
			elsif Ram_rd_count_1 = "00000000000" then				

				wea_1_a <= '0';	
				addra_1_a<=Ram_rd_count_1_cut;	
				Spec_out<="0100010000110000"; --D0
			else
			
				wea_1_a <= '0';		
				addra_1_a<=Ram_rd_count_1_cut;
				
				Spec_out<=dout_1_a;
			end if;
		
			
		elsif flag_3 = '1' and flag_4 = '1'  then 
			if Ram_rd_count_1 = "00" & X"821"  then
	           flag_Init_6_1 <='1';
	        
				Spec_out<=X"3636"; --ASCII 66
				cnt_addr_1_B<="0000000000000";
			elsif Ram_rd_count_1 = "00" & X"820" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_B<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81f" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_B<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81e" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_B<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81d" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_B<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81c" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_B<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81b" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_B<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"81a" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_B<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"819" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_B<="0000000000000";
             elsif Ram_rd_count_1 = "00" & X"818" then  -- reserve
                Spec_out<="0000000000000000"; -- reserve	
                cnt_addr_1_B<="0000000000000";  
     
                GM_count_T  <= (others => '0');                      	
			 elsif Ram_rd_count_1 = "00" & X"817" then  -- GM count
                Spec_out<=GM_count_T; -- GM count	
            
                cnt_addr_1_B<="0000000000000";	
			elsif Ram_rd_count_1 = "00" & X"816" then  -- temp
                Spec_out<="0000"&MEASURED_AUX3_in(15 downto 4); -- temp
	
				cnt_addr_1_B<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"815" then  -- 1460KeV
                Spec_out<="0000010000000111"; --1460KeV
	
				cnt_addr_1_B<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"814" then  -- 662KeV
                Spec_out<="0000001000011010"; --662KeV
	
				cnt_addr_1_B<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"813" then  -- 32KeV
                Spec_out<="0000000000011111"; --32KeV
	
				cnt_addr_1_B<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"812" then  -- HVADC
                
            elsif Ram_rd_count_1 = "00" & X"811" then  -- GAin
                Spec_out<=GC; --Gain
	
				cnt_addr_1_B<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"810" then  -- HVDAC
                Spec_out<=HV_DAC; --HV_DAC
	
				cnt_addr_1_B<="0000000000000";
            elsif Ram_rd_count_1 = "00" & X"80F" then  -- LABAL
                Spec_out<=Det_label; --Det_Label
	           R_Counter_RAM_T<=(Others=>'0');
				cnt_addr_1_B<="0000000000000";
			 elsif Ram_rd_count_1 = "00" & X"805" then  -- real_time
                Spec_out<=Real_time(15 downto 0); --real_time
	           R_Counter_RAM_T<=(Others=>'0');
				cnt_addr_1_B<="0000000000000";	
			elsif Ram_rd_count_1 = "00" & X"804" then  -- real_time
                Spec_out<=Real_time(31 downto 16); --real_time
	           R_Counter_RAM_T<=(Others=>'0');
				cnt_addr_1_B<="0000000000000";	
			elsif Ram_rd_count_1 = "00" & X"803" then  -- real_time
                Spec_out<=Real_time(47 downto 32); --real_time
	           R_Counter_RAM_T<=(Others=>'0');
				cnt_addr_1_B<="0000000000000";		
			elsif Ram_rd_count_1 = "00000000000" then

				addra_1_b<=Ram_rd_count_1_cut;	
				wea_1_b <= '0';
				Spec_out<="0100010000110000"; --D0
			else
					
				addra_1_b<=Ram_rd_count_1_cut;
				Spec_out<=dout_1_b;
				wea_1_b <= '0';
			end if;
			
--			elsif flag_3 = '1'  and flag_11 = "001" then -- Time & Sensor  read	
--				if Ram_rd_count_5 = "0000000100" then
				
								
--					flag_12 <= '1';
					
--					Spec_out<="0011001100110011"; --333
--					elsif Ram_rd_count_5 = "0000000011" then
--							Spec_out(15 downto 0)<=Real_Time(15 downto 0);
								
--				elsif Ram_rd_count_5 = "0000000010" then
					
--					Spec_out(15 downto 0)<=Real_Time(31 downto 16);
					
--						--Spec_out<="111111111000000011111111";
--				elsif Ram_rd_count_5 = "0000000001" then	
--					Spec_out(15 downto 0)<=Real_Time(47 downto 32);
--					--Spec_out<="1111111111111111";
				
--				else
--					Spec_out<=R_laser_count_A;
					
--				end if;							
					
		end if;	
		if flag_12 = '1' then
			if cnt_flag_12 = "10010" then
				flag_12 <= '0';
				if flag_11 = "001" then
				   flag_11 <= "000";
				else
					flag_11<= flag_11 + 1;
				end if;
				cnt_flag_12 <= "000000";
			else
				cnt_flag_12 <= cnt_flag_12 + '1';
			end if;
		end if;
			
		if flag_Init_5_1 ='1' then			-- Ram 1 reset
			if cnt_addr_1_A = "1111111111111" then 
			
				cnt_addr_1_A<="0000000000000";
				flag_Init_5_1<='0';

				wea_1_a <='0';
				

			elsif cnt_addr_1_A = "00000100" then
--				ena_a<='1';
				
				din_1_a<="0000000000000000";
				addra_1_a <= cnt_addr_1_A;
				cnt_addr_1_A <= cnt_addr_1_A +1;
			elsif cnt_addr_1_A = "00000000" then
--				ena_a<='1';
				
				wea_1_a <='1';
				din_1_a<="0000000000000000";
				addra_1_a <= cnt_addr_1_A;
				cnt_addr_1_A <= cnt_addr_1_A +1;
			else
--				ena_a<='1';
				din_1_a<="0000000000000000";
				addra_1_a <= cnt_addr_1_A;
				cnt_addr_1_A <= cnt_addr_1_A +1;
			end if;			
		end if;
		
		if flag_Init_6_1='1'  then			
			if cnt_addr_1_B = "1111111111111" then 
				cnt_addr_1_B<="0000000000000";
				--flag_6<='0';
				flag_Init_6_1<= '0';
				--ena_b<='0';
				wea_1_b <='0';
				
				--flag_check<='1';
				--flag_4 <='0';	
--			elsif cnt_addr_1_B = "00000000000" then
				--ena_b<='1';
				
				--flag_check<='0';
					
				
				--addra_1_b <= "10000000100";
--				wea_1_b <='0';
				--addra_1_b  <= "10000000101";
--				cnt_addr_1_B <= cnt_addr_1_B +1;
			elsif cnt_addr_1_B = "00000100" then
				din_1_b<="0000000000000000";
				--ena_b<='1';
				wea_1_b <='1';
				addra_1_b <= cnt_addr_1_B;
				cnt_addr_1_B <= cnt_addr_1_B +1;
			
			elsif cnt_addr_1_B = "00000000" then
				din_1_b<="0000000000000000";
				wea_1_b <='1';
				
				addra_1_b <= cnt_addr_1_B;
				cnt_addr_1_B <= cnt_addr_1_B +1;
				--ena_b<='1';
			else
				din_1_b<="0000000000000000";
				wea_1_b <='1';
				addra_1_b <= cnt_addr_1_B;
				cnt_addr_1_B <= cnt_addr_1_B +1;
				--ena_b<='1';
			end if;			
		
		end if;
			
			
					i_rd_clk( 0 ) <= acq_count;
					i_rd_clk( 1 ) <= i_rd_clk( 0 );					
			
			--if GM_LS_Neutron_reset = '0' and acq_start = '1'  then
		

		
if acq_take = '1' then
			 	
	 flag_3 <= '1';
     acq_done<='0';
			 	
			 	
				if i_rd_clk( 0 ) > i_rd_clk( 1 ) then
	case RD_Count_State is
    when RD_Count_01 =>			
			  		
         flag_ram<='1';
      
           if Ram_rd_count = "00" & X"821" then
    
             Ram_rd_count<= (others=>'0');
             Ram_rd_count_1 <="00" & X"821";
             Ram_rd_count_2<= (others=>'0');
             Ram_rd_count_3<= (others=>'0');
             Ram_rd_count_4<= (others=>'0');
             Ram_rd_count_5<=(others=>'0');
          --  RD_Count_State <= RD_Count_02;
              
    
           else
                
    
             Ram_rd_count <= Ram_rd_count + 1;
             Ram_rd_count_1 <= Ram_rd_count_1 + 1;
             Ram_rd_count_2<= (others=>'0');
             Ram_rd_count_3<= (others=>'0');
             Ram_rd_count_4<= (others=>'0');
             Ram_rd_count_5<=(others=>'0');
             if Ram_rd_count_1= "00000000000" then
              Ram_rd_count_1_cut<= (others=>'0');
             elsif Ram_rd_count_1= "00000000001"	then		
              Ram_rd_count_1_cut<= (others=>'0');
             else
              Ram_rd_count_1_cut <= Ram_rd_count_1_cut + 1;
             end if;				
     
         end if;
					
                         
 	                          
    when RD_Count_02 =>  --
 
        if Ram_rd_count = "00000000111" then

                Ram_rd_count<= (others=>'0');
                Ram_rd_count_1 <= (others=>'0');
                Ram_rd_count_2<= (others=>'0');
                Ram_rd_count_3<= (others=>'0');
                Ram_rd_count_4<= (others=>'0');
                Ram_rd_count_5<=  "00000000111";
               RD_Count_State <=RD_Count_01;
               
   
         else

                 Ram_rd_count <= Ram_rd_count + 1;
                 Ram_rd_count_1 <= (others=>'0');
                 Ram_rd_count_2<= (others=>'0');
                 Ram_rd_count_3<=(others=>'0');
                 Ram_rd_count_4<= (others=>'0');
                 Ram_rd_count_5<= Ram_rd_count_5 + 1;
               
                 

         end if;                                   
                                        
				end case;
				end if;	
			else
				Ram_rd_count<= (others=>'0');
				Ram_rd_count_1<= (others=>'0');
				Ram_rd_count_2<= (others=>'0');
				Ram_rd_count_3<= (others=>'0');
				Ram_rd_count_4<= (others=>'0');
    Ram_rd_count_5<=(others=>'0');
    
     Ram_rd_count_1_cut<= (others=>'0');
      Ram_rd_count_2_cut<= (others=>'0');
       Ram_rd_count_3_cut<= (others=>'0');
        Ram_rd_count_4_cut<= (others=>'0');
         Ram_rd_count_5_cut<= (others=>'0');
    	flag_3 <= '0';
          -- flag_10<='0';
           acq_done<='1';
           flag_11 <= "000";
           flag_12 <= '0';
           cnt_flag_12 <= "000000";
            flag_ram<='0';
             RD_Count_State <= RD_Count_01;  
			
			end if;
		
	
		
end if;	
	
end process;


					
process(clk_20us_1) -- laser_count(swich(2)) 200ms true signal
begin		
	if rising_edge(clk_20us_1) then
			i_acq_take( 0 ) <= acq_take;
			i_acq_take( 1 ) <= i_acq_take( 0 );	
		
			i_acq_start( 0 ) <= acq_start;
			i_acq_start( 1 ) <=i_acq_start( 0 );	
	
		if i_acq_start(1) < i_acq_start(0) then
			real_time_ena <='1';
		elsif i_acq_start(1) > i_acq_start(0) then
			real_time_ena <='0';
		end if;
		
		

	
		
		if real_time_ena = '1' then
			if  i_acq_take(1) < i_acq_take(0) then
				Real_Time<=real_time_count;
				real_time_count<= (others => '0');			
			else
				real_time_count<=real_time_count+1;	
			end if;
			
			
		else
			real_time_count<= (others => '0');		
		end if;	
		
	end if;	
		
end process;

process(acq_start,acq_take)
begin
	

	if acq_start = '0' then
		flag_4 <= '1';
		flag_2 <= '0';
	elsif rising_edge(acq_take) then
		flag_4 <= not flag_4;
		flag_2 <= not flag_2;
	end if;

end process;

end Behavioral;



