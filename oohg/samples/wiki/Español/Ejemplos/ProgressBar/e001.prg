/*
 * Ejemplo ProgressBar n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo definir un control ProgressBar
 * con estila Marquee (el control muestra una barra animada
 * que nunca se detiene), y cómo cambiar el estilo desde el
 * programa.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   LOCAL nPrevio := 10

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 466 + GetBorderWidth() ;
      HEIGHT 200 + GetTitleHeight() + 2 * GetBorderHeight() ;
      TITLE "OOHG - Estilos Marquee y Normal en Controles ProgressBar" ;
      MAIN

      @ 20,20 PROGRESSBAR Progress_1 ;
         OBJ oProg1 ;
         WIDTH 420 ;
         HEIGHT 26 ;
         SMOOTH ;
         TOOLTIP 'Control ProgressBar Marquee. Cliquee el boton "Detener" para detener la animación.' ;
         MARQUEE 90
      /*
       * 90 es el tiempo, en milisegundos, con que se actualiza la animación.
       * Cuanto más alto sea el número, más despacio se mueve.
       * Si este parámetro es cero o negativo, la animación se detiene.
       */

      @ 80,20 PROGRESSBAR Progress_2 ;
         OBJ oProg2 ;
         RANGE 0, 100 ;
         WIDTH 420 ;
         HEIGHT 26 ;
         SMOOTH ;
         VALUE 30 ;
         TOOLTIP 'Control ProgressBar Normal. Cliquee el boton "Cambiar Estilo" para cambiar a Marquee.'

      @ 140,20 BUTTON Button_1 ;
         OBJ oBut1 ;
         CAPTION "Cambiar Estilo" ;
         WIDTH 100 ;
         HEIGHT 28 ;
         ACTION nPrevio := CambiarEstilo( oProg2, nPrevio, oBut1 ) ;
         TOOLTIP 'Cliquee para convertir el segundo ProgressBar a Marquee e iniciar la animación.'

      @ 140,340 BUTTON Button_2 ;
         OBJ oBut2 ;
         CAPTION "Detener" ;
         WIDTH 100 ;
         HEIGHT 28 ;
         ACTION AlternarMarquee( oProg1, oBut2 ) ;
         TOOLTIP 'Cliquee para detener el primer control.'

      ON KEY ESCAPE ACTION Form_1.Release
   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION CambiarEstilo( oProg, nValue, oBut )

   IF oProg:IsStyleNormal()
      nValue := oProg:Value

      oProg:SetStyleMarquee( 20 )
      oBut:ToolTip := 'Cliquee para convertir el segundo ProgressBar a estilo Normal.'
      oProg:ToolTip := 'Control ProgressBar Marquee. Cliquee el boton "Cambiar Estilo" para cambiar a Normal.'
   ELSE
      oProg:SetStyleNormal( nValue )
      oBut:ToolTip := 'Cliquee para convertir el segundo ProgressBar a estilo Marquee e iniciar la animación.'
      oProg:ToolTip := 'Control ProgressBar Normal. Cliquee el boton "Cambiar Estilo" para cambiar a Marquee.'
   ENDIF

   /*
    * SetStyleNormal() configura el control en estilo Normal.
    * Si el parámetro se omite o no es numérico o es negativo,
    * se asume cero. Este parámetro setea el VALUE del control.
    *
    * SetStyleMarquee() configura el control en estilo Marquee.
    * Si el parámetro se omite o no es numérico o es negativo,
    * el estilo se cambia pero lo animación no se inicia.
    * Este parámetro indica el tiempo, en milisegundos, con que
    * se actualiza la animación. Cuanto más alto sea el número,
    * más despacio se mueve.
    *
    * Al configurar el estilo normal no se restaura el VALUE
    * del control al valor anterior al cambio de estilo.
    * Ud. debe guardar el VALUE antes de cambiar el estilo si
    * desea restaurarlo más tarde.
    */

RETURN nValue

FUNCTION AlternarMarquee( oProg, oBut )

   IF oProg:IsStyleMarquee()
      IF oProg:IsMarqueeRunning()
         oProg:StopMarquee()
         oBut:Caption := "Iniciar"
         oBut:ToolTip := 'Cliquee para animar el primer control.'
         oProg:ToolTip := 'Control ProgressBar Marquee. Cliquee el boton "Iniciar" para comenzar la animación.'
      ELSE
         oProg:StartMarquee()
         oBut:Caption := "Detener"
         oBut:ToolTip := 'Cliquee para detener la animación del primer control.'
         oProg:ToolTip := 'Control ProgressBar Marquee. Cliquee el boton "Detener" para detener la animación.'
      ENDIF
   ENDIF

   /*
    * StartMarquee() utiliza el tiempo definido en el control.
    * Si este valor es negativo o cero, se asume 30.
    *
    * En estilo Marquee, el VALUE del control es siempre 1, por lo
    * tanto no es posible reiniciar la animación desde el punto en
    * que se detuvo. Siempre se inicia desde el principio.
    */

RETURN NIL

/*
 * EOF
 */
