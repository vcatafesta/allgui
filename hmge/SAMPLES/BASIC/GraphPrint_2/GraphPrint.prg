/*******************************************************************************
Filename        : GraphPrint.prg

Created         : 18 June 2015 (22:01:26)
Created by      : Stefano Biancini

Last Updated    : 20 October 2015 (13:33:09)
Updated by      : Pierpaolo Martinello

Comments        : Main            Line 92
*******************************************************************************/
/*
* MINIGUI - Harbour Win32 GUI library Demo
* 775
*/

*  Questo programma è stato creato per sopperire alla mancanza di funzioni grafiche
*  del linguaggio harbour, per creare barre linee, punti e torte.
*  Il programma crea questi grafici esclusivamente con la lettura di dati inseriti
*  in un DBF richiamato dalla riga di comando come parametro, insieme al colore
*  della maschera formato dai 3 colori primari 0-255
*  Inoltre il programma riconosce automaticamente se il tipo di grafico è un grafico
*  a barre singolo colore barre multicolore o a torta dai parametri inseriti nel dbf
*  1) se il campo a_riga > 0 il programma esegue il grafico della torta
*  2) se il campo a_riga = 0 .AND. num_dicascalia = 1 .AND. num_elementi = num_colori esegue il grafico barre multicolor
*  3) se il campo a_riga = 0 .AND. num_dicascalia = num_colori  esegue il grafico barre 1 colore, 1 o piu variabili
*  Il dbf può avere qualunque nome si voglia dare, purche chiamato come parametro
*  Il tracciato record non è vincolante nella misura dei campi, ma solamente nei
*  nomi delle variabili stesse
*  Il programma inoltre supporta delle funzioni diagnostiche per cui se si inseriscono
*  dati incongruenti, esso segnala l'errore indicando :
*  Nome DBF richiamato
*  Tipo di grafico Torta / Barre
*  Record in cui si trova l'errore
*  campo in cui si trova l'errore
*  descrizione dell'errore rilevato
*  I campi slargh e saltezza sono opzionali, poiche se mancanti, la stampa viene eseguita direttamente
*  con gli assi direttamente del grafico del video
*  Il campo legenda serve per dare una misura alla legenda la misura di DEFAULT = 80

************************************************** ******************************
* This program was created to compensate for the lack of graphical functions
* Language of the harbor, to create bar lines, points and cakes.
* The program creates these charts exclusively with the reading of data entered
* In a DBF called from the command line as a parameter, along with the color
* Mask formed by the three primary colors 0-255
* In addition, the program automatically recognizes if the type of graph is a graph
* Bar single color multicolored bars or pie by the parameters entered in the dbf
* 1) if the field a_riga > 0 the program executes the pie graph
* 2) = 0 if the field a_riga .AND. num_dicascalia = 1 .AND. num_elementi = num_colori backs multicolor bar graph
* 3) = 0 if the field a_riga .AND. num_dicascalia = num_colori run the bar chart 1 color, one or more variables
* The DBF can have any name you want to give, as long as a parameter called
* The track record is not binding to the extent of the field, but only in
* Variable names themselves
* The program also supports the diagnostic functions so if they fit
* Inconsistent data, it reports the error indicating:
* Name DBF recalled
* Chart Type Pie / Barre
* Record in which the error is
* Field in which the error is
* Description of the detected
* Fields slargh and saltezza are optional, because if missing, the printer will print directly
* Directly with the axes of the graph of the video
* Field legend is used to give a measure of the extent of the legend DEFAULT = 80

#include "minigui.ch"

MEMVAR Msg_Dbf,Msg_Grafico,Col_Bottoni,LMostradati,tipo
MEMVAR titolo_graph,TITOLO_MASK,op_pie,POS_BUTTON,NUM_REC,LARG_WIN
MEMVAR ALTEZ_WIN,SPOST_COLO,SPOST_LARG,LARGH_WIN,LMOSTRA_3D
MEMVAR COL_GRAF,DIDASCA,A_RIGA,LEN_DESCRI,LEN_STR_ASER,NUM_ELEMENTI

FUNCTION Main(DbArc,r,g,b)

   LOCAL   narg := pcount()
   PRIVATE col_bottoni, lChanged, lMostraDati
   PRIVATE lMostra_3d, didascalie, colore_graph
   PRIVATE aSer
   PRIVATE titolo_mask, titolo_graph, colore_sfondo

   PRIVATE valori_y, valori_asse, profondita
   PRIVATE da_riga, da_colo, a_riga, a_colo, largh, altezza
   PRIVATE sda_riga, sda_colo, slargh, saltezza
   PRIVATE data_mask, len_legenda, largh_win, altez_win
   PRIVATE spost_colo   && spostamento verso sinistra grafico
   PRIVATE spost_larg   && largezza dimensione grafico

   PRIVATE msg_dbf, msg_grafico, tipo         && tipo grafico

   m->lChanged    := .t.
   m->lMostraDati := .F.
   m->lMostra_3d  := .T.

   IF narg = 0 .or. narg = 1
      DbArc := "Grafico.dBF"       // dopo rimettere grafico.dbf
      r     := "200"
      g     := "200"
      b     := "200"
   ELSEIF narg >=2 .AND.  narg <=3
      Msgstop("Parametri RGB inseriti dal batch errati !"+CRLF;
         +"Uso: GraphPrint  archivio colore(r) Colore (g) Colore (b)")
      QUIT
   ENDIF

   IF upper(Right(Dbarc,4)) <> ".DBF"
      dbArc += ".dBF"
   ENDIF

   IF !file (dbArc)
      Msgstop("Archivio "+DbArc+ " non trovato."+CRLF+"Parametro 1 errato !","Errore !!!")
      QUIT
   ENDIF

   msg_dbf    := "Nome DBF: " + DbArc

   REQUEST HB_LANG_IT      // Italian.
   // Set default language to italian.
   HB_LANGSELECT( "IT" )

   USE &DbArc shared

   GO TOP
   m->colore_sfondo := {VAL(r),VAL(g),VAL(b)}
   tipo := tipo_grafico()        && quale tipo di grafico barra multi torta

   IF UPPER(tipo) <> "MULTI"
      Controlla_Var()    && controllo riempimento campi del dbf
   ENDIF
   Carica_Var()          && carico tutte le variabili singole

   IF m->a_riga = 0
      barre()
   ELSEIF m->a_riga > 0
      torta()
   ENDIF

   Return(nil)

PROCEDURE barre()

   m->da_colo  := m->da_colo -20
   col_bottoni := m->altezza -5
   largh_win   := m->largh   +30
   altez_win   := m->altezza - m->da_colo + 50

   spost_colo  := m->len_legenda-80
   spost_larg  := spost_colo/2

   DEFINE WINDOW GraphTest  ;
         At 0,0               ;
         Width  largh_win     ;
         Height altez_win     ;
         Title m->titolo_mask ;
         Main                 ;
         Icon "Main"          ;
         Nomaximize Nosize    ;
         Backcolor m->colore_sfondo ;
         On Init DrawBarGraph ( )

      @ col_bottoni, 30 COMBOBOX Combo_1     ;
         ITEMS {'Barre','Linee','Punti'} ;
         WIDTH 100                       ;
         VALUE 1                         ;
         BOLD                            ;
         TOOLTIP "Scegli il tipo di grafico"                         ;
         ON CHANGE iif(m->lChanged,escoja(graphtest.combo_1.value),nil) ;
         ON DROPDOWN (m->lChanged := .f.)                               ;
         ON CLOSEUP (m->lChanged := .t.,escoja(graphtest.combo_1.value))

      @ col_bottoni, 150 COMBOBOX Combo_3d             ;
         ITEMS {'Grafico 3D','Grafico piatto'}     ;
         TOOLTIP "Scegli Grafico 3D oppure Piatto" ;
         VALUE 1     ;
         WIDTH 100   ;
         BOLD        ;
         ON CHANGE iif(m->lMostra_3d,escoja(graphtest.combo_1.value),nil) ;
         ON DROPDOWN (m->lMostra_3d := .f.)                               ;
         ON CLOSEUP  (m->lMostra_3d := .t.,escoja(graphtest.combo_1.value))

      @ col_bottoni, 270 COMBOBOX Combo_m          ;
         ITEMS {'Mostra Dati','Nascondi Dati'} ;
         TOOLTIP "Scegli Se visualizzare o nascondere i dati all'interno del grafico" ;
         VALUE 2   ;
         WIDTH 100 ;
         BOLD      ;
         ON CHANGE iif(m->lMostraDati,escoja(graphtest.combo_1.value),nil) ;
         ON DROPDOWN (m->lMostraDati := .f.) ;
         ON CLOSEUP  (m->lMostraDati := .t.,escoja(graphtest.combo_1.value))

      @ col_bottoni, 390 Button Button_1 ;
         Caption 'Stampa'            ;
         HEIGHT  24                  ;
         Action  PrintGraph(graphtest.combo_1.value) ;
         TOOLTIP 'Trasferisci il grafico sul foglio di stampa' ;
         bold

      @ col_bottoni, 510 Button Button_2  ;
         Caption 'Esci'               ;
         HEIGHT  24                   ;
         TOOLTIP 'Esci dal programma' ;
         Action  GraphTest.Release    ;
         bold

   END WINDOW

   CENTER WINDOW GraphTest
   ACTIVATE WINDOW GraphTest

   RETURN

PROCEDURE Controlla_Var()

   *  controllo riempimento variabili stringa e array formato stringa nel DBF
   LOCAL msg_campo
   LOCAL msg_record := "Record   n. : 1"
   LOCAL msg_errore := "Errore. . . . . : "
   LOCAL cTitle     := "Errore riempimento campo"

   GO 1

   IF EMPTY(field->tit_mask)
      msg_campo  :=  "Campo. . . .: [ tit_mask ]"
      msg_errore += "campo Titolo maschera Vuoto"
      MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
      QUIT
   ENDIF

   IF EMPTY(field->tit_graf)
      msg_campo  := "Campo. . . .: [ tit_graf ]"
      msg_errore += "campo Titolo grafico Vuoto"
      MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
      QUIT
   ENDIF

   IF EMPTY(field->didasca)
      msg_campo  := "Campo. . . .: [ didasca ]"
      msg_errore += "campo Didascalia Vuoto"
      MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
      QUIT
   ENDIF

   IF EMPTY(field->profona)
      msg_campo  := "Campo. . . .: [ profona ]"
      msg_errore += "campo Profondità grafico 3D Vuoto"
      MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
      QUIT
   ENDIF

   IF field->a_riga > 0
      IF EMPTY(field->a_colo)
         msg_campo  := "Campo. . . .: [ a_colo ]"
         msg_errore += "manca colonna x torta"
         MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF
   ELSE
      IF field->altezza >0 .AND. field->larghez = 0
         msg_campo  := "Campo. . . .: [ largh ]"
         msg_errore += "manca larghezza  x Barre"
         MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF

      IF field->altezza = 0 .AND. field->larghez > 0
         msg_campo  := "Campo. . . .: [ altezza ]"
         msg_errore += "manca altezza  x Barre"
         MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF

      IF field->altezza = 0 .AND. field->larghez = 0
         msg_campo  := "Campi. . . . : [ altezza e largh]"
         msg_errore += "manca sia altezza che larghezza x Barre"
         MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF

      IF field->larghez <  field->altezza
         msg_campo  := "Campi. . . . : [ larghezza e altezza ]"
         msg_errore += "la larghezza è minore dell'altezza"
         MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF

      IF field->slargh > 0 .AND. field->saltezza = 0
         msg_campo  := "Campi. . . . : [ slargh e saltezza ]"
         msg_errore += "E' inserita la larghezza ma non l'altezza di stampa"
         MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF

      IF field->slargh = 0 .AND. field->saltezza > 0
         msg_campo  := "Campi. . . . : [ slargh e saltezza ]"
         msg_errore += "E' inserita l'altezza ma non la larghezza di stampa"
         MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF

      IF field->slargh > 0 .AND. field->saltezza > 0
         IF field->slargh  <  field->saltezza
            msg_campo  := "Campi. . . . : [  slargh e saltezza ]"
            msg_errore += "la larghezza di stampa è minore dell'altezza"
            MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
            QUIT
         ENDIF
      ENDIF

   ENDIF

   IF EMPTY(field->len_legend)
      msg_campo  := "Campi. . . . : [ len_legend ]"
      msg_errore += "manca la lunghezza della legenda x Barre   -   Legenda = 80 "
      MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
   ENDIF

   IF field->len_legend > 150
      msg_campo  := "Campi. . . . : [ len_legend ]"
      msg_errore += "La lunghezza della legenda potrebbe essere troppo alta "
      MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
   ENDIF

   IF field->len_legend < 60 .AND. field->len_legend > 0
      msg_campo  := "Campi. . . . : [ len_legend ]"
      msg_errore += "La lunghezza della legenda potrebbe essere troppo bassa "
      MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
   ENDIF

   *-- controllo il riempimento dei campi array SOLO come stringa
   GO TOP
   WHILE !EOF()
      msg_record := "Record   n. :" + TRANSFORM(RECNO(),"99")
      msg_errore := "Errore. . . . . : "
      IF EMPTY(field->didasca)
         msg_campo  := "Campi. . . . : [ didasca ]"
         msg_errore += "manca campo didasca [didascalia] "
         MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF

      IF EMPTY(field->col_graf)
         msg_campo  := "Campi. . . . : [ col_graf ]"
         msg_errore += "manca campo col_graf [colore barra] "
         MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF

      IF EMPTY(field->aser)
         msg_campo  := "Campi. . . . : [ aser ]"
         msg_errore += "manca campo aser [lunghezza barre] "
         MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF
      SKIP

   END

   RETURN

PROCEDURE escoja(op)

   *-Setto mostra dati in funzione della scelta
   IF GraphTest.combo_m.Value = 1
      lMostraDati := .T.
   ELSEIF GraphTest.combo_m.Value = 2
      lMostraDati := .F.
   ENDIF

   *-Setto mostra_3d in funzione della scelta
   IF GraphTest.combo_3d.Value = 1
      lMostra_3D := .T.
   ELSEIF GraphTest.combo_3d.Value = 2
      lMostra_3D := .F.
   ENDIF

   IF op = 1
      DrawBarGraph( )
   ELSEIF op = 2
      drawlinesgraph( )
   ELSEIF op = 3
      drawpointsgraph( )
   ENDIF

   RETURN

PROCEDURE DrawBarGraph ()

   ERASE WINDOW GraphTest

   *-dalla colonna va sottratto la differenza tra len_leggenda - 80
   *-dalla larghezza va sottratto la (differenza tra len_leggenda - 80)/2

   DEFINE GRAPH IN WINDOW GraphTest
   ROW            m->da_riga
   COL            m->da_colo-spost_colo
   BOTTOM         m->altezza
   RIGHT          m->largh-spost_larg

   TITLE          m->titolo_graph
   GRAPHTYPE BARS
   SERIES         m->aSer
   YVALUES        m->valori_y
   DEPTH          m->profondita
   BARWIDTH 15
   HVALUES        m->valori_asse
   SERIENAMES     m->didascalie
   COLORS         m->colore_graph
   3DVIEW         lMostra_3d
   SHOWGRID       .T.
   SHOWXVALUES    .T.
   SHOWYVALUES    .T.
   SHOWLEGENDS    .T.
   SHOWDATAVALUES lMostraDati
   DATAMASK       m->data_mask
   LEGENDSWIDTH   m->len_legenda

END GRAPH

RETURN

PROCEDURE DrawLinesGraph ()

   ERASE WINDOW GraphTest

   DEFINE GRAPH IN WINDOW GraphTest
   ROW            m->da_riga
   COL            m->da_colo -spost_colo
   BOTTOM         m->altezza
   RIGHT          m->largh   -spost_larg

   TITLE          m->titolo_graph
   GRAPHTYPE LINES
   SERIES         m->aSer
   YVALUES        m->valori_y
   DEPTH          m->profondita
   BARWIDTH       15
   HVALUES        m->valori_asse
   SERIENAMES     m->didascalie
   COLORS         m->colore_graph
   3DVIEW         lMostra_3d
   SHOWGRID       .T.
   SHOWXVALUES    .T.
   SHOWYVALUES    .T.
   SHOWLEGENDS    .T.
   SHOWDATAVALUES lMostraDati
   DATAMASK       m->data_mask
   LEGENDSWIDTH   m->len_legenda
END GRAPH

RETURN

PROCEDURE DrawPointsGraph ()

   ERASE WINDOW GraphTest

   DEFINE GRAPH IN WINDOW GraphTest
   ROW            m->da_riga
   COL            m->da_colo - spost_colo
   BOTTOM         m->altezza
   RIGHT          m->largh - spost_larg

   TITLE          m->titolo_graph
   GRAPHTYPE POINTS
   SERIES         m->aSer
   YVALUES        m->valori_y
   DEPTH          m->profondita
   BARWIDTH       15
   HVALUES        m->valori_asse
   SERIENAMES     m->didascalie
   COLORS         m->colore_graph
   3DVIEW         lMostra_3d
   SHOWGRID       .T.
   SHOWXVALUES    .T.
   SHOWYVALUES    .T.
   SHOWLEGENDS    .T.
   SHOWDATAVALUES lMostraDati
   DATAMASK       m->data_mask
   LEGENDSWIDTH   m->len_legenda
END GRAPH

RETURN
*     Da qui cominciano le stampe

*-- inizio delle barre   --------------------------------------------------------

PROCEDURE PrintGraph(op)

   IF op = 1  .AND. GraphTest.Combo_3d.Value = 1 .AND. lMostraDati = .T.

      PRINT GRAPH                       ;
         IN WINDOW GraphTest             ;
         AT  m->sda_riga,  m->sda_colo   ;
         TO  m->saltezza,  m->slargh     ;
         TITLE titolo_graph              ;
         TYPE BARS                       ;
         SERIES  m->aSer                 ;
         YVALUES  m->valori_y            ;
         DEPTH  m->profondita           ;
         BARWIDTH 15                     ;
         HVALUES  m->valori_asse         ;
         SERIENAMES  m->didascalie       ;
         COLORS   m->colore_graph        ;
         3DVIEW                          ;
         SHOWGRID                        ;
         SHOWXVALUES                     ;
         SHOWYVALUES                     ;
         SHOWLEGENDS SHOWDATAVALUES DATAMASK  m->data_mask

   ELSEIF op = 1  .AND. GraphTest.Combo_3d.Value = 1 .AND. lMostraDati = .F.
      PRINT GRAPH                       ;
         IN WINDOW GraphTest             ;
         AT  m->sda_riga,  m->sda_colo   ;
         TO  m->saltezza,  m->slargh     ;
         TITLE titolo_graph              ;
         TYPE BARS                       ;
         SERIES  m->aSer                 ;
         YVALUES  m->valori_y            ;
         DEPTH  m->profondita            ;
         BARWIDTH 15                     ;
         HVALUES  m->valori_asse         ;
         SERIENAMES  m->didascalie       ;
         COLORS   m->colore_graph        ;
         3DVIEW                          ;
         SHOWGRID                        ;
         SHOWXVALUES                     ;
         SHOWYVALUES                     ;
         SHOWLEGENDS DATAMASK  m->data_mask

   ELSEIF op=1  .AND. GraphTest.Combo_3d.Value = 2 .AND. lMostraDati = .T.
      PRINT GRAPH                       ;
         IN WINDOW GraphTest            ;
         AT  m->sda_riga,  m->sda_colo  ;
         TO  m->saltezza,  m->slargh    ;
         TITLE titolo_graph             ;
         TYPE BARS                      ;
         SERIES  m->aSer                ;
         YVALUES  m->valori_y           ;
         DEPTH  m->profondita           ;
         BARWIDTH 15                    ;
         HVALUES  m->valori_asse        ;
         SERIENAMES  m->didascalie      ;
         COLORS   m->colore_graph       ;
         SHOWGRID                       ;
         SHOWXVALUES                    ;
         SHOWYVALUES                    ;
         SHOWLEGENDS SHOWDATAVALUES DATAMASK  m->data_mask

   ELSEIF op=1  .AND. GraphTest.Combo_3d.Value = 2 .AND. lMostraDati = .F.
      PRINT GRAPH                       ;
         IN WINDOW GraphTest            ;
         AT  m->sda_riga,  m->sda_colo  ;
         TO  m->saltezza,  m->slargh    ;
         TITLE titolo_graph             ;
         TYPE BARS                      ;
         SERIES  m->aSer                ;
         YVALUES  m->valori_y           ;
         DEPTH  m->profondita           ;
         BARWIDTH 15                    ;
         HVALUES  m->valori_asse        ;
         SERIENAMES  m->didascalie      ;
         COLORS   m->colore_graph       ;
         SHOWGRID                       ;
         SHOWXVALUES                    ;
         SHOWYVALUES                    ;
         SHOWLEGENDS DATAMASK  m->data_mask

      *-- fine delle barre   ----------------------------------------------------------

      *-- Inizio delle Linee   --------------------------------------------------------
   ELSEIF op=2  .AND. GraphTest.Combo_3d.Value = 1  .AND. lMostraDati = .T.
      PRINT GRAPH                      ;
         IN WINDOW GraphTest            ;
         AT  m->sda_riga,  m->sda_colo  ;
         TO  m->saltezza,  m->slargh    ;
         TITLE  m->titolo_graph         ;
         TYPE LINES                     ;
         SERIES  m->aSer                ;
         YVALUES  m->valori_y           ;
         DEPTH  m->profondita           ;
         BARWIDTH 15                    ;
         HVALUES  m->valori_asse        ;
         SERIENAMES  m->didascalie      ;
         COLORS   m->colore_graph       ;
         3DVIEW                         ;
         SHOWGRID                       ;
         SHOWXVALUES                    ;
         SHOWYVALUES                    ;
         SHOWLEGENDS SHOWDATAVALUES DATAMASK  m->data_mask

   ELSEIF op=2  .AND. GraphTest.Combo_3d.Value = 1  .AND. lMostraDati = .F.
      PRINT GRAPH                      ;
         IN WINDOW GraphTest            ;
         AT  m->sda_riga,  m->sda_colo  ;
         TO  m->saltezza,  m->slargh    ;
         TITLE  m->titolo_graph         ;
         TYPE LINES                     ;
         SERIES  m->aSer                ;
         YVALUES  m->valori_y           ;
         DEPTH  m->profondita           ;
         BARWIDTH 15                    ;
         HVALUES  m->valori_asse        ;
         SERIENAMES  m->didascalie      ;
         COLORS   m->colore_graph       ;
         3DVIEW                         ;
         SHOWGRID                       ;
         SHOWXVALUES                    ;
         SHOWYVALUES                    ;
         SHOWLEGENDS  DATAMASK  m->data_mask

   ELSEIF op=2  .AND. GraphTest.Combo_3d.Value = 2 .AND. lMostraDati = .T.
      PRINT GRAPH                      ;
         IN WINDOW GraphTest            ;
         AT  m->sda_riga,  m->sda_colo  ;
         TO  m->saltezza,  m->slargh    ;
         TITLE  m->titolo_graph         ;
         TYPE LINES                     ;
         SERIES  m->aSer                ;
         YVALUES  m->valori_y           ;
         DEPTH  m->profondita           ;
         BARWIDTH 15                    ;
         HVALUES  m->valori_asse        ;
         SERIENAMES  m->didascalie      ;
         COLORS   m->colore_graph       ;
         SHOWGRID                       ;
         SHOWXVALUES                    ;
         SHOWYVALUES                    ;
         SHOWLEGENDS SHOWDATAVALUES DATAMASK  m->data_mask

   ELSEIF op=2  .AND. GraphTest.Combo_3d.Value = 2 .AND.lMostraDati = .F.
      PRINT GRAPH                      ;
         IN WINDOW GraphTest            ;
         AT  m->sda_riga,  m->sda_colo  ;
         TO  m->saltezza,  m->slargh    ;
         TITLE  m->titolo_graph         ;
         TYPE LINES                     ;
         SERIES  m->aSer                ;
         YVALUES  m->valori_y           ;
         DEPTH  m->profondita           ;
         BARWIDTH 15                    ;
         HVALUES  m->valori_asse        ;
         SERIENAMES  m->didascalie      ;
         COLORS   m->colore_graph       ;
         SHOWGRID                       ;
         SHOWXVALUES                    ;
         SHOWYVALUES                    ;
         SHOWLEGENDS DATAMASK  m->data_mask
      *-- Fine delle Linee   ----------------------------------------------------------

      *-- Inizio dei punti   ----------------------------------------------------------
   ELSEIF op=3  .AND. GraphTest.Combo_3d.Value = 1 .AND. lMostraDati = .T.
      PRINT GRAPH                     ;
         IN WINDOW GraphTest           ;
         AT  m->sda_riga,  m->sda_colo ;
         TO  m->saltezza,  m->slargh   ;
         TITLE  m->titolo_graph        ;
         TYPE POINTS                   ;
         SERIES  m->aSer               ;
         YVALUES  m->valori_y          ;
         DEPTH 15                      ;
         BARWIDTH  m->profondita       ;
         HVALUES  m->valori_asse       ;
         SERIENAMES  m->didascalie     ;
         COLORS   m->colore_graph      ;
         3DVIEW                        ;
         SHOWGRID                      ;
         SHOWXVALUES                   ;
         SHOWYVALUES                   ;
         SHOWLEGENDS SHOWDATAVALUES DATAMASK  m->data_mask

   ELSEIF op=3  .AND. GraphTest.Combo_3d.Value = 1 .AND. lMostraDati = .F.
      PRINT GRAPH                     ;
         IN WINDOW GraphTest           ;
         AT  m->sda_riga,  m->sda_colo ;
         TO  m->saltezza,  m->slargh   ;
         TITLE  m->titolo_graph        ;
         TYPE POINTS                   ;
         SERIES  m->aSer               ;
         YVALUES  m->valori_y          ;
         DEPTH 15                      ;
         BARWIDTH  m->profondita       ;
         HVALUES  m->valori_asse       ;
         SERIENAMES  m->didascalie     ;
         COLORS   m->colore_graph      ;
         3DVIEW                        ;
         SHOWGRID                      ;
         SHOWXVALUES                   ;
         SHOWYVALUES                   ;
         SHOWLEGENDS DATAMASK  m->data_mask

   ELSEIF op=3  .AND. GraphTest.Combo_3d.Value = 2 .AND. lMostraDati = .T.
      PRINT GRAPH                     ;
         IN WINDOW GraphTest           ;
         AT  m->sda_riga,  m->sda_colo ;
         TO  m->saltezza,  m->slargh   ;
         TITLE  m->titolo_graph        ;
         TYPE POINTS                   ;
         SERIES  m->aSer               ;
         YVALUES  m->valori_y          ;
         DEPTH 15                      ;
         BARWIDTH  m->profondita       ;
         HVALUES  m->valori_asse       ;
         SERIENAMES  m->didascalie     ;
         COLORS   m->colore_graph      ;
         SHOWGRID                      ;
         SHOWXVALUES                   ;
         SHOWYVALUES                   ;
         SHOWLEGENDS SHOWDATAVALUES DATAMASK  m->data_mask

   ELSEIF op=3  .AND. GraphTest.Combo_3d.Value = 2 .AND. lMostraDati = .F.
      PRINT GRAPH                     ;
         IN WINDOW GraphTest           ;
         AT  m->sda_riga,  m->sda_colo ;
         TO  m->saltezza,  m->slargh   ;
         TITLE  m->titolo_graph        ;
         TYPE POINTS                   ;
         SERIES  m->aSer               ;
         YVALUES  m->valori_y          ;
         DEPTH 15                      ;
         BARWIDTH  m->profondita       ;
         HVALUES  m->valori_asse       ;
         SERIENAMES  m->didascalie     ;
         COLORS   m->colore_graph      ;
         SHOWGRID                      ;
         SHOWXVALUES                   ;
         SHOWYVALUES                   ;
         SHOWLEGENDS DATAMASK  m->data_mask
      *-- Fine dei punti   ------------------------------------------------------------

   ENDIF

   RETURN

FUNCTION tipo_grafico ()

   LOCAL num_elementi
   LOCAL num_col_graf
   LOCAL num_didasca
   LOCAL vRet

   COUNT TO num_col_graf   FOR !EMPTY(_Field->col_graf)
   COUNT TO num_didasca    FOR !EMPTY(_Field->didasca )

   GO 1
   m->valori_y  := HB_ATOKENS( ALLTRIM(field->val_y), ',' )
   num_elementi := LEN( m->valori_y )
   Vret        := ""
   msg_grafico := "Grafico sconosciuto"

   IF _Field->a_riga > 0
      vRet := "Torta"
      msg_grafico := "Figura . . . .: Torta "
   ELSEIF num_didasca = 1 .AND. ( num_col_graf = num_elementi )
      Vret := "Multi"
      msg_grafico := "Figura . . . .: Multi "
   ELSEIF num_didasca = num_col_graf
      VRet := "Barre Linee Punti"
      msg_grafico := "Figura . . . .: Barre Linee Punti"
   ENDIF

   RETURN vRet

PROCEDURE carica_var()

   PRIVATE num_elementi    //  num_elementi val_y = aser
   PRIVATE num_rec         //  num_record
   PRIVATE didasca         //  stringa descrizione didascalia
   PRIVATE str_aser        //  valore stringa_aser
   PRIVATE len_descri      //  lunghezza massima descrizione
   PRIVATE len_str_aser    //  lunghezza massima elemento aser

   *-- da qui inizia il controllo dei campi array, per cercare i difetti, inizialmente
   *   devo sapere quali errori cercare e cosa mi devo aspettare per pensare che i dati sono giusti
   *    punti fermi

   *    1) controllo prima di tutto dei campi obbligatori nel DBF dati
   *    2) il numero degli elementi di val_y è uguale al numero degli elementi di aser
   *    3) il numero degli elementi di col_graf è sempre 3 e vanno da 0 a 255
   *    4) se oltre alla prima riga del record ci fossero altre devono essere caricati solo:
   *       didasca, col_graf, aser con le regole come sopra

   GO TOP

   len_descri      := 0
   len_str_aser    := 0

   *- per allineare le legenda devo fare 2 due operazioni ----------------------
   *- 1) contare quanto è la descrizione piu lunga, quindi creare tutte le descrizioni lunga quanto dfescrizione piu lunga
   *- 2) aggiungere alri spazi alla descrizione in proporzione alla dimensione del valore successivo alla descrizione
   *  altd()
   *- 1) cerco la descrizione piu lunga

   GO TOP
   WHILE !EOF()
      IF LEN(ALLTRIM(field-> didasca)) > len_descri
         len_descri   := LEN(ALLTRIM(field-> didasca))
      ENDIF

      IF LEN(ALLTRIM(field->aser)) > len_str_aser
         len_str_aser := LEN(ALLTRIM(field->aser))
      ENDIF

      SKIP
   END

   COUNT TO num_rec FOR !EMPTY(_Field->didasca)
   GO TOP

   m->titolo_mask  := ALLTRIM(field->tit_mask)
   m->titolo_graph := ALLTRIM(field->tit_graf)
   m->didasca      := ALLTRIM(field->didasca)
   m->str_aser     := ALLTRIM(field->aser)
   m->didasca      += SPACE(len_descri   - LEN(m->didasca ) )
   m->didasca      += SPACE(len_str_aser - LEN(m->str_aser) )

   *  m->colore_sfondo= HB_ATOKENS(field->col_mask , ',' )

   m->valori_asse  := field->val_asse
   m->profondita   := field->profona

   m->a_riga       := field->a_riga

   m->a_colo       := field->a_colo

   m->da_riga      := 20
   m->da_colo      := 20

   m->largh        := field->larghez
   m->altezza      := field->altezza

   m->sda_riga     := field->sda_riga
   m->sda_colo     := field->sda_colo

   *- i campi di stampa se esistono, li carico altrimento metto i dati dell'immagine schermo
   IF field->slargh > 0
      m->slargh    := field->slargh
   ELSE
      m->slargh    := m->largh
   ENDIF

   IF field->saltezza > 0
      m->saltezza  := field->saltezza
   ELSE
      m->saltezza  := m->altezza
   ENDIF

   m->valori_y     := HB_ATOKENS( ALLTRIM(field->val_y), ',' )
   num_elementi    := LEN(m->valori_y       )   // conto quanti elementi ci sono su valori_y

   m->data_mask    := field->data_mask

   IF !EMPTY(field->len_legend)
      m->len_legenda := field->len_legend
   ELSE
      m->len_legenda := 80
   ENDIF

   m->aser        := {}
   m->colore_graph:= {}
   m->didascalie  := {}

   aadd(m->aser        , &( "{" + FIELD->aser     + "}" ))
   aadd(m->colore_graph, &( "{" + FIELD->col_graf + "}" ))
   aadd(m->didascalie  , &( "'" + m->didasca  + "'" ))

   IF UPPER(tipo) <> "MULTI"
      contr_array()     //  controlla errori array
   ENDIF

   SKIP

   IF .NOT. EOF()
      WHILE !EOF()
         IF !EMPTY(FIELD->aser)
            aadd(m->aser,         &( "{" + FIELD->aser     + "}" ))
         ENDIF

         IF !EMPTY(FIELD->col_graf)
            aadd(m->colore_graph, &( "{" + FIELD->col_graf + "}" ))
         ENDIF

         m->didasca      := ALLTRIM(field->didasca)
         m->str_aser     := ALLTRIM(field->aser)
         m->didasca      += SPACE(len_descri   - LEN(m->didasca ) )
         m->didasca      += SPACE(len_str_aser - LEN(m->str_aser) )

         IF !EMPTY(FIELD->didasca)
            aadd(m->didascalie,   &( "'" +  m->didasca  + "'" ))
         ENDIF

         IF UPPER(tipo) <> "MULTI"
            contr_array()     //  controlla errori array
         ENDIF

         SKIP
      END

   ENDIF

   RELEASE num_elementi    //  num_elementi val_y = aser
   RELEASE num_rec         //  num_record
   RELEASE didasca         //  stringa descrizione didascalia
   RELEASE str_aser        //  valore stringa_aser
   RELEASE len_descri      //  lunghezza massima descrizione
   RELEASE len_str_aser    //  lunghezza massima elemento aser

   RETURN

PROCEDURE contr_array()

   LOCAL len_aser        //  num_elementi aser
   LOCAL len_colore      //  num_elementi colore
   LOCAL Rcn := RECNO()

   LOCAL msg_campo
   LOCAL msg_errore
   LOCAL Epos
   LOCAL msg_record := "Record   n. :" + TRANSFORM(Rcn,"99")
   LOCAL cTitle     := "Errore riempimento campo"

   *   altd()

   *--controllo aser non funziona per i campi oltre il primo
   IF !EMPTY(m->aser[Rcn])
      len_aser  := LEN(m->aser        [Rcn])   // conto quanti elementi ci sono su m->aser
   ENDIF

   len_colore   := LEN(m->colore_graph[Rcn])   // conto quanti elementi ci sono su m->colore_graf

   *--controllo se gli elementi sono quanti i valori di aser
   *--le nelle barre len_aser = num_elementi, mentre per le torte len_aser = 1

   IF m->a_riga = 0

      IF !EMPTY(m->aser[Rcn])
         IF len_aser <> num_elementi
            msg_campo  := "Campi. . . . : [ aser e val_y ]"
            msg_errore := "Errore. . . . . : numero elementi aser <> numero elementi val_y"
            MsgInfo (msg_dbf + CRLF + msg_grafico + CRLF + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
            QUIT
         ENDIF
      ENDIF

   ELSEIF m->a_riga > 0
      IF len_aser <> 1
         msg_campo  := "Campo. . . .: [   aser  ]"
         msg_errore := "Errore. . . . . : Lunghezza campo aser <> 1"
         MsgInfo (msg_dbf + CRLF + msg_grafico + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
         QUIT
      ENDIF
   ENDIF

   *--controllo se i colori sono effettivamente 3
   msg_campo  := "Campo. . . .: [   col_graf  ]"

   IF len_colore <> 3
      *     msg_grafico= "Figura . . . .: Torta"
      msg_errore := "Errore. . . . . : Numero colori <> 3"
      MsgInfo (msg_dbf + CRLF + msg_grafico + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
      QUIT
   ENDIF

   Epos := 0
   aeval(m->colore_graph[Rcn],{|x,y|if (x > 255 ,Epos := y ,)} )

   IF epos > 0
      msg_errore := "Errore. . . . . : Colore numero "+strzero(epos,1)+" Fuori scala"
      MsgInfo (msg_dbf + CRLF + msg_grafico + msg_campo + CRLF + msg_record + CRLF + msg_errore, cTitle)
      QUIT
   ENDIF

   RETURN

PROCEDURE torta

   PRIVATE pos_button   // posizione bottone

   op_pie = 0

   carica_var()

   SET font to 'Courier New', 10

   m->aser  := {}
   GO TOP

   pos_button = m->a_riga+7

   DO WHILE .NOT. EOF()
      IF !EMPTY(FIELD->aser)
         aadd(m->aser,   &(  FIELD->aser  ))
      ENDIF
      SKIP
   ENDDO

   IF m->a_colo < 480
      m->a_colo = 480
   ENDIF

   DEFINE WINDOW m at 0,0 ;
         Width m->a_colo+40 ;
         Height  m->a_riga +80 main;
         Title titolo_mask ;
         backcolor m->colore_sfondo
      showpie_3d()

      @ pos_button ,20 Button Button_3d ;
         Caption   'Torta 3D'             ;
         Action  ( showpie_3d() )          ;
         bold

      @ pos_button,140 Button Button_flat ;
         Caption   'Torta Flat'             ;
         Action  ( showpie_flat() )          ;
         bold

      @ pos_button,260 Button Button_pie ;
         Caption   'Stampa'                ;
         Action  ( printpie() )             ;
         bold

      @ pos_button, 380 Button Button_exit ;
         Caption   'Esci'                    ;
         TOOLTIP 'Esci dal programma'         ;
         Action  m.Release                    ;
         bold

   END WINDOW
   m.center
   m.activate

   RETURN

PROCEDURE showpie_3D

   ERASE WINDOW m
   op_pie := 1

   DRAW GRAPH IN WINDOW m AT m->da_riga, m->da_colo;
      TO m->a_riga, m->a_colo ;
      TITLE m->titolo_graph ;
      TYPE PIE;
      SERIES m->aser ;
      DEPTH m->profondita ;
      SERIENAMES m->didascalie ;
      COLORS m->colore_graph ;
      3DVIEW;
      SHOWXVALUES;
      SHOWLEGENDS DATAMASK m->data_mask

   RETURN

PROCEDURE showpie_flat

   ERASE WINDOW m
   op_pie := 2

   DRAW GRAPH IN WINDOW m AT m->da_riga, m->da_colo;
      TO m->a_riga, m->a_colo ;
      TITLE m->titolo_graph ;
      TYPE PIE;
      SERIES m->aser ;
      DEPTH m->profondita ;
      SERIENAMES m->didascalie ;
      COLORS m->colore_graph ;
      SHOWXVALUES;
      SHOWLEGENDS DATAMASK m->data_mask

   RETURN

PROCEDURE Printpie

   LOCAL sa_riga
   LOCAL sa_colo

   sa_riga := m->sda_riga + m->slargh
   sa_colo := m->sda_colo + m->saltezza

   IF op_pie = 1
      PRINT GRAPH IN WINDOW m AT m->sda_riga, m->sda_colo;
         TO sa_riga, sa_colo  ;
         TITLE m->titolo_graph ;
         TYPE PIE;
         SERIES m->aser;
         DEPTH m->profondita ;
         SERIENAMES m->didascalie ;
         COLORS m->colore_graph  ;
         3DVIEW;
         SHOWXVALUES;
         SHOWLEGENDS DATAMASK m->data_mask

   ELSEIF op_pie = 2
      PRINT GRAPH IN WINDOW m AT m->sda_riga, m->sda_colo;
         TO sa_riga, sa_colo ;
         TITLE m->titolo_graph ;
         TYPE PIE;
         SERIES m->aser;
         DEPTH m->profondita ;
         SERIENAMES m->didascalie ;
         COLORS m->colore_graph  ;
         SHOWXVALUES;
         SHOWLEGENDS DATAMASK m->data_mask
   ENDIF

   RETURN
