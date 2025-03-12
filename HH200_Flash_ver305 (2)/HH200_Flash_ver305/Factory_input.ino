void factory_input() {
  ////////////////////////////////////////////////////
  // A(0) : CGN
  // B(1) : LGN
  // C(2) : NaI(3x3)
  // D(3) : NaI(2x2)
  // E(4) : NaI(1.5x1.5)
  // F(5) : NaI(2x4x16)
  // G(6) : NaI(3x5x16)
  // H(7) : CGN 2X2
  // I(8) : LGN 2X2
  // J(9) : NaI(1x1)
  // K(10) : NaI(2x3)
  // L(11) : NaI(4x4X16)
  // M(12) : CEBR(3x3)
  // N(13) : LABR(3x3)
  // O(14) : NaI(2x4x12)
  ////////////////////////////////////////////////////
  g_Detector = 7;                          //디텍터 코드
  HV_Start.DAC_Value = 4000;
  HV_DAC.DAC_Value = 25900;                //HV 설정 DAC값 
  HV_init_ADC.DAC_Value = 2252;           //HV ADC값(목표치)
  g_GC_init.DAC_Value = 30500;            //AD603 DAC값(gain) 33000
  g_32keV_init.DAC_Value = 12;             //32kev 값
  g_662keV_init.DAC_Value = 218;          //662kev 값
  g_K40_init.DAC_Value = 485;             //K40 값
  adc_cal = 0.24061;

  MCU_ver[0] = '3';//3.0.3
  MCU_ver[1] = '0';
  MCU_ver[2] = '3';

  FPGA_ver[0] = '3';//3.0.8.0
  FPGA_ver[1] = '0';
  FPGA_ver[2] = '8';
  FPGA_ver[3] = '0';

  Board_ver[0] = 'F';// DAQ Rev
  Board_ver[1] = 'D';// HV Rev CCFL , URT Rev.D
  Board_ver[2] = 'I';// GM Rev
  Board_ver[3] = 'D';// HV divider - 200 NAI
  Board_ver[4] = '0';// Preamap - 200 NAI
  Board_ver[5] = '0';// ACC 3

  SerialNumber[0] = '9';//HH224AI-CGN
  SerialNumber[1] = '5';
  SerialNumber[2] = '0';
  SerialNumber[3] = '1';
  SerialNumber[4] = '6';
  SerialNumber[5] = '7';
}
