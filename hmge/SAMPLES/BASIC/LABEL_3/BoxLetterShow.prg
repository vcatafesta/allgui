#include "minigui.ch"

Proc BoxShadowL(CurRowN, CurColN, Nomb, cTexto, nSize, Color1, Color2) //BoxShadowL(100, 50, "02" , " Hola, como estas? ", 10, GREEN , BLACK )

   LOCAL clavel01N := ALLTRIM("Label_") + ALLTRIM(Nomb)
   LOCAL clavel03N := ALLTRIM("Label_") + ALLTRIM(Nomb)+"a"

   DEFINE LABEL &clavel03N
      ROW   CurRowN
      COL   CurColN
      VALUE cTexto
      FONTNAME "Ms Sans Serif"
      FONTSIZE nSize
      TOOLTIP ""
      FONTBOLD .F.
      FONTITALIC .F.
      FONTUNDERLINE .F.
      FONTSTRIKEOUT .F.
      HELPID Nil
      VISIBLE  .T.
      TRANSPARENT .F.
      ACTION Nil
      AUTOSIZE .T.
      BACKCOLOR    Color2
      FONTCOLOR Color2
   END LABEL

   DEFINE LABEL &clavel01N
      ROW    CurRowN  - 6
      COL    CurColN  - 4
      VALUE cTexto
      FONTNAME "ARIAL"
      FONTSIZE nSize
      TOOLTIP ""
      FONTBOLD .F.
      FONTITALIC .F.
      FONTUNDERLINE .F.
      FONTSTRIKEOUT .F.
      HELPID Nil
      VISIBLE  .T.
      TRANSPARENT .F.
      ACTION Nil
      AUTOSIZE .T.
      BACKCOLOR Color1
      FONTCOLOR Color2
      BORDER .F.
      CLIENTEDGE .F.
   END LABEL

   RETURN

   Proc Line(nRow,nCol,nWidth,nHeight,cControl,Color)   // Line(225, 50, 175, 001 ,"05",  WHITE )            or          Line(225, 225, 001, 175 ,"06",  RED )
      LOCAL clavel01 :=   ALLTRIM("Label_") + ALLTRIM(cControl)

      DEFINE LABEL &clavel01
         ROW   nRow
         COL   nCol
         WIDTH  nWidth
         HEIGHT nHeight
         VALUE ""
         FONTNAME "Ms Sans Serif"
         FONTSIZE 11
         TOOLTIP ""
         FONTBOLD .F.
         FONTITALIC .F.
         FONTUNDERLINE .F.
         FONTSTRIKEOUT .F.
         HELPID Nil
         VISIBLE  .T.
         TRANSPARENT .F.
         ACTION Nil
         AUTOSIZE .F.
         BACKCOLOR Color
         FONTCOLOR Nil
         BORDER .F.
         CLIENTEDGE .F.
      END LABEL

      RETURN

      Proc Rectangle(nRow,nCol,nWidth,nHeight,cControl,Color,nType,nWidthG,nWidthD)   // Rectangle(50,300,175,50,"12",BLUE,1,5,1)
         LOCAL clavel01 := ALLTRIM("Label_") + ALLTRIM(cControl)
         LOCAL clavel02 := ALLTRIM("Label_") + ALLTRIM(cControl)+ "a"
         LOCAL clavel03 := ALLTRIM("Label_") + ALLTRIM(cControl)+ "b"
         LOCAL clavel04 := ALLTRIM("Label_") + ALLTRIM(cControl)+ "c"

         LOCAL CurSRow1      := nRow
         LOCAL CurSCol1       := nCol
         LOCAL LastSWidth1    := 0
         LOCAL LastSHeight1    := 0

         LOCAL CurSRow2      := nRow
         LOCAL CurSCol2       := nCol
         LOCAL LastSWidth2     := 0
         LOCAL LastSHeight2    := 0

         LOCAL CurSRow3      := nRow
         LOCAL CurSCol3       := nCol+nWidth
         LOCAL LastSWidth3     := 0
         LOCAL LastSHeight3    := 0

         LOCAL CurSRow4      := nRow+nHeight
         LOCAL CurSCol4       := nCol
         LOCAL LastSWidth4     := 0
         LOCAL LastSHeight4    := 0

         DO CASE
         CASE nType = 1
            LastSWidth1    := nWidth
            LastSHeight1    := nWidthG
            LastSWidth2     := nWidthG
            LastSHeight2    := nHeight
            LastSWidth3     := nWidthG
            LastSHeight3    := nHeight
            LastSWidth4     := nWidth + nWidthG
            LastSHeight4    := nWidthG
         CASE nType = 2
            LastSWidth1    := nWidth
            LastSHeight1    := nWidthD
            LastSWidth2     := nWidthG
            LastSHeight2    := nHeight
            LastSWidth3     := nWidthG
            LastSHeight3    := nHeight
            LastSWidth4     := nWidth + nWidthG
            LastSHeight4    := nWidthD
         CASE nType = 3
            LastSWidth1    := nWidth
            LastSHeight1    := nWidthG
            LastSWidth2     := nWidthD
            LastSHeight2    := nHeight
            LastSWidth3     := nWidthD
            LastSHeight3    := nHeight
            LastSWidth4     := nWidth + nWidthD
            LastSHeight4    := nWidthG
         CASE nType = 4
            LastSWidth1    := nWidth
            LastSHeight1    := nWidthG
            LastSWidth2     := nWidthG
            LastSHeight2    := nHeight
            LastSWidth3     := nWidthD
            LastSHeight3    := nHeight
            LastSWidth4     := nWidth + nWidthD
            LastSHeight4    := nWidthD
         ENDCASE

         DEFINE LABEL &clavel01
            ROW   CurSRow1
            COL   CurSCol1
            WIDTH  LastSWidth1
            HEIGHT LastSHeight1
            VALUE ""
            FONTNAME "Ms Sans Serif"
            FONTSIZE 11
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE  .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR Color
            FONTCOLOR Nil
            BORDER .F.
            CLIENTEDGE .F.
         END LABEL

         DEFINE LABEL &clavel02
            ROW   CurSRow2
            COL   CurSCol2
            WIDTH  LastSWidth2
            HEIGHT LastSHeight2
            VALUE ""
            FONTNAME "Ms Sans Serif"
            FONTSIZE 11
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE  .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR Color
            FONTCOLOR Nil
            BORDER .F.
            CLIENTEDGE .F.
         END LABEL

         DEFINE LABEL &clavel03
            ROW   CurSRow3
            COL   CurSCol3
            WIDTH  LastSWidth3
            HEIGHT LastSHeight3
            VALUE ""
            FONTNAME "Ms Sans Serif"
            FONTSIZE 11
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE  .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR Color
            FONTCOLOR Nil
            BORDER .F.
            CLIENTEDGE .F.
         END LABEL

         DEFINE LABEL &clavel04
            ROW   CurSRow4
            COL   CurSCol4
            WIDTH  LastSWidth4
            HEIGHT LastSHeight4
            VALUE ""
            FONTNAME "Ms Sans Serif"
            FONTSIZE 11
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE  .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR Color
            FONTCOLOR Nil
            BORDER .F.
            CLIENTEDGE .F.
         END LABEL

         RETURN

         Proc MyFrame(nRow,nCol,nWidth,nHeight,cControl,cTexto,Color,ColorBackground)   // MyFrame(300,300,175,50,"16","Mi Frame",BLUE,VERDE)
            LOCAL clavel01 := ALLTRIM("Label_") + ALLTRIM(cControl)
            LOCAL clavel02 := ALLTRIM("Label_") + ALLTRIM(cControl)+ "a"
            LOCAL clavel03 := ALLTRIM("Label_") + ALLTRIM(cControl)+ "b"
            LOCAL clavel04 := ALLTRIM("Label_") + ALLTRIM(cControl)+ "c"
            LOCAL clavel05 := ALLTRIM("Label_") + ALLTRIM(cControl)+ "d"

            LOCAL CurSRow1      := nRow
            LOCAL CurSCol1       := nCol
            LOCAL LastSWidth1    := nWidth
            LOCAL LastSHeight1    := 1

            LOCAL CurSRow2      := nRow
            LOCAL CurSCol2       := nCol
            LOCAL LastSWidth2     := 1
            LOCAL LastSHeight2    := nHeight

            LOCAL CurSRow3      := nRow
            LOCAL CurSCol3       := nCol+nWidth
            LOCAL LastSWidth3     := 1
            LOCAL LastSHeight3    := nHeight

            LOCAL CurSRow4      := nRow+nHeight
            LOCAL CurSCol4       := nCol
            LOCAL LastSWidth4     := nWidth + 1
            LOCAL LastSHeight4    := 1

            DEFINE LABEL &clavel02
               ROW   CurSRow1
               COL   CurSCol1
               WIDTH  LastSWidth1
               HEIGHT LastSHeight1
               VALUE ""
               FONTNAME "Ms Sans Serif"
               FONTSIZE 11
               TOOLTIP ""
               FONTBOLD .F.
               FONTITALIC .F.
               FONTUNDERLINE .F.
               FONTSTRIKEOUT .F.
               HELPID Nil
               VISIBLE  .T.
               TRANSPARENT .F.
               ACTION Nil
               AUTOSIZE .F.
               BACKCOLOR Color
               FONTCOLOR Nil
               BORDER .F.
               CLIENTEDGE .F.
            END LABEL

            DEFINE LABEL &clavel03
               ROW   CurSRow2
               COL   CurSCol2
               WIDTH  LastSWidth2
               HEIGHT LastSHeight2
               VALUE ""
               FONTNAME "Ms Sans Serif"
               FONTSIZE 11
               TOOLTIP ""
               FONTBOLD .F.
               FONTITALIC .F.
               FONTUNDERLINE .F.
               FONTSTRIKEOUT .F.
               HELPID Nil
               VISIBLE  .T.
               TRANSPARENT .F.
               ACTION Nil
               AUTOSIZE .F.
               BACKCOLOR Color
               FONTCOLOR Nil
               BORDER .F.
               CLIENTEDGE .F.
            END LABEL

            DEFINE LABEL &clavel04
               ROW   CurSRow3
               COL   CurSCol3
               WIDTH  LastSWidth3
               HEIGHT LastSHeight3
               VALUE ""
               FONTNAME "Ms Sans Serif"
               FONTSIZE 11
               TOOLTIP ""
               FONTBOLD .F.
               FONTITALIC .F.
               FONTUNDERLINE .F.
               FONTSTRIKEOUT .F.
               HELPID Nil
               VISIBLE  .T.
               TRANSPARENT .F.
               ACTION Nil
               AUTOSIZE .F.
               BACKCOLOR Color
               FONTCOLOR Nil
               BORDER .F.
               CLIENTEDGE .F.
            END LABEL

            DEFINE LABEL &clavel05
               ROW   CurSRow4
               COL   CurSCol4
               WIDTH  LastSWidth4
               HEIGHT LastSHeight4
               VALUE ""
               FONTNAME "Ms Sans Serif"
               FONTSIZE 11
               TOOLTIP ""
               FONTBOLD .F.
               FONTITALIC .F.
               FONTUNDERLINE .F.
               FONTSTRIKEOUT .F.
               HELPID Nil
               VISIBLE  .T.
               TRANSPARENT .F.
               ACTION Nil
               AUTOSIZE .F.
               BACKCOLOR Color
               FONTCOLOR Nil
               BORDER .F.
               CLIENTEDGE .F.
            END LABEL

            DEFINE LABEL &clavel01
               ROW   CurSRow1 - 8
               COL   CurSCol1 + 5
               WIDTH  LastSWidth1
               HEIGHT LastSHeight1
               VALUE cTexto
               FONTNAME "Ms Sans Serif"
               FONTSIZE 11
               TOOLTIP ""
               FONTBOLD .F.
               FONTITALIC .F.
               FONTUNDERLINE .F.
               FONTSTRIKEOUT .F.
               HELPID Nil
               VISIBLE  .T.
               TRANSPARENT .F.
               ACTION Nil
               AUTOSIZE .T.
               BACKCOLOR ColorBackground
               FONTCOLOR Color
               BORDER .F.
               CLIENTEDGE .F.
            END LABEL

            RETURN

            Proc BoxShadow(CurSRow, CurSCol, LastSWidth, LastSHeight , NOSm , ColorBox, ColorShadow , nType ) // BoxShadow( 20, 600, 175, 058 ,"24", BLUE,      , 1 )   // BoxShadow(230, 800, 175, 058 ,"31", BLUE,BLACK , 4 )
               LOCAL Sclavel01 :=   ALLTRIM("Label_") + ALLTRIM(NoSm)
               LOCAL Sclavel02 :=   ALLTRIM("Label_") + ALLTRIM(NoSm)+ "a"
               LOCAL lBorder
               LOCAL lCLIENTEDGE

               DO CASE
               CASE nType = 1
                  lBorder    := .F.
                  lCLIENTEDGE := .F.
               CASE nType = 2
                  lBorder    := .T.
                  lCLIENTEDGE := .F.
               CASE nType = 3
                  lBorder    := .F.
                  lCLIENTEDGE := .T.
               CASE nType = 4
                  lBorder    := .T.
                  lCLIENTEDGE := .T.
               ENDCASE

               IF !Empty(ColorShadow)
                  DEFINE LABEL &Sclavel02
                     ROW   CurSRow+6
                     COL   CurSCol+6
                     WIDTH  LastSWidth
                     HEIGHT LastSHeight
                     BACKCOLOR ColorShadow
                     BORDER .F.
                     CLIENTEDGE .F.
                  END LABEL
               ENDIF

               DEFINE LABEL &Sclavel01
                  ROW   CurSRow
                  COL   CurSCol
                  WIDTH  LastSWidth
                  HEIGHT LastSHeight
                  BACKCOLOR ColorBox
                  BORDER lBorder
                  CLIENTEDGE lCLIENTEDGE
               END LABEL

               RETURN

               Proc LetterShadow(nRow, nCol,cControl , cValue ,SizeL ,Color )    // LetterShadow(400, 300,"17" , "La Casa de la Abuela" ,10 ,BLUE )
                  LOCAL Lclavel01 :=   ALLTRIM("Label_") + ALLTRIM(cControl)
                  LOCAL Lclavel02 :=   ALLTRIM("Label_") + ALLTRIM(cControl)+"a"
                  LOCAL nSep     := 0

                  IF SizeL < 10
                     nSep := .5
                  ELSEIF SizeL < 20
                     nSep := 1
                  ELSEIF SizeL < 30
                     nSep := 1
                  ELSEIF SizeL < 40
                     nSep := 2
                  ELSEIF SizeL < 50
                     nSep := 2.5
                  ELSE
                     nSep := 2.5
                  ENDIF

                  IF SizeL < 50
                     DEFINE LABEL &Lclavel02
                        ROW   nRow
                        COL   nCol
                        VALUE cValue
                        FONTNAME "Arial"
                        FONTSIZE SizeL
                        TOOLTIP ""
                        FONTBOLD .T.
                        FONTITALIC .F.
                        FONTUNDERLINE .F.
                        FONTSTRIKEOUT .F.
                        HELPID Nil
                        VISIBLE .T.
                        TRANSPARENT .T.
                        ACTION Nil
                        AUTOSIZE .T.
                        BACKCOLOR Nil
                        FONTCOLOR BLACK
                     END LABEL

                     DEFINE LABEL &Lclavel01
                        ROW  nRow  - nSep
                        COL  nCol  - nSep
                        VALUE cValue
                        FONTNAME "Arial"
                        FONTSIZE  SizeL
                        TOOLTIP ""
                        FONTBOLD .T.
                        FONTITALIC .F.
                        FONTUNDERLINE .F.
                        FONTSTRIKEOUT .F.
                        HELPID Nil
                        VISIBLE .T.
                        TRANSPARENT .T.
                        ACTION Nil
                        AUTOSIZE .T.
                        BACKCOLOR Nil
                        FONTCOLOR Color
                     END LABEL
                  ELSE
                     DEFINE LABEL &Lclavel01
                        ROW  nRow  - nSep
                        COL  nCol  - nSep
                        VALUE cValue
                        FONTNAME "Arial"
                        FONTSIZE  SizeL
                        TOOLTIP ""
                        FONTBOLD .T.
                        FONTITALIC .F.
                        FONTUNDERLINE .F.
                        FONTSTRIKEOUT .F.
                        HELPID Nil
                        VISIBLE .T.
                        TRANSPARENT .T.
                        ACTION Nil
                        AUTOSIZE .T.
                        BACKCOLOR Nil
                        FONTCOLOR Color
                     END LABEL

                     DEFINE LABEL &Lclavel02
                        ROW   nRow
                        COL   nCol
                        VALUE cValue
                        FONTNAME "Arial"
                        FONTSIZE SizeL
                        TOOLTIP ""
                        FONTBOLD .T.
                        FONTITALIC .F.
                        FONTUNDERLINE .F.
                        FONTSTRIKEOUT .F.
                        HELPID Nil
                        VISIBLE .T.
                        TRANSPARENT .T.
                        ACTION Nil
                        AUTOSIZE .T.
                        BACKCOLOR Nil
                        FONTCOLOR BLACK
                     END LABEL

                  ENDIF

                  RETURN
