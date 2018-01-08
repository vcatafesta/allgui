#include <minigui.ch>

MEMVAR backcolor
MEMVAR akalai
MEMVAR x
MEMVAR y

FUNCTION main

   LOCAL showinterval := 2000
   PRIVATE backcolor := {0,0,0}
   PRIVATE akalai := {}
   PRIVATE x := 250 // xcenter
   PRIVATE y := 250 // ycenter

   DEFINE WINDOW k at 0,0 width 650 height 530 title "Kaleidoscope - 3D v.1.1 by S. Rathinagiri" main icon "kalai" nomaximize nosize on init drawkalai()
      define timer timer1 interval showinterval action (drawkalai(),iif(iswindowactive(s),drawstereowindow(),))

      DEFINE LABEL iterationslabel
         ROW 10
         COL 510
         value "Iterations"
         WIDTH 80
      END LABEL
      DEFINE SPINNER iterations
         ROW 10
         COL 590
         WIDTH 50
         rangemin 1
         rangemax 999
         value 3
      END spinner
      DEFINE FRAME shapes
         ROW 40
         COL 505
         WIDTH 135
         HEIGHT 200
         caption "Shapes"
      END FRAME
      DEFINE CHECKBOX triangles
         ROW 60
         COL 510
         WIDTH 120
         caption "Triangles"
      END CHECKBOX
      DEFINE CHECKBOX circles
         ROW 90
         COL 510
         WIDTH 120
         caption "Circles"
      END CHECKBOX
      DEFINE CHECKBOX rectangles
         ROW 120
         COL 510
         WIDTH 120
         caption "Rectangles"
      END CHECKBOX
      DEFINE CHECKBOX ellipses
         ROW 150
         COL 510
         WIDTH 120
         caption "Ellipses"
      END CHECKBOX
      DEFINE CHECKBOX squares
         ROW 180
         COL 510
         WIDTH 120
         caption "Squares"
      END CHECKBOX
      DEFINE CHECKBOX polygons
         ROW 210
         COL 510
         WIDTH 120
         caption "Polygons"
         value .t.
      END CHECKBOX
      DEFINE BUTTON backcolor
         ROW 250
         COL 510
         WIDTH 130
         caption "Background Colour"
         action  setbackcolor()
      END BUTTON
      DEFINE CHECKBOX show1
         ROW 280
         COL 510
         caption "Slideshow ("+alltrim(str(showinterval/1000,5,0))+" Sec)"
         WIDTH 130
         onchange show1changed()
      END CHECKBOX
      DEFINE BUTTON but1
         ROW 310
         COL 510
         WIDTH 60
         caption "Show"
         action drawkalai()
      END BUTTON
      DEFINE BUTTON save
         ROW 310
         COL 580
         WIDTH 60
         caption "Save"
         action savewindow1()
      END BUTTON
      DEFINE BUTTON showstereo
         ROW 340
         COL 510
         WIDTH 130
         caption "Show Stereo"
         action showstereowindow()
      END BUTTON
      define hyperlink email1
         ROW 400
         COL 510
         value "Algorithm of Cliff"
         WIDTH 130
         handcursor .t.
         address "http://sprott.physics.wisc.edu/pickover/ekscop.html"
      END hyperlink
      define hyperlink email
         ROW 430
         COL 510
         value "E-Mail me"
         WIDTH 130
         handcursor .t.
         address "srgiri@dataone.in"
      END hyperlink
      ON KEY ESCAPE ACTION thiswindow.release()
   END WINDOW
   k.show1.value := .t.
   k.center
   ACTIVATE WINDOW k

   RETURN NIL

FUNCTION drawkalai

   LOCAL aPoints
   LOCAL apoints1
   LOCAL x1,x2,y1,y2,t
   LOCAL i,j := 0,r,g,b,r1
   LOCAL sides

   asize(akalai,0)
   ERASE window k
   IF k.iterations.value < 1

      RETURN NIL
   ENDIF

   drawrect("k",0,0,x*2,y*2,backcolor,,backcolor)

   FOR i = 1 to k.iterations.value

      IF k.triangles.value
         sides := 3
         aPoints := {}
         FOR j := 1 to sides
            x1 := random(x)
            y1 := random(y)
            IF ( x1 > y1 )
               t := x1
               x1 := y1
               y1 := t
            ENDIF
            aadd(apoints,{x1,y1})
         NEXT j
         r := random(255)
         g := random(255)
         b := random(255)
         FOR j := 1 to 8
            apoints1 := flip(aclone(apoints),x,y,j)
            drawpolygon("k",aPoints1,{r,g,b},,{r,g,b})
            aadd(akalai,{aclone(apoints1),{r,g,b},"TRIANGLE"})
         NEXT j
      ENDIF

      IF k.circles.value
         x1 = random(x)
         y1 = random(y)
         r1 := random(min(x-x1,y-y1))
         IF ( x1 > y1 )
            t := x1
            x1 := y1
            y1 := t
         ENDIF
         x2 := x1 + r1
         y2 := y1 + r1
         r := random(255)
         g := random(255)
         b := random(255)
         aPoints := {{x1,y1},{x2,y2}}
         FOR j := 1 to 8
            apoints1 := flip(aclone(apoints),x,y,j)
            drawellipse("k",apoints1[1,1],apoints1[1,2],apoints1[2,1],apoints1[2,2],{r,g,b},,{r,g,b})
            aadd(akalai,{aclone(apoints1),{r,g,b},"CIRCLE"})
         NEXT j
      ENDIF

      IF k.ellipses.value
         sides := 2
         aPoints := {}
         FOR j := 1 to sides
            x1 := random(x)
            y1 := random(y)
            IF ( x1 > y1 )
               t := x1
               x1 := y1
               y1 := t
            ENDIF
            aadd(apoints,{x1,y1})
         NEXT j
         r := random(255)
         g := random(255)
         b := random(255)
         FOR j := 1 to 8
            apoints1 := flip(aclone(apoints),x,y,j)
            drawellipse("k",apoints1[1,1],apoints1[1,2],apoints1[2,1],apoints1[2,2],{r,g,b},,{r,g,b})
            aadd(akalai,{aclone(apoints1),{r,g,b},"ELLIPSE"})
         NEXT j
      ENDIF

      IF k.rectangles.value
         sides := 2
         aPoints := {}
         FOR j := 1 to sides
            x1 := random(x)
            y1 := random(y)
            IF ( x1 > y1 )
               t := x1
               x1 := y1
               y1 := t
            ENDIF
            aadd(apoints,{x1,y1})
         NEXT j
         r := random(255)
         g := random(255)
         b := random(255)

         FOR j := 1 to 8
            apoints1 := flip(aclone(apoints),x,y,j)
            drawrect("k",apoints1[1,1],apoints1[1,2],apoints1[2,1],apoints1[2,2],{r,g,b},,{r,g,b})
            aadd(akalai,{aclone(apoints1),{r,g,b},"RECTANGLE"})
         NEXT j
      ENDIF

      IF k.squares.value
         x1 = random(x)
         y1 = random(y)
         r1 := random(min(x-x1,y-y1))
         IF ( x1 > y1 )
            t := x1
            x1 := y1
            y1 := t
         ENDIF
         x2 := x1 + r1
         y2 := y1 + r1
         r := random(255)
         g := random(255)
         b := random(255)
         aPoints := {{x1,y1},{x2,y2}}
         FOR j := 1 to 8
            apoints1 := flip(aclone(apoints),x,y,j)
            drawrect("k",apoints1[1,1],apoints1[1,2],apoints1[2,1],apoints1[2,2],{r,g,b},,{r,g,b})
            aadd(akalai,{aclone(apoints1),{r,g,b},"SQUARE"})
         NEXT j
      ENDIF

      IF k.polygons.value .or. empty(j)
         IF empty(j)
            k.polygons.value := .t.
         ENDIF
         sides := 4+random(20)
         aPoints := {}
         FOR j := 1 to sides
            x1 := random(x)
            y1 := random(y)
            IF ( x1 > y1 )
               t := x1
               x1 := y1
               y1 := t
            ENDIF
            aadd(apoints,{x1,y1})
         NEXT j
         r := random(255)
         g := random(255)
         b := random(255)
         FOR j := 1 to 8
            apoints1 := flip(aclone(apoints),x,y,j)
            drawpolygon("k",aPoints1,{r,g,b},,{r,g,b})
            aadd(akalai,{aclone(apoints1),{r,g,b},"POLYGON"})
         NEXT j
      ENDIF
   NEXT i

   RETURN NIL

FUNCTION savewindow1

   LOCAL filename

   IF k.show1.value
      k.timer1.enabled := .f.
   ENDIF

   filename := PutFile ( {{"Bitmap Files (*.bmp)","*.bmp"}} , "Save to bitmap file" ,  , .f. )
   IF !empty(filename)
      IF at(".bmp",lower(filename)) > 0
         IF .not. right(lower(filename),4) == ".bmp"
            filename := filename + ".bmp"
         ENDIF
      ELSE
         filename := filename + ".bmp"
      ENDIF

      IF file(filename)
         IF msgyesno("Are you sure to overwrite?","Save to bitmap")
            savewindow("k",filename,0,0,500,500)
         ENDIF
      ELSE
         savewindow("k",filename,0,0,500,500)
      ENDIF
   ENDIF

   IF k.show1.value
      k.timer1.enabled := .t.
   ENDIF

   RETURN NIL

FUNCTION setbackcolor

   BACKCOLOR := getcolor(backcolor)

   RETURN NIL

FUNCTION show1changed

   IF .not. iscontroldefined(timer1,k)

      RETURN NIL
   ENDIF
   IF k.show1.value
      k.timer1.enabled := .t.
   ELSE
      k.timer1.enabled := .f.
   ENDIF

   RETURN NIL

FUNCTION showstereowindow

   IF .not. iswindowdefined(s)
      DEFINE WINDOW s at 0,0 width 1100 height 580 title "Stereo Window" modal nosize backcolor {0,0,0} on init drawstereowindow()
         DEFINE BUTTON save1
            ROW 520
            COL 10
            WIDTH 50
            caption "Save"
            action savestereowindow1()
         END BUTTON
         DEFINE BUTTON close1
            ROW 520
            COL 70
            WIDTH 50
            caption "Close"
            action s.release()
         END BUTTON

         ON KEY ESCAPE ACTION thiswindow.release()
      END WINDOW
      s.center
      s.activate
   ELSE
      drawstereowindow()
   ENDIF

   RETURN NIL

FUNCTION drawstereowindow

   LOCAL stereobase := 30
   LOCAL sdiff, i
   LOCAL alpoints1
   LOCAL arpoints1

   IF len(akalai) == 0

      RETURN NIL
   ENDIF
   sdiff := stereobase /len(akalai) * 8

   ERASE window s
   drawrect("s",0,0,500,1030,backcolor,,backcolor)

   FOR i := 1 to len(akalai)

      alpoints1 := converttolpoints(aclone(akalai[i,1]),stereobase,sdiff*int((i-1)/8))
      arpoints1 := converttorpoints(aclone(akalai[i,1]),stereobase)

      DO CASE
      CASE akalai[i,3] == "TRIANGLE" .or. akalai[i,3] == "POLYGON"
         drawpolygon("s",alPoints1,akalai[i,2],,akalai[i,2])
         drawpolygon("s",arPoints1,akalai[i,2],,akalai[i,2])
      CASE akalai[i,3] == "CIRCLE" .or. akalai[i,3] == "ELLIPSE"
         drawellipse("s",alpoints1[1,1],alpoints1[1,2],alpoints1[2,1],alpoints1[2,2],akalai[i,2],,akalai[i,2])
         drawellipse("s",arpoints1[1,1],arpoints1[1,2],arpoints1[2,1],arpoints1[2,2],akalai[i,2],,akalai[i,2])
      CASE akalai[i,3] == "RECTANGLE" .or. akalai[i,3] == "SQUARE"
         drawrect("s",alpoints1[1,1],alpoints1[1,2],alpoints1[2,1],alpoints1[2,2],akalai[i,2],,akalai[i,2])
         drawrect("s",arpoints1[1,1],arpoints1[1,2],arpoints1[2,1],arpoints1[2,2],akalai[i,2],,akalai[i,2])
      ENDCASE

   NEXT i

   RETURN NIL

FUNCTION converttolpoints(apoints,stereobase,sdiff)

   LOCAL alpoints := aclone(apoints)
   LOCAL i

   FOR i := 1 to len(alpoints)
      alpoints[i,2] := alpoints[i,2] + stereobase - sdiff
   NEXT i

   RETURN alpoints

FUNCTION converttorpoints(apoints,stereobase)

   LOCAL arpoints := aclone(apoints)
   LOCAL i

   FOR i := 1 to len(arpoints)
      arpoints[i,2] := arpoints[i,2] + (2*y) + stereobase
   NEXT i

   RETURN arpoints

FUNCTION savestereowindow1

   LOCAL filename

   IF k.show1.value
      k.timer1.enabled := .f.
   ENDIF

   filename := PutFile ( {{"Bitmap Files (*.bmp)","*.bmp"}} , "Save to bitmap file" ,  , .f. )
   IF !empty(filename)
      IF at(".bmp",lower(filename)) > 0
         IF .not. right(lower(filename),4) == ".bmp"
            filename := filename + ".bmp"
         ENDIF
      ELSE
         filename := filename + ".bmp"
      ENDIF

      IF file(filename)
         IF msgyesno("Are you sure to overwrite?","Save to bitmap")
            savewindow("s",filename,0,0,1030,500)
         ENDIF
      ELSE
         savewindow("s",filename,0,0,1030,500)
      ENDIF
   ENDIF

   IF k.show1.value
      k.timer1.enabled := .t.
   ENDIF

   RETURN NIL

FUNCTION flip(apoints,nx,ny,i)

   LOCAL aout := {}
   LOCAL j
   LOCAL x1 := 0
   LOCAL y1 := 0
   LOCAL xj
   LOCAL yj

   FOR j := 1 to len(apoints)
      xj := apoints[j,1]
      yj := apoints[j,2]
      DO CASE
      CASE i == 1
         x1 := nx + xj
         y1 := ny + yj
      CASE i == 2
         x1 := nx + xj
         y1 := ny - yj
      CASE i == 3
         x1 := nx - xj
         y1 := ny + yj
      CASE i == 4
         x1 := nx - xj
         y1 := ny - yj
      CASE i == 5
         x1 := ny + yj
         y1 := nx + xj
      CASE i == 6
         x1 := ny + yj
         y1 := nx - xj
      CASE i == 7
         x1 := ny - yj
         y1 := nx + xj
      CASE i == 8
         x1 := ny - yj
         y1 := nx - xj
      ENDCASE
      aadd(aout,{x1,y1})
   NEXT j

   RETURN aclone(aout)

FUNCTION SAVEWINDOW ( cWindowName , cFileName , nRow , nCol , nWidth , nHeight )

   LOCAL ntop , nleft , nbottom , nright

   IF valtype ( cFileName ) = 'U'
      cFileName := GetStartupFolder() + "\" + cWindowName + '.bmp'
   ENDIF

   IF   valtype ( nRow ) = 'U' ;
         .or. ;
         valtype ( nCol ) = 'U' ;
         .or. ;
         valtype ( nWidth ) = 'U' ;
         .or. ;
         valtype ( nHeight ) = 'U'

      ntop   := -1
      nleft   := -1
      nbottom   := -1
      nright   := -1

   ELSE

      ntop   := nRow
      nleft   := nCol
      nbottom   := nHeight + nRow
      nright   := nWidth + nCol

   ENDIF

   SAVEWINDOWBYHANDLE ( GetFormHandle ( cWindowName ) , cFileName , ntop , nleft , nbottom , nright )

   RETURN NIL
