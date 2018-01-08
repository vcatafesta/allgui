/*
sistema     : superchef pizzaria
programa    : backup
compilador  : xharbour 1.2 simplex
lib gráfica : minigui 1.7 extended
programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

MEMVAR destino_backup

FUNCTION backup()

   PRIVATE destino_backup

   DEFINE WINDOW form_backup;
         at 000,000;
         WIDTH 400;
         HEIGHT 225;
         TITLE 'Backup do Banco de Dados';
         ICON path_imagens+'icone.ico';
         modal ;
         NOSIZE

      DEFINE BUTTONEX button_backup
         PICTURE path_imagens+'img_zip.bmp'
         COL 060
         ROW 140
         WIDTH 180
         HEIGHT 040
         CAPTION 'Iniciar o Backup'
         ACTION CreateZip()
         FONTNAME 'verdana'
         fontsize 9
         FONTCOLOR _preto_001
      END BUTTONEX
      DEFINE BUTTONEX button_destino
         PICTURE path_imagens+'img_destino.bmp'
         COL 280
         ROW 010
         WIDTH 100
         HEIGHT 040
         CAPTION 'Pasta ?'
         ACTION Escolhe_Pasta()
         FONTNAME 'verdana'
         fontsize 9
         FONTCOLOR _preto_001
      END BUTTONEX
      DEFINE BUTTONEX button_sair
         PICTURE path_imagens+'img_sair.bmp'
         COL 250
         ROW 140
         WIDTH 090
         HEIGHT 040
         CAPTION 'Sair'
         ACTION form_backup.release
      END BUTTONEX

      define progressbar progressbar_1
         ROW 070
         COL 045
         WIDTH 310
         HEIGHT 030
         RANGEMIN 0
         RANGEMAX 010
         VALUE 0
         forecolor {000,130,000}
      END progressbar

      DEFINE LABEL label_local
         ROW 010
         COL 010
         autosize .t.
         HEIGHT 20
         VALUE 'Escolha o local para ser gerado o backup'
         FONTBOLD .t.
         transparent .t.
      END LABEL
      DEFINE LABEL label_destino
         ROW 030
         COL 010
         WIDTH 240
         HEIGHT 40
         VALUE ''
         FONTBOLD .t.
         transparent .t.
         FONTCOLOR BLUE
      END LABEL
      DEFINE LABEL label_zip
         ROW 110
         COL 25
         WIDTH 350
         HEIGHT 20
         VALUE ''
         FONTNAME 'arial'
         fontsize 10
         TOOLTIP ''
         FONTBOLD .t.
         transparent .t.
         centeralign .t.
      END LABEL
   END WINDOW

   form_backup.center
   form_backup.activate

   RETURN NIL

STATIC FUNCTION escolhe_pasta()

   destino_backup := GetFolder('Escolha a pasta')
   SetProperty('form_backup','label_destino','value',alltrim(destino_backup))

   RETURN NIL

STATIC FUNCTION createzip()

   LOCAL aDir := directory('c:\super\tabelas\*.dbf'), aFiles:= {}, nLen
   LOCAL cPath := 'c:\super\tabelas\'

   IF empty(destino_backup)
      msgstop('Você precisa definir para onde o backup será feito','Atenção')

      RETURN NIL
   ENDIF

   FillFiles( aFiles, aDir, cPath )

   IF ( nLen := Len(aFiles) ) > 0
      form_backup.ProgressBar_1.RangeMin := 1
      form_backup.ProgressBar_1.RangeMax := nLen
      MODIFY CONTROL label_zip OF form_backup FONTCOLOR {0,0,0}

      COMPRESS aFiles ;
         TO destino_backup+'\backup_pizzaria.zip' ;
         BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
         LEVEL 9 ;
         OVERWRITE ;
         STOREPATH

      MODIFY CONTROL label_zip OF form_backup FONTCOLOR {0,0,255}
      form_backup.label_zip.value := 'Backup realizado com sucesso'
   ENDIF

   RETURN NIL

STATIC FUNCTION ProgressUpdate( nPos , cFile , lShowFileName )

   DEFAULT lShowFileName := .F.

   form_backup.progressbar_1.Value := nPos
   form_backup.label_zip.value := cFileNoPath( cFile )

   IF lShowFileName
      INKEY(.1)
   ENDIF

   RETURN NIL

STATIC FUNCTION FillFiles( aFiles, cDir, cPath )

   LOCAL aSubDir, cItem

   FOR cItem :=1 TO LEN(cDir)
      IF cDir[cItem][5] <> 'D'
         AADD( aFiles, cPath+cDir[cItem][1] )
      ELSEIF cDir[cItem][1] <> '.' .AND. cDir[cItem][1] <> '..'
         aSubDir := DIRECTORY( cPath+cDir[cItem][1]+'\*.*', 'D' )
         aFiles:=FillFiles( aFiles, aSubdir, cPath+cDir[cItem][1]+'\' )
      ENDIF
   NEXT

   return(aFiles)
