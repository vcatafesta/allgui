#include "Directry.ch"
#include "MiniGUI.ch"
#include "Stock.ch"

// Language template

#define TEMPLATE_NAME        'TEMPLATE.LNG'
#define TEMPLATE_FILE        ( LANGFILE_PATH + TEMPLATE_NAME )

// Messages arrays

// Main menu

#define ARRMENU_LANG         { { 'File', 'File'                                          }, ;
   { 'New'    , 'New'                                        }, ;
   { 'msgNew' , 'Build new list'                             }, ;
   { 'Open'   , 'Open'                                       }, ;
   { 'msgOpen', 'Load existing list'                         }, ;
   { 'Save'   , 'Save'                                       }, ;
   { 'msgSave', 'Save list to file'                          }, ;
   { 'Exit'   , 'Exit'                                       }, ;
   { 'msgExit', 'Leaving programm'                           }, ;
   { 'Edit', 'Edit'                                            }, ;
   { 'SetTitle'     , 'Description'                          }, ;
   { 'msgSetTitle'  , 'Set description current catalog'      }, ;
   { 'OpenEditor'   , 'Open in editor'                       }, ;
   { 'msgOpenEditor', 'Open module in external editor'       }, ;
   { 'CopyName'     , 'Copy name'                            }, ;
   { 'msgCopyName'  , 'Copy name to buffer Windows'          }, ;
   { 'Tools', 'Tools'                                          }, ;
   { 'CodeFormat'   , 'Code formatting'                      }, ;
   { 'msgCodeFormat', 'Source code formatter'                }, ;
   { 'CallsTable'   , 'Functions calls'                      }, ;
   { 'msgCallsTable', 'Procedures and functions calls table' }, ;
   { 'Service', 'Service'                                      }, ;
   { 'Language'      , 'Language'                            }, ;
   { 'SelectLang'  , 'Choose language'                     }, ;
   { 'msgLanguage' , 'Select language'                     }, ;
   { 'TemplateLang', 'Create template'                     }, ;
   { 'msgTemplate', 'Create language template file'        }, ;
   { 'Options', 'Options'                                      }, ;
   { 'msgOptions', 'Set options of programm'                 }, ;
   { 'About', 'About'                                          }, ;
   { 'msgAbout', 'About Stock'                                 }  ;
   }

// Main window

#define ARRMAINFORM_LANG     { { 'Title'        , APPTITLE                  }, ;
   { 'btnNew'       , 'Create new list'         }, ;
   { 'btnOpen'      , 'Load list from file'     }, ;
   { 'btnSave'      , 'Save to file'            }, ;
   { 'btnEdit'      , 'Open in external editor' }, ;
   { 'btnOptions'   , 'Settings'                }, ;
   { 'NameColumn'   , 'Name'                    }, ;
   { 'TypeColumn'   , 'Type'                    }, ;
   { 'CommentColumn', 'Comment'                 }, ;
   { 'lblSearch'    , 'Find'                    }, ;
   { 'msgSearch'    , 'String for search'       }, ;
   { 'btnSearch'    , 'Find more'               }, ;
   { 'btnFindAll'   , 'Find all'                }  ;
   }

// Options form

#define ARROPTIONFORM_LANG   { { 'Title'         , 'Options'           }, ;
   { 'frmOnStart'    , 'On start'          }, ;
   { 'rdgOnStart1'   , 'Nothing'           }, ;
   { 'rdgOnStart2'   , 'Load last list'    }, ;
   { 'frmSearch'     , 'Search mode'       }, ;
   { 'rdgSearch1'    , 'Exact'             }, ;
   { 'rdgSearch2'    , 'Match'             }, ;
   { 'Editor'        , 'External editor'   }, ;
   { 'rdgParameters1', 'Simple'            }, ;
   { 'rdgParameters2', 'Goto line %N'      }, ;
   { 'rdgParameters3', 'Goto procedure %P' }  ;
   }

// Language selecting form

#define ARRSELECTLANG_LANG   { { 'Title', 'Select language' } }

// Catalog Title selecting form

#define ARRSETTITLE_LANG     { { 'Title'  , 'Title catalog' }, ;
   { 'lblName', 'Name'          }  ;
   }

// Search in list form

#define ARRFINDALL_LANG      { { 'Title'     , 'Result search' }, ;
   { 'lblName'   , 'Entry'         }, ;
   { 'NameColumn', 'Name'          }, ;
   { 'FileColumn', 'File'          }, ;
   { 'TypeColumn', 'Type'          }, ;
   { 'btnGoto'   , 'Go'            }  ;
   }

// Code formatting form

#define ARRFORMAT_LANG       { { 'Title'      , 'Source code formatting' }, ;
   { 'frmFiles'   , 'To Do'                  }, ;
   { 'rdgFiles1'  , 'Current file only'      }, ;
   { 'rdgFiles2'  , 'All files'              }, ;
   { 'frmCase'    , 'Keyword case'           }, ;
   { 'rdgCase1'   , 'lower'                  }, ;
   { 'rdgCase2'   , 'UPPER'                  }, ;
   { 'rdgCase3'   , 'Capitalize'             }, ;
   { 'btnGoto'    , 'Start'                  }, ;
   { 'Console'    , 'Progress'               }, ;
   { 'Started'    , 'Started'                }, ;
   { 'Skipped'    , 'skipped'                }, ;
   { 'Finished'   , 'Finished'               }, ;
   { 'Elapsed'    , 'Elapsed time'           }, ;
   { 'KeyLoad'    , 'Keywords list loaded'   }, ;
   { 'KeyEmpty'   , 'Keywords list empty'    }, ;
   { 'PhLoad'     , 'Phrases list loaded'    }, ;
   { 'PhEmpty'    , 'Phrases list empty'     }, ;
   { 'OpenError'  , 'Error open'             }, ;
   { 'CreateError', 'Error create'           }  ;
   }

// Function calling form

#define ARRCALLSTABLE_LANG   { { 'Console'      , 'Build ...'       }, ;
   { 'Title'        , 'Functions calls' }, ;
   { 'NameColumn'   , 'Name'            }, ;
   { 'TypeColumn'   , 'Type'            }, ;
   { 'DefinedColumn', 'Defined'         }, ;
   { 'CalledColumn' , 'Called from'     }  ;
   }

// System messages

#define ARRSYSDIALOGS_LANG   { { 'FromFile'    , 'Load from file'           }, ;
   { 'ChoiceEditor', 'Choice editor'            }, ;
   { 'TextFiles'   , 'Text'                     }, ;
   { 'AppFiles'    , 'Executable'               }, ;
   { 'AllFiles'    , 'All files'                }, ;
   { 'SourceDir'   , 'Source directory'         }, ;
   { 'ToFile'      , 'Save to file'             }, ;
   { 'Warning'     , 'Warning'                  }, ;
   { 'FileExist'   , 'File %N exist. Rewrite ?' }, ;
   { 'Inform'      , 'Information'              }, ;
   { 'Created'     , 'Created file %N'          }  ;
   }

/******
*       SelectLanguage()
*       Change the language interface
*/

PROCEDURE SelectLanguage

   MEMVAR aOptions
   LOCAL aFiles  , ;
      nLen    , ;
      Cycle   , ;
      cName   , ;
      aStrings := GetLangStrings( GET_SELECTLANGFORM_LANG )

   // If defined lang file and its exist, do initialization

   IF !Empty( aOptions[ OPTIONS_LANGFILE ] )
      IF File( LANGFILE_PATH + aOptions[ OPTIONS_LANGFILE ] )
         aStrings := GetLangStrings( GET_SELECTLANGFORM_LANG, aOptions[ OPTIONS_LANGFILE ] )
      ENDIF

   ENDIF

   DEFINE WINDOW wLangs           ;
         At 0, 0                 ;
         WIDTH 245               ;
         HEIGHT 125              ;
         TITLE aStrings[ 1, 2 ] ;
         ICON 'STOCK'            ;
         Modal

      @ 15, 10 ComboBox cmbLangs ;
         WIDTH 215         ;
         HEIGHT 165        ;
         ITEMS {}          ;
         ON CHANGE SetProperty( 'wLangs', 'btnOK', 'Enabled', !Empty( This.Value ) )

      @ ( wLangs.cmbLangs.Row + 40 ), wLangs.cmbLangs.Col ;
         Button btnOK                                      ;
         CAPTION _HMG_MESSAGE[ 6 ]                         ;
         ACTION LangReset( aFiles )

      @ wLangs.btnOk.Row, ( wLangs.btnOk.Col + wLangs.btnOk.Width + 15 ) ;
         Button btnCancel                                                 ;
         CAPTION _HMG_MESSAGE[ 7 ]                                        ;
         ACTION ThisWindow.Release

      On key Escape of wLangs Action wLangs.Release
      On key Alt+X  of wLangs Action ReleaseAllWindows()

   END WINDOW

   // Create lang files list

   IF !Empty( aFiles := Directory( LANGFILE_PATH + '*.lng' ) )

      nLen := Len( aFiles )
      FOR Cycle := 1 to nLen

         // Look for existing files and add to list
         // the lang name (exception - template file)

         IF !( Upper( aFiles[ Cycle, F_NAME ] ) == TEMPLATE_NAME )

            cName := ''

            BEGIN INI FILE ( LANGFILE_PATH + aFiles[ Cycle, F_NAME ] )
               GET cName Section HEADER_SECTION Entry 'NativeLanguage' Default ''
            END INI

            IF Empty( cName )
               cName := aFiles[ Cycle, F_NAME ]
            ENDIF

            wLangs.cmbLangs.AddItem( cName )

         ENDIF

      NEXT

      // Setup position of current language

      nLen := AScan( aFiles, { | elem | Upper( elem[ F_NAME ] ) == Upper( aOptions[ OPTIONS_LANGFILE ] ) } )

      IF !Empty( nLen )
         wLangs.cmbLangs.Value := nLen
      ENDIF

   ENDIF

   IF Empty( wLangs.cmbLangs.Value )
      wLangs.btnOK.Enabled := .F.
   ENDIF

   CENTER WINDOW wLangs
   ACTIVATE WINDOW wLangs

   RETURN

   ****** End of SelectLanguage ******

   /******
   *       LangReset( aFiles )
   *       Reinstallation the language interface
   */

STATIC PROCEDURE LangReset( aFiles )

   MEMVAR aOptions
   LOCAL nValue := wLangs.cmbLangs.Value

   IF !Empty( nValue )

      aOptions[ OPTIONS_LANGFILE ] := aFiles[ nValue, F_NAME ]

      BEGIN INI FILE STOCK_INI
         SET SECTION 'MAIN' entry 'LangFile' to aOptions[ OPTIONS_LANGFILE ]
      END INI

      // Change main window, menu, setup messages

      ModifyMainForm( GetLangStrings( GET_MAINFORM_LANG, aOptions[ OPTIONS_LANGFILE ] ) )
      BuildMenu( GetLangStrings( GET_MENU_LANG, aOptions[ OPTIONS_LANGFILE ] ) )

      SetBaseLang()

   ENDIF

   wLangs.Release

   RETURN

   ****** End of LangReset ******

   /******
   *       SetBaseLang()
   *       Setup messages (buttons caption, messages, ...)
   */

PROCEDURE SetBaseLang

   MEMVAR aOptions
   LOCAL cName := ''

   // Get english name of selecting language and setup
   // as environment

   IF !Empty( aOptions[ OPTIONS_LANGFILE ] )

      IF File( LANGFILE_PATH + aOptions[ OPTIONS_LANGFILE ] )

         BEGIN INI FILE ( LANGFILE_PATH + aOptions[ OPTIONS_LANGFILE ] )
            GET cName Section HEADER_SECTION Entry 'Language' Default ''
         END INI

      ENDIF

   ENDIF

   IF !Empty( cName  )

      cName := Upper( cName )

      DO CASE
      CASE ( cName == 'SPANISH' )
         SET LANGUAGE TO Spanish

      CASE ( cName == 'FRENCH' )
         SET LANGUAGE TO French

      CASE ( cName == 'PORTUGUESE' )
         SET LANGUAGE TO Portuguese

      CASE ( cName == 'ITALIAN' )
         SET LANGUAGE TO Italian

      CASE ( cName == 'GERMAN' )
         SET LANGUAGE TO German

      CASE ( cName == 'POLISH' )
         SET LANGUAGE TO Polish

      CASE ( cName == 'FINNISH' )
         SET LANGUAGE TO Finnish

      CASE ( cName == 'DUTCH' )
         SET LANGUAGE TO Dutch

      CASE ( cName == 'RUSSIAN' )
         SET LANGUAGE TO Russian

         //      Case ( cName == 'UKRAINIAN' )
         //        Set language to Ukrainian

      OTHERWISE
         SET LANGUAGE TO English

      ENDCASE

   ELSE
      SET LANGUAGE TO English

   ENDIF

   RETURN

   ****** End of SetBaseLang ******

   /*****
   *       GetLangStrings( nType, cFile ) --> aStrings
   *       Getting array of lang strings.
   */

FUNCTION GetLangStrings( nType, cFile )

   LOCAL aStrings    , ;
      cSectionName

   DO CASE
   CASE ( nType == GET_MENU_LANG )            // Menu items and status help
      aStrings     := ARRMENU_LANG
      cSectionName := MAINMENU_SECTION

   CASE ( nType == GET_MAINFORM_LANG )        // Main window
      aStrings     := ARRMAINFORM_LANG
      cSectionName := MAINFORM_SECTION

   CASE ( nType == GET_OPTIONSFORM_LANG )     // Options dialog
      aStrings     := ARROPTIONFORM_LANG
      cSectionName := OPTIONSFORM_SECTION

   CASE ( nType == GET_SELECTLANGFORM_LANG )  // Language dialog
      aStrings     := ARRSELECTLANG_LANG
      cSectionName := SELECTLANGFORM_SECTION

   CASE ( nType == GET_SETTITLE_LANG )        // Catalog Title dialog
      aStrings     := ARRSETTITLE_LANG
      cSectionName := SETTITLEFORM_SECTION

   CASE ( nType == GET_FINDALL_LANG )         // Search list dialog
      aStrings     := ARRFINDALL_LANG
      cSectionName := FINDALLFORM_SECTION

   CASE ( nType == GET_FORMATTER_LANG )       // Code formatting dialog
      aStrings     := ARRFORMAT_LANG
      cSectionName := FORMATTERFORM_SECTION

   CASE ( nType == GET_CALLSTABLE_LANG )      // Function calling dialog
      aStrings     := ARRCALLSTABLE_LANG
      cSectionName := CALSSTABLE_SECTION

   CASE ( nType == GET_SYSDIALOGS_LANG )      // System dialogs (Get file,...)
      aStrings     := ARRSYSDIALOGS_LANG
      cSectionName := SYSDIALOGSFORM_SECTION

   ENDCASE

   IF !( cFile == nil )
      aStrings := FillLangArray( aStrings, cFile, cSectionName )
   ENDIF

   RETURN aStrings

   ****** End of GetLangStrings *****

   /******
   *       FillLangArray( aStrings, cFile, cSection ) --> aStrings
   *       Filling the array of lang strings from the appropriate file
   */

STATIC FUNCTION FillLangArray( aStrings, cFile, cSection )

   LOCAL nLen     := Len( aStrings ), ;
      cString                    , ;
      Cycle

   cFile := ( LANGFILE_PATH + cFile )

   IF File( cFile )

      BEGIN INI FILE cFile

         FOR Cycle := 1 to nLen

            cString := ''
            GET cString Section cSection Entry aStrings[ Cycle, 1 ] Default ''

            IF !Empty( cString )
               aStrings[ Cycle, 2 ] := AllTrim( cString )
            ENDIF

         NEXT

      END INI

   ENDIF

   RETURN aStrings

   ****** End of FillLangArray ******

   /******
   *       MakeLangTemplate()
   *       Making template for language interface
   */

PROCEDURE MakeLangTemplate

   MEMVAR aOptions
   LOCAL aStrings := GetLangStrings( GET_SYSDIALOGS_LANG, aOptions[ OPTIONS_LANGFILE ] ), ;
      cString

   BEGIN Sequence

      IF File( TEMPLATE_FILE )

         cString := StrTran( aStrings[ 9, 2 ]               , ;
            '%N'                           , ;
            ( CRLF + TEMPLATE_FILE + CRLF )  ;
            )

         IF !MsgYesNo( cString, aStrings[ 8, 2 ], .T. )
            Break
         ELSE
            ERASE ( TEMPLATE_FILE )
         ENDIF

      ENDIF

      BEGIN INI FILE TEMPLATE_FILE

         SET SECTION HEADER_SECTION entry 'Language'       to 'Language in English'
         SET SECTION HEADER_SECTION entry 'NativeLanguage' to 'Language national name'

         SaveToTemplate( MAINFORM_SECTION      , GetLangStrings( GET_MAINFORM_LANG ) )
         SaveToTemplate( MAINMENU_SECTION      , GetLangStrings( GET_MENU_LANG ) )
         SaveToTemplate( OPTIONSFORM_SECTION   , GetLangStrings( GET_OPTIONSFORM_LANG ) )
         SaveToTemplate( SELECTLANGFORM_SECTION, GetLangStrings( GET_SELECTLANGFORM_LANG ) )
         SaveToTemplate( SETTITLEFORM_SECTION  , GetLangStrings( GET_SETTITLE_LANG ) )
         SaveToTemplate( FORMATTERFORM_SECTION , GetLangStrings( GET_FORMATTER_LANG ) )
         SaveToTemplate( FINDALLFORM_SECTION   , GetLangStrings( GET_FINDALL_LANG ) )
         SaveToTemplate( SYSDIALOGSFORM_SECTION, GetLangStrings( GET_SYSDIALOGS_LANG ) )

      END INI

      cString := StrTran( aStrings[ 11, 2 ], '%N', ( CRLF + TEMPLATE_FILE ) )
      MsgInfo( cString, aStrings[ 10, 2 ] )

   END

   RETURN

   ****** End of MakeLangTemplate ******

   /******
   *       SaveToTemplate( cSection, aStrings )
   *       Section saving to lang template
   */

STATIC PROCEDURE SaveToTemplate( cSection, aStrings )

   LOCAL nLen  := Len( aStrings ), ;
      Cycle

   FOR Cycle := 1 to nLen
      SET SECTION cSection entry aStrings[ Cycle, 1 ] to aStrings[ Cycle, 2 ]
   NEXT

   RETURN

   ****** End of SaveToTemplate ******
