// CVS-REV:libxml2-win-build/include/libxml/xmlIO.h:1.41:
{
  ------------------------------------------------------------------------------
  Translated into pascal with help of h2pas utility from the FreePascal project.
  Petr Kozelka <pkozelka@email.cz>
  ------------------------------------------------------------------------------
}

(*
 * Summary: interface for the I/O interfaces used by the parser
 * Description: interface for the I/O interfaces used by the parser
 *
 * Copy: See Copyright for the status of this software.
 *
 * Author: Daniel Veillard
 *
 *)

type
  (*
   * Those are the functions and datatypes for the parser input
   * I/O structures.
   *)

  (**
   * xmlInputMatchCallback:
   * @filename: the filename or URI
   *
   * Callback used in the I/O Input API to detect if the current handler
   * can provide input functionality for this resource.
   *
   * Returns 1 if yes and 0 if another Input module should be used
   *)
  xmlInputMatchCallback = function(filename: PChar): Longint; cdecl;

  (**
   * xmlInputOpenCallback:
   * @filename: the filename or URI
   *
   * Callback used in the I/O Input API to open the resource
   *
   * Returns an Input context or NULL in case or error
   *)
  xmlInputOpenCallback = function(filename: PChar): Pointer; cdecl;

  (**
   * xmlInputReadCallback:
   * @context:  an Input context
   * @buffer:  the buffer to store data read
   * @len:  the length of the buffer in bytes
   *
   * Callback used in the I/O Input API to read the resource
   *
   * Returns the number of bytes read or -1 in case of error
   *)
  xmlInputReadCallback = function(context: Pointer; buffer: PChar; len: Integer): Longint; cdecl;

  (**
   * xmlInputCloseCallback:
   * @context:  an Input context
   *
   * Callback used in the I/O Input API to close the resource
   *
   * Returns 0 or -1 in case of error
   *)
  xmlInputCloseCallback = function(context: Pointer): Longint; cdecl;
{$IFDEF LIBXML_OUTPUT_ENABLED}
  (*
   * Those are the functions and datatypes for the library output
   * I/O structures.
   *)

  (**
   * xmlOutputMatchCallback:
   * @filename: the filename or URI
   *
   * Callback used in the I/O Output API to detect if the current handler
   * can provide output fonctionnalities for this resource.
   *
   * Returns 1 if yes and 0 if another Output module should be used
   *)
  xmlOutputMatchCallback = function(const filename: PChar): Integer; cdecl;

  (**
   * xmlOutputOpenCallback:
   * @filename: the filename or URI
   *
   * Callback used in the I/O Output API to open the resource
   *
   * Returns an Output context or NULL in case or error
   *)
  xmlOutputOpenCallback = function(filename: PChar): Pointer; cdecl;

  (**
   * xmlOutputWriteCallback:
   * @context:  an Output context
   * @buffer:  the buffer of data to write
   * @len:  the length of the buffer in bytes
   *
   * Callback used in the I/O Output API to write to the resource
   *
   * Returns the number of bytes written or -1 in case of error
   *)
  xmlOutputWriteCallback = function(context: Pointer; buffer: PChar; len: Longint): Longint; cdecl;

  (**
   * xmlOutputCloseCallback:
   * @context:  an Output context
   *
   * Callback used in the I/O Output API to close the resource
   *
   * Returns 0 or -1 in case of error
   *)
  xmlOutputCloseCallback = function(context: Pointer): Longint; cdecl;

  xmlParserInputBufferPtr = ^xmlParserInputBuffer;
  xmlParserInputBuffer = record
    context: Pointer;
    readcallback: xmlInputReadCallback;
    closecallback: xmlInputCloseCallback;
    encoder: xmlCharEncodingHandlerPtr;    (* I18N conversions to UTF-8 *)
    buffer: xmlBufferPtr;                  (* Local buffer encoded in UTF-8 *)
    raw: xmlBufferPtr;                     (* if encoder != NULL buffer for raw input *)
      compressed: Longint;                        (* -1=unknown, 0=not compressed, 1=compressed *)
      error: Longint;                             
      rawconsumed: DWORD;                         (* amount consumed from raw *)
  end;

  xmlOutputBufferPtr = ^xmlOutputBuffer;
  xmlOutputBuffer = record
    context: Pointer;
    writecallback: xmlOutputWriteCallback;
    closecallback: xmlOutputCloseCallback;
    encoder: xmlCharEncodingHandlerPtr;   { I18N conversions to UTF-8  }
    buffer: xmlBufferPtr;                 { Local buffer encoded in UTF-8 or ISOLatin  }
    conv: xmlBufferPtr;                   { if encoder != NULL buffer for output  }
    written: Longint;                     { total number of byte written  }
  end;
{$ENDIF}
(* LIBXML_OUTPUT_ENABLED *)
(*
 * Interfaces for input
 *)
procedure xmlCleanupInputCallbacks; cdecl; external LIBXML2_SO;
function xmlPopInputCallbacks: Longint; cdecl; external LIBXML2_SO;
procedure xmlRegisterDefaultInputCallbacks; cdecl; external LIBXML2_SO;
function  xmlAllocParserInputBuffer(enc: xmlCharEncoding): xmlParserInputBufferPtr; cdecl; external LIBXML2_SO;
function  xmlParserInputBufferCreateFilename(URI: PChar; enc: xmlCharEncoding): xmlParserInputBufferPtr; cdecl; external LIBXML2_SO;
function  xmlParserInputBufferCreateFile(aFile: PLibXml2File; enc: xmlCharEncoding): xmlParserInputBufferPtr; cdecl; external LIBXML2_SO;
function  xmlParserInputBufferCreateFd(fd: Longint; enc: xmlCharEncoding): xmlParserInputBufferPtr; cdecl; external LIBXML2_SO;
function xmlParserInputBufferCreateMem(mem: PChar; size: Longint; enc: xmlCharEncoding): xmlParserInputBufferPtr; cdecl; external LIBXML2_SO;
function xmlParserInputBufferCreateStatic(mem: PChar; size: Longint; enc: xmlCharEncoding): xmlParserInputBufferPtr; cdecl; external LIBXML2_SO;
function  xmlParserInputBufferCreateIO(ioread: xmlInputReadCallback; ioclose: xmlInputCloseCallback; ioctx: Pointer; enc: xmlCharEncoding): xmlParserInputBufferPtr; cdecl; external LIBXML2_SO;
function  xmlParserInputBufferRead(aIn: xmlParserInputBufferPtr; len: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlParserInputBufferGrow(aIn: xmlParserInputBufferPtr; len: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlParserInputBufferPush(aIn: xmlParserInputBufferPtr; len: Longint; buf: PChar): Longint; cdecl; external LIBXML2_SO;
procedure xmlFreeParserInputBuffer(aIn: xmlParserInputBufferPtr); cdecl; external LIBXML2_SO;
function  xmlParserGetDirectory(filename: PChar): PChar; cdecl; external LIBXML2_SO;
function xmlRegisterInputCallbacks(matchFunc: xmlInputMatchCallback; openFunc: xmlInputOpenCallback; readFunc: xmlInputReadCallback; closeFunc: xmlInputCloseCallback): Longint; cdecl; external LIBXML2_SO;
function __xmlParserInputBufferCreateFilename(URI: PChar; enc: xmlCharEncoding): xmlParserInputBufferPtr; cdecl; external LIBXML2_SO;
{$IFDEF LIBXML_OUTPUT_ENABLED}
(*
 * Interfaces for output
 *)
procedure xmlCleanupOutputCallbacks; cdecl; external LIBXML2_SO;
function xmlPopOutputCallbacks: Longint; cdecl; external LIBXML2_SO;
procedure xmlRegisterDefaultOutputCallbacks; cdecl; external LIBXML2_SO;
function  xmlAllocOutputBuffer(encoder: xmlCharEncodingHandlerPtr): xmlOutputBufferPtr; cdecl; external LIBXML2_SO;
function  xmlOutputBufferCreateFilename(URI: PChar; encoder: xmlCharEncodingHandlerPtr; compression: Longint): xmlOutputBufferPtr; cdecl; external LIBXML2_SO;
function xmlOutputBufferCreateFile(aFile: PLibXml2File; encoder: xmlCharEncodingHandlerPtr): xmlOutputBufferPtr; cdecl; external LIBXML2_SO;
function xmlOutputBufferCreateBuffer(buffer: xmlBufferPtr; encoder: xmlCharEncodingHandlerPtr): xmlOutputBufferPtr; cdecl; external LIBXML2_SO;
function  xmlOutputBufferCreateFd(fd: Longint; encoder: xmlCharEncodingHandlerPtr): xmlOutputBufferPtr; cdecl; external LIBXML2_SO;
function  xmlOutputBufferCreateIO(iowrite: xmlOutputWriteCallback; ioclose: xmlOutputCloseCallback; ioctx: Pointer; encoder: xmlCharEncodingHandlerPtr): xmlOutputBufferPtr; cdecl; external LIBXML2_SO;
(* Couple of APIs to get the output without digging into the buffers *)
function xmlOutputBufferGetContent(aOut: xmlOutputBufferPtr): PxmlChar; cdecl; external LIBXML2_SO;
function xmlOutputBufferGetSize(aOut: xmlOutputBufferPtr): size_t; cdecl; external LIBXML2_SO;
function xmlOutputBufferWrite(aOut: xmlOutputBufferPtr; len: Longint; buf: PChar): Longint; cdecl; external LIBXML2_SO;
function  xmlOutputBufferWriteString(aOut: xmlOutputBufferPtr; str: PChar): Longint; cdecl; external LIBXML2_SO;
function xmlOutputBufferWriteEscape(aOut: xmlOutputBufferPtr; str: PxmlChar; escaping: xmlCharEncodingOutputFunc): Longint; cdecl; external LIBXML2_SO;
function  xmlOutputBufferFlush(aOut: xmlOutputBufferPtr): Longint; cdecl; external LIBXML2_SO;
function  xmlOutputBufferClose(aOut: xmlOutputBufferPtr): Longint; cdecl; external LIBXML2_SO;
function  xmlRegisterOutputCallbacks(matchFunc: xmlOutputMatchCallback; openFunc: xmlOutputOpenCallback; writeFunc: xmlOutputWriteCallback; closeFunc: xmlOutputCloseCallback): Longint; cdecl; external LIBXML2_SO;
function __xmlOutputBufferCreateFilename(URI: PChar; encoder: xmlCharEncodingHandlerPtr; compression: Longint): xmlOutputBufferPtr; cdecl; external LIBXML2_SO;
{$IFDEF LIBXML_HTTP_ENABLED}
(*  This function only exists if HTTP support built into the library  *)
procedure xmlRegisterHTTPPostCallbacks; cdecl; external LIBXML2_SO;
{$ENDIF}
(* LIBXML_HTTP_ENABLED *)
{$ENDIF}
(* LIBXML_OUTPUT_ENABLED *)
function xmlCheckHTTPInput(ctxt: xmlParserCtxtPtr; ret: xmlParserInputPtr): xmlParserInputPtr; cdecl; external LIBXML2_SO;
(*
 * A predefined entity loader disabling network accesses
 *)
{ [pk] declared in libxml2.pas
function  xmlNoNetExternalEntityLoader(URL: PChar; ID: PChar; ctxt: xmlParserCtxtPtr): xmlParserInputPtr; cdecl;external LIBXML2_SO;
}

(*
 * xmlNormalizeWindowsPath is obsolete, don't use it.
 * Check xmlCanonicPath in uri.h for a better alternative.
 *)
 function xmlNormalizeWindowsPath(path: PxmlChar): PxmlChar; cdecl; external LIBXML2_SO; 
 function xmlCheckFilename(path: PChar): Longint; cdecl; external LIBXML2_SO;
(*
 * Default 'file://' protocol callbacks
 *)
function xmlFileMatch(filename: PChar): Longint; cdecl; external LIBXML2_SO;
function xmlFileOpen(filename: PChar): Pointer; cdecl; external LIBXML2_SO;
function xmlFileRead(context: Pointer; buffer: PChar; len: Longint): Longint; cdecl; external LIBXML2_SO;
function xmlFileClose(context: Pointer): Longint; cdecl; external LIBXML2_SO;

(*
 * Default 'http://' protocol callbacks
 *)
{$IFDEF LIBXML_HTTP_ENABLED}
function xmlIOHTTPMatch(filename: PChar): Longint; cdecl; external LIBXML2_SO;
function xmlIOHTTPOpen(filename: PChar): Pointer; cdecl; external LIBXML2_SO;
{$IFDEF LIBXML_OUTPUT_ENABLED}
function  xmlIOHTTPOpenW(post_uri: PChar; compression: Longint): Pointer; cdecl; external LIBXML2_SO;
{$ENDIF}
(* LIBXML_OUTPUT_ENABLED *)
function xmlIOHTTPRead(context: Pointer; buffer: PChar; len: Longint): Longint; cdecl; external LIBXML2_SO;
function xmlIOHTTPClose(context: Pointer): Longint; cdecl; external LIBXML2_SO;
{$ENDIF}
(* LIBXML_HTTP_ENABLED *)
(*
 * Default 'ftp://' protocol callbacks
 *)
{$IFDEF LIBXML_FTP_ENABLED }
function xmlIOFTPMatch(filename: PChar): Longint; cdecl; external LIBXML2_SO;
function xmlIOFTPOpen(filename: PChar): Pointer; cdecl; external LIBXML2_SO;
function xmlIOFTPRead(context: Pointer; buffer: PChar; len: Longint): Longint; cdecl; external LIBXML2_SO;
function xmlIOFTPClose(context: Pointer): Longint; cdecl; external LIBXML2_SO;
{$ENDIF}
(* LIBXML_FTP_ENABLED *)
