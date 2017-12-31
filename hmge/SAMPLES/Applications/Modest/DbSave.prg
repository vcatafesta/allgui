#include "HBCompat.ch"
#include "MiniGUI.ch"
#include "DbStruct.ch"
#include "HBXml.ch"         // HBXml.ch from folder HARBOUR\CONTRIB\XHB
#include "Modest.ch"

// Program messages

#define MSG_SAVE_STARTED             'Save started '
#define MSG_SAVE_ERROR               'Execute error'
#define MSG_SAVE_SUCCESS             'Finished successful'
#define MSG_ERROR_CREATE             'Error create file '
#define MSG_ERROR_CREATE_MEMO        'Error create file Memo '
#define MSG_ERROR_CREATE_XML         'Error create file XML-description '
#define MSG_TRANSFER_PROGRESS        'Transfer in progress. Wait...'
#define MSG_TRANSFER_FINISH          'Transfer completed'
#define MSG_ERROR_BACKUP_BASE        'Error create backup base '
#define MSG_ERROR_BACKUP_MEMO        'Error create backup memo '
#define MSG_ERROR_BACKUP_XML         'Error create backup XML-description '

DECLARE window wModest

/******
*       SaveData() --> lSuccess
*       Reorganization of database, preservation of description
*/

FUNCTION SaveData

   MEMVAR aStat, oEditStru, aCollector, aParams
   LOCAL lSuccess := .F., ;
      aStru    := {} , ;
      aTmp           , ;
      Cycle          , ;
      nLen

   // Array of working params

   PRIVATE aParams := { 'SaveStru'   => .F., ;    // Keep of database structure
      'SaveDesc'   => .F., ;    // Keep of description
      'DeletedOff' => .T., ;    // Transfer the deleted records
      'CreateBAK'  => .F., ;    // Create backup
      'NewFile'    => .T., ;    // Flag: new file creation
      'Path'       => '' , ;    // Path to preservation
      'File'       => '' , ;    // File name (without path)
      'Ext'        => '' , ;    // File extension
      'RDD'        => '' , ;    // Database RDD
      'TmpFile'    => ''   ;    // Temporary file
      }

   LOAD WINDOW DbSave as wSave

   IF !Empty( aStat[ 'FileName' ] )
      wSave.btnDatabase.Value := aStat[ 'FileName' ]
   ELSE
      wSave.btnDatabase.Value := ( hb_DirSepDel( GetCurrentFolder() ) + '\NewBase.dbf' )
   ENDIF

   wSave.cmbRDD.Value := Iif( ( aStat[ 'RDD' ] == 'DBFCDX' ), 2, 1 )

   wSave.Title := APPNAME + ' - Save file'

   // Only changed parts for keep

   wSave.cmbRDD.Enabled := aStat[ 'ChStruct' ]

   wSave.cbxSaveStru.Value   := aStat[ 'ChStruct' ]
   wSave.cbxSaveStru.Enabled := aStat[ 'ChStruct' ]

   wSave.cbxSaveDescript.Value   := aStat[ 'ChDescript' ]
   wSave.cbxSaveDescript.Enabled := aStat[ 'ChDescript' ]

   wSave.cbxDeleted.Enabled   := aStat[ 'ChStruct' ]
   wSave.cbxCreateBAK.Value   := .T.
   wSave.cbxCreateBAK.Enabled := ( aStat[ 'ChStruct' ] .or. aStat[ 'ChDescript' ] )

   On key Escape of wSave Action { || lSuccess := .F., wSave.Release }

   // Because of this procedure may be evoked at Main form closing
   // (exit without saving changed data), when repeatedly pressing Alt+X
   // will be close program immediately.

   On key Alt+X of wSave Action ReleaseAllWindows()

   SetEnabled()        // Availability of controls

   CENTER WINDOW wSave
   ACTIVATE WINDOW wSave

   // If saving was confirmed

   IF lSuccess

      // In this place lSuccess is not saving result, but
      // result of setting of saving params in form.

      IF ( lSuccess := DoSave() )

         // Change the data in edit form. For example, user
         // was change something and decide to select other file. The data was saved,
         // but he was refuse from selected file - and datas at editing
         // are remain as is.

         nLen := oEditStru : nLen

         FOR Cycle := 1 to nLen

            IF !( oEditStru : aArray[ Cycle, DBS_FLAG ] == FLAG_DELETED )
               aTmp := Array( DBS_NEW_ALEN )

               aTmp[ DBS_FLAG    ] := FLAG_DEFAULT
               aTmp[ DBS_NAME    ] := oEditStru : aArray[ Cycle, DBS_NAME    ]
               aTmp[ DBS_TYPE    ] := oEditStru : aArray[ Cycle, DBS_TYPE    ]
               aTmp[ DBS_LEN     ] := oEditStru : aArray[ Cycle, DBS_LEN     ]
               aTmp[ DBS_DEC     ] := oEditStru : aArray[ Cycle, DBS_DEC     ]
               aTmp[ DBS_OLDNAME ] := oEditStru : aArray[ Cycle, DBS_NAME    ]
               aTmp[ DBS_OLDTYPE ] := oEditStru : aArray[ Cycle, DBS_TYPE    ]
               aTmp[ DBS_OLDLEN  ] := oEditStru : aArray[ Cycle, DBS_LEN     ]
               aTmp[ DBS_OLDDEC  ] := oEditStru : aArray[ Cycle, DBS_DEC     ]
               aTmp[ DBS_COMMENT ] := oEditStru : aArray[ Cycle, DBS_COMMENT ]
               aTmp[ DBS_RULE    ] := ''

               AAdd( aStru, aTmp )

            ENDIF

         NEXT

         oEditStru : SetArray( aStru )

         oEditStru : Display()

         oEditStru : goTop()
         oEditStru : Refresh()

         SetWinTitle()
         SetIconSave( 0 )
         SetRDDName()

         // Process the collector after successful saving.
         // Because the database already exists, all fields, which are placed in the collector
         // get flag "New field". Transformation rules are destroyed.

         AEval( aCollector, { | aItem | aItem[ DBS_FLAG    ] :=  FLAG_INSERTED, ;
            aItem[ DBS_OLDNAME ] := ''            , ;
            aItem[ DBS_OLDTYPE ] := ''            , ;
            aItem[ DBS_OLDLEN  ] := ''            , ;
            aItem[ DBS_OLDDEC  ] := ''            , ;
            aItem[ DBS_RULE    ] := ''              ;
            } )
         FillCollector()   // Collector refreshing

      ENDIF

   ENDIF

   RETURN lSuccess

   ****** End of SaveData ******

   /******
   *       SetEnabled()
   *       Control for availability of controls in dialog
   */

STATIC PROCEDURE SetEnabled

   MEMVAR aStat

   wSave.btnDatabase.Enabled := wSave.cbxSaveStru.Value

   IF Empty( wSave.btnDatabase.Value )
      wSave.btnOK.Enabled := .F.
   ELSE
      wSave.btnOK.Enabled := ( ( wSave.cbxSaveStru.Value          .or. ;
         wSave.cbxSaveDescript.Value           ;
         )                                 .and. ;
         !Empty( wSave.btnDatabase.Value )       ;
         )
   ENDIF

   RETURN

   ****** End of SetEnabled ******

   /******
   *      WhatSave()
   *      Select file for preservation
   */

STATIC PROCEDURE WhatSave

   LOCAL cFile := PutFile( FILEDLG_FILTER, 'Select dBASE file', , .T. )

   IF !Empty( cFile )
      wSave.btnDatabase.Value := cFile
   ENDIF

   RETURN

   ****** End of WhatSave ******

   /******
   *       KeepParams()
   *       Bring the setting to working array
   */

STATIC PROCEDURE KeepParams

   MEMVAR aParams
   LOCAL cFile, ;
      nPos

   aParams[ 'SaveStru'   ] := wSave.cbxSaveStru.Value
   aParams[ 'SaveDesc'   ] := wSave.cbxSaveDescript.Value
   aParams[ 'DeletedOff' ] := wSave.cbxDeleted.Value
   aParams[ 'CreateBAK'  ] := wSave.cbxCreateBAK.Value
   aParams[ 'RDD'        ] := Iif( ( GetProperty( 'wSave', 'cmbRDD', 'Value' ) == 1 ), 'DBFNTX', 'DBFCDX' )

   // Allocate from full name the path, file name and extension

   cFile := AllTrim( wSave.btnDatabase.Value )

   IF ( ( nPos := RAt( '.', cFile ) ) > 0 )
      aParams[ 'Ext' ] := Substr( cFile, ( nPos + 1 ) )
      cFile := Substr( cFile, 1, ( nPos - 1 ) )
   ENDIF

   IF ( ( nPos := RAt( '\', cFile ) ) > 0 )
      aParams[ 'File' ] := Substr( cFile, ( nPos + 1 ) )
      aParams[ 'Path' ] := Substr( cFile, 1, ( nPos - 1 ) )
   ELSE
      aParams[ 'File' ] := cFile
      aParams[ 'Path' ] := GetCurrentFolder()
   ENDIF

   IF Empty( aParams[ 'Ext' ] )
      aParams[ 'Ext' ] := 'dbf'       // Typical extension
   ENDIF

   cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )
   WriteMsg( MSG_SAVE_STARTED + cFile )

   // If file is not exest, when keeping will be easier. Therefore
   // check for parameter.

   aParams[ 'NewFile' ] := !File( cFile )

   RETURN

   ****** End of KeepParams ******

   /******
   *       DoSave() --> lSuccess
   *       Description keeping
   */

STATIC FUNCTION DoSave

   MEMVAR oEditStru, aStat, aParams, aStru
   LOCAL lSuccess := .F., ;
      cFile          , ;
      Cycle          , ;
      nLen           , ;
      aTmp

   // Expanded array of fields description for function DbCreate(). It's possible, because
   // this function have used DBS_NAME, DBS_TYPE, DBS_LEN, DBS_DEC and ignore
   // the others elements.

   PRIVATE aStru := {}

   // Fill of the structure description. Deleted fileds are ignored.

   nLen := oEditStru : nLen

   FOR Cycle := 1 to nLen

      IF !( oEditStru : aArray[ Cycle, DBS_FLAG ] == FLAG_DELETED )

         aTmp := Array( DBS_NEW_ALEN )

         aTmp[ DBS_NAME    ] := oEditStru : aArray[ Cycle, DBS_NAME    ]
         aTmp[ DBS_TYPE    ] := oEditStru : aArray[ Cycle, DBS_TYPE    ]
         aTmp[ DBS_LEN     ] := oEditStru : aArray[ Cycle, DBS_LEN     ]
         aTmp[ DBS_DEC     ] := oEditStru : aArray[ Cycle, DBS_DEC     ]
         aTmp[ DBS_OLDNAME ] := oEditStru : aArray[ Cycle, DBS_OLDNAME ]
         aTmp[ DBS_OLDTYPE ] := oEditStru : aArray[ Cycle, DBS_OLDTYPE ]
         aTmp[ DBS_RULE    ] := oEditStru : aArray[ Cycle, DBS_RULE    ]
         aTmp[ DBS_COMMENT ] := oEditStru : aArray[ Cycle, DBS_COMMENT ]

         AAdd( aStru, aTmp )

      ENDIF

   NEXT

   BEGIN Sequence

      IF aParams[ 'SaveStru' ]      // Keep structure

         IF !aParams[ 'NewFile' ]
            // Create tempfile at database folder.
            aParams[ 'TmpFile' ] := TempFileName()
         ENDIF

         IF !CreateEmpty()
            Break
         ENDIF

         IF !aParams[ 'NewFile' ]

            // If it modify of existing base, transfer the records in a new structure

            IF !Transfer()
               Break
            ENDIF

            // Create backup if its needed

            IF aParams[ 'CreateBAK' ]

               // Backup name is construct by add the complementary
               // extension .bak
               // Existed backups should be erased before renaming,
               //  otherwise FRename() will finished with error.

               cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )

               IF File( cFile + '.bak' )
                  ERASE ( cFile + '.bak' )
               ENDIF

               IF Empty( FRename( cFile, ( cFile + '.bak' ) ) )

                  // If database have the comment file

                  cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' )
                  cFile += Iif( ( aStat[ 'RDD' ] == 'DBFCDX' ), 'FPT', 'DBT' )

                  IF File( cFile + '.bak' )
                     ERASE ( cFile + '.bak' )
                  ENDIF

                  IF File( cFile )
                     IF !Empty( FRename( cFile, ( cFile + '.bak' ) ) )
                        WriteMsg( MSG_ERROR_BACKUP_MEMO + cFile )
                        Break
                     ENDIF
                  ENDIF

               ELSE
                  WriteMsg( MSG_ERROR_BACKUP_BASE + cFile )
                  Break
               ENDIF

            ENDIF

            // If backup was not created, it is needed before renaming
            // to erase the initial (output) files

            cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )
            ERASE ( cFile )

            cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' )
            cFile += Iif( ( aStat[ 'RDD' ] == 'DBFCDX' ), 'FPT', 'DBT' )
            ERASE ( cFile )

            // Rename the tempfile to working file.

            cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )

            IF Empty( FRename( aParams[ 'TmpFile' ], cFile ) )

               // File of comments

               aParams[ 'TmpFile' ] := Left( aParams[ 'TmpFile' ], ( Len( aParams[ 'TmpFile' ] ) - 3 ) )
               aParams[ 'TmpFile' ] += Iif( ( aParams[ 'RDD' ] == 'DBFCDX' ), 'FPT', 'DBT' )

               IF File( aParams[ 'TmpFile' ] )

                  cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' )
                  cFile += Iif( ( aParams[ 'RDD' ] == 'DBFCDX' ), 'FPT', 'DBT' )

                  IF !Empty( FRename( aParams[ 'TmpFile' ], cFile ) )
                     WriteMsg( MSG_ERROR_CREATE_MEMO + cFile )
                     Break
                  ENDIF
               ENDIF

            ELSE
               WriteMsg( MSG_ERROR_CREATE + cFile )
               Break
            ENDIF

         ENDIF

      ENDIF

      IF aParams[ 'SaveDesc' ]        // Keep the database description

         cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.xml' )

         IF aParams[ 'CreateBAK' ]

            IF File( cFile + '.bak' )
               ERASE ( cFile + '.bak' )
            ENDIF

            IF File( cFile )
               IF !Empty( FRename( cFile, ( cFile + '.bak' ) ) )
                  WriteMsg( MSG_ERROR_BACKUP_XML + cFile )
                  Break
               ENDIF
            ENDIF

         ENDIF

         IF File( cFile )
            ERASE ( cFile )
         ENDIF

         IF !SaveXML()
            WriteMsg( MSG_ERROR_CREATE_XML + cFile )
            Break
         ENDIF

      ENDIF

      lSuccess := .T.

   END

   IF lSuccess

      // Change the array of working params

      aStat[ 'FileName'   ] := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )
      aStat[ 'RDD'        ] := aStat[ 'RDD' ]
      aStat[ 'ChStruct'   ] := .F.          // Changing is absent
      aStat[ 'ChDescript' ] := .F.

      WriteMsg( MSG_SAVE_SUCCESS )
      Do Events

   ELSE
      WriteMsg( MSG_SAVE_ERROR )

   ENDIF

   wModest.StatusBar.Item( 2 ) := ''

   RETURN lSuccess

   ****** End of DoSave ******

   /******
   *       TempFileName() --> cFile
   *       Create the temporary file
   */

STATIC FUNCTION TempFileName

   MEMVAR aParams
   LOCAL nHandle, cFile

   DO WHILE .T.

      IF ( ( nHandle := HB_FTempCreate( aParams[ 'Path' ],,, @cFile ) ) > 0 )
         FClose( nHandle )
         ERASE ( cFile )
      ENDIF

      // Change the extension of .tmp file, which is created by HB_FTempCreate()
      // to standard. Reason - database must be contain the fields of comments.

      IF !File( cFile := Left( cFile, ( Len( cFile ) - 3 ) ) + 'dbf' )
         EXIT
      ENDIF

   ENDDO

   RETURN cFile

   ****** End of TempFileName

   /******
   *       CreateEmpty() --> lSuccess
   *       Create the empty base with the declared structure
   */

STATIC FUNCTION CreateEmpty

   MEMVAR aParams, aStru
   LOCAL cFile          , ;
      lSuccess := .F.

   IF !aParams[ 'NewFile' ]
      cFile := aParams[ 'TmpFile' ]
   ELSE
      cFile := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] )
   ENDIF

   Try
      DbCreate( cFile, aStru, aParams[ 'RDD' ] )
      lSuccess := .T.
   CATCH
      WriteMsg( MSG_ERROR_CREATE + cFile )
   END

   RETURN lSuccess

   ****** End of CreateEmpty ******

   /******
   *       Transfer() --> lSuccess
   *       Transfer the records to database with a new structure
   */

STATIC FUNCTION Transfer

   MEMVAR aStat, aParams
   LOCAL lSuccess := .T.

   Try

      DbUseArea( .T., aStat[ 'RDD'   ], ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' + aParams[ 'Ext' ] ), 'OldBase' )
      DbUseArea( .T., aParams[ 'RDD' ], aParams[ 'TmpFile' ], 'NewBase' )

      WriteMsg( MSG_TRANSFER_PROGRESS )
      OldBase->( DbEval( { || ChangeRecord() }, { || Iif( aParams[ 'DeletedOff' ], .T., !Deleted() ) } ) )
      WriteMsg( MSG_TRANSFER_FINISH )

   CATCH
      lSuccess := .F.
      Finally
      DbCloseAll()
   END

   RETURN lSuccess

   ****** End of Transfer ******

   /******
   *       ChangeRecord()
   *       Transfer the fields contents
   */

STATIC PROCEDURE ChangeRecord

   MEMVAR aParams, aStru
   LOCAL nRecno := OldBase->( Recno() )   , ;
      nCount := OldBase->( Reccount() ), ;
      nElems := Len( aStru )           , ;
      Cycle                            , ;
      cField                           , ;
      nField                           , ;
      xValue

   wModest.StatusBar.Item( 2 ) := ( LTrim( Str( nRecno ) ) + '/' + LTrim( Str( nCount ) ) )
   Do Events

   NewBase->( DbAppend() )

   FOR Cycle := 1 to nElems

      // If previous field name is absent, means that it a new field,
      // no need to tarnster data from old base

      IF !Empty( cField := aStru[ Cycle, DBS_OLDNAME ] )

         nField := OldBase->( FieldPos( cField ) )

         IF !( ( xValue := EqnType( nField, Cycle ) ) == nil )
            NewBase->( FieldPut( Cycle, xValue ) )
         ENDIF

      ENDIF

   NEXT

   // Restore the deletion flag at transfering of deleted records

   IF aParams[ 'DeletedOff' ]
      IF OldBase->( Deleted() )
         NewBase->( DbDelete() )
      ENDIF
   ENDIF

   RETURN

   ****** End of ChangeRecord ******

   /******
   *       EqnType( nField, nElem ) --> xVar
   *       The coordination of field's types
   */

STATIC FUNCTION EqnType( nField, nElem )

   MEMVAR aStru, aStat, xVar
   LOCAL cOldType := aStru[ nElem, DBS_OLDTYPE ], ;
      cNewType := aStru[ nElem, DBS_TYPE    ], ;
      cName                                  , ;
      cRule

   IF Empty( aStru[ nElem, DBS_RULE ] )

      // If rule is not set, transformation is typical

      PRIVATE xVar := OldBase->( FieldGet( nField ) )

      DO CASE
      CASE ( ( cOldType == 'C' ) .or. ( cOldType == 'M' ) )

         DO CASE
         CASE ( cNewType == 'C' )
            xVar := Left( xVar, aStru[ nElem, DBS_LEN ] )

         CASE ( cNewType == 'N' )
            xVar := Iif( ( Type( 'Val( xVar )' ) == 'N' ), Val( xVar ), 0 )

         CASE ( cNewType == 'D' )
            xVar := Iif( ( Type( 'CtoD( xVar )' ) == 'D' ), ;
               CtoD( xVar ), CtoD( '' ) )

         CASE ( cNewType == 'L' )
            xVar := AllTrim( xVar )
            IF ( Len( xVar ) == 1 )
               xVar := Iif( ( xVar == 'T' ), .T., .F. )
            ELSE
               xVar := .F.
            ENDIF

         ENDCASE

      CASE ( cOldType == 'N' )

         DO CASE
         CASE ( ( cNewType == 'C' ) .or. ( cNewType == 'M' ) )
            xVar := Str( xVar, aStru[ nElem, DBS_LEN ], ;
               aStru[ nElem, DBS_DEC ] )

         CASE ( cNewType == 'D' )
            xVar := CtoD( AllTrim( Str( xVar ) ) )

         CASE ( cNewType == 'L' )
            xVar := Iif( ( xVar == 1 ), .T., .F. )

         ENDCASE

      CASE ( cOldType == 'D' )

         DO CASE
         CASE ( ( cNewType == 'C' ) .or. ( cNewType == 'M' ) )
            xVar := DtoC( xVar )

         CASE ( cNewType == 'N' )
            xVar := Val( DtoC( xVar ) )

         CASE ( cNewType == 'L' )
            xVar := .F.

         ENDCASE

      CASE ( cOldType == 'L' )

         DO CASE
         CASE ( ( cNewType == 'C' ) .or. ( cNewType == 'M' ) )
            xVar := Iif( xVar, 'T', 'F' )

         CASE ( cNewType == 'N' )
            xVar := Iif( xVar, 1, 0 )

         CASE ( cNewType == 'D' )
            xVar := CtoD( '' )

         ENDCASE

      ENDCASE

   ELSE

      cName := aStru[ nElem, DBS_OLDNAME ]
      cName := ( 'OldBase->' + cName )

      cRule := aStru[ nElem, DBS_RULE ]
      cRule := StrTran( cRule, aStat[ 'Expression' ], cName )

      Try
         cRule := &( '{ || ' + cRule + ' }' )
         xVar  := Eval( cRule )
      CATCH
         xVar := nil
      END

   ENDIF

   RETURN xVar

   ****** End of EqnType ******

   /******
   *       SaveXML() --> lSuccess
   *       Keep the database description
   */

STATIC FUNCTION SaveXML

   MEMVAR aParams, aStru
   LOCAL lSuccess     := .T.                                                  , ;
      cFile        := ( aParams[ 'Path' ] + '\' + aParams[ 'File' ] + '.' ), ;
      oXMLDoc                                                              , ;
      oXMLDatabase                                                         , ;
      oXMLHeader                                                           , ;
      oXMLStruct                                                           , ;
      oXMLField                                                            , ;
      aField                                                               , ;
      aAttr                                                                , ;
      nFileHandle

   Try

      /*
      The result is a file with the following contents:

      <?xml version="1.0"?>
      <Database file="D:\Programs\Modest\FOXHELP.DBF">
      <Description>FoxPro Help</Description>
      <Structure>
      <Field dec="0" len="30" name="TOPIC" type="C">Topic</field>
      <Field dec="0" len="10" name="DETAILS" type="M">Text</field>
      <Field dec="0" len="20" name="CLASS" type="C"/>
      </Structure>
      </Database>

      */

      // Create empty XML-document with header

      oXMLDoc := TXMLDocument() : New( '<?xml version="1.0"?>' )

      // Create main XML node

      oXMLDatabase := TXMLNode() : New( , XML_TAG_DATABASE, { XML_TAG_FILE => ( cFile + aParams[ 'Ext' ] ) } )
      oXMLDoc : oRoot : AddBelow( oXMLDatabase )

      // Add node with the database description

      oXMLHeader := TXMLNode() : New( HBXML_TYPE_TAG, XML_TAG_DESCRIPTION, nil, AllTrim( wModest.edtGeneral.Value ) )
      oXMLDatabase : AddBelow( oXMLHeader )

      // Section of field's description
      oXMLStruct := TXMLNode() : New( , XML_TAG_STRUCTURE )
      oXMLDatabase : AddBelow( oXMLStruct )

      FOR EACH aField in aStru
         aAttr := { XML_ATTR_NAME => aField[ DBS_NAME ]              , ;
            XML_ATTR_TYPE => aField[ DBS_TYPE ]              , ;
            XML_ATTR_LEN => LTrim( Str( aField[ DBS_LEN ] ) ), ;
            XML_ATTR_DEC => LTrim( Str( aField[ DBS_DEC ] ) )  ;
            }

         IF !Empty( aField[ DBS_COMMENT ] )
            oXMLField := TXMLNode() : New( HBXML_TYPE_TAG, XML_TAG_FIELD, aAttr, aField[ DBS_COMMENT ] )
         ELSE
            oXMLField := TXMLNode() : New( HBXML_TYPE_TAG, XML_TAG_FIELD, aAttr )
         ENDIF

         oXMLStruct : AddBelow( oXMLField )

      NEXT

      // Create XML file
      nFileHandle := FCreate( cFile + 'XML')

      IF Empty( FError() )

         // Keep XML tree
         oXmlDoc : Write( nFileHandle, HBXML_STYLE_INDENT )
         FClose( nFileHandle )

      ENDIF

   CATCH
      lSuccess := .F.
   END

   RETURN lSuccess

   ****** End of SaveXML ******
