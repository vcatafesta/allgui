#include "hmg.ch"

DECLARE window Main

FUNCTION main_button_4_action

   c_RingTone := Getfile ( { {'WAV Files','*.*'} } , 'Open File' , 'Media\' , .f. , .t. )

   RETURN NIL

