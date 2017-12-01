/*******************************************************************************
Filename         : Indici.prg

Created         : 05 April 2012 (10:50:55)
Created by      : Pierpaolo Martinello

Last Updated      : 01/06/2013 15:39:30
Updated by      : Pierpaolo

Comments         : Freeware
*******************************************************************************/

PROCEDURE Opentable()

   LOCAL aarq, dbd :="."+right(oFatt:Dbf_driver,3), error :=.f. , lf:={}
   LOCAL archivio := oFatt:DataPath+"Presa.DbF"
   LOCAL aMsg := {"Archive Bookings unavailable try again?"," Archivio Prenotazioni non disponibile Riprovo?"} [alng]

   CLEAN MEMORY

   IF ! ISDIRECTORY(ofatt:DataPath)
      Createfolder(oFatt:DataPath)
      MSGT(1.5,[Cartella Dati creata!],,.t.)
   ENDIF
   Archivio:= oFatt:DataPath+'Presa.DbF'

   IF ! File(Archivio)
      aarq := {}
      Aadd( aarq ,  {'RESOURCE  ','C',1, 0} )
      Aadd( aarq ,  {'DATA_IN   ','D',8, 0} )
      Aadd( aarq ,  {'DATA_OUT  ','D',8, 0} )
      Aadd( aarq ,  {'TIME_IN   ','C',5, 0} )
      Aadd( aarq ,  {'TIME_OUT  ','C',5, 0} )
      Aadd( aarq ,  {'DELAY     ','N',3, 0} )
      Aadd( aarq ,  {'MOTIVO    ','C',60,0} )
      Aadd( aarq ,  {'DA        ','C',30,0} )
      Aadd( aarq ,  {'IN_DATA   ','D',8, 0} )
      Aadd( aarq ,  {'DATA_CANC ','D',8, 0} )
      Aadd( aarq ,  {'OLD_USER  ','C',30,0} )

      DbCreate((Archivio), aarq, oFatt:Dbf_driver)
      MSGT(1.5,[Archivio Prenotazioni creato!],,.t.)

      aarq:={}
   ENDIF
   dbSelectArea( "1" )
   IF net_use( Archivio,"PRESA",.t.,2,.F.,aMsg )
      //  msgbox("indicizzo",alias())
      Lf := directory(oFatt:DataPath+"Maint*.txt","H")
      IF len(lf) > 0
         aeval(lf,{|x| deletefile(oFatt:DataPath+x[1])} )
      ENDIF

      IF ofatt:pack
         PACK
      ENDIF
      INDEX ON dtos(PRESA->DATA_IN)+PRESA->RESOURCE+PRESA->TIME_IN to Presa
      dbcloseall()
   ENDIF

   dbSelectArea( "1" )
   Apridb({"PRESA","1"},Archivio,.F.,2,.F.,aMsg ;
      ,{"Presa",{"Presa"}},1,.F.,.t.) // error)

   RETURN
   /*
   */

FUNCTION Apridb(warea,dbfile,modo,tries,interattivo,msg,indice,ordine,error,cl_Msg)

   //Net_use( file, ali, ex_use, tries, interactive, YNmessage )
   LOCAL dbd := "."+right(oFatt:Dbf_driver,3), abag := indice[2], rtv := .T.

   DEFAULT msg to " Archivio "+warea[1]+" non disponibile Riprovo?"
   DEFAULT tries to 5, modo to .F., interattivo to .T., error to .F.,cl_Msg to ''
   dbSelectArea( warea[2] )

   IF net_use( Dbfile, warea[1], .f., tries, interattivo, msg ) .and. !error
      IF !.F. ; ordListClear() ; end
         IF dbd == ".NTX"
            aeval(abag,{|x| ordListAdd( oFatt:DataPath+x )})
         ELSE   // CDX
            IF indice[1] # NIL .or. !Empty(indice[1])
               ordListAdd( oFatt:DataPath+indice[1])
            ENDIF
         ENDIF
         ordSetFocus( ordine )
         GO TOP
      ELSE
         IF (empty(Cl_Msg),ChiudiPrg(.T.),ErrTipo(Cl_Msg,alias()) )
            rtv := .F.
         ENDIF

         RETURN rtv
         /*
         */

FUNCTION ErrTipo( dove ,label)

   LOCAL aMsg:={ dove+CRLF+[Repeat the rebuilding indexes]+CRLF+[as the only active user!];
      ,dove+CRLF+[Ripetere la ricostruzione indici]+CRLF+[come unico utente attivo!]} [alng]
   DEFAULT label to  ''
   msgExclamation( aMsg,label)

   RETURN .T.
   /*
   */
