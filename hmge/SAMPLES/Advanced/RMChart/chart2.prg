/*
Este ejemplo requiere que tengas instalado el ocx de RMChart
puedes descargarlo de http://www.rmchart.com/
adaptado para ooHG por MigSoft 2007
*/

* Translated for MiniGUI by Grigory Filatov <gfilatov@inbox.ru>

#include 'minigui.ch'
#include 'RMChart.ch'

SET Procedure To tAxPrg.prg

STATIC oChart, oActiveX

FUNCTION Main()

   DEFINE WINDOW Win_1 ;
         At 0,0 ;
         WIDTH 600 ;
         HEIGHT 450 ;
         TITLE 'Demo RMChart - Adapted by Grigory Filatov for MiniGUI' ;
         ICON "Main" ;
         Main ;
         On Init fOpenActivex() ;
         On Size Ajust() ;
         On Maximize Ajust() ;
         On Release fCloseActivex()

      Win_1.MinWidth  := 600
      Win_1.MinHeight := 450

   END WINDOW

   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

   RETURN(Nil)

STATIC PROCEDURE fOpenActivex()

   LOCAL nVersion, nWidth, nHeight

   nWidth   := GetProperty(ThisWindow.Name, "width") -  2 * GetBorderWidth()
   nHeight  := GetProperty(ThisWindow.Name, "height") - 2 * GetBorderHeight() - GetTitleHeight()

   oActiveX := TActiveX():New( ThisWindow.Name, 'RMChart.RMChartX' , 0 , 0 , nWidth , nHeight )

   oChart := oActiveX:Load()

   nVersion := oChart:RMCVersion

   oChart:Reset()
   oChart:RMCBackColor   := Bisque
   oChart:RMCStyle       := RMC_CTRLSTYLE3DLIGHT
   oChart:RMCWidth       := nWidth
   oChart:RMCHeight      := nHeight
   oChart:RMCBgImage     := ""
   oChart:Font           := "Tahoma"

   // Add Region 1
   oChart:AddRegion()

   WITH OBJECT oChart:Region( 1 )

      :Left   := 5
      :Top    := 10
      :Width  := -5
      :Height := -5
      :Footer = 'Version' + Str(nVersion/100, 5, 2)

      // Add caption to region 1
      :AddCaption()

      WITH OBJECT :Caption()
         :Titel       := "Saldos por Banco año 2007"
         :BackColor   := Bisque
         :TextColor   := Black
         :FontSize    := 11
         :Bold        := TRUE
      END

      // Add grid to region 1
      :AddGrid()

      WITH OBJECT :Grid
         :BackColor   := Cornsilk
         :AsGradient  := FALSE
         :BicolorMode := RMC_BICOLOR_NONE
         :Left        := 0
         :Top         := 0
         :Width       := 0
         :Height      := 0
      END

      // Add data axis to region 1
      :AddDataAxis()

      WITH OBJECT :DataAxis( 1 )
         :Alignment      := RMC_DATAAXISLEFT
         :MinValue       := 0
         :MaxValue       := 50000
         :TickCount      := 11
         :Fontsize       := 8
         :TextColor      := Black
         :LineColor      := Black
         :LineStyle      := RMC_LINESTYLESOLID
         :DecimalDigits  := 0
         :AxisUnit       := " $"
         :AxisText       := "Miles de Dólares\9b"
      END

      // Add label axis to region 1
      :AddLabelAxis()

      WITH OBJECT :LabelAxis
         :AxisCount     := 1
         :TickCount     := 6
         :Alignment     := RMC_LABELAXISBOTTOM
         :Fontsize      := 8
         :TextColor     := Black
         :TextAlignment := RMC_TEXTCENTER
         :LineColor     := Black
         :LineStyle     := RMC_LINESTYLESOLID
         :AxisText      := "Primer semestre"
         :LabelString   := "Enero*Febrero*Marzo*Abril*Mayo*Junio"
      END

      // Add legend to region 1
      :AddLegend()

      WITH OBJECT :Legend
         :Alignment           := RMC_LEGEND_CUSTOM_UL
         :BackColor           := LightYellow
         :Style               := RMC_LEGENDRECT
         :TextColor           := Blue
         :Fontsize            := 8
         :Bold                := FALSE
         :LegendString        := "Citibank*Boston*BBVA*Santander"
      END

      // Add Series 1 to region 1
      :AddBarSeries()

      WITH OBJECT :BarSeries(1)
         :SeriesType          := RMC_BARSTACKED
         :SeriesStyle         := RMC_COLUMN_FLAT
         :Lucent              := FALSE
         :Color               := DarkBlue
         :Horizontal          := FALSE
         :WhichDataAxis       := 1
         :ValueLabelOn        := RMC_VLABEL_NONE
         :PointsPerColumn     := 1
         :HatchMode           := RMC_HATCHBRUSH_OFF
         :DataString          := "10000*10000*16000*12000*20000*10000"
      END

      // Add Series 2 to region 1
      :AddBarSeries()

      WITH OBJECT :BarSeries(2)
         :SeriesType          := RMC_BARSTACKED
         :SeriesStyle         := RMC_COLUMN_FLAT
         :Lucent              := FALSE
         :Color               := DarkGreen
         :Horizontal          := FALSE
         :WhichDataAxis       := 1
         :ValueLabelOn        := RMC_VLABEL_NONE
         :PointsPerColumn     := 1
         :HatchMode           := RMC_HATCHBRUSH_OFF
         :DataString          := "5000*7000*4000*15000*10000*10000"
      END

      // Add Series 3 to region 1
      :AddBarSeries()

      WITH OBJECT :BarSeries(3)
         :SeriesType          := RMC_BARSTACKED
         :SeriesStyle         := RMC_COLUMN_FLAT
         :Lucent              := FALSE
         :Color               := Maroon
         :Horizontal          := FALSE
         :WhichDataAxis       := 1
         :ValueLabelOn        := RMC_VLABEL_NONE
         :PointsPerColumn     := 1
         :HatchMode           := RMC_HATCHBRUSH_OFF
         :DataString          := "10000*3000*12000*10000*5000*20000"
      END

      // Add Series 4 to region 1
      :AddBarSeries()

      WITH OBJECT :BarSeries(4)
         :SeriesType          := RMC_BARSTACKED
         :SeriesStyle         := RMC_COLUMN_FLAT
         :Lucent              := FALSE
         :Color               := DarkGoldenrod
         :Horizontal          := FALSE
         :WhichDataAxis       := 1
         :ValueLabelOn        := RMC_VLABEL_NONE
         :PointsPerColumn     := 1
         :HatchMode           := RMC_HATCHBRUSH_OFF
         :DataString          := "5000*9000*12000*6000*10000*5000"
      END

   END

   oChart:Draw()

   RETURN

STATIC PROCEDURE fCloseActivex()

   IF VALTYPE(oActiveX) <> "U"
      oActiveX:Release()
   ENDIF

   RETURN

STATIC PROCEDURE Ajust()

   oActiveX:Adjust()

   RETURN
