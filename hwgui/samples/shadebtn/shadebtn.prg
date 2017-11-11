/*
* $Id: shadebtn.prg 1615 2011-02-18 13:53:35Z mlacecilia $
* Shade buttons sample
*/

#include "hwgui.ch"

FUNCTION Main

   LOCAL oMainWindow, oFont
   LOCAL oIco1 := HIcon():AddFile("..\image\ok.ico")
   LOCAL oIco2 := HIcon():AddFile("..\image\cancel.ico")

   PREPARE FONT oFont NAME "Times New Roman" WIDTH 0 HEIGHT 15

   INIT WINDOW oMainWindow MAIN TITLE "Shade Buttons" ;
      AT 200,0 SIZE 480,220 COLOR COLOR_3DLIGHT+1

   @ 10,10 SHADEBUTTON SIZE 100,36 TEXT "Metal" FONT oFont EFFECT SHS_METAL PALETTE PAL_METAL
   @ 10,50 SHADEBUTTON SIZE 100,36 TEXT "Softbump" FONT oFont EFFECT SHS_SOFTBUMP PALETTE PAL_METAL
   @ 10,90 SHADEBUTTON SIZE 100,36 TEXT "Noise" FONT oFont EFFECT SHS_NOISE  PALETTE PAL_METAL GRANULARITY 33
   @ 10,130 SHADEBUTTON SIZE 100,36 TEXT "Hardbump" FONT oFont EFFECT SHS_HARDBUMP PALETTE PAL_METAL

   @ 120,10 SHADEBUTTON SIZE 100,36 TEXT "HShade" FONT oFont EFFECT SHS_HSHADE PALETTE PAL_METAL
   @ 120,50 SHADEBUTTON SIZE 100,36 TEXT "VShade" FONT oFont EFFECT SHS_VSHADE PALETTE PAL_METAL
   @ 120,90 SHADEBUTTON SIZE 100,36 TEXT "DiagShade" FONT oFont EFFECT SHS_DIAGSHADE  PALETTE PAL_METAL
   @ 120,130 SHADEBUTTON SIZE 100,36 TEXT "HBump" FONT oFont EFFECT SHS_HBUMP  PALETTE PAL_METAL

   // @ 128,0 GROUPBOX "" SIZE 94,75

   @ 230,10 SHADEBUTTON SIZE 100,40 FLAT BITMAP oIco1 COORDINATES 52,0,0,0 ;
      EFFECT SHS_VSHADE  PALETTE PAL_METAL HIGHLIGHT 12
   @ 230,50 SHADEBUTTON SIZE 100,40 FLAT BITMAP oIco2 COORDINATES 52,0,0,0 ;
      EFFECT SHS_VSHADE  PALETTE PAL_METAL HIGHLIGHT 12
   @ 230,90 SHADEBUTTON SIZE 100,40 FLAT ;
      EFFECT SHS_VSHADE  PALETTE PAL_METAL HIGHLIGHT 12
   @ 230,130 SHADEBUTTON SIZE 100,40 FLAT TEXT "Flat" FONT oFont ;
      EFFECT SHS_VSHADE  PALETTE PAL_METAL HIGHLIGHT 12

   @ 340,10 SHADEBUTTON SIZE 100,36 EFFECT SHS_METAL  PALETTE PAL_METAL GRANULARITY 33 ;
      HIGHLIGHT 20 TEXT "Close" FONT oFont ON CLICK {||oMainWindow:Close()}
   @ 340,50 SHADEBUTTON SIZE 100,36 EFFECT SHS_SOFTBUMP  PALETTE PAL_METAL GRANULARITY 33 HIGHLIGHT 20

   ACTIVATE WINDOW oMainWindow

   RETURN NIL

