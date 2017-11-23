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
                     row 60
                     col 50
                     value "From Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX linerow1
                     row 60
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL fromlinecollabel
                     row 60
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX linecol1
                     row 60
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL tolinerowlabel
                     row 90
                     col 50
                     value "TO Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX linerow2
                     row 90
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL tolinecollabel
                     row 90
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX linecol2
                     row 90
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE BUTTON line1
                     row 90
                     col 410
                     caption "Draw"
                     action drawline1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Rectangle"
                  DEFINE LABEL fromrectrowlabel
                     row 60
                     col 50
                     value "From Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX rectrow1
                     row 60
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL fromrectcollabel
                     row 60
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX rectcol1
                     row 60
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL torectrowlabel
                     row 90
                     col 50
                     value "TO Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX rectrow2
                     row 90
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL torectcollabel
                     row 90
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX rectcol2
                     row 90
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE BUTTON rect1
                     row 90
                     col 410
                     caption "Draw"
                     action drawrect1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Rounded Rectangle"
                  DEFINE LABEL fromroundrectrowlabel
                     row 60
                     col 50
                     value "From Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX roundrectrow1
                     row 60
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL fromroundrectcollabel
                     row 60
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX roundrectcol1
                     row 60
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL roundrectwidthlabel
                     row 60
                     col 410
                     value "Width"
                     width 60
                  END LABEL
                  DEFINE TEXTBOX roundrectwidth
                     row 60
                     col 470
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL toroundrectrowlabel
                     row 90
                     col 50
                     value "TO Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX roundrectrow2
                     row 90
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL toroundrectcollabel
                     row 90
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX roundrectcol2
                     row 90
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL roundrectheightlabel
                     row 90
                     col 410
                     value "Height"
                     width 60
                  END LABEL
                  DEFINE TEXTBOX roundrectheight
                     row 90
                     col 470
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE BUTTON roundrect1
                     row 140
                     col 350
                     caption "Draw"
                     action drawroundrect1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Ellipse"
                  DEFINE LABEL fromellipserowlabel
                     row 60
                     col 50
                     value "From Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX ellipserow1
                     row 60
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL fromellipsecollabel
                     row 60
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX ellipsecol1
                     row 60
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL toellipserowlabel
                     row 90
                     col 50
                     value "TO Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX ellipserow2
                     row 90
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL toellipsecollabel
                     row 90
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX ellipsecol2
                     row 90
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE BUTTON ellipse1
                     row 90
                     col 410
                     caption "Draw"
                     action drawellipse1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Arc"
                  DEFINE LABEL fromarcrowlabel
                     row 60
                     col 50
                     value "From Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX arcrow1
                     row 60
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL fromarccollabel
                     row 60
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX arccol1
                     row 60
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL toarcrowlabel
                     row 90
                     col 50
                     value "TO Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX arcrow2
                     row 90
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL toarccollabel
                     row 90
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX arccol2
                     row 90
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL fromarcrrowlabel
                     row 120
                     col 50
                     value "From Radial"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX arcrow3
                     row 120
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL fromarcrcollabel
                     row 120
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX arccol3
                     row 120
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL toarcrrowlabel
                     row 150
                     col 50
                     value "TO Radial"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX arcrow4
                     row 150
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL toarcrcollabel
                     row 150
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX arccol4
                     row 150
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE BUTTON arc1
                     row 150
                     col 410
                     caption "Draw"
                     action drawarc1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Pie"
                  DEFINE LABEL frompierowlabel
                     row 60
                     col 50
                     value "From Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX pierow1
                     row 60
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL frompiecollabel
                     row 60
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX piecol1
                     row 60
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL topierowlabel
                     row 90
                     col 50
                     value "TO Row"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX pierow2
                     row 90
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL topiecollabel
                     row 90
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX piecol2
                     row 90
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL frompierrowlabel
                     row 120
                     col 50
                     value "From Radial"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX pierow3
                     row 120
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL frompiercollabel
                     row 120
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX piecol3
                     row 120
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL topierrowlabel
                     row 150
                     col 50
                     value "TO Radial"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX pierow4
                     row 150
                     col 150
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE LABEL topiercollabel
                     row 150
                     col 210
                     value "Col"
                     width 90
                  END LABEL
                  DEFINE TEXTBOX piecol4
                     row 150
                     col 310
                     value 50
                     width 50
                     numeric .t.
                     rightalign .t.
                  END TEXTBOX
                  DEFINE BUTTON pie1
                     row 150
                     col 410
                     caption "Draw"
                     action drawpie1()
                  END BUTTON
               END PAGE
               DEFINE PAGE "Colours"
                  DEFINE LABEL pencolorlabel
                     row 60
                     col 30
                     value "Pen Color"
                  END LABEL
                  DEFINE LABEL penrlabel
                     row 60
                     col 100
                     value "Red"
                     width 50
                  END LABEL
                  DEFINE TEXTBOX penr
                     row 60
                     col 160
                     value 0
                     numeric .t.
                     rightalign .t.
                     width 40
                  END TEXTBOX
                  DEFINE LABEL penglabel
                     row 60
                     col 200
                     value "Green"
                     width 50
                  END LABEL
                  DEFINE TEXTBOX peng
                     row 60
                     col 260
                     value 0
                     numeric .t.
                     rightalign .t.
                     width 40
                  END TEXTBOX
                  DEFINE LABEL penblabel
                     row 60
                     col 300
                     value "Blue"
                     width 50
                  END LABEL
                  DEFINE TEXTBOX penb
                     row 60
                     col 360
                     value 0
                     numeric .t.
                     rightalign .t.
                     width 40
                  END TEXTBOX
                  DEFINE LABEL penwidthlabel
                     row 60
                     col 400
                     value "Width"
                     width 50
                  END LABEL
                  DEFINE TEXTBOX penwidth
                     row 60
                     col 460
                     value 5
                     numeric .t.
                     rightalign .t.
                     width 40
                  END TEXTBOX
                  DEFINE LABEL fillcolorlabel
                     row 90
                     col 30
                     value "Fill Color"
                  END LABEL
                  DEFINE LABEL fillrlabel
                     row 90
                     col 100
                     value "Red"
                     width 50
                  END LABEL
                  DEFINE TEXTBOX fillr
                     row 90
                     col 160
                     value 255
                     numeric .t.
                     rightalign .t.
                     width 40
                  END TEXTBOX
                  DEFINE LABEL fillglabel
                     row 90
                     col 200
                     value "Green"
                     width 50
                  END LABEL
                  DEFINE TEXTBOX fillg
                     row 90
                     col 260
                     value 255
                     numeric .t.
                     rightalign .t.
                     width 40
                  END TEXTBOX
                  DEFINE LABEL fillblabel
                     row 90
                     col 300
                     value "Blue"
                     width 50
                  END LABEL
                  DEFINE TEXTBOX fillb
                     row 90
                     col 360
                     value 0
                     numeric .t.
                     rightalign .t.
                     width 40
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
