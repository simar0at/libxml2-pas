// CVS-REV:libxslt-win-build/libxslt/templates.h:1.10:
{
  ------------------------------------------------------------------------------
  Translated into pascal with help of h2pas utility from the FreePascal project.
  Uwe Fechner <ufechner@4commerce.de> - 4commerce technologies AG
  Petr Kozelka <pkozelka@email.cz>
  ------------------------------------------------------------------------------
}
(*
 * templates.h: interface for the template processing
 *
 * See Copyright for the status of this software.
 *
 * daniel@veillard.com
 *)

function xsltEvalXPathPredicate(ctxt: xsltTransformContextPtr; comp: xmlXPathCompExprPtr; nsList: PxmlNsPtr; nsNr: Longint): Longint; cdecl; external libxslt-win-build_SO;
function xsltEvalTemplateString(ctxt: xsltTransformContextPtr; node: xmlNodePtr; parent: xmlNodePtr): PxmlChar; cdecl; external libxslt-win-build_SO;
function xsltEvalAttrValueTemplate(ctxt: xsltTransformContextPtr; node: xmlNodePtr; name: PxmlChar; ns: PxmlChar): PxmlChar; cdecl; external libxslt-win-build_SO;
function xsltEvalStaticAttrValueTemplate(style: xsltStylesheetPtr; node: xmlNodePtr; name: PxmlChar; ns: PxmlChar; found: PLongint): PxmlChar; cdecl; external libxslt-win-build_SO;
(* TODO: this is obviously broken ... the namespaces should be passed too ! *)
function xsltEvalXPathString(ctxt: xsltTransformContextPtr; comp: xmlXPathCompExprPtr): PxmlChar; cdecl; external libxslt-win-build_SO;
function xsltTemplateProcess(ctxt: xsltTransformContextPtr; node: xmlNodePtr): PxmlNodePtr; cdecl; external libxslt-win-build_SO;
function xsltAttrListTemplateProcess(ctxt: xsltTransformContextPtr; target: xmlNodePtr; cur: xmlAttrPtr): xmlAttrPtr; cdecl; external libxslt-win-build_SO;
function xsltAttrTemplateProcess(ctxt: xsltTransformContextPtr; target: xmlNodePtr; attr: xmlAttrPtr): xmlAttrPtr; cdecl; external libxslt-win-build_SO;
function xsltAttrTemplateValueProcess(ctxt: xsltTransformContextPtr; attr: PxmlChar): PxmlChar; cdecl; external libxslt-win-build_SO;
function xsltAttrTemplateValueProcessNode(ctxt: xsltTransformContextPtr; str: PxmlChar; node: xmlNodePtr): PxmlChar; cdecl; external libxslt-win-build_SO;

