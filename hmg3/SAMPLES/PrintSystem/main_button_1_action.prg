#include "hmg.ch"

DECLARE window Main

FUNCTION main_button_1_action

   USE Test

   LOAD REPORT Test

   EXECUTE REPORT Test PREVIEW SELECTPRINTER

   USE

   RETURN NIL
