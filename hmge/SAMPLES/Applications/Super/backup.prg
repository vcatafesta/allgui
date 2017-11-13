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
         width 400;
         height 225;
         title 'Backup do Banco de Dados';
         icon path_imagens+'icone.ico';
         modal ;
         nosize

      DEFINE BUTTONEX button_backup
         picture path_imagens+'img_zip.bmp'
         col 060
         row 140
         width 180
         height 040
         caption 'Iniciar o Backup'
         action CreateZip()
         fontname 'verdana'
         fontsize 9
         fontcolor _preto_001
      END BUTTONex
      DEFINE BUTTONEX button_destino
         picture path_imagens+'img_destino.bmp'
         col 280
         row 010
         width 100
         height 040
         caption 'Pasta ?'
         action Escolhe_Pasta()
         fontname 'verdana'
         fontsize 9
         fontcolor _preto_001
      END BUTTONex
      DEFINE BUTTONEX button_sair
         picture path_imagens+'img_sair.bmp'
         col 250
         row 140
         width 090
         height 040
         caption 'Sair'
         action form_backup.release
      END BUTTONex

      define progressbar progressbar_1
         row 070
         col 045
         width 310
         height 030
         rangemin 0
         rangemax 010
         value 0
         forecolor {000,130,000}
      end progressbar

      DEFINE LABEL label_local
         row 010
         col 010
         autosize .t.
         height 20
         value 'Escolha o local para ser gerado o backup'
         fontbold .t.
         transparent .t.
      END LABEL
      DEFINE LABEL label_destino
         row 030
         col 010
         width 240
         height 40
         value ''
         fontbold .t.
         transparent .t.
         fontcolor BLUE
      END LABEL
      DEFINE LABEL label_zip
         row 110
         col 25
         width 350
         height 20
         value ''
         fontname 'arial'
         fontsize 10
         tooltip ''
         fontbold .t.
         transparent .t.
         centeralign .t.
      END LABEL
   END WINDOW

   form_backup.center
   form_backup.activate

   RETURN(nil)

STATIC FUNCTION escolhe_pasta()

   destino_backup := GetFolder('Escolha a pasta')
   SetProperty('form_backup','label_destino','value',alltrim(destino_backup))

   RETURN(nil)

STATIC FUNCTION createzip()

   LOCAL aDir := directory('c:\super\tabelas\*.dbf'), aFiles:= {}, nLen
   LOCAL cPath := 'c:\super\tabelas\'

   IF empty(destino_backup)
      msgstop('Você precisa definir para onde o backup será feito','Atenção')

      RETURN(nil)
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

   RETURN(nil)

STATIC FUNCTION ProgressUpdate( nPos , cFile , lShowFileName )

   DEFAULT lShowFileName := .F.

   form_backup.progressbar_1.Value := nPos
   form_backup.label_zip.value := cFileNoPath( cFile )

   IF lShowFileName
      INKEY(.1)
   ENDIF

   RETURN(nil)

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

   RETURN(aFiles)

