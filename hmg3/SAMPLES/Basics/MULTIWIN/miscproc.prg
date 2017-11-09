#include 'hmg.ch'

DECLARE Window Test_1
DECLARE Window Andy1

PROCEDURE Opentest

   IF !IsWindowDefined(Test_1) .And. !IsWindowDefined(Andy1)

      LOAD WINDOW Test_1
      LOAD WINDOW Andy1

      Test_1.Row := 30
      Test_1.Col := 30

      Andy1.Row := 200
      Andy1.Col := 200

      ACTIVATE WINDOW Andy1 , Test_1

   ENDIF

   RETURN

