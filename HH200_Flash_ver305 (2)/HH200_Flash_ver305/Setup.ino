
void setup() {//-------------------------------------------------------------------------------------------setup
  // put your setup code here, to run once:
  pmc_enable_periph_clk(PIOB_IRQn); //em set to input
  pmc_enable_periph_clk(PIOD_IRQn);
  pmc_enable_periph_clk(PIOC_IRQn);
  REG_PIOB_PER = 0x10000000;
  REG_PIOB_PER = 0x20000000;
  REG_PIOB_PER = 0x40000000;
  REG_PIOB_PER = 0x80000000;
  REG_PIOB_OER = 0x00000001;  //start
  REG_PIOB_OER = 0x00000004;  //fpga_re
  REG_PIOB_OER = 0x00000008;  //fpga_clk
  REG_PIOB_OER = 0x00000010;  //Lamp
  REG_PIOB_OER = 0x10000000;  //TCK
  REG_PIOB_OER = 0x20000000;  //TDI
  REG_PIOB_OER = 0x40000000;  //TDO
  REG_PIOB_OER = 0x80000000;  //TMS

  REG_PIOB_CODR = 0x10000000;
  REG_PIOB_CODR = 0x20000000;
  REG_PIOB_CODR = 0x40000000;
  REG_PIOB_CODR = 0x80000000;
  //    REG_PIOB_SODR = 0x10000000;
  //    REG_PIOB_SODR = 0x20000000;
  //    REG_PIOB_SODR = 0x40000000;
  //    REG_PIOB_SODR = 0x80000000;

  REG_PIOD_OER = 0x200; //LED_On
  pinMode(12, OUTPUT);
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);


  analogReadResolution(12);
  REG_PIOD_OER = 0x80; //LED_Off
  REG_PIOB_SODR = 0x10; //Lamp off
  REG_PIOB_OER = 0x80;//CS2
  REG_PIOB_OER = 0x40;//CS1
  REG_PIOD_OER = 0x400; //Bat_3P3
  delay(1000);
  Serial.begin(115200);
  Serial2.begin(115200);
  Serial.println("HP DCP");
  cpu_irq_enable();
  SPI.begin();
  //g_Detector
  if (digitalRead(29)) {
    FactoryReset();
  }
  REG_PIOD_CODR = 0x400; //Bat_3P3 low

  REG_ADC_MR = (REG_ADC_MR & 0xFFF0FFFF) | 0x00020000;

  factory_input();
  if (dueFlashStorage.read(0) == 255) {
    Serial.println("Data_Write");
    dueFlashStorage.write(0, g_Detector);
    dueFlashStorage.write(1,  HV_DAC.value[0]);///////////ch1  detector2
    dueFlashStorage.write(2,  HV_DAC.value[1]);
    dueFlashStorage.write(3,  g_GC_init.value[0]);//////////ch2   detector1
    dueFlashStorage.write(4,  g_GC_init.value[1]);
    dueFlashStorage.write(5,  g_K40_init.value[0]);//////////ch3
    dueFlashStorage.write(6,  g_K40_init.value[1]);
    dueFlashStorage.write(7,  g_32keV_init.value[0]);//////////ch4 720
    dueFlashStorage.write(8,  g_32keV_init.value[1]);
    dueFlashStorage.write(9,  g_662keV_init.value[0]);
    dueFlashStorage.write(10, g_662keV_init.value[1]);
    dueFlashStorage.write(11,  HV_init_ADC.value[0]);
    dueFlashStorage.write(12, HV_init_ADC.value[1]);
    dueFlashStorage.write(13, CONTROL_MOD);

    dueFlashStorage.write(20, g_Detector);
    dueFlashStorage.write(21, HV_DAC.value[0]);///////////ch1  detector2
    dueFlashStorage.write(22, HV_DAC.value[1]);
    dueFlashStorage.write(23, g_GC_init.value[0]);//////////ch2   detector1
    dueFlashStorage.write(24, g_GC_init.value[1]);
    dueFlashStorage.write(25, g_K40_init.value[0]);//////////ch3
    dueFlashStorage.write(26, g_K40_init.value[1]);
    dueFlashStorage.write(27, g_32keV_init.value[0]);//////////ch4 720
    dueFlashStorage.write(28, g_32keV_init.value[1]);
    dueFlashStorage.write(29, g_662keV_init.value[0]);
    dueFlashStorage.write(30, g_662keV_init.value[1]);
    dueFlashStorage.write(31, HV_init_ADC.value[0]);
    dueFlashStorage.write(32, HV_init_ADC.value[1]);
    //--------------------------------------MCU ver
    dueFlashStorage.write(40, MCU_ver[0]);
    dueFlashStorage.write(41, MCU_ver[1]);
    dueFlashStorage.write(42, MCU_ver[2]);
    //--------------------------------------FPGA ver
    dueFlashStorage.write(50, FPGA_ver[0]);
    dueFlashStorage.write(51, FPGA_ver[1]);
    dueFlashStorage.write(52, FPGA_ver[2]);
    dueFlashStorage.write(53, FPGA_ver[3]);
    //--------------------------------------Board ver
    dueFlashStorage.write(60, Board_ver[0]);
    dueFlashStorage.write(61, Board_ver[1]);
    dueFlashStorage.write(62, Board_ver[2]);
    dueFlashStorage.write(63, Board_ver[3]);
    dueFlashStorage.write(64, Board_ver[4]);
    dueFlashStorage.write(65, Board_ver[5]);
    //--------------------------------------S/N
    dueFlashStorage.write(70, SerialNumber[0]);
    dueFlashStorage.write(71, SerialNumber[1]);
    dueFlashStorage.write(72, SerialNumber[2]);
    dueFlashStorage.write(73, SerialNumber[3]);
    dueFlashStorage.write(74, SerialNumber[4]);
    dueFlashStorage.write(75, SerialNumber[5]);



    //dueFlashStorage.write(0,0);//////////////// 0이면 data 저장되어 있다는 뜻
  }
  Serial.println("Data_read");
  g_Detector = dueFlashStorage.read(0);
  HV_DAC.value[0] = dueFlashStorage.read(1);
  HV_DAC.value[1] = dueFlashStorage.read(2);
  g_GC_init.value[0] = dueFlashStorage.read(3);
  g_GC_init.value[1] = dueFlashStorage.read(4);
  g_K40_init.value[0] = dueFlashStorage.read(5);
  g_K40_init.value[1] = dueFlashStorage.read(6);
  g_32keV_init.value[0] = dueFlashStorage.read(7);
  g_32keV_init.value[1] = dueFlashStorage.read(8);
  g_662keV_init.value[0] = dueFlashStorage.read(9);
  g_662keV_init.value[1] = dueFlashStorage.read(10);
  HV_init_ADC.value[0] = dueFlashStorage.read(11);
  HV_init_ADC.value[1] = dueFlashStorage.read(12);
  CONTROL_MOD = dueFlashStorage.read(13);

  //--------------------------------------MCU ver
  MCU_ver[0] = dueFlashStorage.read(40);
  MCU_ver[1] = dueFlashStorage.read(41);
  MCU_ver[2] = dueFlashStorage.read(42);
  //--------------------------------------FPGA ver
  FPGA_ver[0] = dueFlashStorage.read(50);
  FPGA_ver[1] = dueFlashStorage.read(51);
  FPGA_ver[2] = dueFlashStorage.read(52);
  FPGA_ver[3] = dueFlashStorage.read(53);
  //--------------------------------------Board ver
  Board_ver[0] = dueFlashStorage.read(60);
  Board_ver[1] = dueFlashStorage.read(61);
  Board_ver[2] = dueFlashStorage.read(62);
  Board_ver[3] = dueFlashStorage.read(63);
  Board_ver[4] = dueFlashStorage.read(64);
  Board_ver[5] = dueFlashStorage.read(65);
  //--------------------------------------S/N
  SerialNumber[0] = dueFlashStorage.read(70);
  SerialNumber[1] = dueFlashStorage.read(71);
  SerialNumber[2] = dueFlashStorage.read(72);
  SerialNumber[3] = dueFlashStorage.read(73);
  SerialNumber[4] = dueFlashStorage.read(74);
  SerialNumber[5] = dueFlashStorage.read(75);

  //if(spi==1) {
  HV_high = HV_DAC.DAC_Value >> 4;
  HV_low = HV_DAC.DAC_Value << 4;

  REG_PIOB_CODR = 0x80;/////////HV 설정

  // 고압 조절하는 DAC종류에 따라서 함수 호출을 다르게 함.
  if (HV_CON_DAC)
  {
    SPI.transfer(48);
    SPI.transfer(HV_high);
    SPI.transfer(HV_low);
  } else
  {
    Serial.println("HV is turned on. It takes 10 seconds.");
    delay (2000);

    DAC8830_write_HV(HV_Start.value[1], HV_Start.value[0]);


    for (int i = 0; i < 3; i++)
    {
      delay (2000);
      HV_Start.DAC_Value += 5000;
      DAC8830_write_HV(HV_Start.value[1], HV_Start.value[0]);
      Serial.println("HV_DAC value is increasing by +5000.");
    }

    delay (2000);
    DAC8830_write_HV(HV_DAC.value[1], HV_DAC.value[0]); // 저장되어 있었 HV DAC 값 전송
    //DAC8830_write_HV(HV_DAC.value[1], HV_DAC.value[0]); // 저장되어 있었 HV DAC 값 전송


  }
  REG_PIOB_SODR = 0x80;

  REG_PIOB_CODR = 0x40;//DAC8830 gain 설정
  SPI.transfer(g_GC_init.value[1]);
  SPI.transfer(g_GC_init.value[0]);
  REG_PIOB_SODR = 0x40;

  //spi=0;
  //}
  /*
    attachInterrupt(27,sw1,RISING);
    attachInterrupt(28,sw2,RISING);
    attachInterrupt(14,sw3,RISING);
    attachInterrupt(15,sw4,RISING);
    attachInterrupt(29,sw5,RISING);
  */
  attachInterrupt(25, sw0, CHANGE);
  attachInterrupt(27, sw1, CHANGE);
  attachInterrupt(28, sw2, CHANGE);
  attachInterrupt(14, sw3, CHANGE);
  attachInterrupt(15, sw4, CHANGE);
  attachInterrupt(29, sw5, CHANGE);
  startTimer(TC1, 0, TC3_IRQn, FREQ_5Hz);

}
