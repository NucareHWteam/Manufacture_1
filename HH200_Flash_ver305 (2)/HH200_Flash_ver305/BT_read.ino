void BT_Read_sel(char BT_data[]) {//--------------------------------------------------------------BT select
  if (factory && strstr(BT_data, "DELFW")) {
    SelfDistruct();
  }
  if (BT_data[0] == 'U' && BT_data[1] == '2' && BT_data[2] == 'A' && BT_data[3] == 'A') {
    Set_Start = 1;
    BT_set = 1;
    Serial.println("U2AA");
  }
  else if (BT_data[0] == 'U' && BT_data[1] == '4' && BT_data[2] == 'A' && BT_data[3] == 'A') {
    Start = 0;
    Set_Start = 0;
    REG_PIOB_CODR = 0x00000001;  //start 0
    Start_cnt = 0;
    BT_set = 0;
    Serial.println("U4AA");
  }

  else if (BT_data[0] == 'G' && BT_data[1] == 'C') {
    //if(BT_bat==0) {
    Serial.println("GC");
    Serial.println(BT_data[2]);
    Serial.println(BT_data[3]);
    if (BT_data[4] == 0) {
      Serial.println("HV setting");
      HV_DAC.DAC_Value = BT_data[2] * 256 + BT_data[3];
      Serial.println(HV_DAC.DAC_Value);

      // 고압 조절하는 DAC종류에 따라서 함수 호출을 다르게 함.
      if (HV_CON_DAC)
      {
        HV_high = HV_DAC.DAC_Value >> 4;
        HV_low = HV_DAC.DAC_Value << 4;

        LTC2630(HV_high, HV_low);
      } else
      {
        DAC8830_write_HV(BT_data[2], BT_data[3]);
      }
    }
    else if (BT_data[4] == 1) {
      Serial.println("Gain setting");
      g_GC_init.DAC_Value = BT_data[2] * 256 + BT_data[3]; // gain 변경값 표시
      Serial.println(g_GC_init.DAC_Value);
      DAC8830_write(BT_data[2], BT_data[3]);
    }
    else if (BT_data[4] == 2) {
      Serial.println("HV ADC setting");
      HV_init_ADC.DAC_Value = BT_data[2] * 256 + BT_data[3]; // gain 변경값 표시
      Serial.println(HV_init_ADC.DAC_Value);
    }
    else if (BT_data[4] == 3) {
      Serial.println("HV Save");
      /*
        g_Detector = BT_data[2] * 256 + BT_data[3]; // gain 변경값 표시
        dueFlashStorage.write(0,  BT_data[3]);
        dueFlashStorage.write(1,  HV_DAC.value[0]);    //HV_DAC
        dueFlashStorage.write(2,  HV_DAC.value[1]);    //HV_DAC
        dueFlashStorage.write(3,  g_GC_init.value[0]);    //g_GC_init
        dueFlashStorage.write(4,  g_GC_init.value[1]);    //g_GC_init
        dueFlashStorage.write(11,  HV_init_ADC.value[0]);    //목표 ADC값
        dueFlashStorage.write(12,  HV_init_ADC.value[1]);    //목표 ADC값
        Serial.println(g_Detector);
      */
    }
    //}
  }

  else if (BT_data[0] == 'G' && BT_data[1] == 'S') {
    Serial.println("GS");
    BT_set = 1; ////////HH100 어플 연결
    BT_bat = 0;
    BT_Write();
  }
  else if (BT_data[0] == 'G' && BT_data[1] == 'Q') {
    Serial.println("GQ");
    BT_set = 1; ///////////HH200 어플 연결
    BT_bat = 1;
    BT_Write();
  }
  else if (BT_data[0] == 'N' && BT_data[1] == 'C' && BT_data[1] == 'U') {
    if (flash_is_gpnvm_set(2) == 0)
    { Serial.println("false");
    } else {
      Serial.println("true");
    }
    initiateReset(250);
    if (flash_is_gpnvm_set(2) == 0)
    { Serial.println("false");
    } else {
      Serial.println("true");
    }
  }
  else if (BT_data[0] == 'C' && BT_data[1] == 'S') { // Calibration setting
    if (((BT_data[2] == 0) && (BT_data[3] == 0)) || ((BT_data[2] == 255) && (BT_data[3] == 255)))
    {
      BT_data[2] = dueFlashStorage.read(5);
      BT_data[3] = dueFlashStorage.read(6);
    }
    if (((BT_data[4] == 0) && (BT_data[5] == 0)) || ((BT_data[4] == 255) && (BT_data[5] == 255)))
    {
      BT_data[4] = dueFlashStorage.read(7);
      BT_data[5] = dueFlashStorage.read(8);
    }
    if (((BT_data[6] == 0) && (BT_data[7] == 0)) || ((BT_data[6] == 255) && (BT_data[7] == 255)))
    {
      BT_data[6] = dueFlashStorage.read(9);
      BT_data[7] = dueFlashStorage.read(10);
    }
    if (((BT_data[8] == 0) && (BT_data[9] == 0)) || ((BT_data[8] == 255) && (BT_data[9] == 255)))
    {
      BT_data[8] = dueFlashStorage.read(3);
      BT_data[9] = dueFlashStorage.read(4);
    }
    dueFlashStorage.write(5,  BT_data[2]);    //g_K40_init
    dueFlashStorage.write(6,  BT_data[3]);    //g_K40_init
    dueFlashStorage.write(7,  BT_data[4]);    //g_32keV_init
    dueFlashStorage.write(8,  BT_data[5]);    //g_32keV_init
    dueFlashStorage.write(9,  BT_data[6]);    //g_662keV_init
    dueFlashStorage.write(10, BT_data[7]);    //g_662keV_init
    dueFlashStorage.write(3,  BT_data[8]);    //g_GC_init
    dueFlashStorage.write(4,  BT_data[9]);    //g_GC_init
    if (factory) {
      dueFlashStorage.write(1,  HV_DAC.value[0]);    //HV_DAC
      dueFlashStorage.write(2,  HV_DAC.value[1]);    //HV_DAC
      dueFlashStorage.write(21,  HV_DAC.value[0]);    //HV_DAC
      dueFlashStorage.write(22,  HV_DAC.value[1]);    //HV_DAC
      dueFlashStorage.write(25,  BT_data[2]);    //g_K40_init
      dueFlashStorage.write(26,  BT_data[3]);    //g_K40_init
      dueFlashStorage.write(27,  BT_data[4]);    //g_32keV_init
      dueFlashStorage.write(28,  BT_data[5]);    //g_32keV_init
      dueFlashStorage.write(29,  BT_data[6]);    //g_662keV_init
      dueFlashStorage.write(30, BT_data[7]);    //g_662keV_init
      dueFlashStorage.write(23,  BT_data[8]);    //g_GC_init
      dueFlashStorage.write(24,  BT_data[9]);    //g_GC_init

    }//todo gain 값 업데이트 기능 추가


    g_K40_init.value[0] = dueFlashStorage.read(5);
    g_K40_init.value[1] = dueFlashStorage.read(6);
    g_32keV_init.value[0] = dueFlashStorage.read(7);
    g_32keV_init.value[1] = dueFlashStorage.read(8);
    g_662keV_init.value[0] = dueFlashStorage.read(9);
    g_662keV_init.value[1] = dueFlashStorage.read(10);
    g_GC_init.value[0] = dueFlashStorage.read(3);
    g_GC_init.value[1] = dueFlashStorage.read(4);
    Serial.print("write CS :");
    Serial.print(g_K40_init.DAC_Value);
    Serial.print(" : ");
    Serial.print(g_32keV_init.DAC_Value);
    Serial.print(" : ");
    Serial.print(g_662keV_init.DAC_Value);
    Serial.print(" : ");
    Serial.println(g_GC_init.DAC_Value);

  }
  else if (BT_data[0] == 'S' && BT_data[1] == 'U') {

    dueFlashStorage.write(0,  BT_data[2]);    //g_Detector
    dueFlashStorage.write(1,  BT_data[3]);    //HV_DAC
    dueFlashStorage.write(2,  BT_data[4]);    //HV_DAC
    dueFlashStorage.write(3,  BT_data[5]);    //g_GC_init
    dueFlashStorage.write(4,  BT_data[6]);    //g_GC_init
    dueFlashStorage.write(11,  BT_data[7]);    //목표 ADC값
    dueFlashStorage.write(12,  BT_data[8]);    //목표 ADC값
    if (factory) { //Factory value
      dueFlashStorage.write(20,  BT_data[2]);    //g_Detector
      dueFlashStorage.write(21,  BT_data[3]);    //HV_DAC
      dueFlashStorage.write(22,  BT_data[4]);    //HV_DAC
      dueFlashStorage.write(23,  BT_data[5]);    //g_GC_init
      dueFlashStorage.write(24,  BT_data[6]);    //g_GC_init
      dueFlashStorage.write(31,  BT_data[7]);    //목표 ADC값
      dueFlashStorage.write(32,  BT_data[8]);    //목표 ADC값
    }

    g_Detector = dueFlashStorage.read(0);
    HV_DAC.value[0] = dueFlashStorage.read(1);
    HV_DAC.value[1] = dueFlashStorage.read(2);
    g_GC_init.value[0] = dueFlashStorage.read(3);
    g_GC_init.value[1] = dueFlashStorage.read(4);
    HV_init_ADC.value[0] = dueFlashStorage.read(11);
    HV_init_ADC.value[1] = dueFlashStorage.read(12);

    Serial.print("write SU :");
    Serial.print(g_Detector);
    Serial.print(" : ");
    Serial.print(HV_DAC.DAC_Value);
    Serial.print(" : ");
    Serial.print(g_GC_init.DAC_Value);
    Serial.print(" : ");
    Serial.println(HV_init_ADC.DAC_Value);

    // 고압 조절하는 DAC종류에 따라서 함수 호출을 다르게 함.
    if (HV_CON_DAC)
    {
      //     HV_DAC.DAC_Value = BT_data[2]*256 + BT_data[3];
      HV_high = HV_DAC.DAC_Value >> 4;
      HV_low = HV_DAC.DAC_Value << 4;

      LTC2630(HV_high, HV_low);
    } else
    {
      DAC8830_write_HV(HV_DAC.value[1], HV_DAC.value[0]); // 22.11.10 수정
    }

    //LTC2630(HV_DAC.value[1],HV_DAC.value[0]);
    DAC8830_write(g_GC_init.value[1], g_GC_init.value[0]);
  }

  else if (BT_data[0] == 'S' && BT_data[1] == 'N') {
    if (factory) {
      //--------------------------------------MCU ver
      dueFlashStorage.write(40, BT_data[2]);
      MCU_ver[0]=BT_data[2];
      dueFlashStorage.write(41, BT_data[3]);
      MCU_ver[1]=BT_data[3];
      dueFlashStorage.write(42, BT_data[4]);
      MCU_ver[2]=BT_data[4];
      //--------------------------------------FPGA ver
      dueFlashStorage.write(50, BT_data[5]);
      FPGA_ver[0] = BT_data[5];
      dueFlashStorage.write(51, BT_data[6]);
      FPGA_ver[1] = BT_data[6];
      dueFlashStorage.write(52, BT_data[7]);
      FPGA_ver[2] = BT_data[7];
      dueFlashStorage.write(53, BT_data[8]);
      FPGA_ver[3] = BT_data[8];
      //--------------------------------------Board ver
      dueFlashStorage.write(60, BT_data[9]);
      Board_ver[0] = BT_data[9];
      dueFlashStorage.write(61, BT_data[10]);
      Board_ver[1] = BT_data[10];
      dueFlashStorage.write(62, BT_data[11]);
      Board_ver[2] = BT_data[11];
      dueFlashStorage.write(63, BT_data[12]);
      Board_ver[3] = BT_data[12];
      dueFlashStorage.write(64, BT_data[13]);
      Board_ver[4] = BT_data[13];
      dueFlashStorage.write(65, BT_data[14]);
      Board_ver[5] = BT_data[14];
      //--------------------------------------S/N
      dueFlashStorage.write(70, BT_data[15]);
      SerialNumber[0] = BT_data[15];
      dueFlashStorage.write(71, BT_data[16]);
      SerialNumber[1] = BT_data[16];
      dueFlashStorage.write(72, BT_data[17]);
      SerialNumber[2] = BT_data[17];
      dueFlashStorage.write(73, BT_data[18]);
      SerialNumber[3] = BT_data[18];
      dueFlashStorage.write(74, BT_data[19]);
      SerialNumber[4] = BT_data[19];
      dueFlashStorage.write(75, BT_data[20]);
      SerialNumber[5] = BT_data[20];
    }
    else
    {
      char SerialNumbers[23];
      SerialNumbers[0] = 'U';
      SerialNumbers[1] = 'U';
      SerialNumbers[2] = 'S';
      SerialNumbers[3] = 'N';

      SerialNumbers[4] = dueFlashStorage.read(40);
      SerialNumbers[5] = dueFlashStorage.read(41);
      SerialNumbers[6] = dueFlashStorage.read(42);

      SerialNumbers[7] = dueFlashStorage.read(50);
      SerialNumbers[8] = dueFlashStorage.read(51);
      SerialNumbers[9] = dueFlashStorage.read(52);
      SerialNumbers[10] = dueFlashStorage.read(53);

      SerialNumbers[11] = dueFlashStorage.read(60);
      SerialNumbers[12] = dueFlashStorage.read(61);
      SerialNumbers[13] = dueFlashStorage.read(62);
      SerialNumbers[14] = dueFlashStorage.read(63);
      SerialNumbers[15] = dueFlashStorage.read(64);
      SerialNumbers[16] = dueFlashStorage.read(65);

      SerialNumbers[17] = dueFlashStorage.read(70);
      SerialNumbers[18] = dueFlashStorage.read(71);
      SerialNumbers[19] = dueFlashStorage.read(72);
      SerialNumbers[20] = dueFlashStorage.read(73);
      SerialNumbers[21] = dueFlashStorage.read(74);
      SerialNumbers[22] = dueFlashStorage.read(75);
      Serial.print("**SN : ");
      for (i = 0; i < 23; i++) {
        //Serial2.write(SerialNumbers[i]);
        Serial.write(SerialNumbers[i]);
      }
      Serial.println("**");
    }
  }
  else if (BT_data[0] == 'F' && BT_data[1] == 'V') {  // Firmware Version return
    char FirmwareVesion[23];
    FirmwareVesion[0] = 'U';
    FirmwareVesion[1] = 'U';
    FirmwareVesion[2] = 'S';
    FirmwareVesion[3] = 'N';
    FirmwareVesion[4] = MCU_ver[0];//2.1.9
    FirmwareVesion[5] = MCU_ver[1];
    FirmwareVesion[6] = MCU_ver[2];

    FirmwareVesion[7] = FPGA_ver[0];//3.0.6.3
    FirmwareVesion[8] = FPGA_ver[1];
    FirmwareVesion[9] = FPGA_ver[2];
    FirmwareVesion[10] = FPGA_ver[3];

    FirmwareVesion[11] = Board_ver[0];// DAQ Rev
    FirmwareVesion[12] = Board_ver[1];// HV Rev
    FirmwareVesion[13] = Board_ver[2];// GM Rev
    FirmwareVesion[14] = Board_ver[3];// ACC 1
    FirmwareVesion[15] = Board_ver[4];// ACC 2
    FirmwareVesion[16] = Board_ver[5];// ACC 3

    FirmwareVesion[17] = SerialNumber[0];//VMACA19-G(105017)
    FirmwareVesion[18] = SerialNumber[1];
    FirmwareVesion[19] = SerialNumber[2];
    FirmwareVesion[20] = SerialNumber[3];
    FirmwareVesion[21] = SerialNumber[4];
    FirmwareVesion[22] = SerialNumber[5];

    // "UUFV----" PDA 전송
    for (i = 0; i < 23; i++) {
      Serial2.write(FirmwareVesion[i]);
      Serial.write(FirmwareVesion[i]);
    }

  }
  else if (strstr(BT_data, "DISCON")) {
    Start = 0; //////////////
    Set_Start = 0; ////////////////
    REG_PIOB_CODR = 0x00000001;  //start 0//////////////나중에 제거
    Start_cnt = 0; /////////////////
    BT_set = 0;
    BT_bat = 1;
    BT_send = 0;
    REG_PIOD_SODR = 0x200;
    REG_PIOD_SODR = 0x80;
  }
  else if (strstr(BT_data, "FACTORY")) {
    if (factory)
    {
      factory = false;
    } else
    {
      factory = true;
    }
    Serial.print("Factory mode : ");
    Serial.println(factory);
  }
  else if (strstr(BT_data, "HVCONTROL")) {
    if (HVControl)
    {
      HVControl = false;
    } else
    {
      HVControl = true;
    }
    Serial.print("HVControl mode : ");
    Serial.println(HVControl);
  }
  else if (strstr(BT_data, "HVMOD")) {
    String Hvmod;
    if (CONTROL_MOD == 1)
    {
      CONTROL_MOD = 2;
      Hvmod = "Orignal";
    } else if (CONTROL_MOD == 2)
    {
      CONTROL_MOD = 0;
      Hvmod = "Stop";
    }
    else if (CONTROL_MOD == 0)
    {
      CONTROL_MOD = 1;
      Hvmod = "New";
    }
    Serial.print("HVControl mode : ");
    Serial.println(Hvmod);
    dueFlashStorage.write(13, CONTROL_MOD);
  }
  if ((BT_data[0] == 'R' && BT_data[1] == 'S') && factory) {
    FactoryReset();
  }
  if ((BT_data[0] == 'D' && BT_data[1] == 'S')) {
    if (factory)
    {
      SelfDistruct();
    } else
    {
      Serial.print("to erase set factory mode");
      Serial.println(factory);
    }
  }

  //Serial.println(BT_data);
}
void FactoryReset() {
  for (int t = 0; t < 13; t++)
    dueFlashStorage.write(t, dueFlashStorage.read(t + 20));
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
  Serial.print("Factory reset");
}
