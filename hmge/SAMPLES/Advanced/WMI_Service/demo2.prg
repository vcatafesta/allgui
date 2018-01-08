/*
* MiniGUI WMI Service Demo
* (c) 2009 Logoshniy Sergey <serlogosh@yandex.ru>
* Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

PROCEDURE Main

   SET CENTURY ON
   SET DATE ANSI

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 200 ;
         TITLE 'WMI Service Demo 2' ;
         MAIN ;
         ON INTERACTIVECLOSE MsgYesNo ( 'Are You Sure ?', 'Exit' )

      DEFINE BUTTON Button_1
         ROW   10
         COL   10
         WIDTH   120
         CAPTION 'OS Info'
         ACTION OSInfo()
      END BUTTON

      DEFINE BUTTON Button_2
         ROW   40
         COL   10
         WIDTH   120
         CAPTION 'Bios Info'
         ACTION BiosInfo()
      END BUTTON

      DEFINE BUTTON Button_3
         ROW   70
         COL   10
         WIDTH   120
         CAPTION 'Video Info'
         ACTION VideoInfo()
      END BUTTON

      DEFINE BUTTON Button_4
         ROW   100
         COL   10
         WIDTH   120
         CAPTION 'Monitor Info'
         ACTION MonitorInfo()
      END BUTTON

      DEFINE BUTTON Button_5
         ROW   130
         COL   10
         WIDTH   120
         CAPTION 'Logical Disk Info'
         ACTION LogicalDiskInfo()
      END BUTTON

      DEFINE BUTTON Button_6
         ROW   10
         COL   160
         WIDTH   120
         CAPTION 'Memory Info'
         ACTION MemoryInfo()
      END BUTTON

      DEFINE BUTTON Button_7
         ROW   40
         COL   160
         WIDTH   120
         CAPTION 'Printer Info'
         ACTION PrinterInfo()
      END BUTTON

      DEFINE BUTTON Button_8
         ROW   70
         COL   160
         WIDTH   120
         CAPTION 'Net Adapter Info'
         ACTION NetAdapterInfo()
      END BUTTON

      DEFINE BUTTON Button_9
         ROW   100
         COL   160
         WIDTH   120
         CAPTION 'Sound Info'
         ACTION SoundInfo()
      END BUTTON

      DEFINE BUTTON Button_10
         ROW   130
         COL   160
         WIDTH   120
         CAPTION 'Environment vars'
         ACTION EnvVarInfo()
      END BUTTON

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN

#translate IFNOTCHAR( <exp1>,<exp2> ) ;
      => ;
      IF( VALTYPE( <exp1> ) != "C",<exp2>,<exp1> )

#define IS_DATE(x)                   (VALTYPE(x) == "D")
#define IS_LOGICAL(x)                (VALTYPE(x) == "L")
#define IS_NUMERIC(x)                (VALTYPE(x) == "N")
#define CASE_AT(x,y,z)               z[AT(x,y)+1]
#define TRIM_NUMBER(x)               LTRIM(STR(x))
#define NULL                         ""

#define XTOC(x)              CASE_AT(VALTYPE(x), "CNDLM", ;
      { NULL, ;
      x, ;
      IF(IS_NUMERIC(x), ;
      TRIM_NUMBER(x), ;
      NULL), ;
      IF(IS_DATE(x),DTOC(x),NULL), ;
      IF(IS_LOGICAL(x), ;
      IF(x,".T.",".F."), ;
      NULL), ;
      x })

FUNCTION MemoryInfo()

   LOCAL oWmi, oMemory
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oMemory IN oWmi:ExecQuery( "SELECT * FROM Win32_LogicalMemoryConfiguration" )

      cInfo:= "Memory Total: " +  XTOC(Round(oMemory:TotalPhysicalMemory/(1024*1024),2)) + " GB"

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION BiosInfo()

   LOCAL oWmi, oBios
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oBios IN oWmi:ExecQuery( "SELECT * FROM Win32_BIOS" )

      cInfo+="Name: " +  oBios:Name+ CRLF
      cInfo+="Date: " +  Left(oBios:ReleaseDate,8)+ CRLF
      cInfo+="Version: " +  oBios:Version+ CRLF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION MonitorInfo()

   LOCAL oWmi, oMonitor
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oMonitor IN oWmi:ExecQuery( "SELECT * FROM Win32_DesktopMonitor" )

      cInfo+="Name: " +  oMonitor:Name+ CRLF
      cInfo+="Width: " +  XTOC(oMonitor:ScreenWidth)+ CRLF
      cInfo+="Height: " +  XTOC(oMonitor:ScreenHeight)+ CRLF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION NetAdapterInfo()

   LOCAL oWmi, oNetA
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oNetA IN oWmi:ExecQuery( "SELECT * FROM Win32_NetworkAdapter" )

      cInfo+="Name: " +  oNetA:Name+ CRLF
      cInfo+="Type: " +  XTOC(oNetA:AdapterType)+ CRLF
      cInfo+="Speed: " +  XTOC(oNetA:Speed)+ CRLF
      cInfo+="MAC: " +  XTOC(oNetA:MACAddress)+ CRLF
      cInfo+="Addresses: " +  XTOC(oNetA:NetworkAddresses)+ CRLF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION VideoInfo()

   LOCAL oWmi, oVideo
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oVideo IN oWmi:ExecQuery( "SELECT * FROM Win32_VideoController" )

      cInfo+="Card: " +  oVideo:Description+ CRLF
      cInfo+="Video Mode: " +  oVideo:VideoModeDescription+ CRLF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION SoundInfo()

   LOCAL oWmi, oSound
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oSound IN oWmi:ExecQuery( "SELECT * FROM Win32_SoundDevice" )

      cInfo+="Name: " +  oSound:ProductName+ CRLF

      IF IsWinNT()

         cInfo+="Manuf: " +  oSound:Manufacturer+ CRLF

      ENDIF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION CdRomInfo()

   LOCAL oWmi, oCdRom
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oCdRom IN oWmi:ExecQuery( "SELECT * FROM Win32_CDROMDrive" )

      cInfo+="Name: " +  oCdRom:Name+ CRLF
      cInfo+="Drive: " +  oCdRom:Drive+ CRLF
      cInfo+="Status: " +  oCdRom:Status+ CRLF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION ModemInfo()

   LOCAL oWmi, oModem
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oModem IN oWmi:ExecQuery( "SELECT * FROM Win32_POTSModem" )

      cInfo+="Name: " +  oModem:Name+ CRLF
      cInfo+="Port: " +  oModem:AttachedTo+ CRLF
      cInfo+="Type: " +  oModem:DeviceType+ CRLF
      cInfo+="Status: " +  oModem:Status+ CRLF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION MouseInfo()

   LOCAL oWmi, oMouse
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oMouse IN oWmi:ExecQuery( "SELECT * FROM Win32_PointingDevice" )

      cInfo+="Name: " +  oMouse:Name+ CRLF
      cInfo+="Manufacturer: " +  oMouse:Manufacturer+ CRLF
      cInfo+="Type: " +  oMouse:HardWareType+ CRLF
      cInfo+="Status: " +  oMouse:Status+ CRLF
      cInfo+="Buttons: " +  XTOC(oMouse:NumberofButtons)+ CRLF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION PrinterInfo()

   LOCAL oWmi, oPrinter
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oPrinter IN oWmi:ExecQuery( "SELECT * FROM Win32_Printer" )

      cInfo+="Name: " +  oPrinter:Name+ CRLF
      cInfo+="Share: " +  XTOC(oPrinter:ShareName)+ CRLF
      cInfo+="Location: " +  XTOC(oPrinter:Location)+ CRLF
      cInfo+="Status: " +  oPrinter:Status+ CRLF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION LogicalDiskInfo()

   LOCAL oWmi, oDrive, cSerialNumber
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oDrive IN oWmi:ExecQuery( "SELECT * FROM Win32_LogicalDisk" )

      cInfo += "Drive: " + oDrive:DeviceId + CRLF
      cInfo += "Name: " + oDrive:Description + CRLF
      cInfo += "Type: " + XTOC(oDrive:DriveType) + CRLF
      cInfo += "File System: " + XTOC(oDrive:FileSystem) + CRLF
      cInfo += "Size: " + XTOC(oDrive:Size) + CRLF
      cInfo += "Free Space: " + XTOC(oDrive:FreeSpace) + CRLF
      cInfo += "Serial Number:" + XTOC( oDrive:VolumeSerialNumber )+ CRLF

   NEXT

   MsgInfo( cInfo )

   RETURN NIL

FUNCTION OSInfo()

   LOCAL oWmi, oOs
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oOs IN oWmi:ExecQuery( "SELECT * FROM Win32_OperatingSystem" )

      cInfo+="Name: " +  oOs:Caption+ CRLF
      cInfo+="Version: " +  oOs:Version+ CRLF
      cInfo+="Service Pack: " +  XTOC(oOs:CSDVersion)+ CRLF
      cInfo+="Build: " +  oOs:BuildNumber+ CRLF
      cInfo+="Locale: " +  oOs:Locale+ CRLF
      cInfo+="Serial Number: " +  oOs:SerialNumber+ CRLF
      cInfo+="Registered User: " +  oOs:RegisteredUser+ CRLF

      IF IsVistaOrLater()

         cInfo+="OS Type: " + GetProductType(oOs:OperatingSystemSKU)+ CRLF

      ENDIF
      IF IsWinNT()

         cInfo+="Install Date: " + DtoC(StoD(Left(oOs:InstallDate, 8)))+ CRLF
         cInfo+="Last BootUp: " + DtoC(StoD(Left(oOs:LastBootUpTime, 8)))+ CRLF

      ENDIF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

FUNCTION GetProductType( nType )

   LOCAL cName := ""

   DO CASE
   CASE nType == 1
      cName := "Ultimate Edition"

   CASE nType == 2  // ?
      cName := "Home Basic Edition"

   CASE nType == 3  // ?
      cName := "Home Premium Edition"

   CASE nType == 4  // ?
      cName := "Enterprise Edition"

   CASE nType == 6  // ?
      cName := "Business Edition"

   CASE nType == 48
      cName := "Professional Edition"

   ENDCASE

   RETURN cName

FUNCTION EnvVarInfo()

   LOCAL oWmi, oEnvVar
   LOCAL cInfo := ""

   oWmi := WmiService()

   FOR EACH oEnvVar IN oWmi:ExecQuery( "SELECT * FROM Win32_Environment" )

      cInfo += oEnvVar:Name + "=" + oEnvVar:VariableValue+ CRLF+ CRLF

   NEXT

   MsgInfo(cInfo)

   RETURN NIL

STATIC FUNCTION WMIService()

   STATIC oWMI

   LOCAL oLocator

   IF oWMI == NIL

      oLocator   := CreateObject( "wbemScripting.SwbemLocator" )
      oWMI       := oLocator:ConnectServer()

   ENDIF

   RETURN oWMI
