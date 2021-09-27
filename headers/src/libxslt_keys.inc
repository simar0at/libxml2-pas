// CVS-REV:libxslt-win-build/libxslt/keys.h:1.5:
{
  ------------------------------------------------------------------------------
  Translated into pascal with help of h2pas utility from the FreePascal project.
  Uwe Fechner <ufechner@4commerce.de> - 4commerce technologies AG
  Petr Kozelka <pkozelka@email.cz>
  ------------------------------------------------------------------------------
}
(*
 * key.h: interface for the key matching used in template matches.
 *
 * See Copyright for the status of this software.
 *
 * daniel@veillard.com
 *)

function  xsltAddKey(style: xsltStylesheetPtr; name: PxmlChar; nameURI: PxmlChar; match: PxmlChar; use: PxmlChar; inst: xmlNodePtr): Longint; cdecl; external libxslt-win-build_SO;
function  xsltGetKey(ctxt: xsltTransformContextPtr; name: PxmlChar; nameURI: PxmlChar; value: PxmlChar): xmlNodeSetPtr; cdecl; external libxslt-win-build_SO;
procedure xsltInitCtxtKeys(ctxt: xsltTransformContextPtr; doc: xsltDocumentPtr); cdecl; external libxslt-win-build_SO;
procedure xsltFreeKeys(style: xsltStylesheetPtr); cdecl; external libxslt-win-build_SO;
procedure xsltFreeDocumentKeys(doc: xsltDocumentPtr); cdecl; external libxslt-win-build_SO;

