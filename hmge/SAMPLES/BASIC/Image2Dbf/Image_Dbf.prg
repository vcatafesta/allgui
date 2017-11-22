#include "MiniGUI.ch"

MEMVAR m_ver, p_GetFile

proc main

   LOCAL x_arq := 'config.dbf'

   REQUEST DBFCDX
   RDDSETDEFAULT( "DBFCDX" )

   SET MULTIPLE OFF WARNING

   IF !file ( x_arq )
      DBCREATE( x_arq , { ;
         {"ROW"    , "N" , 9 , 3} ,;
         {"COL"    , "N" , 9 , 3} ,;
         {"WIDTH"  , "N" , 9 , 3} ,;
         {"HEIGHT" , "N" , 9 , 3} } )
   end

   x_arq := 'arq.dbf'

   IF !file ( x_arq )
      DBCREATE( x_arq , { ;
         {"NOME"   , "C" , 254 , 0} ,;
         {"IMAGEM" , "M" ,  10 , 0} } )
   end

   USE &x_arq alias IMAGE new exclusive
   INDEX ON field->nome tag image to image

   PUBLIC m_ver := GetStartupFolder() + '\_cas_ver.JPG', p_GetFile := ''

   SET DATE BRITISH
   SET CENTURY ON
   SET DELETED ON

   SET BROWSESYNC ON

   DEFINE WINDOW Form_1 ;
         At 0, 0 Width 700 Height 500 ;
         on init f_init() ;
         on release f_release() ;
         nosysmenu ;
         Title 'IMAGE to DBF - by cas.soft@gmail.com' Main

      @ 01,1 button btn_read caption 'Importar' action f_importar()
      @ 30,1 button btn_save caption 'Exportar' action f_exportar()
      @ 60,1 button btn_dele caption 'Apagar'   action f_apagar()
      @ 90,1 button btn_sair caption 'Sair'     action thiswindow.release

      @ 1,120 image img_cas picture '' Width 300 Height 120 stretch

      @ 128,1 BROWSE Browse_1 ;
         WIDTH 690 ;
         HEIGHT 330 ;
         HEADERS { 'Arquivo'} ;
         WIDTHS { 668 } ;
         VALUE 1 ;
         WORKAREA IMAGE ;
         FIELDS { 'NOME' } ;
         ON CHANGE browse_1_change() ;
         LOCK ;
         EDIT INPLACE

      DEFINE CONTEXT menu
         Item "Importar" Action f_importar()
         Item "Exportar" Action f_exportar()
         Item "Apagar"   Action f_apagar()
         Item "Sair"     Action thiswindow.release
      End Menu

      Define timer timer_1 ;
         interval 250 ;
         action ( setforegroundwindow( getformhandle('form_1') ),;
         form_1.browse_1.setfocus ) once

   END WINDOW

   form_1.Center
   form_1.Activate

   RETURN

   *..............................................................................................*

   func f_init
      LOCAL bkp_alias := alias()
      LOCAL m_row
      LOCAL m_col
      LOCAL m_width
      LOCAL m_height

      sele 0
      USE config
      IF lastrec() # 0
         m_row := FIELD->ROW
         m_col := FIELD->COL
         m_width := FIELD->WIDTH
         m_height:= FIELD->HEIGHT
      ELSE
         m_row := 100
         m_col := 200
         m_width := 300
         m_height:= 400
      end
      USE
      sele &bkp_alias

      DEFINE WINDOW Form_2 ;
            At m_row, m_col Width m_width Height m_height ;
            title 'CAS' ;
            on init f_size() ;
            on maximize f_size() ;
            on size f_size() ;
            nosysmenu ON INTERACTIVECLOSE .f. child
         @ 0,0 image img_cas picture ''
      END WINDOW

      form_1.browse_1.value := 1
      browse_1_change()

      form_2.activate

      retu nil

      *..............................................................................................*

      func f_size

         form_2.img_cas.width := form_2.width   - 8
         form_2.img_cas.height := form_2.height - 8
         form_2.img_cas.picture := m_ver

         retu nil

         *..............................................................................................*

         func f_apagar

            IF empty( lastrec() )
               retu nil
            end

            repl NOME   with ''
            repl IMAGEM with ''
            dele
            PACK
            GO TOP

            form_1.browse_1.value := recno()
            form_1.browse_1.refresh

            IF empty(form_1.browse_1.value)
               form_1.img_cas.picture := ''
               form_1.img_cas.hide
               form_1.img_cas.show
               form_2.img_cas.picture := ''
               form_2.img_cas.hide
               form_2.img_cas.show
               form_2.title := ''
            ELSE
               browse_1_change()
            end

            retu nil

            *..............................................................................................*

            func f_exportar
               LOCAL a_arqs := { ;
                  { "Image Files" , "*.JPG;*.BMP;*.GIF;*.ICO" } ,;
                  { "Arquivos JPG" , "*.JPG" } ,;
                  { "Arquivos BMP" , "*.BMP" } ,;
                  { "Arquivos GIF" , "*.GIF" } ,;
                  { "Arquivos ICO" , "*.ICO" } } ,;
                  m_novo := alltrim( IMAGE->NOME ) , cFile

               IF empty( lastrec() )
                  retu nil
               end

               cFile := Putfile( a_arqs ,;
                  'Salvar Arquivo como...' , GetCurrentFolder() , .f. , m_novo )

               IF empty( cFile )
                  retu nil
               end

               IF file( cFile )
                  MsgStop( "Arquivo já existe", "Erro", , .f. )
               ELSE
                  MemoWrit( cFile , UnMaskBinData( FIELD->IMAGEM ) )
               end

               retu nil

               *..............................................................................................*

               func browse_1_change

                  MemoWrit( m_ver , UnMaskBinData( FIELD->IMAGEM ) )

                  form_1.img_cas.picture := m_ver
                  form_2.img_cas.picture := m_ver
                  form_2.title := trim(IMAGE->NOME)

                  retu nil

                  *.................................................................*

                  proc f_release

                     CLOSE all
                     ERASE &m_ver

                     IF .not. file('config.dbf')

                        RETURN
                     end

                     USE config
                     IF lastrec() = 0
                        APPEND BLANK
                     end
                     repl ROW    with form_2.row
                     repl COL    with form_2.col
                     repl WIDTH  with form_2.width
                     repl HEIGHT with form_2.height

                     RETURN

                     *.................................................................*

FUNCTION MaskBinData( x )                && Não lembro quem fez

   x := StrTran( x , chr(26) , '\\#26//' )
   x := StrTran( x , chr(00) , '\\#00//' )

   RETURN x

   *.................................................................*

FUNCTION UnMaskBinData( x )              && Não lembro quem fez

   x := StrTran( x , '\\#26//' , chr(26) )
   x := StrTran( x , '\\#00//' , chr(00) )

   RETURN x

   *.................................................................*

FUNCTION f_importar

   LOCAL varios := .t.   && selecionar varios arquivos
   LOCAL arq_cas, i, n_for, File_cas, m_rat

   p_GetFile := iif( empty( p_GetFile ) , GetMyDocumentsFolder() , p_GetFile )

   arq_cas := GetFile ( { ;
      {'Image Files' , '*.JPG;*.BMP;*.GIF;*.ICO'} ,;
      {'JPG Files' , '*.JPG'} ,;
      {'BMP Files' , '*.BMP'}  } ,;
      'Open File(s)' , p_GetFile , varios , .t. )

   IF len( arq_cas ) = 0

      RETURN NIL
   ENDIF

   FOR n_for := 1 to len( arq_cas )
      i = n_for + 1

      IF n_for = len(arq_cas)  && esta consistencia foi feita pq o ultimo arquivo
         i = 1       && é sempre o primeiro
      ENDIF

      File_cas := strtran( arq_cas[ i ] , '\\' , '\' )

      APPEND BLANK

      m_rat := rat( '\' , File_cas )
      IF m_rat # 0
         repl NOME   with substr( File_cas , m_rat + 1 )
      ELSE
         repl NOME   with File_cas
      end

      repl IMAGEM with MaskBinData( MemoRead( File_cas ) )

   NEXT

   m_rat = rat('\',arq_cas[1])
   p_GetFile := left( arq_cas[1] , m_rat-1 )

   form_1.browse_1.value := recno()
   form_1.browse_1.refresh

   RETURN NIL

