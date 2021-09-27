// CVS-REV:libxslt-win-build/libxslt/preproc.h:1.6:
{
  ------------------------------------------------------------------------------
  Translated into pascal with help of h2pas utility from the FreePascal project.
  Uwe Fechner <ufechner@4commerce.de> - 4commerce technologies AG
  Petr Kozelka <pkozelka@email.cz>
  ------------------------------------------------------------------------------
}
(*
 * preproc.h: precomputing data interfaces
 *
 * See Copyright for the status of this software.
 *
 * daniel@veillard.com
 *)

(*
 * Interfaces
 *)
{todo
extern const xmlChar *xsltExtMarker;
}
function  xsltDocumentComp(style: xsltStylesheetPtr; inst: xmlNodePtr; transformfunction: xsltTransformFunction): xsltElemPreCompPtr; cdecl; external libxslt-win-build_SO;
procedure xsltStylePreCompute(style: xsltStylesheetPtr; inst: xmlNodePtr); cdecl; external libxslt-win-build_SO;
procedure xsltFreeStylePreComps(style: xsltStylesheetPtr); cdecl; external libxslt-win-build_SO;

