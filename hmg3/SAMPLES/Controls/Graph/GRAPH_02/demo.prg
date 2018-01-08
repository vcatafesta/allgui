#include "hmg.ch"

FUNCTION main

   DEFINE WINDOW x at 0,0 width 640 height 480 title "Shapes" main

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM 'Erase All' ACTION EraseAll()
         END POPUP
      END MENU

      DEFINE SPLITBOX horizontal
         DEFINE WINDOW y width 640 height 200 splitchild

            DEFINE TEXTBOX TEXT_1
               ROW 10
               COL 10
            END TEXTBOX

         END WINDOW
         DEFINE WINDOW z width 640 height 150 splitchild
            DEFINE TAB shapes at 10,10 width 600 height 200
               DEFINE PAGE "Line"
                  DEFINE LABEL fromlinerowlabel
                     ROW 60
                     COL 50
                     VALUE "From Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX linerow1
                     ROW 60
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL fromlinecollabel
                     ROW 60
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX linecol1
                     ROW 60
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL tolinerowlabel
                     ROW 90
                     COL 50
                     VALUE "TO Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX linerow2
                     ROW 90
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL tolinecollabel
                     ROW 90
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX linecol2
                     ROW 90
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE BUTTON line1
                     ROW 90
                     COL 410
                     CAPTION "Draw"
                     ACTION drawline1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Rectangle"
                  DEFINE LABEL fromrectrowlabel
                     ROW 60
                     COL 50
                     VALUE "From Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX rectrow1
                     ROW 60
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL fromrectcollabel
                     ROW 60
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX rectcol1
                     ROW 60
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL torectrowlabel
                     ROW 90
                     COL 50
                     VALUE "TO Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX rectrow2
                     ROW 90
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL torectcollabel
                     ROW 90
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX rectcol2
                     ROW 90
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE BUTTON rect1
                     ROW 90
                     COL 410
                     CAPTION "Draw"
                     ACTION drawrect1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Rounded Rectangle"
                  DEFINE LABEL fromroundrectrowlabel
                     ROW 60
                     COL 50
                     VALUE "From Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX roundrectrow1
                     ROW 60
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL fromroundrectcollabel
                     ROW 60
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX roundrectcol1
                     ROW 60
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL roundrectwidthlabel
                     ROW 60
                     COL 410
                     VALUE "Width"
                     WIDTH 60
                  END LABEL
                  DEFINE TEXTBOX roundrectwidth
                     ROW 60
                     COL 470
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL toroundrectrowlabel
                     ROW 90
                     COL 50
                     VALUE "TO Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX roundrectrow2
                     ROW 90
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL toroundrectcollabel
                     ROW 90
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX roundrectcol2
                     ROW 90
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL roundrectheightlabel
                     ROW 90
                     COL 410
                     VALUE "Height"
                     WIDTH 60
                  END LABEL
                  DEFINE TEXTBOX roundrectheight
                     ROW 90
                     COL 470
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE BUTTON roundrect1
                     ROW 140
                     COL 350
                     CAPTION "Draw"
                     ACTION drawroundrect1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Ellipse"
                  DEFINE LABEL fromellipserowlabel
                     ROW 60
                     COL 50
                     VALUE "From Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX ellipserow1
                     ROW 60
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL fromellipsecollabel
                     ROW 60
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX ellipsecol1
                     ROW 60
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL toellipserowlabel
                     ROW 90
                     COL 50
                     VALUE "TO Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX ellipserow2
                     ROW 90
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL toellipsecollabel
                     ROW 90
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX ellipsecol2
                     ROW 90
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE BUTTON ellipse1
                     ROW 90
                     COL 410
                     CAPTION "Draw"
                     ACTION drawellipse1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Arc"
                  DEFINE LABEL fromarcrowlabel
                     ROW 60
                     COL 50
                     VALUE "From Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX arcrow1
                     ROW 60
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL fromarccollabel
                     ROW 60
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX arccol1
                     ROW 60
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL toarcrowlabel
                     ROW 90
                     COL 50
                     VALUE "TO Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX arcrow2
                     ROW 90
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL toarccollabel
                     ROW 90
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX arccol2
                     ROW 90
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL fromarcrrowlabel
                     ROW 120
                     COL 50
                     VALUE "From Radial"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX arcrow3
                     ROW 120
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL fromarcrcollabel
                     ROW 120
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX arccol3
                     ROW 120
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL toarcrrowlabel
                     ROW 150
                     COL 50
                     VALUE "TO Radial"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX arcrow4
                     ROW 150
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL toarcrcollabel
                     ROW 150
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX arccol4
                     ROW 150
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE BUTTON arc1
                     ROW 150
                     COL 410
                     CAPTION "Draw"
                     ACTION drawarc1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Pie"
                  DEFINE LABEL frompierowlabel
                     ROW 60
                     COL 50
                     VALUE "From Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX pierow1
                     ROW 60
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL frompiecollabel
                     ROW 60
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX piecol1
                     ROW 60
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL topierowlabel
                     ROW 90
                     COL 50
                     VALUE "TO Row"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX pierow2
                     ROW 90
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL topiecollabel
                     ROW 90
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX piecol2
                     ROW 90
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL frompierrowlabel
                     ROW 120
                     COL 50
                     VALUE "From Radial"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX pierow3
                     ROW 120
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL frompiercollabel
                     ROW 120
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX piecol3
                     ROW 120
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL topierrowlabel
                     ROW 150
                     COL 50
                     VALUE "TO Radial"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX pierow4
                     ROW 150
                     COL 150
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE LABEL topiercollabel
                     ROW 150
                     COL 210
                     VALUE "Col"
                     WIDTH 90
                  END LABEL
                  DEFINE TEXTBOX piecol4
                     ROW 150
                     COL 310
                     VALUE 50
                     WIDTH 50
                     NUMERIC .t.
                     RIGHTALIGN .t.
                  END TEXTBOX
                  DEFINE BUTTON pie1
                     ROW 150
                     COL 410
                     CAPTION "Draw"
                     ACTION drawpie1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Colours"
                  DEFINE LABEL pencolorlabel
                     ROW 60
                     COL 30
                     VALUE "Pen Color"
                  END LABEL
                  DEFINE LABEL penrlabel
                     ROW 60
                     COL 100
                     VALUE "Red"
                     WIDTH 50
                  END LABEL
                  DEFINE TEXTBOX penr
                     ROW 60
                     COL 160
                     VALUE 0
                     NUMERIC .t.
                     RIGHTALIGN .t.
                     WIDTH 40
                  END TEXTBOX
                  DEFINE LABEL penglabel
                     ROW 60
                     COL 200
                     VALUE "Green"
                     WIDTH 50
                  END LABEL
                  DEFINE TEXTBOX peng
                     ROW 60
                     COL 260
                     VALUE 0
                     NUMERIC .t.
                     RIGHTALIGN .t.
                     WIDTH 40
                  END TEXTBOX
                  DEFINE LABEL penblabel
                     ROW 60
                     COL 300
                     VALUE "Blue"
                     WIDTH 50
                  END LABEL
                  DEFINE TEXTBOX penb
                     ROW 60
                     COL 360
                     VALUE 0
                     NUMERIC .t.
                     RIGHTALIGN .t.
                     WIDTH 40
                  END TEXTBOX
                  DEFINE LABEL penwidthlabel
                     ROW 60
                     COL 400
                     VALUE "Width"
                     WIDTH 50
                  END LABEL
                  DEFINE TEXTBOX penwidth
                     ROW 60
                     COL 460
                     VALUE 5
                     NUMERIC .t.
                     RIGHTALIGN .t.
                     WIDTH 40
                  END TEXTBOX
                  DEFINE LABEL fillcolorlabel
                     ROW 90
                     COL 30
                     VALUE "Fill Color"
                  END LABEL
                  DEFINE LABEL fillrlabel
                     ROW 90
                     COL 100
                     VALUE "Red"
                     WIDTH 50
                  END LABEL
                  DEFINE TEXTBOX fillr
                     ROW 90
                     COL 160
                     VALUE 255
                     NUMERIC .t.
                     RIGHTALIGN .t.
                     WIDTH 40
                  END TEXTBOX
                  DEFINE LABEL fillglabel
                     ROW 90
                     COL 200
                     VALUE "Green"
                     WIDTH 50
                  END LABEL
                  DEFINE TEXTBOX fillg
                     ROW 90
                     COL 260
                     VALUE 255
                     NUMERIC .t.
                     RIGHTALIGN .t.
                     WIDTH 40
                  END TEXTBOX
                  DEFINE LABEL fillblabel
                     ROW 90
                     COL 300
                     VALUE "Blue"
                     WIDTH 50
                  END LABEL
                  DEFINE TEXTBOX fillb
                     ROW 90
                     COL 360
                     VALUE 0
                     NUMERIC .t.
                     RIGHTALIGN .t.
                     WIDTH 40
                  END TEXTBOX
               END PAGE
            END TAB
         END WINDOW
      END SPLITBOX
   END WINDOW
   x.center
   x.activate

   RETURN NIL

FUNCTION drawline1

   DRAW LINE in window y at z.linerow1.value,z.linecol1.value to z.linerow2.value,z.linecol2.value pencolor {z.penr.value,z.peng.value,z.penb.value} penwidth z.penwidth.value

   RETURN NIL

FUNCTION drawrect1

   draw rectangle in window y at z.rectrow1.value,z.rectcol1.value to z.rectrow2.value,z.rectcol2.value pencolor {z.penr.value,z.peng.value,z.penb.value} penwidth z.penwidth.value fillcolor {z.fillr.value,z.fillg.value,z.fillb.value}

   RETURN NIL

FUNCTION drawroundrect1

   draw roundrectangle in window y at z.roundrectrow1.value,z.roundrectcol1.value to z.roundrectrow2.value,z.roundrectcol2.value roundwidth z.roundrectwidth.value roundheight z.roundrectheight.value pencolor {z.penr.value,z.peng.value,z.penb.value} penwidth z.penwidth.value fillcolor {z.fillr.value,z.fillg.value,z.fillb.value}

   RETURN NIL

FUNCTION drawellipse1

   draw ellipse in window y at z.ellipserow1.value,z.ellipsecol1.value to z.ellipserow2.value,z.ellipsecol2.value pencolor {z.penr.value,z.peng.value,z.penb.value} penwidth z.penwidth.value fillcolor {z.fillr.value,z.fillg.value,z.fillb.value}

   RETURN NIL

FUNCTION drawarc1

   draw arc in window y at z.arcrow1.value,z.arccol1.value to z.arcrow2.value,z.arccol2.value from radial z.arcrow3.value,z.arccol3.value to radial z.arcrow4.value,z.arccol4.value pencolor {z.penr.value,z.peng.value,z.penb.value} penwidth z.penwidth.value

   RETURN NIL

FUNCTION drawpie1

   draw pie in window y at z.pierow1.value,z.piecol1.value to z.pierow2.value,z.piecol2.value from radial z.pierow3.value,z.piecol3.value to radial z.pierow4.value,z.piecol4.value pencolor {z.penr.value,z.peng.value,z.penb.value} penwidth z.penwidth.value fillcolor {z.fillr.value,z.fillg.value,z.fillb.value}

   RETURN NIL

FUNCTION EraseAll()

   ERASE WINDOW Y

   RETURN NIL
