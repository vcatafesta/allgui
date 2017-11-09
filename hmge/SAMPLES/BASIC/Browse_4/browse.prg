/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

FUNCTION Main

   SET BROWSESYNC ON

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 800 HEIGHT 480 ;
         TITLE 'MiniGUI Browse Demo' ;
         MAIN NOMAXIMIZE ;
         ON INIT OpenTables() ;
         ON RELEASE CloseTables()

      @ 10,10 LABEL Label_1 VALUE 'Pedidos'

      @ 10,400 LABEL Label_2 VALUE 'Items'

      @ 40,10 BROWSE Pedidos   ;
         WIDTH 380 ;
         HEIGHT 370 ;
         HEADERS { 'Pedido' , 'Cliente' , 'Endereco' , 'Cidade' } ;
         WIDTHS { 100 , 250 , 250 , 150 } ;
         WORKAREA Pedidos ;
         FIELDS { 'Pedidos->Pedido' , 'Clientes->Nome' , 'Clientes->Endereco' , 'Clientes->Cidade' } ;
         ON CHANGE UpdateItems() ;
         EDIT INPLACE ;
         READONLY { .T. , .F. , .F. , .F. } LOCK

      @ 40,400 BROWSE Items ;
         WIDTH 380 ;
         HEIGHT 370 ;
         HEADERS { 'Pedido' , 'Produto' , 'Quant' , 'Valor' , 'Sum' } ;
         WIDTHS { 99 , 120 , 60 , 80 , 90 } ;
         WORKAREA Items ;
         FIELDS { 'Items->Pedido' , 'Items->Produto' , 'Items->Quant' , 'Items->Valor', 'Quant*Valor' } ;
         JUSTIFY { BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT } ;
         EDIT INPLACE ;
         READONLY { .T. , .F. , .F. , .F. , .T. } LOCK

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

PROCEDURE OpenTables()

   LOCAL aProduto := {}

   USE Clientes Shared New
   INDEX ON Field->Codigo To Clientes

   USE Produtos Shared New
   INDEX ON Field->Produto To Produtos
   dbeval( { || aadd( aProduto, {Nome, Produto} ) } )

   USE Items Shared New
   INDEX ON Field->Pedido To Items

   USE Pedidos Shared New
   SET RELATION TO Field->Cliente Into Clientes

   Form_1.Pedidos.Value := RecNo()
   UpdateItems()

   Form_1.Items.InputItems := { Nil , aProduto , Nil , Nil , Nil }

   Form_1.Items.DisplayItems := { Nil , aProduto , Nil , Nil , Nil }

   RETURN

PROCEDURE CloseTables()

   CLOSE DataBases
   AEval( Directory( '*.ntx' ), { |file| Ferase( file[1] ) } )

   RETURN

PROCEDURE UpdateItems()

   LOCAL nArea := Select()

   SELECT Items
   OrdScope(0,Pedidos->Pedido)
   OrdScope(1,Pedidos->Pedido)
   GO TOP
   Form_1.Items.Value := RecNo()
   Select(nArea)

   RETURN

