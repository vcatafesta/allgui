/*
Este ejemplo requiere que tengas instalado el ocx de RMChart
puedes descargarlo de http://www.rmchart.com/
adaptado para ooHG por MigSoft 2007
*/

#include "oohg.ch"
#include "RMChart.ch"

STATIC oChart, oWnd

FUNCTION Main()

   DEFINE WINDOW Start OBJ oWnd At 0,0 Width 600 Height 450         ;
         TITLE "Demo RMChart 2 - Adapted by MigSoft for ooHG" Main ;
         ON Size Ajust() ON Maximize Ajust() ON MOUSECLICK oWnd:print()

      @ 0,0 ACTIVEX ActiveX OBJ oChart Width oWnd:Width - 7 ;
         HEIGHT oWnd:Height - 35 PROGID "RMChart.RMChartX"

   END WINDOW

   oChart:Reset()
   oChart:RMCBackColor   := Bisque
   oChart:RMCStyle       := RMC_CTRLSTYLE3DLIGHT
   oChart:RMCWidth       := 600
   oChart:RMCHeight      := 450
   oChart:RMCBgImage     := ""
   oChart:Font           := "Tahoma"

   // Add Region 1
   oChart:AddRegion()

   WITH OBJECT oChart:Region( 1 )

      :Left   := 5
      :Top    := 10
      :Width  := -5
      :Height := -5
      :Footer := "https://oohg.github.io/"

      // Add caption to region 1
      :AddCaption()

      WITH OBJECT :Caption()
         :Titel       := "Saldos por Banco a�o 2007"
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
         :AxisUnit       := " $"
         :AxisText       := "Miles de Dolares\9b"
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

   oChart:Draw( .T. )

   oWnd:Center()
   oWnd:Activate()

   RETURN NIL

PROCEDURE Ajust()

   oChart:Width  := iif( oWnd:Width  -  7 < 50, 50, oWnd:Width  -  7 )
   oChart:Height := iif( oWnd:Height - 35 < 50, 50, oWnd:Height - 35 )
   Return(Nil)
