RAMFUNC
void SelfDistruct()
{
WDT->WDT_MR = WDT_MR_WDD(0xFFF)
                | WDT_MR_WDRPROC
                | WDT_MR_WDRSTEN
                | WDT_MR_WDV(256 * 2);
  Serial.println("clear lock");
  Clear_LOCK();
  Serial.println("now erase Good bye");
  Serial.flush();

  Furmup_Ready();
}

void Clear_LOCK()
{
    unsigned int status ;
    /* Send the Start Read unique Identifier command (STUI) by writing the Flash Command Register with the STUI command.*/
     for(int i = 0;i<100;i++){
     status = flash_unlock((uint32_t)FLASH_START+i, (uint32_t)FLASH_START+i, 0, 0);
     Serial.print(status);
     }
     Serial.println();
     Serial.println("Clear Finish");
}
void Furmup_Ready()
{
    unsigned int status ;
    /* Send the Start Read unique Identifier command (STUI) by writing the Flash Command Register with the STUI command.*/
         
     status = efc_perform_command(EFC0,EFC_FCMD_CGPB,1);
     Serial.println(status);
}
