#include "HBCompat.ch"
#include "MiniGUI.ch"
#include "TsBrowse.ch"
#include "DbStruct.ch"
#include "Modest.ch"

// Program messages

#define MSG_STRUCTURE_LOADED         ' structure loaded'
#define MSG_ERROR_LOAD               'Error load structure for '
#define MSG_NEW_STRUCTURE            'New structure (empty) started'
#define MSG_ERROR_FIELDNAME          'Field names begin with a letter and may contain A-Z, 0-9, and "_"'
#define MSG_CHAR_INCORRECT           'Incorrect symbol '
#define MSG_LEN_EMPTY                'Zero length of the field'
#define MSG_DECIMALS_LONG            'Invalid field width or number of decimals'
#define MSG_FIELD_ALREADY            'The field name is duplicated with'
#define MSG_RULE_INCORRECT           'Incorrect transormation rule'
#define MSG_RULE_TYPES               'Types mismatch.'
#define MSG_NOACTIVE_STRUCTURE       'The fields list no active'
#define MSG_STRUCTURE_EMPTY          'A structure does not contain the fields'
#define MSG_NOACTIVE_COLLECTOR       'The Collector no active'
#define MSG_COLLECTOR_EMPTY          'A Collector does not contain the records or record no select'

// Constant part of the help in editing modes

#define SHORTKEY_TOOLTIP              '[F2] - Apply, [Esc] - Discard'

// Allowable field's types

#define CORRECT_TYPES                 { 'C', 'N', 'D', 'L', 'M' }

#define TYPE_IS_CHAR                  1
#define TYPE_IS_NUM                   2
#define TYPE_IS_DATE                  3
#define TYPE_IS_LOGIC                 4
#define TYPE_IS_MEMO                  5

// Restrictions of field length

#define LEN_IS_CHAR                 254
#define LEN_IS_NUM                   20
#define LEN_IS_DATE                   8
#define LEN_IS_LOGIC                  1
#define LEN_IS_MEMO                  10

// Working mode. Utilize at editing/creation of fields.

#define MODE_DEFAULT                  0           // Main mode
#define MODE_NEWFIELD                 1           // Add field
#define MODE_INSFIELD                 2           // Insert field
#define MODE_EDITFIELD                3           // Editing

// End of dialog actions

#define SET_OK                        1           // Accept
#define SET_CANCEL                    2           // Reject

// Transfer record to collector modes

#define MODE_COPY                     0           // Copy
#define MODE_CUT                      1           // Cut

// Color theme

#define NAVY_COLOR                    { 0, 0, 106 }

// Complementary RDD

REQUEST DBFCDX, DBFFPT
#include "Requests.ch"                // Function list for transformation rules

STATIC nShift     := 0         // Row's insert mode. Utilize in
// procedure FiniEditField() (for inserting a new
// field) and procedure of inserting from collector

MEMVAR aCollector
MEMVAR aStat
MEMVAR oEditStru

/******
*       Editing and documenting of database structures
*/

PROCEDURE Main( cFile )

   LOCAL nModestHeight, ;
      aStru

   // Array of working parameters

   PRIVATE aStat := { 'CurrMode'   => MODE_DEFAULT , ;    // Review mode
      'FileName'   => ''           , ;    // Working file name
      'RDD'        => DbSetDriver(), ;    // Current database RDD
      'DefName'    => 'NEW'        , ;    // Field name prefix at adding
      'DefType'    => TYPE_IS_CHAR , ;    // Field type (numbet in array) CORRECT_TYPES
      'DefLen'     => 10           , ;    // Field length
      'DefDec'     => 0            , ;    // Field decimal
      'Expression' => THIS_VALUE   , ;    // Transformation rule
      'ChStruct'   => .F.          , ;    // Structure is changed
      'ChDescript' => .F.          , ;    // Description is changed
      'Counter'    => 1            , ;    // Internal counter (for new field adding)
      'Cargo'      => ''             ;    // Temporary saving of mixed datas
      }
   PRIVATE oEditStru                                      // TBrowse-object
   PRIVATE aCollector := {}                               // Collector of fields

   aStru := InitDefault()       // Set empty structure because of TsBrowse reguires the existing
   // of one value evethough

   SET Font to 'Tahoma', 9
   SET MenuStyle Extended
   SET NAVIGATION EXTENDED

   SetMenuTheme()

   GetOptions()                // Loading of params from INI

   DEFINE WINDOW wModest       ;
         At 0, 0              ;
         WIDTH 720            ;
         HEIGHT 580           ;
         TITLE APPNAME        ;
         ICON '1MODEST'       ;
         MAIN                 ;
         ON INIT ReSize()     ;
         On Size ReSize()     ;
         On Maximize ReSize() ;
         On Minimize ReSize() ;
         On InteractiveClose Done()

      // Creation of the program main menu

      DEFINE MAIN MENU

         DEFINE POPUP '&File'
            MENUITEM '&New' Action NewFile()               ;
               Image 'NEW_FILE'               ;
               Name pdNew                     ;
               Message 'Create new structure'
            MENUITEM '&Open' Action LoadFile() ;
               Image 'OPEN_FILE' ;
               Name pdOpen       ;
               Message 'Open file and load structure'
            MENUITEM '&Save' Action SaveData() ;
               Image 'SAVE'      ;
               Name pdSave       ;
               Message 'Save structure and description'
            SEPARATOR
            MENUITEM '&Print' Action PrintStructure() ;
               Image 'PRINT'           ;
               Name pdPrint            ;
               Message 'Print structure and comments'
            SEPARATOR
            MENUITEM 'E&xit Alt+X' Action { || Done(), ThisWindow.Release } ;
               Image 'HBPRINT_CLOSE'                    ;
               Message 'Exit from application'
         END POPUP

         DEFINE POPUP '&Edit'
            MENUITEM '&Copy'  Action AddInCollector( MODE_COPY ) ;
               Image 'COPY'                       ;
               Name pdCopy                        ;
               Message 'Copy to Collector'
            MENUITEM 'C&ut'   Action AddInCollector( MODE_CUT ) ;
               Image 'CUT'                       ;
               Name pdCut                        ;
               Message 'Cut to Collector'
            MENUITEM 'Paste (&After)' Action { || nShift := 1, PasteFromCollector() } ;
               Image 'PASTE'                                   ;
               Name pdPasteAfter                               ;
               Message 'Paste from Collector (after current)'
            MENUITEM 'Paste (&Before)' Action { || nShift := 0, PasteFromCollector() } ;
               Name pdPasteBefore                              ;
               Message 'Paste from Collector (before current)'
            SEPARATOR
            MENUITEM '&Description' Action EditGeneralDesc() ;
               Image 'EDIT_TEXT'        ;
               Name pdDescription       ;
               Message 'Modify database description'
         END POPUP

         DEFINE POPUP 'F&ield'
            MENUITEM '&Add' Action EditField( MODE_NEWFIELD ) ;
               Image 'ADD_FIELD'                 ;
               Name pdAdd                        ;
               Message 'Add new field'
            MENUITEM '&Edit' Action EditField( MODE_EDITFIELD ) ;
               Image 'EDIT_FIELD'                 ;
               Name pdEdit                        ;
               Message 'Edit current field'
            SEPARATOR
            MENUITEM '&Insert after' Action { || nShift := 1, EditField( MODE_INSFIELD ) } ;
               Image 'INS_FIELD'                                      ;
               Name pdInsertAfter                                    ;
               Message 'Insert field after current'
            MENUITEM 'Insert &before' Action { || nShift := 0, EditField( MODE_INSFIELD ) } ;
               Name pdInsertBefore                                   ;
               Message 'Insert field before current'
            SEPARATOR
            MENUITEM '&Delete' Action DelField() ;
               Image 'DEL_FIELD' ;
               Name pdDelete     ;
               Message 'Delete/Undelete field'
         END POPUP

         DEFINE POPUP '&Service'
            MENUITEM '&Export to text' Action ExportToTXT() ;
               Name pdExport        ;
               Message 'Export description to text file'
            SEPARATOR
            MENUITEM 'Clear &messages' Action ClearMsg() ;
               Message 'Clear messages area'
            MENUITEM 'Clear &Collector' Action ClearCollector() ;
               Message 'Clear Collector'
            SEPARATOR
            MENUITEM '&Options' Action Options() ;
               Image 'OPTIONS'  ;
               Message 'Set parameters application'
         END POPUP

         DEFINE POPUP '?' Name ppHelp
            MENUITEM '&About me' Action AboutMe() Image 'ABOUT'
         END POPUP

      END MENU

      // Toolbar

      DEFINE TOOLBAR tbrAction ButtonSize 24, 24 Flat
         Button btnNewFile         ;
            PICTURE 'NEW_FILE' ;
            ACTION NewFile()   ;
            TOOLTIP 'New file'
         Button btnOpenFile         ;
            PICTURE 'OPEN_FILE' ;
            ACTION LoadFile()   ;
            TOOLTIP 'Load structure from file'
         Button btnSave           ;
            PICTURE 'SAVE'    ;
            ACTION SaveData() ;
            TOOLTIP 'Save files'
         Button btnPrint Picture 'PRINT'               ;
            ACTION PrintStructure()                ;
            TOOLTIP 'Print structure and comments' ;
            SEPARATOR
         Button btnEditGeneral                        ;
            PICTURE 'EDIT_TEXT'                   ;
            ACTION EditGeneralDesc()              ;
            TOOLTIP 'Modify database description' ;
            SEPARATOR
         Button btnAddField                       ;
            PICTURE 'ADD_FIELD'               ;
            ACTION EditField( MODE_NEWFIELD ) ;
            TOOLTIP 'Add field'
         Button btnInsField                                           ;
            PICTURE 'INS_FIELD'                                   ;
            ACTION { || nShift := 1, EditField( MODE_INSFIELD ) } ;
            DropDown                                              ;
            TOOLTIP 'Insert field after current (default)'
         Button btnEditField                       ;
            PICTURE 'EDIT_FIELD'               ;
            ACTION EditField( MODE_EDITFIELD ) ;
            TOOLTIP 'Modify field'
         Button btnDeleteField         ;
            PICTURE 'DEL_FIELD'    ;
            ACTION DelField()      ;
            TOOLTIP 'Delete field' ;
            SEPARATOR
         Button btnCopy                            ;
            PICTURE 'COPY'                     ;
            ACTION AddInCollector( MODE_COPY ) ;
            TOOLTIP 'Copy to Collector'
         Button btnCut                            ;
            PICTURE 'CUT'                     ;
            ACTION AddInCollector( MODE_CUT ) ;
            TOOLTIP 'Cut to Collector'
         Button btnPaste                                               ;
            PICTURE 'PASTE'                                        ;
            ACTION { || nShift := 1, PasteFromCollector() }        ;
            DropDown                                               ;
            TOOLTIP 'Paste from Collector after current (default)' ;
            SEPARATOR
         Button btnOptions                           ;
            PICTURE 'OPTIONS'                    ;
            ACTION Options()                     ;
            TOOLTIP 'Set parameters application' ;
            SEPARATOR
         Button btnAbout         ;
            PICTURE 'ABOUT'  ;
            ACTION AboutMe() ;
            TOOLTIP 'About me'
      END Toolbar

      // Dropdown menu for inserting a new field

      Define dropdown menu button btnInsField
         MENUITEM 'Insert after'  Action { || nShift := 1, EditField( MODE_INSFIELD ) } ;
            Message 'Insert field after current'
         MENUITEM 'Insert before' Action { || nShift := 0, EditField( MODE_INSFIELD ) } ;
            Message 'Insert field before current'
      END MENU

      // Dropdown menu for inserting a field from collector

      Define dropdown menu button btnPaste
         MENUITEM 'Insert after'  Action { || nShift := 1, PasteFromCollector() } ;
            Message 'Paste from Collector (after current)'
         MENUITEM 'Insert before' Action { || nShift := 0, PasteFromCollector() } ;
            Message 'Paste from Collector (before current)'
      END MENU

      // Status bar
      // Declaration is placed before others definitions of controls,
      // because it is necessary for TsBrowse for show of position.

      DEFINE STATUSBAR Font 'Tahoma' Size 9
         StatusItem '' Default
         StatusItem '' Width 100                           // Show of position
         StatusItem '' Width 30                            // Changing indicator
         StatusItem aStat[ 'RDD' ] Width 100               // Current database RDD
      END STATUSBAR

      // Warning!
      // The all following coords of controls are conditional and changed by
      // procedure ReSize()

      // Table of existing fields

      DEFINE TBROWSE oEditStru                  ;
         At 40 + If(IsXPThemeActive(), 5, 0), 5  ;
         WIDTH 200                               ;
         HEIGHT 200                              ;
         ON CHANGE ShowValues()                  ;
         ON DBLCLICK EditField( MODE_EDITFIELD ) ;
         CELLED

      oEditStru : SetArray( aStru )

      // avoids changing of order by double clicking on column's headers

      oEditStru : lNoChangeOrd := .T.

      // 1st column (numbering) is freezed and locked

      oEditStru : nFreeze := 1
      oEditStru : lLockFreeze := .T.

      // Column of field's numbering

      Add column to TBrowse oEditStru                                      ;
         ShowBlock { | nNum | Iif( nNum == Nil, oEditStru : nAt, nNum ) } ;
         TITLE '#'                                                        ;
         Size 40                                                          ;
         Colors CLR_BLACK, CLR_HGRAY

      // Columns for datas

      Add column to TBrowse oEditStru                          ;
         DATA array element DBS_NAME                          ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         TITLE 'Name'                                         ;
         Size 100
      Add column to TBrowse oEditStru                          ;
         DATA array element DBS_TYPE                          ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         TITLE 'Type'                                         ;
         Size 50
      Add column to TBrowse oEditStru                          ;
         DATA array element DBS_LEN                           ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         TITLE 'Len'                                          ;
         Size 80
      Add column to TBrowse oEditStru                          ;
         DATA array element DBS_DEC                           ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         TITLE 'Dec'                                          ;
         Size 50
      Add column to TBrowse oEditStru                          ;
         DATA array element DBS_OLDNAME                       ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         TITLE 'Old name'                                     ;
         Size 100
      Add column to TBrowse oEditStru                          ;
         DATA array element DBS_OLDTYPE                       ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         TITLE 'Old type'                                     ;
         Size 50
      Add column to TBrowse oEditStru                          ;
         DATA array element DBS_OLDLEN                        ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         TITLE 'Old len'                                      ;
         Size 80
      Add column to TBrowse oEditStru                          ;
         DATA array element DBS_OLDDEC                        ;
         Colors CLR_BLACK, { | Pos, Col | BackColors( Pos, Col ) } ;
         TITLE 'Old dec'                                      ;
         Size 50

   END TBrowse

   DEFINE TAB tbDescript ;
         At 40 + If(IsXPThemeActive(), 5, 0), 205 ;
         WIDTH 340          ;
         HEIGHT 200

      DEFINE PAGE 'Field'

         // Field name

         @ 40, 15 Label lblName  ;
            VALUE 'Name'   ;
            WIDTH 50       ;
            HEIGHT 18      ;
            Bold           ;
            FONTCOLOR NAVY_COLOR
         @ 40, 40 TextBox txbName ;
            VALUE ''        ;
            WIDTH 90        ;
            MAXLENGTH 10    ;
            UPPERCASE

         // Field type

         @ 40, 80 Label lblType  ;
            VALUE 'Type'   ;
            HEIGHT 18      ;
            WIDTH 60       ;
            Bold           ;
            FONTCOLOR NAVY_COLOR
         @ 40, 100 ComboBox cmbType    ;
            WIDTH 40            ;
            HEIGHT 110          ;
            ITEMS CORRECT_TYPES ;
            VALUE 1             ;
            ListWidth 40        ;
            ON CHANGE ChangeMaxLimit()

         // Field length

         @ 60, 15 Label lblLen   ;
            VALUE 'Length' ;
            WIDTH 35       ;
            HEIGHT 18      ;
            Bold           ;
            FONTCOLOR NAVY_COLOR
         @ 60, 40 Spinner spnLen       ;
            Range 1, LEN_IS_CHAR ;
            VALUE 1              ;
            WIDTH 50             ;
            ON LOSTFOCUS ChangeMaxLimit()

         // Field decimal

         @ 60, 80 Label lblDec     ;
            VALUE 'Decimals' ;
            HEIGHT 18        ;
            Bold             ;
            FONTCOLOR NAVY_COLOR
         @ 60, 100 Spinner spnDec      ;
            Range 0, LEN_IS_NUM ;
            VALUE 0             ;
            WIDTH 50            ;
            ON LOSTFOCUS ChangeMaxLimit()

         // Comment of field

         @ 80, 5 Label lblComment ;
            VALUE 'Comment'   ;
            HEIGHT 18         ;
            WIDTH 60          ;
            Bold              ;
            FONTCOLOR NAVY_COLOR
         @ 120, 15 EditBox edtComment ;
            VALUE ''           ;
            NOHSCROLL          ;
            READONLY

         // Transformation rule of field contexts at the changing of value type

         @ 210, 5 Label lblRule               ;
            VALUE 'Transformation rule' ;
            HEIGHT 18                   ;
            WIDTH 130                   ;
            Bold                        ;
            FONTCOLOR NAVY_COLOR
         @ 230, 40 TextBox txbRule ;
            VALUE ''

         // Buttons Apply/Discard changes in field description

         @ 240, 110 ButtonEx btnFldOk              ;
            WIDTH 30 Height 30             ;
            ICON 'OK'                      ;
            ACTION FiniEditField( SET_OK ) ;
            TOOLTIP 'Apply changes [F2]'   ;
            Flat                           ;
            BACKCOLOR WHITE
         @ 240, 145 ButtonEx btnFldCancel              ;
            WIDTH 30 Height 30                 ;
            ICON 'CANCEL'                      ;
            ACTION FiniEditField( SET_CANCEL ) ;
            TOOLTIP 'Discard changes [Esc]'    ;
            Flat                               ;
            BACKCOLOR WHITE

      END PAGE

      DEFINE PAGE 'Database'

         // General description of database

         @ 30, 5 EditBox edtGeneral ;
            VALUE ''           ;
            NOHSCROLL          ;
            READONLY

         // Buttons Apply/Discard changes

         @ 240, 110 ButtonEx btnGeneralOk           ;
            WIDTH 30 Height 30              ;
            ICON 'OK'                       ;
            ACTION FiniEdtGeneral( SET_OK ) ;
            TOOLTIP 'Apply changes [F2]'    ;
            Flat                            ;
            BACKCOLOR WHITE
         @ 240, 145 ButtonEx btnGeneralCancel           ;
            WIDTH 30 Height 30                  ;
            ICON 'CANCEL'                       ;
            ACTION FiniEdtGeneral( SET_CANCEL ) ;
            TOOLTIP 'Discard changes [Esc]'     ;
            Flat                                ;
            BACKCOLOR WHITE
      END PAGE

      DEFINE PAGE 'Collector'

         // Collector of fields

         @ 30, 5 Grid grdCollector                                              ;
            HEADERS { 'Name', 'Type', 'Len', 'Dec', 'Comment' }            ;
            WIDTHS  { 80    , 45    , 40   , 40   , 102    }               ;
            DYNAMICBACKCOLOR { { | xVal, nItem | DynamicColors( nItem ) }, ;
            { | xVal, nItem | DynamicColors( nItem ) }, ;
            { | xVal, nItem | DynamicColors( nItem ) }, ;
            { | xVal, nItem | DynamicColors( nItem ) }, ;
            { | xVal, nItem | DynamicColors( nItem ) }  ;
            }
      END PAGE

   END TAB

   // Decoding of used colors in table

   @ 220, 5 Label lblLegend ;
      VALUE 'Legend:' ;
      HEIGHT 20       ;
      Bold            ;
      FONTCOLOR NAVY_COLOR  ;
      AUTOSIZE
   @ 220, 55 Label lblNew    ;
      VALUE 'New'     ;
      HEIGHT 18       ;
      WIDTH 60        ;
      CenterAlign     ;
      Border          ;
      BACKCOLOR { 227, 227, 234 }
   @ 220, 105 Label lblModified         ;
      VALUE 'Modified'          ;
      HEIGHT 18                 ;
      WIDTH 60                  ;
      CenterAlign               ;
      Border                    ;
      BACKCOLOR { 128, 255, 0 } ;
      FONTCOLOR BLACK
   @ 220, 155 Label lblDeleted            ;
      VALUE 'Deleted'             ;
      HEIGHT 18                   ;
      WIDTH 60                    ;
      CenterAlign                 ;
      Border                      ;
      BACKCOLOR { 255, 128, 128 } ;
      FONTCOLOR BLACK

   // System messages area

   @ 240, 5 EditBox edtMessages ;
      VALUE ''            ;
      HEIGHT 90           ;
      READONLY            ;
      BACKCOLOR WHITE

   On key Alt+X of wModest Action { || Done(), ReleaseAllWindows() }

END WINDOW

// If program starts with parameter when to load a structure. Certainly,
// if specified file exists, else it is considered, that a such file must be created.

IF ( Valtype( cFile ) == 'C' )

   IF File( cFile )
      GetStructure( cFile )
   ELSE
      WriteMsg( MSG_NEW_STRUCTURE )
   ENDIF

ELSE
   WriteMsg( MSG_NEW_STRUCTURE )

ENDIF

// Window title

SetWinTitle()

IF IsXPThemeActive()
   nModestHeight := wModest.Height + 10
   wModest.Height := nModestHeight
ENDIF

wModest.MinWidth := 720
wModest.MinHeight := GetProperty( 'wModest', 'Height' )

// All controls for editing are unavailable in review mode

wModest.txbName.Enabled := .F.
wModest.cmbType.Enabled := .F.
wModest.spnLen.Enabled  := .F.
wModest.spnDec.Enabled  := .F.
wModest.txbRule.Enabled := .F.

// Buttons Ok/Cancel

wModest.btnFldOk.Enabled     := .F.
wModest.btnFldCancel.Enabled := .F.

wModest.btnGeneralOk.Enabled     := .F.
wModest.btnGeneralCancel.Enabled := .F.

// Alignment in column
// 1st parameter - # column
// 2nd - level 1=Cell, 2=Header, 3=Footer
// 3rd - attribute DT_LEFT, DT_CENTER, DT_RIGHT and DT_VERT for header

oEditStru : SetAlign( 1, 1, DT_RIGHT )

wModest.oEditStru.SetFocus

CENTER WINDOW wModest
ACTIVATE WINDOW wModest

RETURN

****** End of Main ******

/******
*       Done() --> lSuccess
*       Program closing procedure
*/

FUNCTION Done

   MEMVAR aStat

   IF ( aStat[ 'ChStruct'   ] .or. ;
         aStat[ 'ChDescript' ]      ;
         )

      IF MsgYesNo( 'Data was changed. Would you like to save?', 'Attention', .F., , .F., .F. )
         SaveData()
      ENDIF

   ENDIF

   RETURN .T.

   ****** End of Done ******

   /******
   *       GetOptions()
   *       Parameters initialization
   */

STATIC PROCEDURE GetOptions

   MEMVAR aStat
   LOCAL cName  := '', ;
      nType  := 1, ;
      nLen   := 0 , ;
      nDec   := 0 , ;
      cRDD   := '', ;
      cValue := ''

   IF File( MODEST_INI )

      BEGIN INI FILE MODEST_INI

         // Common parameters

         GET cRDD   Section 'Common' Entry 'RDD'        Default ''
         GET cValue Section 'Common' Entry 'Expression' Default ''

         // Field attributes, which are used at the creating
         // the new fields.

         GET cName Section 'Field' Entry 'Field_Name' Default ''
         GET nType Section 'Field' Entry 'Field_Type' Default 0
         GET nLen  Section 'Field' Entry 'Field_Len'  Default 0
         GET nDec  Section 'Field' Entry 'Field_Dec'  Default 0

      END INI

      // Analyse of input datas.

      IF !Empty( cRDD )

         // Support for 2 RDD only

         IF ( ( cRDD == 'DBFCDX' ) .or. ( cRDD == 'DBFNTX' ) )
            aStat[ 'RDD' ] := cRDD
         ENDIF

      ENDIF

      IF !Empty( cValue )
         aStat[ 'Expression' ] := cValue
      ENDIF

      IF !Empty( cName )
         aStat[ 'DefName' ] := Left( AllTrim( cName ), 7 )
      ENDIF

      IF ( ( nType > 0 ) .and. ( nType <= Len( CORRECT_TYPES ) ) )
         aStat[ 'DefType' ] := nType
      ENDIF

      IF ( nLen >= 0 )
         aStat[ 'DefLen' ] := Min( nLen, LEN_IS_CHAR )
      ENDIF

      IF ( nDec >= 0 )
         aStat[ 'DefDec' ] := Min( nDec, LEN_IS_NUM )
      ENDIF

   ENDIF

   RETURN

   ****** End of GetOptions ******

   /******
   *       BackColors( nRow, nCol ) --> nColor
   *       Colors of fields table
   *       (color show of the changing)
   */

STATIC FUNCTION BackColors( nRow, nCol )

   MEMVAR oEditStru
   LOCAL nColor := CLR_WHITE

   IF !Empty( oEditStru : aArray[ nRow, DBS_NAME ] )

      DO CASE
      CASE  ( oEditStru : aArray[ nRow, DBS_FLAG ] == FLAG_INSERTED )
         // Added row
         nColor := RGB( 227, 227, 234 )

      CASE  ( oEditStru : aArray[ nRow, DBS_FLAG ] == FLAG_DELETED )
         // Deleted row
         nColor := RGB( 255, 128, 128 )

      OTHERWISE

         // Row with changed values

         IF ( ( nCol == 2 ) .or. ;          // Field name (current and previous)
               ( nCol == 6 )      ;
               )
            IF !( Eval( oEditStru : aColumns[ 2 ] : bData ) ==  Eval( oEditStru : aColumns[ 6 ] : bData ) )
               nColor := RGB( 128, 255, 0 )
            ENDIF

         ELSEIF ( ( nCol == 3 ) .or. ;      // Type (current and previous)
               ( nCol == 7 )      ;
               )
            IF !( Eval( oEditStru : aColumns[ 3 ] : bData ) ==  Eval( oEditStru : aColumns[ 7 ] : bData ) )
               nColor := RGB( 128, 255, 0 )
            ENDIF

         ELSEIF ( ( nCol == 4 ) .or. ;      // Length (current and previous)
               ( nCol == 8 )      ;
               )
            IF !( Eval( oEditStru : aColumns[ 4 ] : bData ) ==  Eval( oEditStru : aColumns[ 8 ] : bData ) )
               nColor := RGB( 128, 255, 0 )
            ENDIF

         ELSEIF ( ( nCol == 5 ) .or. ;      // Decimal
               ( nCol == 9 )      ;
               )
            IF !( Eval( oEditStru : aColumns[ 5 ] : bData ) ==  Eval( oEditStru : aColumns[ 9 ] : bData ) )
               nColor := RGB( 128, 255, 0 )
            ENDIF

         ENDIF

      ENDCASE

   ENDIF

   RETURN nColor

   ****** End of BackColors ******

   /******
   *       DynamicColors( nItem )
   *       Colors in the collector table
   */

STATIC FUNCTION DynamicColors( nItem )

   MEMVAR aCollector
   LOCAL nColor := RGB( 255, 255, 255 )

   // We will show in color only records with attributes
   // "New element" �nd "Deleted element"

   IF !Empty( aCollector )

      IF ( nItem > 0 )

         IF ( aCollector[ nItem, DBS_FLAG ] == FLAG_INSERTED )
            // Added row
            nColor := RGB( 227, 227, 234 )

         ELSEIF ( aCollector[ nItem, DBS_FLAG ] == FLAG_DELETED )
            // Deleted row
            nColor := RGB( 255, 128, 128 )

         ENDIF

      ENDIF

   ENDIF

   RETURN nColor

   ****** End of DynamicColors ******

   /******
   *       InitDefault() --> aStru
   *       "Empty" structure
   */

STATIC FUNCTION InitDefault

   MEMVAR aStat
   LOCAL aStru := Array( DBS_NEW_ALEN )

   aStat[ 'FileName'   ] := ''           // Working file
   aStat[ 'ChStruct'   ] := .F.          // Changing is absent
   aStat[ 'ChDescript' ] := .F.
   aStat[ 'Counter'    ] := 1            // Counter is reestablished

   RETURN { aStru }

   ****** End of InitDefault ******

   /******
   *       AboutMe()
   *       About program
   */

STATIC PROCEDURE AboutMe

   LOAD WINDOW AboutMe as wAboutMe

   wAboutMe.lblAppName.Value    := APPNAME
   wAboutMe.lblAppVersion.Value := APPVERSION
   wAboutMe.lblCopyright.Value  := ( 'Author:' + COPYRIGHT )
   wAboutMe.lblComponents.Value := ( HB_Compiler()    + CRLF + ;
      Version()        + CRLF + ;
      MiniGuiVersion()          ;
      )

   On key Escape of wAboutMe Action wAboutMe.Release()
   On key Alt+X of wAboutMe Action { || Done(), ReleaseAllWindows() }  // Hotkey for urgent program closing

   CENTER WINDOW wAboutMe
   ACTIVATE WINDOW wAboutMe

   RETURN

   ****** End of AboutMe ******

   /******
   *       ReSize()
   *       Arranging of controls size to main window size
   *       It will change the initial arrangement, which is doing in the main procedure
   */

STATIC PROCEDURE ReSize

   MEMVAR oEditStru
   LOCAL nHeight := ( wModest.Height - 215 - IF(IsXPThemeActive(), 15, 0) )

   // Tab control

   wModest.tbDescript.Col    := ( wModest.Width - wModest.tbDescript.Width - 15 )
   wModest.tbDescript.Height := nHeight

   // Field name

   wModest.txbName.Row := ( wModest.lblName.Row - 2 )
   wModest.txbName.Col := ( wModest.lblName.Col + wModest.lblName.Width + 5 )

   // Field type

   wModest.lblType.Row   := wModest.lblName.Row
   wModest.lblType.Col   := ( wModest.txbName.Col + wModest.txbName.Width + 50 )

   wModest.cmbType.Row := ( wModest.lblType.Row - 2 )
   wModest.cmbType.Col := ( wModest.lblType.Col + wModest.lblType.Width + 15 )

   // Field length

   wModest.lblLen.Row   := ( wModest.lblName.Row + 44 )
   wModest.lblLen.Col   := wModest.lblName.Col
   wModest.lblLen.Width := wModest.lblName.Width

   wModest.spnLen.Row := ( wModest.lblLen.Row - 4 )
   wModest.spnLen.Col := ( wModest.txbName.Col + ( wModest.txbName.Width - wModest.spnLen.Width + 5 ) )

   // Decimal

   wModest.lblDec.Row   := wModest.lblLen.Row
   wModest.lblDec.Col   := wModest.lblType.Col
   wModest.lblDec.Width := wModest.lblType.Width

   wModest.spnDec.Row := wModest.spnLen.Row
   wModest.spnDec.Col := ( wModest.cmbType.Col - 10 )

   // Description of field

   wModest.lblComment.Row :=  ( wModest.lblLen.Row + 40 )
   wModest.lblComment.Col := wModest.lblName.Col

   wModest.edtComment.Row := ( wModest.lblComment.Row + 20 )
   wModest.edtComment.Col := wModest.lblComment.Col
   wModest.edtComment.Height := ( nHeight - wModest.lblComment.Row - 145 )
   wModest.edtComment.Width  := ( wModest.tbDescript.Width - 30 )

   // Transformation rule at the type changing

   wModest.lblRule.Row :=  ( wModest.edtComment.Row + wModest.edtComment.Height + 20 )
   wModest.lblRule.Col := wModest.lblName.Col

   wModest.txbRule.Row   := ( wModest.lblRule.Row + 20 )
   wModest.txbRule.Col   := wModest.lblRule.Col
   wModest.txbRule.Width := wModest.edtComment.Width

   // Ok/Cancel

   wModest.btnFldOk.Row := ( wModest.txbRule.Row + wModest.txbRule.Height + 15 )
   wModest.btnFldOk.Col := ( wModest.tbDescript.Width - 80 )

   wModest.btnFldCancel.Row := wModest.btnFldOk.Row
   wModest.btnFldCancel.Col := ( wModest.btnFldOk.Col + wModest.btnFldOk.Width + 5 )

   // System messages

   wModest.edtMessages.Row   := ( wModest.oEditStru.Row + nHeight + 10 )
   wModest.edtMessages.Col   := wModest.oEditStru.Col
   wModest.edtMessages.Width := ( wModest.Width - 20 )

   // Field table

   wModest.oEditStru.Height := ( nHeight - 33 )
   wModest.oEditStru.Width  := ( wModest.Width - wModest.tbDescript.Width - 25 )

   oEditStru : Refresh()

   // Decoding of table colors

   wModest.lblLegend.Row := ( wModest.oEditStru.Row + wModest.oEditStru.Height + 15 )
   wModest.lblLegend.Col := wModest.oEditStru.Col

   wModest.lblNew.Row := ( wModest.lblLegend.Row - 2 )
   wModest.lblNew.Col := ( wModest.lblLegend.Col + wModest.lblLegend.Width + 5 )

   wModest.lblModified.Row := wModest.lblNew.Row
   wModest.lblModified.Col := (wModest.lblNew.Col + wModest.lblNew.Width + 5 )

   wModest.lblDeleted.Row := wModest.lblNew.Row
   wModest.lblDeleted.Col := ( wModest.lblModified.Col + wModest.lblModified.Width + 5 )

   // Description of database

   wModest.edtGeneral.Width  := ( wModest.tbDescript.Width - 12 )
   wModest.edtGeneral.Height := ( wModest.tbDescript.Height - 85 )

   // Description editing (Ok/Cancel)

   wModest.btnGeneralOk.Row := wModest.btnFldOk.Row
   wModest.btnGeneralOk.Col := wModest.btnFldOk.Col

   wModest.btnGeneralCancel.Row := wModest.btnGeneralOk.Row
   wModest.btnGeneralCancel.Col := wModest.btnFldCancel.Col

   // Collector

   wModest.grdCollector.Width  := ( wModest.tbDescript.Width - 12 )
   wModest.grdCollector.Height := ( wModest.tbDescript.Height - 40 )

   // Refresh the all aboved movings

   InvalidateRect( Application.Handle, 0 )

   RETURN

   ****** End of ReSize ******

   /******
   *       SetWinTitle()
   *       Show info about working file at the window title
   */

PROCEDURE SetWinTitle

   MEMVAR aStat

   IF !Empty( aStat[ 'FileName' ] )
      wModest.Title := APPNAME + ' - ' + aStat[ 'FileName' ]
   ELSE
      wModest.Title := APPNAME + ' - New file'
   ENDIF

   RETURN

   ****** End of SetWinTitle ******

   /******
   *       SetIconSave( nIcon )
   *       Show the icon of saving necessity in status
   */

PROCEDURE SetIconSave( nIcon )

   wModest.StatusBar.Icon( 3 ) := IIf( ( nIcon == 1 ), 'MUST_SAVE', '' )

   RETURN

   ****** End of SetIconSave ******

   /******
   *       SetRDDName()
   *       Show the current database RDD in status
   */

PROCEDURE SetRDDName

   MEMVAR aStat

   wModest.StatusBar.Item( 4 ) := aStat[ 'RDD' ]

   RETURN

   ****** End of SetRDDName ******

   /******
   *       ShowValues()
   *       Filling and show the current values in the editing fields
   */

STATIC PROCEDURE ShowValues

   MEMVAR oEditStru
   LOCAL nRow := oEditStru : nAt, ;
      nPos

   IF !Empty( oEditStru : aArray[ nRow, DBS_NAME ] )
      wModest.txbName.Value := oEditStru : aArray[ nRow, DBS_NAME ]

      IF !Empty( nPos := AScan( CORRECT_TYPES, oEditStru : aArray[ nRow, DBS_TYPE ] ) )
         wModest.cmbType.Value := nPos
      ELSE
         wModest.cmbType.Value := TYPE_IS_CHAR
      ENDIF

      wModest.spnLen.Value     := oEditStru : aArray[ nRow, DBS_LEN     ]
      wModest.spnDec.Value     := oEditStru : aArray[ nRow, DBS_DEC     ]
      wModest.edtComment.Value := oEditStru : aArray[ nRow, DBS_COMMENT ]
      wModest.txbRule.Value    := oEditStru : aArray[ nRow, DBS_RULE    ]

      wModest.StatusBar.Item( 2 ) := ( LTrim( Str( nRow ) ) + '/' + LTrim( Str( Len( oEditStru : aArray ) ) ) )

   ELSE

      wModest.StatusBar.Item( 2 ) := 'Empty'

   ENDIF

   RETURN

   ****** End of ShowValues *****

   /******
   *       WriteMsg( cMessage )
   *       Filling the messages area
   */

PROCEDURE WriteMsg( cMessage )

   LOCAL cText := GetProperty( 'wModest', 'edtMessages', 'Value' )

   cText += ( cMessage + CRLF )
   SetProperty( 'wModest', 'edtMessages', 'Value', cText )

   // Showing of last row

   SendMessage( GetControlHandle( 'edtMessages', 'wModest' ), WM_VSCROLL, SB_BOTTOM, 0 )

   RETURN

   ****** End of WriteMsg ******

   /******
   *       ClearCollector()
   *       Clear of the collector
   */

STATIC PROCEDURE ClearCollector

   MEMVAR aCollector

   IF MsgYesNo( 'Clear Collector?', 'Confirm', .T., , .F., .F. )
      aCollector := {}
      FillCollector()
   ENDIF

   RETURN

   ****** End of ClearCollector ******

   /******
   *       ClearMsg()
   *       Clear of the messages area
   */

STATIC PROCEDURE ClearMsg

   IF MsgYesNo( 'Clear messages area?', 'Confirm', .T., , .F., .F. )
      SetProperty( 'wModest', 'edtMessages', 'Value', '' )
      SendMessage( GetControlHandle( 'edtMessages', 'wModest' ), WM_VSCROLL, SB_TOP, 0 )
   ENDIF

   RETURN

   ****** End of ClearMsg ******

   /******
   *       StructASize( aStructure ) --> aStructure
   *       Expanded array of structure description
   */

STATIC FUNCTION StructASize( aStructure )

   AEval( aStructure, { | elem | ASize( elem, DBS_NEW_ALEN )            , ;
      elem[ DBS_COMMENT ] := ''              , ;
      elem[ DBS_FLAG    ] := FLAG_DEFAULT    , ;
      elem[ DBS_OLDNAME ] := elem[ DBS_NAME ], ;
      elem[ DBS_OLDTYPE ] := elem[ DBS_TYPE ], ;
      elem[ DBS_OLDLEN  ] := elem[ DBS_LEN  ], ;
      elem[ DBS_OLDDEC  ] := elem[ DBS_DEC  ], ;
      elem[ DBS_RULE    ] := ''                ;
      } )

   RETURN aStructure

   ****** End of StructASize ******

   /******
   *       InvertEnable( cName )
   *       Inverting of the attribute Enabled for one element
   */

STATIC PROCEDURE InvertEnable( cName )

   LOCAL lEnable := GetProperty( 'wModest', cName, 'Enabled' )

   SetProperty( 'wModest', cName, 'Enabled', !lEnable )

   RETURN

   ****** End of InvertEnable ******

   /******
   *       InvertReadOnly( cName )
   *       Inverting of the attribute ReadOnly for one element
   */

STATIC PROCEDURE InvertReadOnly( cName )

   LOCAL lReadOnly := GetProperty( 'wModest', cName, 'ReadOnly' )

   SetProperty( 'wModest', cName, 'ReadOnly', !lReadOnly )

   RETURN

   ****** End of InvertReadOnly ******

   /******
   *       InvertForEdit( lEnabled )
   *       Inverting of the attributes (menu, toolbar)
   *       at the editing
   */

STATIC PROCEDURE InvertForEdit( lEnabled )

   // Menu

   // Access to menu items are changed here, but is not in procedure InvertEnable(),
   // because the function GetProperty() no determine the current value of property Enabled
   // for menu item

   // File

   SetProperty( 'wModest', 'pdNew'  , 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdOpen' , 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdSave' , 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdPrint', 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdNew'  , 'Enabled', lEnabled )

   // Edit

   SetProperty( 'wModest', 'pdCopy'       , 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdCut'        , 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdPasteAfter' , 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdPasteBefore', 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdDescription', 'Enabled', lEnabled )

   // Field

   SetProperty( 'wModest', 'pdAdd'         , 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdInsertAfter' , 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdInsertBefore', 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdEdit'        , 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdDelete'      , 'Enabled', lEnabled )
   SetProperty( 'wModest', 'pdExport'      , 'Enabled', lEnabled )

   // Toolbar

   InvertEnable( 'btnNewFile' )
   InvertEnable( 'btnOpenFile' )
   InvertEnable( 'btnSave' )
   InvertEnable( 'btnPrint' )
   InvertEnable( 'btnAddField' )
   InvertEnable( 'btnInsField' )
   InvertEnable( 'btnEditField' )
   InvertEnable( 'btnDeleteField' )
   InvertEnable( 'btnCopy' )
   InvertEnable( 'btnCut' )
   InvertEnable( 'btnPaste' )
   InvertEnable( 'btnEditGeneral' )

   RETURN

   ****** End of InvertForEdit ******

   /*****
   *       InvertForGeneral()
   *       Inverting of elements availability at the editing
   *       of general database description
   */

STATIC PROCEDURE InvertForGeneral

   MEMVAR oEditStru

   // Fields list

   InvertEnable( 'oEditStru' )

   // Editing field and buttons Ok/Cancel

   InvertReadOnly( 'edtGeneral' )
   InvertEnable( 'btnGeneralOk' )
   InvertEnable( 'btnGeneralCancel' )

   RETURN

   ****** End of InvertForGeneral ******

   /******
   *       InvertForFields()
   *       Changing of elements availability at the editing
   *       of field characteristics
   */

STATIC PROCEDURE InvertForFields

   // Field list

   InvertEnable( 'oEditStru' )

   // Editing is available

   InvertEnable( 'txbName' )
   InvertEnable( 'cmbType' )
   InvertEnable( 'spnLen' )
   InvertEnable( 'spnDec' )
   InvertReadOnly( 'edtComment' )

   InvertEnable( 'btnFldOk' )
   InvertEnable( 'btnFldCancel' )

   RETURN

   ****** End of InvertForFields ******

   /******
   *       GetStructure( cFile )
   *       Loading of existing structure
   */

STATIC PROCEDURE GetStructure( cFile )

   MEMVAR aStat, oEditStru
   LOCAL aStru := {}, ;
      nPos       , ;
      cName      , ;
      cRDD

   Try

      // Select RDD

      IF ( ( nPos := RAt( '.', cFile ) ) > 0 )

         IF !Empty( cName := Left( cFile, nPos ) )

            IF File( cName + 'FPT' )
               cRDD := 'DBFCDX'
            ELSE
               cRDD := aStat[ 'RDD' ]
            ENDIF

         ENDIF

      ENDIF

      // Reading the database structure, array is transformed to working format.
      // The database is closed after reading.

      DbUseArea( , cRDD, cFile,, .T. )
      aStru := DbStruct()
      aStru := StructASize( aStru )
      DbCloseAll()

      // Filling of comments.

      IF ( nPos > 0 )
         cName := ( Left( cFile, nPos ) + 'XML' )
         IF File( cName )
            aStru := LoadXML( cName, aStru )
         ENDIF
      ENDIF

      WriteMsg( cFile + MSG_STRUCTURE_LOADED )

      aStat[ 'FileName'   ] := cFile
      aStat[ 'RDD'        ] := cRDD
      aStat[ 'ChStruct'   ] := .F.          // Changing is absent
      aStat[ 'ChDescript' ] := .F.
      aStat[ 'Counter'    ] := 1            // Counter is reestablished

      SetWinTitle()
      SetIconSave( 0 )
      SetRDDName()

   CATCH
      WriteMsg( MSG_ERROR_LOAD + cFile )

   END

   // If array is empty when to do the initialization

   IF Empty( aStru )
      aStru := InitDefault()
      SetWinTitle()
   ENDIF

   oEditStru : SetArray( aStru )
   oEditStru : Display()

   oEditStru : goTop()
   oEditStru : Refresh()

   RETURN

   ****** End of GetStructure ******

   /******
   *       LoadXML( cFile, aStru ) --> aStru
   *       Filling of comments of fields
   */

STATIC FUNCTION LoadXML( cFile, aStru )

   LOCAL oXMLDoc  := TXMLDocument() : New(), ;
      oXMLNode                          , ;
      cName                             , ;
      cField                            , ;
      nPos

   oXMLDoc : Read( Memoread( cFile ) )

   oXMLNode := oXMLDoc : FindFirst()

   // Usually for positioning to the needed XML node it is used the
   // function FindFirst() with node name as parameter. But
   // for me this function finds only root node.
   // Therefore desctiption analyse we will do by exhaustive search of the all nodes.

   DO WHILE ( Valtype( oXMLNode ) == 'O' )

      cName := oXMLNode : cName                    // Node name

      DO CASE
      CASE ( cName == XML_TAG_DESCRIPTION )     // Description of database
         wModest.edtGeneral.Value := oXMLNode : cData

      CASE ( cName == XML_TAG_FIELD )           // Description of field row

         // Filling array with only existing description

         IF !Empty( oXMLNode : cData )

            cField := Upper( oXMLNode : GetAttribute( XML_ATTR_NAME ) )

            IF !Empty( nPos := AScan( aStru, { | elem | Upper( elem[ DBS_NAME ] ) == cField } ) )
               aStru[ nPos, DBS_COMMENT ] := AllTrim( oXMLNode : cData )
            ENDIF
         ENDIF

      ENDCASE

      // Go to the next node

      oXmlNode := oXMLDoc : FindNext()

   ENDDO

   RETURN aStru

   ****** End of LoadXML ******

   /******
   *       NewFile()
   *       Create a new structure
   */

STATIC PROCEDURE NewFile

   MEMVAR aStat, oEditStru
   LOCAL aStru

   IF ( aStat[ 'ChStruct'   ] .or. ;
         aStat[ 'ChDescript' ]      ;
         )

      IF MsgYesNo( 'Data changed. Save?', 'Attention', .T., , .F., .F. )
         IF !SaveData()

            RETURN
         ENDIF
      ENDIF

   ENDIF

   aStru := InitDefault()
   oEditStru : SetArray( aStru )

   oEditStru : Display()

   oEditStru : goTop()
   oEditStru : Refresh()

   // Change the datas which ate show in editing fields.

   wModest.txbName.Value    := ''
   wModest.cmbType.Value    := TYPE_IS_CHAR
   wModest.spnLen.Value     := 1
   wModest.spnDec.Value     := 0
   wModest.edtComment.Value := ''
   wModest.txbRule.Value    := ''

   wModest.edtGeneral.Value := ''

   SetWinTitle()
   SetIconSave( 0 )

   WriteMsg( MSG_NEW_STRUCTURE )

   RETURN

   ****** End of NewFile ******

   /******
   *       LoadFile()
   *       Loading of database structure
   */

STATIC PROCEDURE LoadFile

   MEMVAR aStat
   LOCAL cFile

   IF ( aStat[ 'ChStruct'   ] .or. ;
         aStat[ 'ChDescript' ]      ;
         )

      IF MsgYesNo( 'Data changed. Save?', 'Attention', .T., , .F., .F. )
         IF !SaveData()

            RETURN
         ENDIF
      ENDIF

   ENDIF

   cFile := GetFile( FILEDLG_FILTER, 'Select dBASE file', , .F., .T. )

   IF !Empty( cFile )
      GetStructure( cFile )
   ENDIF

   RETURN

   ****** End of LoadFile ******

   /******
   *       EditGeneralDesc()
   *       Editing of general database description
   */

STATIC PROCEDURE EditGeneralDesc

   MEMVAR aStat

   // Available only controls which are needed for editing

   InvertForEdit( .F. )         // Locking of menu, toolbar
   InvertForGeneral()           // Tab controls

   // Save the current value (for possible refusal from changing)

   aStat[ 'Cargo' ] := wModest.edtGeneral.Value

   // Show needed tab and buttons

   wModest.tbDescript.Value := 2

   wModest.StatusBar.Item( 1 ) := ( 'Edit general base description. ' + SHORTKEY_TOOLTIP )

   // Assignment of hotkeys

   On key F2 of wModest Action FiniEdtGeneral( SET_OK )
   On key Escape of wModest Action FiniEdtGeneral( SET_CANCEL )

   wModest.edtGeneral.SetFocus

   RETURN

   ****** End of EditGeneralDesc ******

   /******
   *       FiniEdtGeneral( nMode )
   *       Finish of editing of general database description
   */

STATIC PROCEDURE FiniEdtGeneral( nMode )

   MEMVAR aStat, oEditStru

   IF ( nMode == SET_CANCEL )

      // Restore the previous value
      wModest.edtGeneral.Value := aStat[ 'Cargo' ]

   ELSE

      // Check for changing
      aStat[ 'ChDescript' ] := !( wModest.edtGeneral.Value == aStat[ 'Cargo' ] )

   ENDIF

   aStat[ 'Cargo' ] := ''

   // Open the locked controls

   InvertForEdit( .T. )        // Menu, toolbar
   InvertForGeneral()          // Tab controls

   IF aStat[ 'ChDescript' ]
      SetIconSave( 1 )
   ENDIF

   wModest.StatusBar.Item( 1 ) := ''

   RELEASE key F2 of wModest
   RELEASE key Escape of wModest

   wModest.oEditStru.SetFocus

   RETURN

   ****** End of FiniEdtGeneral ******

   /******
   *       EditField( nMode )
   *       Field's editing
   */

STATIC PROCEDURE EditField( nMode )

   MEMVAR aStat, oEditStru
   LOCAL nRow, ;
      nPos

   // ���������� ��������������. �������� � ���, �� ��� ������������
   // ����� �� PageDown �������� ���� ������ �� �������� ��������, �
   // ���� ���� ��������� ������ � TsBrowse �� ���������� � �����
   // On change

   ShowValues()
   nRow := oEditStru : nAt

   // �������� ���������� ��������� ��������� ��������. ���� ����� ���� �������,
   // �������, �� ��������� �� ���������. � ����� ������� ������������ ����
   // ��������� ������ ����.

   IF ( ( nMode == MODE_INSFIELD  ) .or. ;
         ( nMode == MODE_EDITFIELD )      ;
         )

      IF Empty( oEditStru : aArray[ nRow, DBS_NAME ] )

         // ���� �������� �������� ������� ��� ����������� ������ � �������� ��������,
         // ���������� �� ����� ���������.

         nMode := MODE_NEWFIELD

      ENDIF

   ENDIF

   IF ( nMode == MODE_EDITFIELD )      // �����������. �������� �������.

      wModest.txbName.Value := oEditStru : aArray[ nRow, DBS_NAME ]

      IF !Empty( nPos := AScan( CORRECT_TYPES, oEditStru : aArray[ nRow, DBS_TYPE ] ) )
         wModest.cmbType.Value := nPos
      ELSE
         wModest.cmbType.Value := aStat[ 'DefType' ]
      ENDIF

      wModest.spnLen.Value     := oEditStru : aArray[ nRow, DBS_LEN     ]
      wModest.spnDec.Value     := oEditStru : aArray[ nRow, DBS_DEC     ]
      wModest.edtComment.Value := oEditStru : aArray[ nRow, DBS_COMMENT ]
      wModest.txbRule.Value    := oEditStru : aArray[ nRow, DBS_RULE    ]

      // ������� ������������

      aStat[ 'Cargo' ] := Upper( AllTrim( wModest.txbRule.Value ) )

   ELSE
      wModest.txbName.Value    := ( aStat[ 'DefName' ] + StrZero( aStat[ 'Counter' ], 3 ) )
      wModest.cmbType.Value    := aStat[ 'DefType' ]
      wModest.spnLen.Value     := aStat[ 'DefLen'  ]
      wModest.spnDec.Value     := aStat[ 'DefDec'  ]
      wModest.edtComment.Value := ''
      wModest.txbRule.Value    := ''

   ENDIF

   // �������� ���������� ����� ��������, ��������� ��� �����������

   InvertForEdit( .F. )      // ����, ������ �����������
   InvertForFields()         // �������� �������

   // ������������ ���� ������� ������������ ����� �� ���� ����� � �����
   // ����������� (���� ����� ��������)
   // TODO: ��������� ��������� ������ ����� � ������ � ����������
   // �������� ������

   IF ( nMode == MODE_EDITFIELD )
      InvertEnable( 'txbRule' )
   ENDIF

   wModest.tbDescript.Value := 1           // ³��������� ������� ��������

   DO CASE
   CASE ( nMode == MODE_NEWFIELD )
      aStat[ 'CurrMode' ] := MODE_NEWFIELD
      wModest.StatusBar.Item( 1 ) := ( 'Create new field. ' + SHORTKEY_TOOLTIP )

   CASE ( nMode == MODE_INSFIELD )
      aStat[ 'CurrMode' ] := MODE_INSFIELD
      wModest.StatusBar.Item( 1 ) := ( 'Insert ' + Iif( ( nShift < 0 ), '(before)', '(after)' ) + ;
         ' new field. ' + SHORTKEY_TOOLTIP )

   CASE ( nMode == MODE_EDITFIELD )
      aStat[ 'CurrMode' ] := MODE_EDITFIELD
      wModest.StatusBar.Item( 1 ) := ( 'Edit current field. ' + SHORTKEY_TOOLTIP )

   ENDCASE

   // ����������� ����� ��� �������� ���������� �����������

   On key F2 of wModest Action FiniEditField( SET_OK )
   On key Escape of wModest Action FiniEditField( SET_CANCEL )

   wModest.txbName.SetFocus

   RETURN

   ****** End of EditField ******

   /******
   *       ChangeMaxLimit()
   *       Changing of max field size limit in dependence from type
   */

STATIC PROCEDURE ChangeMaxLimit

   // �������� ������������ ��������� ���� �� ������� �������.
   // ��� ������� ���� �� �� ����� ������������� ������� ���� ����� 1,
   // ���� ������� - 10. �, ��������, ��� ���� �� ������� ���� ������ �������.
   // � ���� �� ���������� 8.

   DO CASE
   CASE ( wModest.cmbType.Value == TYPE_IS_CHAR )
      wModest.spnLen.RangeMax := LEN_IS_CHAR
      wModest.spnLen.Value    := Min( LEN_IS_CHAR, wModest.spnLen.Value )

      // ��� ���������� ���� ������������ ��������� ������ �������.
      // � Clipper �� ��������� ����� ����� ���� �������� ���������
      // ������� ����.

      wModest.spnDec.RangeMax := LEN_IS_NUM
      wModest.spnDec.Value    := Min( LEN_IS_CHAR, wModest.spnDec.Value )

   CASE ( wModest.cmbType.Value == TYPE_IS_NUM )
      wModest.spnLen.RangeMax := LEN_IS_NUM
      wModest.spnLen.Value    := Min( LEN_IS_NUM, wModest.spnLen.Value )

      wModest.spnDec.RangeMax := LEN_IS_NUM
      wModest.spnDec.Value    := Min( LEN_IS_CHAR, wModest.spnDec.Value )

   CASE ( wModest.cmbType.Value == TYPE_IS_DATE )
      wModest.spnLen.RangeMax := LEN_IS_DATE
      wModest.spnLen.Value    := LEN_IS_DATE

      wModest.spnDec.RangeMax := 0
      wModest.spnDec.Value    := 0

   CASE ( wModest.cmbType.Value == TYPE_IS_LOGIC )
      wModest.spnLen.RangeMax := LEN_IS_LOGIC
      wModest.spnLen.Value    := LEN_IS_LOGIC

      wModest.spnDec.RangeMax := 0
      wModest.spnDec.Value    := 0

   CASE ( wModest.cmbType.Value == TYPE_IS_MEMO )
      wModest.spnLen.RangeMax := LEN_IS_MEMO
      wModest.spnLen.Value    := LEN_IS_MEMO
      wModest.spnDec.RangeMax := 0
      wModest.spnDec.Value    := 0

   ENDCASE

   RETURN

   ****** End of ChangeMaxLimit ******

   /******
   *       FiniEditField( nMode )
   *       Finish the field editing
   */

STATIC PROCEDURE FiniEditField( nMode )

   MEMVAR aStat, oEditStru
   LOCAL nRow := oEditStru : nAt, ;
      aItem                  , ;
      nType := wModest.cmbType.Value

   IF ( nMode == SET_OK )

      // ��������� ����������� �������� �����

      IF !CheckData()

         RETURN
      ENDIF

      // �������� ����

      IF ( ( aStat[ 'CurrMode' ] == MODE_NEWFIELD ) .or. ;
            ( aStat[ 'CurrMode' ] == MODE_INSFIELD )      ;
            )

         aItem := Array( DBS_NEW_ALEN )

         aItem[ DBS_FLAG    ] := FLAG_INSERTED
         aItem[ DBS_NAME    ] := wModest.txbName.Value
         aItem[ DBS_TYPE    ] := CORRECT_TYPES[ nType ]
         aItem[ DBS_LEN     ] := wModest.spnLen.Value
         aItem[ DBS_DEC     ] := wModest.spnDec.Value
         aItem[ DBS_OLDNAME ] := ''
         aItem[ DBS_OLDTYPE ] := ''
         aItem[ DBS_OLDLEN  ] := 0
         aItem[ DBS_OLDDEC  ] := 0
         aItem[ DBS_COMMENT ] := wModest.edtComment.Value
         aItem[ DBS_RULE    ] := wModest.txbRule.Value

         aStat[ 'Counter'    ] ++
         aStat[ 'ChStruct'   ] := .T.
         aStat[ 'ChDescript' ] := .T.

      ENDIF

      DO CASE
      CASE ( aStat[ 'CurrMode' ] == MODE_NEWFIELD )

         IF Empty( oEditStru : aArray[ 1, DBS_NAME ] )
            oEditStru : aArray[ 1, DBS_FLAG    ] := FLAG_INSERTED
            oEditStru : aArray[ 1, DBS_NAME    ] := wModest.txbName.Value
            oEditStru : aArray[ 1, DBS_TYPE    ] := CORRECT_TYPES[ nType ]
            oEditStru : aArray[ 1, DBS_LEN     ] := wModest.spnLen.Value
            oEditStru : aArray[ 1, DBS_DEC     ] := wModest.spnDec.Value
            oEditStru : aArray[ 1, DBS_OLDNAME ] := ''
            oEditStru : aArray[ 1, DBS_OLDTYPE ] := ''
            oEditStru : aArray[ 1, DBS_OLDLEN  ] := 0
            oEditStru : aArray[ 1, DBS_OLDDEC  ] := 0
            oEditStru : aArray[ 1, DBS_COMMENT ] := wModest.edtComment.Value
            oEditStru : aArray[ 1, DBS_RULE    ] := wModest.txbRule.Value

         ELSE
            nRow := ( oEditStru : nLen + 1 )
            oEditStru : Insert( aItem, nRow )
            oEditStru : GoPos( nRow, 2 )
            oEditStru : Display()
         ENDIF

      CASE ( aStat[ 'CurrMode' ] == MODE_INSFIELD )

         // ����� ������������ ���� ��������� (nShift == 1) ��� �������� (nShift == 0)

         oEditStru : Insert( aItem, nRow + nShift )
         oEditStru : Display()

      CASE ( aStat[ 'CurrMode' ] == MODE_EDITFIELD )

         // �� ��������

         IF ( !( oEditStru : aArray[ nRow, DBS_NAME ] == wModest.txbName.Value  ) .or. ;
               !( oEditStru : aArray[ nRow, DBS_TYPE ] == CORRECT_TYPES[ nType ] ) .or. ;
               !( oEditStru : aArray[ nRow, DBS_LEN  ] == wModest.spnLen.Value   ) .or. ;
               !( oEditStru : aArray[ nRow, DBS_DEC  ] == wModest.spnDec.Value   )      ;
               )
            aStat[ 'ChStruct' ] := .T.
         ENDIF

         IF !( oEditStru : aArray[ nRow, DBS_COMMENT ] == wModest.edtComment.Value )
            aStat[ 'ChDescript' ] := .T.
         ENDIF

         IF !( Upper( AllTrim( wModest.txbRule.Value ) ) == aStat[ 'Cargo' ] )
            aStat[ 'ChStruct' ] := .T.
         ENDIF

         oEditStru : aArray[ nRow, DBS_NAME    ] := wModest.txbName.Value
         oEditStru : aArray[ nRow, DBS_TYPE    ] := CORRECT_TYPES[ nType ]
         oEditStru : aArray[ nRow, DBS_LEN     ] := wModest.spnLen.Value
         oEditStru : aArray[ nRow, DBS_DEC     ] := wModest.spnDec.Value
         oEditStru : aArray[ nRow, DBS_COMMENT ] := wModest.edtComment.Value
         oEditStru : aArray[ nRow, DBS_RULE    ] := wModest.txbRule.Value

      ENDCASE

      oEditStru : GoPos( ( nRow + nShift ), 2 )

   ENDIF

   // ³�������� ������ �� ��������

   InvertForEdit( .T. )        // ����, ������ �����������
   InvertForFields()           // �������� �������

   // ������� ������������ ������������ ����� � �����
   // ����������� ��������� ����

   IF ( aStat[ 'CurrMode' ] == MODE_EDITFIELD )
      InvertEnable( 'txbRule' )
   ENDIF

   IF ( aStat[ 'ChStruct'   ] .or. ;
         aStat[ 'ChDescript' ]      ;
         )
      SetIconSave( 1 )
   ENDIF

   wModest.StatusBar.Item( 1 ) := ''

   aStat[ 'CurrMode' ] := MODE_DEFAULT
   aStat[ 'Cargo'    ] := ''

   RELEASE key F2 of wModest
   RELEASE key Escape of wModest

   oEditStru : Refresh()

   ShowValues()

   RETURN

   ****** End of FiniEditField ******

   /******
   *       DelField()
   *       To remove the row
   */

STATIC PROCEDURE DelField

   MEMVAR aStat, oEditStru
   LOCAL nRow := oEditStru : nAt

   IF Empty( oEditStru : aArray[ nRow, DBS_NAME ] )

      RETURN
   ENDIF

   // �������� ����� ��������� � �������, � �, �� ��� ��������,
   // ���� ������� �� ��������. �� �� ��������� ����� ������

   IF ( oEditStru : aArray[ nRow, DBS_FLAG ] == FLAG_INSERTED )

      IF ( oEditStru : nLen == 1 )

         // ���� ������� ������ ����� ���� �����, ������
         // ��������� ������� ��������

         oEditStru : aArray[ 1, DBS_FLAG    ] := FLAG_DEFAULT
         oEditStru : aArray[ 1, DBS_NAME    ] := Nil
         oEditStru : aArray[ 1, DBS_TYPE    ] := Nil
         oEditStru : aArray[ 1, DBS_LEN     ] := Nil
         oEditStru : aArray[ 1, DBS_DEC     ] := Nil
         oEditStru : aArray[ 1, DBS_OLDNAME ] := Nil
         oEditStru : aArray[ 1, DBS_OLDTYPE ] := Nil
         oEditStru : aArray[ 1, DBS_OLDLEN  ] := Nil
         oEditStru : aArray[ 1, DBS_OLDDEC  ] := Nil
         oEditStru : aArray[ 1, DBS_COMMENT ] := Nil
         oEditStru : aArray[ 1, DBS_RULE    ] := Nil

      ELSE

         // ��� ��������� ��������� ������� ������ ���������

         oEditStru : SetDeleteMode( .T. )
         oEditStru : DeleteRow()
         oEditStru : SetDeleteMode( .F. )

      ENDIF

   ELSE

      IF ( oEditStru : aArray[ nRow, DBS_FLAG ] == FLAG_DELETED )
         oEditStru : aArray[ nRow, DBS_FLAG ] := FLAG_DEFAULT
      ELSE
         oEditStru : aArray[ nRow, DBS_FLAG ] := FLAG_DELETED
      ENDIF

   ENDIF

   oEditStru : Refresh()

   // ³��������� ����

   aStat[ 'ChStruct' ] := .T.
   SetIconSave( 1 )

   RETURN

   ****** End of DelField ******

   /******
   *       CheckData() --> lSuccess
   *       Checkup for valid field attributes
   */

STATIC FUNCTION CheckData

   MEMVAR aStat, oEditStru
   LOCAL lSuccess   := .F.             , ;
      Cycle                         , ;
      nLen       := oEditStru : nLen, ;
      nRow       := oEditStru : nAt , ;
      cFieldName                    , ;
      cValue                        , ;
      nType                         , ;
      xRule

   BEGIN Sequence

      // �������� ����� ����. ��� �� ���������� � �������, ����������
      // �������� � ���������� ���� "A"-"Z", ����� 0-9 �, �������, �������
      // ������������� "_"

      IF !CheckNameField( AllTrim( wModest.txbName.Value ) )
         Break
      ENDIF

      // ��������� ���������� ����

      FOR Cycle := 1 to nLen

         cFieldName := Iif( Empty( oEditStru : aArray[ Cycle, DBS_NAME ] )           , ;
            ''                                                       , ;
            AllTrim( Upper( oEditStru : aArray[ Cycle, DBS_NAME ] ) )  ;
            )

         IF ( AllTrim( Upper( wModest.txbName.Value ) ) == cFieldName )

            IF ( aStat[ 'CurrMode' ] == MODE_EDITFIELD )
               IF !( Cycle == nRow )
                  WriteMsg( MSG_FIELD_ALREADY + ' #' + LTrim( Str( Cycle ) ) + ' - ' + cFieldName )
                  Break
               ENDIF
            ELSE
               WriteMsg( MSG_FIELD_ALREADY + ' #' + LTrim( Str( Cycle ) ) + ' - ' + cFieldName )
               Break
            ENDIF

         ENDIF

      NEXT

      // ���������� ���� ��������. ��� ���������� ���� - 255,
      // �������� - 20. ���� ��������� ���������� �����������
      // ������� ���� � ������ ������� ��� �����.

      IF ( wModest.cmbType.Value == TYPE_IS_NUM )

         IF ( wModest.spnLen.Value > LEN_IS_NUM )
            WriteMsg( MSG_DECIMALS_LONG )
            Break
         ENDIF

         // ���� � ������ �������, �� �������� ������� ���� ��
         // ����������� �� ���������� + 1 ������� ��� ���������� �����

         IF !Empty( wModest.spnDec.Value )

            IF ( ( wModest.spnDec.Value + 1 ) >= wModest.spnLen.Value )
               WriteMsg( MSG_DECIMALS_LONG )
               Break
            ENDIF

         ENDIF

      ENDIF

      // �������� ������� ������. ��� ���� ������� ������� ������������
      // �����, �� ������ ���� �����������.

      lSuccess := .T.

      // ������� �������������. ҳ���� ��� ����, �� ��� ��������
      // � ��������. ������ ������������� ������ ��������� ����������
      // �����

      IF ( aStat[ 'CurrMode' ] == MODE_EDITFIELD )

         xRule := AllTrim( wModest.txbRule.Value )

         IF !Empty( xRule )

            // �������� �������� ���������� � ����� �������� �������

            DO CASE
            CASE ( ( oEditStru : aArray[ nRow, DBS_OLDTYPE ] == 'C' ) .or. ;
                  ( oEditStru : aArray[ nRow, DBS_OLDTYPE ] == 'M' )      ;
                  )

               cValue := '"'
               FOR Cycle := 1 to oEditStru : aArray[ nRow, DBS_OLDLEN ]
                  cValue += LTrim( Str( Cycle ) )
               NEXT
               cValue += '"'

            CASE ( oEditStru : aArray[ nRow, DBS_OLDTYPE ] == 'N' )

               IF !Empty( oEditStru : aArray[ nRow, DBS_OLDDEC ] )
                  cValue := Replicate( '8', oEditStru : aArray[ nRow, DBS_OLDDEC ] )
                  cValue := ( Replicate( '8', ( oEditStru : aArray[ nRow, DBS_OLDLEN ]       - ;
                     oEditStru : aArray[ nRow, DBS_OLDDEC ] - 1 )   ;
                     ) + '.' + cValue )
               ELSE
                  cValue := Replicate( '8', oEditStru : aArray[ nRow, DBS_OLDLEN ] )
               ENDIF

            CASE ( oEditStru : aArray[ nRow, DBS_OLDTYPE ] == 'D' )
               cValue := 'Date()'

            CASE ( oEditStru : aArray[ nRow, DBS_OLDTYPE ] == 'L' )
               cValue := '.T.'

            ENDCASE

            xRule := StrTran( xRule, aStat[ 'Expression' ], cValue )

            Try

               xRule := &( '{ || ' + xRule + ' }' )
               nType := wModest.cmbType.Value

               cValue := Valtype( Eval( xRule ) )
               IF !( cValue == CORRECT_TYPES[ nType ] )
                  WriteMsg( MSG_RULE_TYPES + 'Rule - ' + cValue + ', field - ' + CORRECT_TYPES[ nType ] )
                  lSuccess := .F.
               ENDIF

            CATCH
               WriteMsg( MSG_RULE_INCORRECT )
               lSuccess := .F.
            END

         ENDIF

      ENDIF

      ChangeMaxLimit()

   END

   RETURN lSuccess

   ****** End of CheckData ******

   /******
   *       CheckNameField( cName ) --> lSuccess
   *       Checkup for valid field name
   */

STATIC FUNCTION CheckNameField( cName )

   LOCAL lSuccess := .T.         , ;
      nLen     := Len( cName ), ;
      Cycle                   , ;
      cChar

   IF !Empty( nLen )

      // First symbol of name must be the letter

      IF IsAlpha( Left( cName, 1 ) )

         FOR Cycle := 1 to nLen

            cChar := Substr( cName, Cycle, 1 )

            IF !( cChar $ 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_' )
               WriteMsg( MSG_CHAR_INCORRECT + cChar )
               lSuccess := .F.
            ENDIF

         NEXT

      ELSE
         WriteMsg( MSG_ERROR_FIELDNAME )
         lSuccess := .F.
      ENDIF

   ELSE
      WriteMsg( MSG_ERROR_FIELDNAME )
      lSuccess := .F.
   ENDIF

   RETURN lSuccess

   ****** End of CheckNameField ******

   /******
   *       AddInCollector( nMode )
   *       To copy (nMode = MODE_COPY) or cut (nMode = MODE_CUT)
   *       row in collector
   */

STATIC PROCEDURE AddInCollector( nMode )

   MEMVAR aStat, oEditStru, aCollector
   LOCAL cObj  := ThisWindow.FocusedControl, ;
      nRow  := oEditStru : nAt          , ;
      aItem

   // The focus must be in the field list for bring the field to collector

   IF !( cObj == 'oEditStru' )
      WriteMsg( MSG_NOACTIVE_STRUCTURE )

      RETURN
   ENDIF

   IF Empty( oEditStru : aArray[ nRow, DBS_NAME ] )
      WriteMsg( MSG_STRUCTURE_EMPTY )

      RETURN
   ENDIF

   aItem := Array( DBS_NEW_ALEN )

   aItem[ DBS_FLAG    ] := oEditStru : aArray[ nRow, DBS_FLAG    ]
   aItem[ DBS_NAME    ] := oEditStru : aArray[ nRow, DBS_NAME    ]
   aItem[ DBS_TYPE    ] := oEditStru : aArray[ nRow, DBS_TYPE    ]
   aItem[ DBS_LEN     ] := oEditStru : aArray[ nRow, DBS_LEN     ]
   aItem[ DBS_DEC     ] := oEditStru : aArray[ nRow, DBS_DEC     ]
   aItem[ DBS_OLDNAME ] := oEditStru : aArray[ nRow, DBS_OLDNAME ]
   aItem[ DBS_OLDTYPE ] := oEditStru : aArray[ nRow, DBS_OLDTYPE ]
   aItem[ DBS_OLDLEN  ] := oEditStru : aArray[ nRow, DBS_OLDLEN  ]
   aItem[ DBS_OLDDEC  ] := oEditStru : aArray[ nRow, DBS_OLDDEC  ]
   aItem[ DBS_COMMENT ] := oEditStru : aArray[ nRow, DBS_COMMENT ]
   aItem[ DBS_RULE    ] := oEditStru : aArray[ nRow, DBS_RULE    ]

   AAdd( aCollector, aItem )

   wModest.grdCollector.AddItem( { aItem[ DBS_NAME ]         , ;
      aItem[ DBS_TYPE ]         , ;
      Str( aItem[ DBS_LEN ], 3 ), ;
      Str( aItem[ DBS_DEC ], 3 ), ;
      aItem[ DBS_COMMENT ]        ;
      } )

   // If row is cut to collector, when to delete from field list

   IF ( nMode == MODE_CUT )
      oEditStru : SetDeleteMode( .T., .F. )
      oEditStru : DeleteRow()
      oEditStru : SetDeleteMode( .F. )

      // Cut a row to collector changes the srtucture (and, probably, description)
      // Establish the appropriate flag.

      aStat[ 'ChStruct' ] := .T.

      IF !Empty( aItem[ DBS_COMMENT ] )
         aStat[ 'ChDescript' ] := .T.
      ENDIF

      SetIconSave( 1 )

   ENDIF

   // Show needed tab (for see the contents of collector)

   wModest.tbDescript.Value := 3

   RETURN

   ****** End of AddInCollector ******

   /******
   *       PasteFromCollector()
   *       Paste field from collector
   */

STATIC PROCEDURE PasteFromCollector

   MEMVAR oEditStru, aStat, aCollector
   LOCAL cObj       := ThisWindow.FocusedControl, ;
      nItem                                  , ;
      aItem      := Array( DBS_NEW_ALEN )    , ;
      nLen       := oEditStru : nLen         , ;
      Cycle                                  , ;
      nRow                                   , ;
      cFieldName

   // If control focus is not the collector, when it is ignored.
   // Also don't execute, if collector is empty or
   // active element is absent.

   IF !( cObj == 'grdCollector' )
      WriteMsg( MSG_NOACTIVE_COLLECTOR )

      RETURN
   ENDIF

   nItem := wModest.grdCollector.Value

   IF ( Empty( wModest.grdCollector.ItemCount ) .or. Empty( nItem ) )
      WriteMsg( MSG_COLLECTOR_EMPTY )

      RETURN
   ENDIF

   ACopy( aCollector[ nItem ], aItem )        // Get inserted data from collector

   // Checking for field dublication

   FOR Cycle := 1 to nLen

      cFieldName := Iif( Empty( oEditStru : aArray[ Cycle, DBS_NAME ] )           , ;
         ''                                                       , ;
         AllTrim( Upper( oEditStru : aArray[ Cycle, DBS_NAME ] ) )  ;
         )

      IF ( AllTrim( Upper( aItem[ DBS_NAME ] ) ) == cFieldName )
         WriteMsg( MSG_FIELD_ALREADY + ' #' + LTrim( Str( Cycle ) ) + ' - ' + cFieldName )

         RETURN
      ENDIF

   NEXT

   nRow := oEditStru : nAt

   IF Empty( oEditStru : aArray[ 1, DBS_NAME ] )
      oEditStru : aArray[ 1, DBS_FLAG    ] := aItem[ DBS_FLAG    ]
      oEditStru : aArray[ 1, DBS_NAME    ] := aItem[ DBS_NAME    ]
      oEditStru : aArray[ 1, DBS_TYPE    ] := aItem[ DBS_TYPE    ]
      oEditStru : aArray[ 1, DBS_LEN     ] := aItem[ DBS_LEN     ]
      oEditStru : aArray[ 1, DBS_DEC     ] := aItem[ DBS_DEC     ]
      oEditStru : aArray[ 1, DBS_OLDNAME ] := aItem[ DBS_OLDNAME ]
      oEditStru : aArray[ 1, DBS_OLDTYPE ] := aItem[ DBS_OLDTYPE ]
      oEditStru : aArray[ 1, DBS_OLDLEN  ] := aItem[ DBS_OLDLEN  ]
      oEditStru : aArray[ 1, DBS_OLDDEC  ] := aItem[ DBS_OLDDEC  ]
      oEditStru : aArray[ 1, DBS_COMMENT ] := aItem[ DBS_COMMENT ]
      oEditStru : aArray[ 1, DBS_RULE    ] := aItem[ DBS_RULE    ]

   ELSE
      oEditStru : Insert( aItem, nRow + nShift )
      oEditStru : Display()
      oEditStru : GoPos( ( nRow + nShift ), 2 )
   ENDIF

   aStat[ 'ChStruct' ] := .T.

   IF !Empty( aItem[ DBS_COMMENT ] )
      aStat[ 'ChDescript' ] := .T.
   ENDIF

   SetIconSave( 1 )

   oEditStru : Refresh()

   ShowValues()

   RETURN

   ****** End of PasteFromCollector ******

   /******
   *       FillCollector()
   *       Filling of collector list
   */

PROCEDURE FillCollector

   MEMVAR aCollector

   wModest.grdCollector.DeleteAllItems

   AEval( aCollector, { | aItem | wModest.grdCollector.AddItem( { aItem[ DBS_NAME ]         , ;
      aItem[ DBS_TYPE ]         , ;
      Str( aItem[ DBS_LEN ], 3 ), ;
      Str( aItem[ DBS_DEC ], 3 ), ;
      aItem[ DBS_COMMENT ]        ;
      } )                          ;
      } )

   RETURN

   ****** End of FillCollector ******

   /******
   *       SetMenuTheme()
   *       Set Themed Menu is based on OS type
   */

STATIC PROCEDURE SetMenuTheme()

   LOCAL aColors := GetMenuColors()

   aColors[ MNUCLR_MENUBARBACKGROUND1 ]  := GetSysColor( 15 )
   aColors[ MNUCLR_MENUBARBACKGROUND2 ]  := GetSysColor( 15 )

   IF IsThemed()

      aColors[ MNUCLR_MENUBARTEXT ]         := GetSysColor(  7 )
      aColors[ MNUCLR_MENUBARSELECTEDTEXT ] := GetSysColor( 14 )
      aColors[ MNUCLR_MENUBARGRAYEDTEXT ]   := GetSysColor( 17 )
      aColors[ MNUCLR_MENUBARSELECTEDITEM1 ]:= GetSysColor( 13 )
      aColors[ MNUCLR_MENUBARSELECTEDITEM2 ]:= GetSysColor( 13 )
      aColors[ MNUCLR_MENUITEMTEXT ]        := GetSysColor(  7 )
      aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= GetSysColor( 14 )
      aColors[ MNUCLR_MENUITEMGRAYEDTEXT ]  := GetSysColor( 17 )

      aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := GetSysColor( 4 )
      aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := GetSysColor( 4 )

      aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := GetSysColor( 13 )
      aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := GetSysColor( 13 )
      aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND1 ]   := GetSysColor( 4 )
      aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND2 ]   := GetSysColor( 4 )

      aColors[ MNUCLR_IMAGEBACKGROUND1 ] := GetSysColor( 15 )
      aColors[ MNUCLR_IMAGEBACKGROUND2 ] := GetSysColor( 15 )

      aColors[ MNUCLR_SEPARATOR1 ] := GetSysColor( 17 )
      aColors[ MNUCLR_SEPARATOR2 ] := GetSysColor( 14 )

      aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := GetSysColor( 13 )
      aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := GetSysColor( 13 )
      aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := GetSysColor( 17 )
      aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := GetSysColor( 14 )

      SET MENUCURSOR FULL
      SET MENUSEPARATOR DOUBLE RIGHTALIGN
      SET MENUITEM BORDER FLAT

   ELSE
      IF ! IsWinNT()
         SetMenuBitmapHeight( BmpSize( "CUT" )[ 1 ] )
      ENDIF

      aColors[ MNUCLR_MENUBARTEXT ]         := RGB(   0,   0,   0 )
      aColors[ MNUCLR_MENUBARSELECTEDTEXT ] := RGB(   0,   0,   0 )
      aColors[ MNUCLR_MENUBARGRAYEDTEXT ]   := RGB( 128, 128, 128 )
      aColors[ MNUCLR_MENUBARSELECTEDITEM1 ]:= GetSysColor(15)
      aColors[ MNUCLR_MENUBARSELECTEDITEM2 ]:= GetSysColor(15)

      aColors[ MNUCLR_MENUITEMTEXT ]        := RGB(   0,   0,   0 )
      aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= RGB( 255, 255, 255 )
      aColors[ MNUCLR_MENUITEMGRAYEDTEXT ]  := RGB( 128, 128, 128 )

      aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := GetSysColor( 4 )
      aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := GetSysColor( 4 )

      aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB(  10,  36, 106 )
      aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB(  10,  36, 106 )
      aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND1 ]   := RGB( 212, 208, 200 )
      aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND2 ]   := RGB( 212, 208, 200 )

      aColors[ MNUCLR_IMAGEBACKGROUND1 ] := GetSysColor( 4 )
      aColors[ MNUCLR_IMAGEBACKGROUND2 ] := GetSysColor( 4 )

      aColors[ MNUCLR_SEPARATOR1 ] := RGB( 128, 128, 128 )
      aColors[ MNUCLR_SEPARATOR2 ] := RGB( 255, 255, 255 )

      aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := RGB(  10,  36, 106 )
      aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := RGB( 128, 128, 128 )
      aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := RGB(  10,  36, 106 )
      aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := RGB( 255, 255, 255 )

      SET MENUCURSOR SHORT
      SET MENUSEPARATOR DOUBLE LEFTALIGN
      SET MENUITEM BORDER 3D

   ENDIF

   SetMenuColors( aColors )

   RETURN

   ****** End of SetMenuTheme ******
