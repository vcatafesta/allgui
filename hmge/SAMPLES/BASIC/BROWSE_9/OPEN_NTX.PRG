*:**************************
*: Program OPEN_NTX.PRG
*:**************************

PROCEDURE open_ntx

   IF ! file ("EMPLOYE.ntx")
      USE EMPLOYE
      INDEX ON FIELD->CLI_ID to EMPLOYE
      USE
   ENDIF

   IF ! file ("EMPLOYEC.ntx")
      USE EMPLOYE
      INDEX ON FIELD->CLI_CITY to EMPLOYEC
      USE
   ENDIF

   RETURN
