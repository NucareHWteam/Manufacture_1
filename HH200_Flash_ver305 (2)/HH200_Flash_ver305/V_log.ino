//1.0.0
//  최초버전
//1.1.0
//  블루투스 버그 해결
//1.2.0
//  블루투스, USB 동시 접속 되도록 수정
//2.0.0
//  플래시 기능 추가
//2.1.2
//  J5만 동작가능 HV정밀도 오차 1이하로 증가 USB 풀 페킷으로 전송함 플래시 기능 사용
//2.1.3    
//  J3도 동작 가능 USB 분산페킷으로 전송함
//2.1.4
//  MCU에서 전송시간 간격 기록기능 추가
//2.1.5
//  MCU 시간간격 오류 수정
//2.1.6
//  ADK 오류 수정(GS 받을 시 0 CPS 데이터 전송하던 버그 수정)
//2.1.7
//USB 연결 없이 BlueTooth 만 연결시 발생하는 오류 해결 버전
//2.1.8
//USB 연결 없이 BlueTooth 만 연결시 발생하는 오류 해결 버전
//2.1.9(21.08.06)
//USB연결시 테스트프로그램으로 GC명령어 통해서 Gain만 변경되던 것을 다른 것도 변경되도록 수정
//HVCONTROL 명령어가 적용되지 않던 것 수정

//2.2.1(22.07.06)
//1. USB(3096바이트)와 BLUETOOTH(3087바이트-HH100과 동일)의 패킷 전송량이 다름.
//   BLUETOOTH의 패킷 전송량을 USB와 동일하게 바꿈.
//2. MCU Firmware버전 정보 2.2.1로 변경(MCU_ver 변수)


//3.0.0(22.08.26)
//1.HV조절하는 DAC 변경으로 인해 변수추가
//   #define HV_CON_DAC 0x0  // 0x1 : LTC2630, 0x0 : DAC8830

//3.0.1(22.08.26)
// RD150에서 HH100, HH200(패킷100), HH200(USB패킷동일) 3개의 보드를 구분하기 위해서 명령어 추가
// FV(Firmware Version) 명령어 전송시


//3.0.2(22.11.10)
// RD150 HV조절할 경우 간헐적으로 DAC출력이 이상한 값으로 변경되는 문제가 있어서 DAC8830_write_HV 전송부분을 2번 하도록 수정
// DAC8830_write_HV(HV_DAC.value[1], HV_DAC.value[0]); // 22.11.10 수정, 인자를 잘 못 주고 있었음.

//3.0.3(22.12.16)
// RD150용 검출기 2x4x12inch 추가(0x0e)
