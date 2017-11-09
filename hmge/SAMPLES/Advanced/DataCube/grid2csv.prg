# include "minigui.ch"

FUNCTION grid2csv(windowname,gridname,lheader)

   LOCAL filename := ""
   LOCAL adata := {}
   LOCAL lines := 0
   LOCAL i, count2
   LOCAL aeditcontrols := {}
   LOCAL count1 := 0
   LOCAL linedata := {}
   LOCAL xres, aec, aitems
   LOCAL cdata := ""
   LOCAL aclinedata := {}
   LOCAL fhandle := 0
   LOCAL linebreak := chr(13)
   LOCAL aline := {}
   LOCAL cline := ''
   LOCAL ncolumns := 0

   DEFAULT lheader := .f.

   filename :=  PutFile ( {{"Comma Separated Value Files (*.csv)","*.csv"}} , "Export to text file (CSV)" ,  , .f. )
   IF len(alltrim(filename)) == 0

      RETURN NIL
   ENDIF

   IF at(".csv",lower(filename)) > 0
      IF .not. right(lower(filename),4) == ".csv"
         filename := filename + ".csv"
      ENDIF
   ELSE
      filename := filename + ".csv"
   ENDIF

   IF file(filename)
      IF .not. msgyesno("Are you sure to overwrite?","Export to text file (CSV)")

         RETURN NIL
      ENDIF
   ENDIF

   fhandle := fcreate(filename)
   IF fhandle < 0
      msgstop("File "+filename+" could not be created!")

      RETURN NIL
   ENDIF

   lines := getproperty(windowname,gridname,"itemcount")
   IF lines == 0
      msginfo("No rows to save!")

      RETURN NIL
   ENDIF

   i := GetControlIndex ( gridname , windowname )

   aEditcontrols := _HMG_aControlMiscData1 [i] [13]

   IF lheader
      asize(aclinedata,0)
      ncolumns := len(getproperty(windowname,gridname,"item",1))
      FOR count1 := 1 to ncolumns
         cdata := getproperty(windowname,gridname,"header",count1)
         aadd(aclinedata,cdata)
      NEXT count1
      aadd(adata,aclone(aclinedata))
   ENDIF

   FOR count1 := 1 to lines
      linedata := getproperty(windowname,gridname,"item",count1)
      asize(aclinedata,0)
      FOR count2 := 1 to len(linedata)
         DO CASE
         CASE ValType(linedata[count2]) == "N"
            xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
            AEC := XRES [1]
            AITEMS := XRES [5]
            IF AEC == 'COMBOBOX'
               cdata := aitems[linedata[count2]]
            ELSE
               cdata := LTrim( Str( linedata[count2] ) )
            ENDIF
         CASE ValType(linedata[count2]) == "D"
            cdata := dtoc( linedata[count2])
         CASE ValType(linedata[count2]) == "L"
            xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
            AEC := XRES [1]
            AITEMS := XRES [8]
            IF AEC == 'CHECKBOX'
               cdata := iif(linedata[count2],aitems[1],aitems[2])
            ELSE
               cdata := iif(linedata[count2],"TRUE","FALSE")
            ENDIF
         OTHERWISE
            cdata := linedata[count2]
         ENDCASE
         aadd(aclinedata,cdata)
      NEXT count2
      aadd(adata,aclone(aclinedata))
   NEXT count1
   FOR count1 := 1 to len(adata)
      cline := ''
      aline := adata[count1]
      FOR count2 := 1 to len(aline)
         cline := cline + '"' + _parsequote(aline[count2]) + '"'
         IF .not. count2 == len(aline)
            cline := cline + ','
         ENDIF
      NEXT count2
      cline := cline + linebreak
      fwrite(fhandle,cline)
   NEXT count1
   IF fclose(fhandle)
      msginfo("Exported Successfully!")
   ELSE
      msgstop("Error in saving!")
   ENDIF

   RETURN NIL

FUNCTION _parsequote(cdata)

   LOCAL i := 0
   LOCAL cout := ""

   FOR i := 1 to len(cdata)
      IF substr(cdata,i,1) == '"'
         cout := cout + substr(cdata,i,1) + '"'
      ELSE
         cout := cout + substr(cdata,i,1)
      ENDIF
   NEXT i

   RETURN cout
