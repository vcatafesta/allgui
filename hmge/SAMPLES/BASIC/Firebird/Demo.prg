/*
* Access a firebird database through ODBC
* Based on ODBC_2 sample included in MiniGui Extended distribution
* Hugo Rozas M.
* HMG Extended v1.9.98
*/

#include 'minigui.ch'
#include "miniprint.ch"

MEMVAR TitlePrint

STATIC oConnection

PROCEDURE start

   SET NAVIGATION EXTENDED

   oConnection = todbc():new('DRIVER=Firebird/InterBase(r) driver;UID=SYSDBA;PWD=masterkey;DBNAME=EMPLOYEE.FDB;')
   oConnection:Open()

   DEFINE WINDOW form1;
         at 0,0 width 400 height 400 title 'Demo Odbc/Firebird';
         Main;
         ON INIT ( adjust(), load_data(1) );
         on maximize ( adjust() );
         on size ( adjust() );
         ON RELEASE ( oConnection:Destroy() );
         font 'ms sans serif' size 8

      @ 0,  0 button btn1 caption '&Add'    width 55 height 20 action events_(1)
      @ 0, 60 button btn2 caption '&Edit'    width 55 height 20 action events_(2)
      @ 0,120 button btn3 caption '&Delete'    width 55 height 20 action events_(3)
      @ 0,180 button btn4 caption '&Print'    width 55 height 20 action Print_List()
      @ 0,240 button btn5 caption '&Reload'    width 55 height 20 action load_data(1)
      @ 0,300 button btn6 caption '&Quit'    width 55 height 20 action form1.release

      DEFINE GRID grid1
         ROW 22
         COL 5
         WIDTH 300
         HEIGHT 300
         HEADERS {'Id','First Name','Last Name','Salary'}
         WIDTHS { 50, 80,110,115 }
         JUSTIFY {BROWSE_JTFY_RIGHT,BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT,BROWSE_JTFY_RIGHT}
         on dblclick    events_(2)
         ON CHANGE    form1.statusbar.item(1) := "Register "+;
            ltrim(str(form1.grid1.value))+" of "+alltrim(str(form1.grid1.itemcount))
         COLUMNCONTROLS   { ;
            {'TEXTBOX','NUMERIC'} , ;
            {'TEXTBOX','CHARACTER'}, ;
            {'TEXTBOX','CHARACTER'}, ;
            {'TEXTBOX','NUMERIC'} ;
            }
      END GRID

      DEFINE STATUSBAR
         statusitem "Register "
         date
      END STATUSBAR
   END WINDOW
   form1.center
   ACTIVATE WINDOW form1

   RETURN

PROCEDURE load_data(n)

   LOCAL i

   form1.grid1.Deleteallitems

   oConnection:Setsql('SELECT * FROM Employee ORDER BY Emp_No')

   IF !oConnection:Open()
      msgstop("Can't connect to database")
   ELSE
      FOR i= 1 to len( oConnection:aRecordset )
         form1.grid1.additem( oConnection:aRecordset[i] )
      NEXT
      form1.grid1.value := n
   END

   oConnection:Close()
   form1.grid1.setfocus

   RETURN

PROCEDURE events_(n)

   LOCAL cL_Name := "",cSalary := "",cF_Name := "", cID := "", Str

   DO CASE
   CASE n == 1 .or. n == 2
      IF n = 2
         cID     := form1.grid1.cell( form1.grid1.value, 1 )
         cF_Name := form1.grid1.cell( form1.grid1.value, 2 )
         cL_Name := form1.grid1.cell( form1.grid1.value, 3 )
         cSalary := form1.grid1.cell( form1.grid1.value, 4 )
      END
      DEFINE WINDOW form1a;
            at 0,0 width 270 height 220;
            TITLE iif(n = 2,'Edit','Add');
            modal;
            font 'ms sans serif' size 8

         @ 10, 10 label label1 width 60 height 20 value 'ID' RIGHTALIGN
         @ 40, 10 label label2 width 60 height 20 value 'First Name' RIGHTALIGN
         @ 70, 10 label label3 width 60 height 20 value 'Last Name' RIGHTALIGN
         @ 100,10 label label4 width 60 height 20 value 'Salary' RIGHTALIGN
         @ 10,80 textbox text1 width 40  height 20 value cID READONLY NUMERIC INPUTMASK '99999' NOTABSTOP
         @ 40,80 textbox text2 width 100 height 20 value cF_Name MaxLength 15
         @ 70,80 textbox text3 width 170 height 20 value cL_Name MaxLength 25
         @ 100,80 textbox text4 width 90 height 20 value cSalary NUMERIC INPUTMASK '9999999999.99'
         @ 150,60 button button1 caption '&Save' action save_data( n ) width 80 height 20
         @ 150,150 button button2 caption '&Close' action form1a.release width 80 height 20

         ON KEY ESCAPE ACTION form1a.button2.onclick
      END WINDOW
      form1a.center
      ACTIVATE WINDOW form1a

   CASE n == 3
      Str := "DELETE FROM Employee WHERE Emp_No="+str(form1.grid1.cell(form1.grid1.value,1))
      IF msgyesno('Delete this register? '+hb_osnewline()+form1.grid1.cell(form1.grid1.value,2),'Confirm')
         oConnection:Setsql( Str )
         IF !oConnection:Open()
            msgstop("Can't delete the register")
         ELSE
            n := form1.grid1.value
            form1.grid1.deleteitem( n )
            form1.grid1.value := iif(n > 1, n-1, 1)
            form1.statusbar.item(1) := "Register "+;
               ltrim(str(form1.grid1.value))+" of "+alltrim(str(form1.grid1.itemcount))
         END
         oConnection:Close()
         form1.grid1.setfocus
      END
   ENDCASE
   Form1.Grid1.SetFocus()

   RETURN

PROCEDURE save_data(n)

   LOCAL Str, cID

   IF n = 1
      IF ( form1a.text1.value = 0 )
         cID := "null"
      ELSE
         cID := "'"+Alltrim(Str(form1a.text1.value))+"'"
      END
      Str := "INSERT INTO Employee (EMP_NO,FIRST_NAME,LAST_NAME,SALARY) VALUES ("+cID+;
         ",'"+form1a.text2.value+;
         "','"+form1a.text3.value+;
         "','"+Alltrim(Str(form1a.text4.value))+;
         "')"
      //msgstop( Str )

   ELSE
      cID := "'"+Alltrim(Str(form1a.text1.value))+"'"
      Str := "UPDATE Employee SET FIRST_NAME='"+form1a.text2.value+"',"+;
         " LAST_NAME='"+form1a.text3.value + "'," + ;
         " SALARY='" + Str(form1a.text4.value) + "'" + ;
         " WHERE Emp_No=" + cID
      //msgstop( Str )
   END
   oConnection:Setsql( Str )
   IF !oConnection:Open()
      msgstop("Can't update Employee table")
   END
   oConnection:Close()
   IF n == 1
      load_data( form1.grid1.itemcount+1 )
   ELSE
      form1.grid1.cell( form1.grid1.value, 1 ) := form1a.text1.value
      form1.grid1.cell( form1.grid1.value, 2 ) := form1a.text2.value
      form1.grid1.cell( form1.grid1.value, 3 ) := form1a.text3.value
      form1.grid1.cell( form1.grid1.value, 4 ) := form1a.text4.value
   END
   form1.statusbar.item(1) := "Register "+;
      ltrim(str(form1.grid1.value))+" de "+alltrim(str(form1.grid1.itemcount))
   form1a.release

   RETURN

PROCEDURE adjust()

   form1.grid1.width := form1.width - 20
   form1.grid1.height:= ( form1.height- form1.grid1.row ) - 60

   RETURN

PROCEDURE Print_List()

   LOCAL nomimp, PAG, LIN, I
   LOCAL cL_Name,cSalary,cF_Name,cID

   PRIVATE TitlePrint := "Employee List"

   nomimp := GetPrinter()
   SELECT PRINTER nomimp ORIENTATION PRINTER_ORIENT_PORTRAIT PREVIEW

   START PRINTDOC NAME TitlePrint
      START PRINTPAGE

         PAG:=0
         LIN:=0
         FOR I := 1 TO form1.grid1.ItemCount
            cID     := form1.grid1.Cell( I, 1 )
            cF_Name := form1.grid1.Cell( I, 2 )
            cL_Name := form1.grid1.Cell( I, 3 )
            cSalary := form1.grid1.Cell( I, 4 )

            IF LIN>=260 .OR. PAG=0
               IF PAG<>0
                  @ LIN+5,105 PRINT "Continue on Page: "+LTRIM(STR(PAG+1)) CENTER
               END PRINTPAGE
               START PRINTPAGE
               ENDIF
               PAG++

               @ 20,20 PRINT "Business Name"
               @ 20,190 PRINT "Page: "+LTRIM(STR(PAG)) RIGHT
               @ 25,20 PRINT DATE()

               @ 25,105 PRINT "Name of Business" CENTER
               @ 35,105 PRINT TitlePrint FONT "ft18" CENTER

               LIN:=55
               @ LIN+4,20 PRINT LINE TO LIN+4,130
               @ LIN,27 PRINT "ID" RIGHT
               @ LIN,40 PRINT "First Name"
               @ LIN,70 PRINT "Last Name"
               @ LIN,125 PRINT "Salary" RIGHT

               LIN:=LIN+5
            ENDIF

            @ LIN,27 PRINT cID RIGHT
            @ LIN,40 PRINT cF_Name
            @ LIN,70 PRINT cL_Name
            @ LIN,125 PRINT TRANSFORM( cSalary , "9,999,999,999.99" ) RIGHT

            LIN:=LIN+5

         NEXT I

      END PRINTPAGE
   END PRINTDOC

   RETURN
