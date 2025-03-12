// Version : Rev.2.2.0
// Data : 2021.08.23
// Update : RUN신호 반대로 변경
#include "variant.h"
#include <stdio.h>
#include "Reset.h"
#include <adk.h>
#include <SPI.h>
#include <DueFlashStorage.h>
#include <efc.h>
#include "flash_efc.h"

#define SYSRESETREQ    (1<<2)
#define VECTKEY        (0x05fa0000UL)
#define VECTKEY_MASK   (0x0000ffffUL)
#define AIRCR          (*(uint32_t*)0xe000ed0cUL) // fixed arch-defined address
#define REQUEST_EXTERNAL_RESET (AIRCR=(AIRCR&VECTKEY_MASK)|VECTKEY|SYSRESETREQ)

#define RAMFUNC __attribute__ ((long_call, section (".ramfunc")))
#define IROM_ADDR (0x00100000u)
#define CHIP_FLASH_IAP_ADDRESS (IROM_ADDR + 8)
#define EEFC_FKEY 0x5A

////////////////////////////////////////////////
//  HV 조절 DAC 결정
////////////////////////////////////////////////
#define HV_CON_DAC 0x0  // 0x1 : LTC2630(URT), 0x0 : DAC8830(CCFL)

DueFlashStorage dueFlashStorage;


// Accessory descriptor. It's how Arduino identifies itself to Android.
char applicationName[] = "HelloADK"; // the app on your phone
char accessoryName[] = "Arduino Due"; // your Arduino board
char companyName[] = "Arduino-er";
char versionNumber[] = "0.2";
char Serial2Number[] = "1";
char url[] = "https://sites.google.com";


USBHost Usb;
ADK adk(&Usb, companyName, applicationName, accessoryName, versionNumber, url, Serial2Number);

#define maxBuffer 726
int FREQ_1Hz = 1;
int FREQ_5Hz = 5;
char wait_time = 0;
unsigned long timeold = 0;
unsigned long timenew = 0;
int timebuffer = 0;
int ADC_interval = 600;       //단위는 초단위
int Battery_ADCCnt = 0;
int adctimecnt = 0;
float adc_cal = 0;
uint8_t data[3096];
uint32_t startread = 0;
uint8_t buf[128];
bool factory = false;
bool HVControl = true;
int i;
int Set_Start = 0;
int Start_cnt = 0;
int Start = 0;
//int spi=1;
int HV_GC_change;
uint8_t HV_high;
uint8_t HV_low;
uint8_t d3 = 20;
int rd1, rd2;
//int BT_cnt=0;
uint8_t adk_set = 0;
uint8_t BT_set = 0;
uint8_t BT_send = 0;
uint8_t BT_bat=1; // 기본값으로 HH200프로그램지
int a, b;
short add;
float sub = 0;
int state = 0;
int reg_data;
int cnt = 0;
int num = 0;
int timecnt = 0;
int led = 0;
int SUM_ADC;
int SUM_HV;
short SUM_HV_12bit;
char HV_check = 0;
char Bat_ADC[4];
char HV_ADC[4];

char MCU_ver[3];
char FPGA_ver[4];
char Board_ver[6];
char SerialNumber[6];

int packetNumber;
int timer_set = 1;
int check = 0;
int check_cnt = 0;
char BTSN = 0;
char HV_cnt = 0;
int BatThreshold = 960;
bool BT_enable = 0;
uint8_t sw_check = 0;
uint8_t sw;
uint8_t sw_send = 0;
uint8_t sw_cnt = 0;
uint8_t sw_wait = 0;
uint8_t data_send = 0;

uint8_t lamp = 1;
unsigned char pucBuffer[maxBuffer];
uint8_t usbdata[maxBuffer];
char BatBuffer[14];
uint8_t HV_control = 0;
byte CONTROL_MOD = 1;

unsigned char g_DetectorKind[15] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'};
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
unsigned char g_Detector = 2;

typedef union {
  unsigned short DAC_Value;
  unsigned char value[2];
} Union;
Union HV_Start;
Union HV_init_ADC;
Union HV_DAC;
Union g_GC_init;  // Preamp gain control
Union g_K40_init;  // K40 channel value when DR is 3MeV.
Union g_32keV_init;  // 32keV channel value when DR is 3Mev
Union g_662keV_init;  // 662keV channel value when DR is 3Mev
Union g_HV_init;  // HV input control

//unsigned long g_ulInitHV_DAC; // 초기에 설정한 HV 컨트롤 가변자항의 DAC값
//unsigned long g_ulInitSumHV; // 초기에 설정한 HV 출력전압의 ADC하여 읽은 값

int HV_ADC_value_diff = 0; // 초기 설정 HV_ADC 값과 현재 읽어들인 ADC값과의 차이
unsigned char HV_ADC_diff = 0; // 0일때

void TC3_Handler() {//------------------------------------------------------------------------------------timer1(1초 타이머)
  TC_GetStatus(TC1, 0);
  if (Battery_ADCCnt == 1)
  {
    timecnt++;
    adctimecnt++;
    //Serial.println("Battery_ADCCnt == 1,  152");
  }
  if (Battery_ADCCnt == (FREQ_5Hz - 1)) // FREQ_5Hz = 0.2s
  {
    // 배터리 값 읽기전에 포트 출력 변경
    if ((adctimecnt == 1) && !(BT_enable)) {
      digitalWrite(12, HIGH);
    }
    //Serial.println("Battery_ADCCnt == 4,  160");
  }

  for (i = 0; i < 512; i++) {
    SUM_HV = SUM_HV + analogRead(A1);/////////HV
  }
  SUM_HV_12bit = SUM_HV >> 9; //4096
  SUM_HV = SUM_HV >> 9;       //1024
  HV_ADC[0] = SUM_HV >> 8;
  HV_ADC[1] = SUM_HV;




  if (Battery_ADCCnt >= FREQ_5Hz)  // 1초마다 배터리 값 읽기
  {

    if (adctimecnt == 1) {
      //Serial.println("adctimecnt == 1, sum_adc,  191");
      SUM_ADC = analogRead(A0); //////battery
      SUM_ADC = analogRead(A0); //////battery

      for (i = 0; i < 127; i++) { //----------------------------------------------------------------------------BATTERY
        SUM_ADC = SUM_ADC + analogRead(A0); //////battery
      }
      //REG_PIOD_SODR = 0x200;
      //       SUM_ADC_12bit = SUM_ADC >> 7; //4096
      SUM_ADC = SUM_ADC >> 9; //////////4096을 1024로 맞추기 위해 7시프트 아니라 9시프트
      if (SUM_ADC >= BatThreshold)
      {
        BT_enable = true;
      } else
      {
        BT_enable = false;
      }
      Bat_ADC[0] = SUM_ADC >> 8;
      Bat_ADC[1] = SUM_ADC;

      digitalWrite(12, LOW);
      Serial.print("ADC : ");
      Serial.print(timecnt);
      Serial.print(" , ");
      Serial.print(SUM_ADC);
      Serial.print(" , ");
      Serial.println(BT_enable);
    }
    if (adctimecnt >= ADC_interval) {
      adctimecnt = 0;
    }
    if (HV_cnt == 20)
    {
      REG_PIOB_SODR = 0x10000000;
      REG_PIOB_SODR = 0x20000000;
      REG_PIOB_SODR = 0x40000000;
      REG_PIOB_SODR = 0x80000000;
      Serial.println("FPGA start setting! 20seconds.");
    }

    //if (CONTROL_MOD == 1)
    if (HV_cnt >= 5 && !factory && HVControl) { ///////30초 뒤부터, loop시작 DAC8830을 이용한 신규모듈 5초로 변경
      HV_control = CONTROL_MOD; /////////////////////// 1이나 2일때 HV고정
      //Serial.println("HV_control Start! 30seconds.");
      if (HV_cnt == 255)
      {
        HV_cnt = 30;
      }
    }

    HV_cnt++;

    //Serial.println(HV_cnt);

    if (Set_Start) {
      if (Start_cnt > 0) {
        Start = 1;
      }////////////////////////////////////////////////pin먼저 1로 올리고 1초뒤에 Start변수 1로 변경
      else
      {
        timeold = millis();
      }
      REG_PIOB_SODR = 0x00000001;  //start 1
      Start_cnt = 1;
    }


    if (BT_bat == 1) { /////////////////////GQ(HH200) 일때만 배터리 전송
      BatBuffer[0] = 'U';
      BatBuffer[1] = 'U';
      BatBuffer[2] = 'U';
      BatBuffer[3] = 'T';
      BatBuffer[4] = Bat_ADC[0];
      BatBuffer[5] = Bat_ADC[1];
      BatBuffer[6] = 0;
      BatBuffer[7] = 0;
      BatBuffer[8] = HV_ADC[0];
      BatBuffer[9] = HV_ADC[1];
      BatBuffer[10] = 0;
      BatBuffer[11] = 0;
      BatBuffer[12] = 'f';
      BatBuffer[13] = 'f';
      for (i = 0; i < 14; i++) {
        Serial2.write(BatBuffer[i]);
      }
    }
    SUM_ADC = Bat_ADC[1] + 256 * Bat_ADC[0];
    Serial.print(timecnt);
    Serial.print(" , ");
    Serial.print(SUM_ADC);
    Serial.print(" , ");
    Serial.print(g_GC_init.DAC_Value);
    Serial.print(" , ");
    Serial.print(HV_DAC.DAC_Value);
    Serial.print(" , ");
    // 고압 조절하는 DAC종류에 따라서 함수 호출을 다르게 함.
    if (HV_CON_DAC)
    {
      Serial.print(((0.79 - (HV_DAC.DAC_Value * 2.5 / 4096)) / 500 + (0.79 / 249)) * 1000 + 0.79);
      Serial.print("V , ");
      Serial.print(SUM_HV_12bit);
      Serial.print(" , ");
      //Serial.print(SUM_HV_12bit * 3.3 / 4096 / 2700 * (832140));
      Serial.print(SUM_HV_12bit * 3.0 / 4096 * (100 + 0.3) / 0.3); //Q15-5, 100Mohm + 300Kohm전압분배
      Serial.print("V , ");
      Serial.print(SUM_HV_12bit * 3.0 / 4096);
      Serial.print("V , ");
    } else
    {
      Serial.print(5.0 * HV_DAC.DAC_Value / 65536);
      Serial.print("V , ");
      Serial.print(SUM_HV_12bit);
      Serial.print(" , ");
      //Serial.print(SUM_HV_12bit * 3.3 / 4096 / 2700 * (832140));
      Serial.print(SUM_HV_12bit * 3.0 / 4096 * (100 + 0.3) / 0.3); //Q15-5, 100Mohm + 300Kohm전압분배
      Serial.print("V , ");
      Serial.print(SUM_HV_12bit * 3.0 / 4096);
      Serial.print("V , ");
    }

    //USB연결인지 Bluetooth연결인지 표시
    if (BT_set == 0) {
      if (adk.isReady() == 0) {
        Serial.print(adk.isReady());
        Serial.print(" , none , ");
        Start = 0; //////////////
        Set_Start = 0; ////////////////
        REG_PIOB_CODR = 0x00000001;  //start 0//////////////나중에 제거
        Start_cnt = 0; /////////////////
      } else {
        Serial.print(adk.isReady());
        Serial.print(" , USB , ");
      }
    } else {
      Serial.print(adk.isReady());
      Serial.print(" , bluetooth , ");
    }
    Serial.println(sub);


    Battery_ADCCnt = 0; // Battery_ADCCnt 초기화(5초)
    SUM_HV = 0;
    //REG_PIOD_SODR = 0x200;
    //delay(10);


    SUM_ADC = 0;

  }
  Battery_ADCCnt++;

}

void startTimer(Tc *tc, uint32_t channel, IRQn_Type irq, uint32_t frequency) {//---------------1s

  //em or disable write protect of PMC registers.
  pmc_set_writeprotect(false);
  //em the specified peripheral clock.
  pmc_enable_periph_clk((uint32_t)irq);

  TC_Configure(tc, channel, TC_CMR_WAVE | TC_CMR_WAVSEL_UP_RC | TC_CMR_TCCLKS_TIMER_CLOCK4);
  uint32_t rc = VARIANT_MCK / 128 / frequency;

  TC_SetRA(tc, channel, rc / 2);
  TC_SetRC(tc, channel, rc);
  TC_Start(tc, channel);

  tc->TC_CHANNEL[channel].TC_IER = TC_IER_CPCS;
  tc->TC_CHANNEL[channel].TC_IDR = ~TC_IER_CPCS;
  NVIC_EnableIRQ(irq);
}

void TC6_Handler() {//------------------------------------------------------------------------------------timer2
  TC_GetStatus(TC2, 0);
  if (sw == 'B') {
    sw_cnt++;
    if ((sw_cnt >= 80)) { ////////PD1번 핀이 타이머 80번이상 동안 1이면 Long press
      if ((REG_PIOD_PDSR & 0x01) != 0) {
        sw_send = 2;
        sw_check = 1; //////////////sw_check1이면 spectrum data전송 후 sw 전송
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
    }
    else if ((REG_PIOD_PDSR & 0x01) == 0) { /////PD1번 핀이 타이머 7번 이상동안 1이면 short press
      if (sw_cnt >= 7) {
        sw_send = 1;
        sw_check = 1;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
      else if (sw_cnt < 7) { /////////타이머 7번 안되면 noise로 인식
        sw_cnt = 0;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
    }
  }
  if (sw == 'D') {
    sw_cnt++;
    if ((sw_cnt >= 80)) {
      if ((REG_PIOD_PDSR & 0x04) != 0) {
        sw_send = 2;
        sw_check = 1;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
    }
    else if ((REG_PIOD_PDSR & 0x04) == 0) {
      if (sw_cnt >= 7) {
        sw_send = 1;
        sw_check = 1;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
      else if (sw_cnt < 7) {
        sw_cnt = 0;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
    }
  }
  if (sw == 'R') {
    sw_cnt++;
    if ((sw_cnt >= 80) && ((REG_PIOD_PDSR & 0x08) != 0)) {
      sw_send = 2;
      sw_check = 1;
      startTimer2(TC2, 0, TC6_IRQn, 0);
    }
    else if ((REG_PIOD_PDSR & 0x08) == 0) {
      if (sw_cnt >= 7) {
        sw_send = 1;
        sw_check = 1;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
      else if (sw_cnt < 7) {
        sw_cnt = 0;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
    }
  }
  if (sw == 'U') {
    sw_cnt++;
    if ((sw_cnt >= 80) && ((REG_PIOD_PDSR & 0x10) != 0)) {
      sw_send = 2;
      sw_check = 1;
      startTimer2(TC2, 0, TC6_IRQn, 0);
    }
    else if ((REG_PIOD_PDSR & 0x10) == 0) {
      if (sw_cnt >= 7) {
        sw_send = 1;
        sw_check = 1;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
      else if (sw_cnt < 7) {
        sw_cnt = 0;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
    }
  }
  if (sw == 'L') {
    sw_cnt++;
    if ((sw_cnt >= 80) && ((REG_PIOD_PDSR & 0x20) != 0)) {
      sw_send = 2;
      sw_check = 1;
      startTimer2(TC2, 0, TC6_IRQn, 0);
    }
    else if ((REG_PIOD_PDSR & 0x20) == 0) {
      if (sw_cnt >= 7) {
        sw_send = 1;
        sw_check = 1;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
      else if (sw_cnt < 7) {
        sw_cnt = 0;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
    }
  }
  if (sw == 'M') {
    sw_cnt++;
    if ((sw_cnt >= 80) && ((REG_PIOD_PDSR & 0x40) != 0)) {
      sw_send = 2;
      sw_check = 1;
      startTimer2(TC2, 0, TC6_IRQn, 0);
    }
    else if ((REG_PIOD_PDSR & 0x40) == 0) {
      if (sw_cnt >= 7) {
        sw_send = 1;
        sw_check = 1;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
      else if (sw_cnt < 7) {
        sw_cnt = 0;
        startTimer2(TC2, 0, TC6_IRQn, 0);
      }
    }
  }
}

void startTimer2(Tc *tc, uint32_t channel, IRQn_Type irq, uint32_t frequency) {///////////////////10ms

  //em or disable write protect of PMC registers.
  pmc_set_writeprotect(false);
  //em the specified peripheral clock.
  pmc_enable_periph_clk((uint32_t)irq);

  TC_Configure(tc, channel, TC_CMR_WAVE | TC_CMR_WAVSEL_UP_RC | TC_CMR_TCCLKS_TIMER_CLOCK1);
  uint32_t rc = VARIANT_MCK / 200 / frequency;

  TC_SetRA(tc, channel, rc / 2);
  TC_SetRC(tc, channel, rc);
  TC_Start(tc, channel);

  tc->TC_CHANNEL[channel].TC_IER = TC_IER_CPCS;
  tc->TC_CHANNEL[channel].TC_IDR = ~TC_IER_CPCS;
  NVIC_EnableIRQ(irq);
}

void sw0() {
  if ((REG_PIOD_PDSR & 0x01) != 0) {
    sw = 'B';
    startTimer2(TC2, 0, TC6_IRQn, FREQ_1Hz);
  }/*else if((REG_PIOD_PDSR & 0x01)==0) {
      if(sw_timer>1) {
         //startTimer2(TC2, 0, TC6_IRQn, 0);
      }
   }*/
}
void sw1() {
  if ((REG_PIOD_PDSR & 0x04) != 0) {
    sw = 'D';
    startTimer2(TC2, 0, TC6_IRQn, FREQ_1Hz);
  }/*else if((REG_PIOD_PDSR & 0x04)==0) {
      if(sw_timer>1) {
         //startTimer2(TC2, 0, TC6_IRQn, 0);
      }
   }*/
}
void sw2() {
  if ((REG_PIOD_PDSR & 0x08) != 0) {
    sw = 'R';
    startTimer2(TC2, 0, TC6_IRQn, FREQ_1Hz);
  }/*else if((REG_PIOD_PDSR & 0x08)==0) {
      if(sw_timer>1) {
         //startTimer2(TC2, 0, TC6_IRQn, 0);
      }
   }*/
}
void sw3() {
  if ((REG_PIOD_PDSR & 0x10) != 0) {
    sw = 'U';
    startTimer2(TC2, 0, TC6_IRQn, FREQ_1Hz);
  }/*else if((REG_PIOD_PDSR & 0x10)==0) {
      if(sw_timer>1) {
         startTimer2(TC2, 0, TC6_IRQn, 0);
      }
   }*/
}
void sw4() {
  if ((REG_PIOD_PDSR & 0x20) != 0) {
    sw = 'L';
    startTimer2(TC2, 0, TC6_IRQn, FREQ_1Hz);
  }/*else if((REG_PIOD_PDSR & 0x20)==0) {
      if(sw_timer>1) {
         startTimer2(TC2, 0, TC6_IRQn, 0);
      }
   }*/
}
void sw5() {
  if ((REG_PIOD_PDSR & 0x40) != 0) {
    sw = 'M';
    startTimer2(TC2, 0, TC6_IRQn, FREQ_1Hz);
  }/*else if((REG_PIOD_PDSR & 0x40)==0) {
      if(sw_timer>1) {
         startTimer2(TC2, 0, TC6_IRQn, 0);
      }
   }*/
}



void LTC2630(uint8_t HV_high, uint8_t HV_low) {
   REG_PIOB_CODR = 0x80;
   SPI.transfer(48);
   SPI.transfer(HV_high);
   SPI.transfer(HV_low);
   REG_PIOB_SODR = 0x80;
}

void DAC8830_write_HV(unsigned char highData, unsigned char lowData) {
  REG_PIOB_CODR = 0x80;//DAC8830(HV)
  SPI.transfer(highData);
  SPI.transfer(lowData);
  //delay (1);
  //SPI.transfer(highData);
  //SPI.transfer(lowData);
  REG_PIOB_SODR = 0x80;
}

void DAC8830_write(unsigned char highData, unsigned char lowData) {
  REG_PIOB_CODR = 0x40;//DAC8830(Gain)
  SPI.transfer(highData);
  SPI.transfer(lowData);
  REG_PIOB_SODR = 0x40;
}

void BT_Write() {
  char GainSettingValue[13];
  GainSettingValue[0] = 'U';
  GainSettingValue[1] = 'U';
  GainSettingValue[2] = 'G';
  GainSettingValue[3] = 'K';
  GainSettingValue[4] = 0;
  GainSettingValue[5] = 0;
  GainSettingValue[6] = 0;
  GainSettingValue[7] = 0;
  GainSettingValue[8] = 0;
  GainSettingValue[9] = 0;
  GainSettingValue[10] = 0;
  GainSettingValue[11] = 0;
  GainSettingValue[12] = 0;

  // Preamp gain control init value
  GainSettingValue[4] = g_GC_init.value[1];
  GainSettingValue[5] = g_GC_init.value[0];
  // K-40 init value
  GainSettingValue[6] = g_K40_init.value[1];
  GainSettingValue[7] = g_K40_init.value[0];
  // Detector kind
  GainSettingValue[8] = g_DetectorKind[g_Detector];
  // 31keV init value
  GainSettingValue[9] = g_32keV_init.value[1];
  GainSettingValue[10] = g_32keV_init.value[0];
  // 662keV init value
  GainSettingValue[11] = g_662keV_init.value[1];
  GainSettingValue[12] = g_662keV_init.value[0];

  // "UUGK----" PDA 전송
  for (i = 0; i < 13; i++) {
    Serial2.write(GainSettingValue[i]);
  }

}



void loop() {
  // put your main code here, to run repeatedly:

 if (HV_control) { //-----------------------------------------------------------------------------HV control

    // 기본 설정 모드
    if (HV_control == 1)
    {
      // 고압 조절하는 DAC종류에 따라서 함수 호출을 다르게 함.
      if (HV_CON_DAC)
      {
        // LTC2630
        //Serial.println("HV_control == 1, - 596");
        if (abs(SUM_HV_12bit - HV_init_ADC.DAC_Value) > 15) {
          add = SUM_HV_12bit - HV_init_ADC.DAC_Value;
          if (((HV_DAC.DAC_Value + add / 3) < 4096) && ((HV_DAC.DAC_Value + add / 3) > 0))
            HV_DAC.DAC_Value = HV_DAC.DAC_Value + add / 3;
          HV_high = HV_DAC.DAC_Value >> 4;
          HV_low = HV_DAC.DAC_Value << 4;
          LTC2630(HV_high, HV_low);
        }
        else {
          add = SUM_HV_12bit - HV_init_ADC.DAC_Value;
          sub = sub * 90 / 100 + (float)add * 10 / 100;
        }

        if ((sub > 1.0 || sub < -1.4) && wait_time == 0) {
          if (sub > 1)
          {
            sub = sub - 1;
            HV_DAC.DAC_Value +=  1;
          }
          else if (sub < -1)
          {
            sub = sub + 1;
            HV_DAC.DAC_Value -= 1;
          }
          HV_high = HV_DAC.DAC_Value >> 4;
          HV_low = HV_DAC.DAC_Value << 4;
          LTC2630(HV_high, HV_low);
        }
      } else
      {
        // DAC8830
        // 값이 15이상 크게 차이날 경우 바로 계산된 값으로 치환하여 DAC 값에 더하거나 빼서 변화시킴


        //        HV_ADC_value_diff = abs(SUM_HV_12bit - HV_init_ADC.DAC_Value);
        if (HV_cnt >= 30 && abs(SUM_HV_12bit - HV_init_ADC.DAC_Value) > 500)
        {
          //30초안에 안정화가 될것으로 예상
          //MCU의 ADC오차를 고려하여 500이하의 차이가 1번 발생하면 무시하고 2번이상 계속 발생할 경우 DAC조정을 하도록 수정
          HV_ADC_diff++;
        } else
        {
          HV_ADC_diff = 0;
        }

        if (HV_ADC_diff != 1) // 500이상 크게 바뀌었을 경우 1번은 무시함.
        {

          if ( abs(SUM_HV_12bit - HV_init_ADC.DAC_Value) > 15 )
          {
            add = HV_init_ADC.DAC_Value - SUM_HV_12bit;
            HV_DAC.DAC_Value = HV_DAC.DAC_Value + ( (11.523 * add) + 45.921 );

            if (HV_DAC.DAC_Value > 0 && HV_DAC.DAC_Value < 50000)
            {
              // HV_DAC의 값이 0과 50000사이의 값일 경우에는 계산된 값 전송
              DAC8830_write_HV(HV_DAC.value[1], HV_DAC.value[0]);
            } else
            {
              // 저장되어 있는 초기 설정값을 읽어서 설정함
              HV_DAC.value[0] = dueFlashStorage.read(1);
              HV_DAC.value[1] = dueFlashStorage.read(2);
              DAC8830_write_HV(HV_DAC.value[1], HV_DAC.value[0]);
            }

          } else
          {
            // 값이 작게 차이날 경우 미세 조정으로 +/- 10씩 조절
            add = HV_init_ADC.DAC_Value - SUM_HV_12bit;
            sub = sub * 70 / 100 + (float)add * 30 / 100;
          }

          if ((sub > 1.0 || sub < -1.0) && wait_time == 0)
          {
            if (sub > 1.0)
            {
              Serial.print("Sub : "); Serial.print(sub); Serial.println("> 1.0");
              sub = sub - 1;
              HV_DAC.DAC_Value += 11;
              Serial.println("DAC8830 : +11 ");//Serial.println(HV_DAC.DAC_Value);
            }

            else if (sub < -1.0)
            {
              Serial.print("Sub : "); Serial.print(sub); Serial.println("< -1.0");
              sub = sub + 1;
              HV_DAC.DAC_Value -= 11;
              Serial.println("DAC8830 : -11"); //Serial.println(HV_DAC.DAC_Value);
            }

            DAC8830_write_HV(HV_DAC.value[1], HV_DAC.value[0]);
          }
        }

      }


      //    else if (HV_control == 2)
      //    {
      //      //Serial.println("HV_control == 2, - 629");
      //      if (abs(SUM_HV_12bit - HV_init_ADC.DAC_Value) > 4) {
      //        add = SUM_HV_12bit - HV_init_ADC.DAC_Value;
      //        if (((HV_DAC.DAC_Value + add) < 4096) && ((HV_DAC.DAC_Value + add) > 0))
      //          HV_DAC.DAC_Value = HV_DAC.DAC_Value + add;
      //        HV_high = HV_DAC.DAC_Value >> 4;
      //        HV_low = HV_DAC.DAC_Value << 4;
      //        LTC2630(HV_high, HV_low);
      //      }
      //    }
      // TC3에서 1초마다 HV_control값 변경해줌
      HV_control = 0;
      //Serial.println("HV_control = 0, - 640");
    }
  }
  if (Start) { //------------------------------------------------------------------------------data acq
    //lasttime = millis();
    REG_PIOB_SODR = 0x00000004; //re=1

    if (a == 0) {
      REG_PIOD_SODR = 0x200;
    }
    if (a == 1) {
      REG_PIOD_CODR = 0x200;
    }
    a = !a;

    if (!((REG_PIOB_PDSR & 0x02) >> 1)) { //if em==0
      for (i = 0; i < 3087; i++) {
        data[i++] = REG_PIOC_PDSR >> 17;
        data[i++] = REG_PIOC_PDSR >> 9;
        data[i] = REG_PIOC_PDSR >> 1;
        REG_PIOB_SODR = 0x00000008; //clk 1
        REG_PIOB_CODR = 0x00000008;  //clk 0
      }
    }
    REG_PIOB_CODR = 0x00000004;  //re 0
    //--------
    timenew = millis();
    timebuffer = timenew - timeold;
    timeold = timenew; // millis();
    data[3088] = Bat_ADC[0];
    data[3089] = Bat_ADC[1];
    data[3090] = timebuffer / 256;
    data[3091] = timebuffer % 256;
    data[3092] = HV_ADC[0];
    data[3093] = HV_ADC[1];
    data[3094] = 0;
    data[3095] = 0;
    // 전송시간 간격 출력
    //Serial.println(timebuffer);
    //            Serial.println(data[3090]);
    //            Serial.println(data[3091]);
    adk_set = 1;
    if (BT_set == 1) { //////////Bluetooth연결
      BT_send = 1;
    }

  }
  if (BT_send) { //------------------------------------------------------------------------Bluetooth send
    char bud[5] = {0x80, 0x90, 0xa0, 0xb0, 0xc0};
    int lastnum = 0;
    BT_send = 0;
    data_send = 1;
    packetNumber = 0; /////////////////////1st
    pucBuffer[packetNumber++] = 0x55;
    pucBuffer[packetNumber++] = 0x55;
    pucBuffer[packetNumber++] = 0x55;
    pucBuffer[packetNumber++] = 0x80;
    for (int h = 0; h < 5; h++)
    {
      int i = 0;
      pucBuffer[3] = bud[h];
      if (h < 4) {
        for (i = 0; i < 720; i++)
        {
          pucBuffer[i + 4] = data[i + lastnum];
          i++;
          pucBuffer[i + 4] = data[i + lastnum];
          i++;
          pucBuffer[i + 4] = data[i + lastnum];
        }
        pucBuffer[724] = 0x66;
        pucBuffer[725] = 0x66;
        lastnum += i;
        if (Start) {
          for (i = 0; i < 726; i++) {
            Serial2.write(pucBuffer[i]);
          }
        }
      }
      else
      {
        for (i = 0; i < 218; i++)
        {
          pucBuffer[i + 4] = data[i + lastnum];
          i++;
          pucBuffer[i + 4] = data[i + lastnum];
          i++;
          pucBuffer[i + 4] = data[i + lastnum];
        }
        pucBuffer[222] = 0x66;
        pucBuffer[223] = 0x66;
        lastnum = i;
        if (Start) {
          for (i = 0; i < 224; i++) {
            Serial2.write(pucBuffer[i]);
          }
        }
      }
    }
    data_send = 0;
    Start = 0;
    if (b == 0) {
      REG_PIOD_SODR = 0x80;
    }
    if (b == 1) {
      REG_PIOD_CODR = 0x80;
    }
    b = !b;
  }//------------------------------------------------------------------------Bluetooth send

  Usb.Task(); //-----------------------------------------------------------------------------------------USB
  if (adk.isReady()) {
    if (Start) {
      if (adk_set) { //data 수집하면 전송
        adk_set = 0;
        data_send = 1;
        int shot = 0;
        char bud[8] = {0x80, 0x90, 0xa0, 0xb0, 0xc0, 0xd0, 0xe0, 0xf0};
        //----------------------------------------j3 통신용
        /*
          packetNumber = 0; /////////////////////1st
          pucBuffer[packetNumber++] = 0x55;
          pucBuffer[packetNumber++] = 0x55;
          pucBuffer[packetNumber++] = 0x55;
          for (int loops = 0; loops < 8; loops++) {
          pucBuffer[3] = bud[loops];
          for (shot = 4; shot < 404; shot++) {
            pucBuffer[shot] = data[shot - 4 + loops * 400];
            if (shot - 4 + loops * 400 >= 3095)
            {
              break;
            }
          }
          pucBuffer[shot++] = 0x66;
          pucBuffer[shot++] = 0x66;
          adk.write(shot, pucBuffer);
          Usb.Task();
          delay(20);
          }
        */
        //------------------------------------------j5 통신욜
        adk.write(3095, data);
        //Serial.println("SendData");
        data_send = 0;
        Start = 0;
      }
    }

    if (sw_wait) {
      if (sw_send == 1) {
        if (adk_set) {
          uint8_t usb_sw[4];
          usb_sw[0] = 'U';
          usb_sw[1] = 'U';
          usb_sw[2] = 'U';
          usb_sw[3] = 'C';
          usb_sw[4] = sw;
          adk.write(5, usb_sw);
        }
        sw_cnt = 0;
      }
      else if (sw_send == 2) {
        if (sw == 'U') {
          if (lamp == 0) {
            REG_PIOB_SODR = 0x10;
          }
          else if (lamp == 1) {
            REG_PIOB_CODR = 0x10;
          }
          lamp = !lamp;
        }
        if (adk_set) {
          uint8_t usb_sw[4];
          usb_sw[0] = 'U';
          usb_sw[1] = 'U';
          usb_sw[2] = 'U';
          usb_sw[3] = 'L';
          usb_sw[4] = sw;
          adk.write(5, usb_sw);
        }
        sw_cnt = 0;
      }
      sw_send = 0;
      startTimer2(TC2, 0, TC6_IRQn, 0);
    }

    adk.read(&startread, 128, buf);

    if (startread > 0) { ////////////////////////////////////////////PDA로 부터 data받으면 실행
      for (uint32_t kaka = 0; kaka < startread; kaka++) {
        Serial.write(buf[kaka]);
      }
      Serial.println(" recv");
      if (buf[0] == 'U' && buf[1] == '2' && buf[2] == 'A' && buf[3] == 'A') {
        Set_Start = 1;
        adk_set = 1;
        Serial.println("U2AA");
      }
      else if (buf[0] == 'U' && buf[1] == '4' && buf[2] == 'A' && buf[3] == 'A') {
        Start = 0;
        Set_Start = 0;
        REG_PIOB_CODR = 0x00000001;  //start 0
        Start_cnt = 0;
        Serial.println("U4AA");
      }
      else if (buf[0] == 'G' && buf[1] == 'S') {

        uint8_t GainSettingValue[13];
        GainSettingValue[0] = 'U';
        GainSettingValue[1] = 'U';
        GainSettingValue[2] = 'G';
        GainSettingValue[3] = 'K';
        GainSettingValue[4] = 0;
        GainSettingValue[5] = 0;
        GainSettingValue[6] = 0;
        GainSettingValue[7] = 0;
        GainSettingValue[8] = 0;
        GainSettingValue[9] = 0;
        GainSettingValue[10] = 0;
        GainSettingValue[11] = 0;
        GainSettingValue[12] = 0;

        // Preamp gain control init value
        GainSettingValue[4] = g_GC_init.value[1];
        GainSettingValue[5] = g_GC_init.value[0];
        // K-40 init value
        GainSettingValue[6] = g_K40_init.value[1];
        GainSettingValue[7] = g_K40_init.value[0];
        // Detector kind
        GainSettingValue[8] = g_DetectorKind[g_Detector];
        // 31keV init value
        GainSettingValue[9] = g_32keV_init.value[1];
        GainSettingValue[10] = g_32keV_init.value[0];
        // 662keV init value
        GainSettingValue[11] = g_662keV_init.value[1];
        GainSettingValue[12] = g_662keV_init.value[0];
        //Serial.write(13,GainSettingValue);
        Usb.Task();
        if (adk.isReady()) {
          Serial.println("adk.isReady");
        }
        else
        {
          while (!adk.isReady()) {
            Serial.println("adk.isNOT READY");
          }
          Serial.println("adk.isReady");
        }
        int lengthofdata = 0;
        lengthofdata = adk.write(13, GainSettingValue);
        //adk.write(13,GainSettingValue);
        //Usb.Task();
        adk_set = 1;
        Serial.println(lengthofdata);
        Serial.println("GS");
      }
      else if (buf[0] == 'G' && buf[1] == 'C') {
        Serial.println("GC");
        //Serial.println(buf[2]);
        //Serial.println(buf[3]);
        //g_GC_init.DAC_Value = buf[2] * 256 + buf[3];
        //DAC8830_write(buf[2], buf[3]);

        if (buf[4] == 0) {
          Serial.println("HV setting");
          HV_DAC.DAC_Value = buf[2] * 256 + buf[3];

          // 고압 조절하는 DAC종류에 따라서 함수 호출을 다르게 함.
          if (HV_CON_DAC)
          {
            HV_high = HV_DAC.DAC_Value >> 4;
            HV_low = HV_DAC.DAC_Value << 4;

            LTC2630(HV_high, HV_low);
          } else
          {
            DAC8830_write_HV(HV_DAC.value[1], HV_DAC.value[0]);
          }
        }
        else if (buf[4] == 1) {
          Serial.println("Gain setting");
          g_GC_init.DAC_Value = buf[2] * 256 + buf[3]; // gain 변경값 표시
          Serial.println(g_GC_init.DAC_Value);
          DAC8830_write(buf[2], buf[3]);
        }
        else if (buf[4] == 2) {
          Serial.println("HV ADC setting");
          HV_init_ADC.DAC_Value = buf[2] * 256 + buf[3]; // gain 변경값 표시
          Serial.println(HV_init_ADC.DAC_Value);
        }
      }
      else if (buf[0] == 'B' && buf[1] == 'T') { ////////////////////////////////BTSN 1이면 Bluetooth 변경모드
        BTSN = 1;
        REG_PIOD_SODR = 0x200;
        delay(200);
        REG_PIOD_CODR = 0x200;
        delay(200);
        REG_PIOD_SODR = 0x200;
        delay(200);
        REG_PIOD_CODR = 0x200;
        delay(200);
        REG_PIOD_SODR = 0x200;
        delay(200);
        REG_PIOD_CODR = 0x200;
      }
      else if (buf[0] == 'S' && buf[1] == 'N') { ////////////////////////////////시리얼번호 변경 모드는 없음.
        uint8_t SerialNumbers[23];
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
        //adk.write(23, SerialNumbers);
        for (i = 0; i < 23; i++) {
          Serial.write(SerialNumbers[i]);
        }
        Serial.println("**");
      }
      else if (buf[0] == 'F' && buf[1] == 'V') {  // Firmware Version return
        uint8_t FirmwareVesion[23];
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


        adk.write(23, FirmwareVesion);

      }
      else if (buf[0] == 'C' && buf[1] == 'S') {

        if (((buf[2] == 0) && (buf[3] == 0)) || ((buf[2] == 255) && (buf[3] == 255)))
        {
          buf[2] = dueFlashStorage.read(5);
          buf[3] = dueFlashStorage.read(6);
        }
        if (((buf[4] == 0) && (buf[5] == 0)) || ((buf[4] == 255) && (buf[5] == 255)))
        {
          buf[4] = dueFlashStorage.read(7);
          buf[5] = dueFlashStorage.read(8);
        }
        if (((buf[6] == 0) && (buf[7] == 0)) || ((buf[6] == 255) && (buf[7] == 255)))
        {
          buf[6] = dueFlashStorage.read(9);
          buf[7] = dueFlashStorage.read(10);
        }
        if (((buf[8] == 0) && (buf[9] == 0)) || ((buf[8] == 255) && (buf[9] == 255)))
        {
          buf[8] = dueFlashStorage.read(3);
          buf[9] = dueFlashStorage.read(4);
        }
        dueFlashStorage.write(5,  buf[2]);    //g_K40_init
        dueFlashStorage.write(6,  buf[3]);    //g_K40_init
        dueFlashStorage.write(7,  buf[4]);    //g_32keV_init
        dueFlashStorage.write(8,  buf[5]);    //g_32keV_init
        dueFlashStorage.write(9,  buf[6]);    //g_662keV_init
        dueFlashStorage.write(10, buf[7]);    //g_662keV_init
        dueFlashStorage.write(3,  buf[8]);    //g_GC_init
        dueFlashStorage.write(4,  buf[9]);    //g_GC_init
        if (factory) {
          dueFlashStorage.write(1,  HV_DAC.value[0]);    //HV_DAC
          dueFlashStorage.write(2,  HV_DAC.value[1]);    //HV_DAC
          dueFlashStorage.write(21,  HV_DAC.value[0]);    //HV_DAC
          dueFlashStorage.write(22,  HV_DAC.value[1]);    //HV_DAC
          dueFlashStorage.write(25,  buf[2]);    //g_K40_init
          dueFlashStorage.write(26,  buf[3]);    //g_K40_init
          dueFlashStorage.write(27,  buf[4]);    //g_32keV_init
          dueFlashStorage.write(28,  buf[5]);    //g_32keV_init
          dueFlashStorage.write(29,  buf[6]);    //g_662keV_init
          dueFlashStorage.write(30,  buf[7]);    //g_662keV_init
          dueFlashStorage.write(23,  buf[8]);    //g_GC_init
          dueFlashStorage.write(24,  buf[9]);    //g_GC_init

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
      else if (buf[0] == 'S' && buf[1] == 'U') {
        dueFlashStorage.write(0,  buf[2]);    //g_Detector
        dueFlashStorage.write(1,  buf[3]);    //HV_DAC
        dueFlashStorage.write(2,  buf[4]);    //HV_DAC
        dueFlashStorage.write(3,  buf[5]);    //g_GC_init
        dueFlashStorage.write(4,  buf[6]);    //g_GC_init
        dueFlashStorage.write(11,  buf[7]);    //목표 ADC값
        dueFlashStorage.write(12,  buf[8]);    //목표 ADC값
        if (factory) { //Factory value
          dueFlashStorage.write(20,  buf[2]);    //g_Detector
          dueFlashStorage.write(21,  buf[3]);    //HV_DAC
          dueFlashStorage.write(22,  buf[4]);    //HV_DAC
          dueFlashStorage.write(23,  buf[5]);    //g_GC_init
          dueFlashStorage.write(24,  buf[6]);    //g_GC_init
          dueFlashStorage.write(31,  buf[7]);    //목표 ADC값
          dueFlashStorage.write(32,  buf[8]);    //목표 ADC값
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
          HV_high = HV_DAC.DAC_Value >> 4;
          HV_low = HV_DAC.DAC_Value << 4;

          LTC2630(HV_high, HV_low);

          LTC2630(HV_DAC.value[1],HV_DAC.value[0]);
            
        } else
        {
          DAC8830_write_HV(HV_DAC.value[1], HV_DAC.value[0]);
        }
        DAC8830_write(g_GC_init.value[1], g_GC_init.value[0]);
      }


      if (BTSN == 1) { /////////////////////////////////////////////////////////////bluletooth change
        if (buf[0] == 'D' && buf[1] == 'C') {
          Serial2.write(0x02);
          //delay(2000);
        }
        else if (buf[0] == 'A' && buf[1] == 'T') {
          Serial2.write("AT\r");
        }
        else if (buf[0] == 'I' && buf[1] == 'N' && buf[2] == 'F' && buf[3] == 'O') {
          Serial2.write("AT+BTINFO?0\r");
        }
        else if (buf[0] == 'C') {
          Serial2.write("AT+BTNAME=");
          for (i = 1; i < startread; i++) {
            Serial2.write(buf[i]);
          }
          Serial2.write("\r");
        }
        else if (buf[0] == 'R' && buf[1] == 'E') {
          Serial2.write("ATZ\r");
          BTSN = 0;
        }

        REG_PIOD_SODR = 0x200;
        delay(200);
        REG_PIOD_CODR = 0x200;
        delay(200);
        REG_PIOD_SODR = 0x200;
        delay(200);
        REG_PIOD_CODR = 0x200;
        delay(200);
        REG_PIOD_SODR = 0x200;
        delay(200);
        REG_PIOD_CODR = 0x200;
      }/////////////////////////////////////////////////////////////bluletooth change
      Serial.print("USB Read : ");
      Serial.println(startread);
    }////////////////////////////////////////////PDA로 부터 data받으면 실행
  }

  if (sw_send) { //--------------------------------------------------------------------------sw send

    if (sw_check) {
      if (data_send == 0) {
        if (sw_send == 1) {

          uint8_t usb_sw[4];
          usb_sw[0] = 'U';
          usb_sw[1] = 'U';
          usb_sw[2] = 'U';
          usb_sw[3] = 'C';
          usb_sw[4] = sw;
          adk.write(5, usb_sw);

          sw_cnt = 0;
          sw_send = 0;
          startTimer2(TC2, 0, TC6_IRQn, 0);
        }
        else if (sw_send == 2) {
          if (sw == 'U') { ///////////////////////up 버튼 long press면 Lamp ON
            if (lamp == 0) {
              REG_PIOB_SODR = 0x10;
            }
            else if (lamp == 1) {
              REG_PIOB_CODR = 0x10;
            }
            lamp = !lamp;
          }

          uint8_t usb_sw[4];
          usb_sw[0] = 'U';
          usb_sw[1] = 'U';
          usb_sw[2] = 'U';
          usb_sw[3] = 'L';
          usb_sw[4] = sw;
          adk.write(5, usb_sw);

          sw_cnt = 0;
          sw_send = 0;
          startTimer2(TC2, 0, TC6_IRQn, 0);
        }
      }
      else if (data_send) { //////////////data_send 1이면 spectrum data 전송중이므로 sw_wait=1로 하고 기다림
        sw_wait = 1;
      }
      sw_cnt = 0;
      sw_check = 0;
    }

  }//--------------------------------------------------------------------------sw send


  if (Serial2.available() > 0) { //------------------------------------------------------------------BT read
    char BT_data[30];
    int BT_i = 0;
    int time_i;
    if (BTSN == 1) {
      uint8_t SN_BT_data[25];
      int SN_BT_i = 0;
      int SN_time_i;
      for (SN_time_i = 0; SN_time_i < 5000; SN_time_i++) {
        while (Serial2.available() > 0) {
          SN_BT_data[SN_BT_i] = Serial2.read();
          SN_BT_i++;
          //delayMicroseconds(1);
        }
      }//SN_BT_data[SN_BT_i]='\0';
      adk.write(SN_BT_i, SN_BT_data);
      REG_PIOD_SODR = 0x80;
      delay(200);
      REG_PIOD_CODR = 0x80;
      delay(200);
      REG_PIOD_SODR = 0x80;
      delay(200);
      REG_PIOD_CODR = 0x80;
      delay(200);
      REG_PIOD_SODR = 0x80;
      delay(200);
      REG_PIOD_CODR = 0x80;
    }

    else {
      for (time_i = 0; time_i < 2000; time_i++) {
        while (Serial2.available() > 0) {
          BT_data[BT_i] = Serial2.read();
          BT_i++;
        }
        BT_data[BT_i] = '\0';
      }

      BT_Read_sel(BT_data);

    }
  }
  if (Serial.available() > 0) {
    char BT_data[30];
    int BT_i = 0;
    int time_i;
    for (time_i = 0; time_i < 5000; time_i++) {
      while (Serial.available() > 0) {
        BT_data[BT_i] = Serial.read();
        BT_i++;
      }
    }
    BT_data[BT_i] = '\0';
    //factory= true;
    Serial.print("Debug Read : ");
    Serial.println(BT_i);
    BT_Read_sel(BT_data);
    //factory= false;
  }
}
