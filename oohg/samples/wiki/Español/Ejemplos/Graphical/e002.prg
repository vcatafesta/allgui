/*
 * Ejemplo Comandos Gráficos n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo dibujar figuras en un formulario.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main()

   DEFINE WINDOW Win_1 ;
      AT 0,0 ;
      WIDTH 800 ;
      HEIGHT 600 ;
      TITLE "Dibujar figuras en un formulario" ;
      MAIN

      // Línea
      FOR i := 1 TO 5
         DRAW LINE IN WINDOW Win_1 ;
            AT 40 + (i * 6), 050 ;
            TO 40 + (i * 6), 200 ;
            PENCOLOR RED ;
            PENWIDTH i
      NEXT i

      // Rectángulo
      DRAW RECTANGLE IN WINDOW Win_1 ;
         AT 100, 050 ;
         TO 150, 200 ;
         PENCOLOR YELLOW ;
         PENWIDTH 2 ;
         FILLCOLOR YELLOW

      // Rectángulo redondeado
      DRAW ROUNDRECTANGLE IN WINDOW Win_1 ;
         AT 180, 050 ;
         TO 230, 200 ;
         ROUNDWIDTH 15 ;
         ROUNDHEIGHT 15 ;
         PENCOLOR BLACK ;
         PENWIDTH 2 ;
         FILLCOLOR WHITE

      // Elipse
      DRAW ELLIPSE IN WINDOW Win_1 ;
         AT 040, 300 ;
         TO 140, 400 ;
         PENCOLOR GREEN ;
         PENWIDTH 2 ;
         FILLCOLOR GREEN

      // Arco
      DRAW ARC IN WINDOW Win_1 ;
         AT 160, 300 ;
         TO 260, 400 ;
         FROM RADIAL 180, 350 ;
         TO RADIAL 200, 400 ;
         PENCOLOR BLUE ;
         PENWIDTH 5

      // Trozo de torta
      DRAW PIE IN WINDOW Win_1 ;
         AT 160, 500 ;
         TO 260, 600 ;
         FROM RADIAL 180, 550 ;
         TO RADIAL 200, 500 ;
         PENCOLOR FUCHSIA ;
         PENWIDTH 2 ;
         FILLCOLOR FUCHSIA

      // Polígono
      DRAW POLYGON IN WINDOW Win_1 ;
         POINTS { {400, 100}, ;
                  {350, 050}, ;
                  {300, 200}, ;
                  {350, 275}, ;
                  {400, 340}, ;
                  {500, 250}, ;
                  {400, 050} } ;
         PENCOLOR PINK ;
         PENWIDTH 2 ;
         FILLCOLOR PINK

      // Curva de Bézier
      DRAW POLYBEZIER IN WINDOW Win_1 ;
      POINTS  ;
      PENCOLOR ORANGE ;
      PENWIDTH 2

      ON KEY ESCAPE ACTION Win_1.Release()
   END WINDOW

   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

RETURN NIL

/*
 * EOF
 */
