// CVS-REV:libxml2-win-build/include/libxml/tree.h:1.125:
{
  ------------------------------------------------------------------------------
  Translated into pascal with help of h2pas utility from the FreePascal project.
  Petr Kozelka <pkozelka@email.cz>
  ------------------------------------------------------------------------------
}

  (**
   * Summary: interfaces for tree manipulation
   * Description: this module describes the structures found in an tree resulting
   *              from an XML or HTML parsing, as well as the API provided for
   *              various processing on that tree
   *
   * Copy: See Copyright for the status of this software.
   *
   * Author: Daniel Veillard
   *
   *)
  (**
   * Some of the basic types Pointer to structures:
   *)
(* xmlIO.h  *)
{[pk] following declarations are in xmlIO.inc:
  type
    xmlParserInputBufferPtrPtr = ^xmlParserInputBufferPtr;
    xmlParserInputBufferPtr = PxmlParserInputBuffer;
    xmlOutputBufferPtrPtr = ^xmlOutputBufferPtr;
    xmlOutputBufferPtr = PxmlOutputBuffer;
}
(* parser.h  *)
{[pk] following declarations are in parser.inc:
    xmlParserInputPtrPtr = ^xmlParserInputPtr;
    xmlParserInputPtr = PxmlParserInput;
    xmlParserCtxtPtrPtr = ^xmlParserCtxtPtr;
    xmlParserCtxtPtr = PxmlParserCtxt;
    xmlSAXLocatorPtrPtr = ^xmlSAXLocatorPtr;
    xmlSAXLocatorPtr = PxmlSAXLocator;
    xmlSAXHandlerPtrPtr = ^xmlSAXHandlerPtr;
    xmlSAXHandlerPtr = PxmlSAXHandler;
}
(* entities.h  *)
{[pk] following declarations are in entities.inc:
    xmlEntityPtrPtr = ^xmlEntityPtr;
    xmlEntityPtr = PxmlEntity;
}
  (**
   * LIBXML_NAMESPACE_DICT:
   *
   * Defines experimental behaviour:
   * 1) xmlNs gets an additional field @context (a xmlDoc)
   * 2) when creating a tree, xmlNs->href is stored in the dict of xmlDoc.
   *)
(* #define LIBXML_NAMESPACE_DICT  *)
  const
  (**
   * XML_XML_NAMESPACE:
   *
   * This is the namespace for the special xml: prefix predefined in the
   * XML Namespace specification.
   *)
  XML_XML_NAMESPACE = 'http://www.w3.org/XML/1998/namespace';
  (**
   * XML_XML_ID:
   *
   * This is the name for the special xml: id attribute
   *)
   XML_XML_ID = 'xml:id';   
  (*
   * The different element types carried by an XML tree.
   *
   * NOTE: This is synchronized with DOM Level1 values
   *       See http://www.w3.org/TR/REC-DOM-Level-1/
   *
   * Actually this had diverged a bit, and now XML_DOCUMENT_TYPE_NODE should
   * be deprecated to use an XML_DTD_NODE.
   *)

type
    xmlElementType = (
  XML_ELEMENT_NODE      = 1,
  XML_ATTRIBUTE_NODE    = 2,
  XML_TEXT_NODE          = 3,
  XML_CDATA_SECTION_NODE = 4,
  XML_ENTITY_REF_NODE    = 5,
  XML_ENTITY_NODE        = 6,
  XML_PI_NODE            = 7,
  XML_COMMENT_NODE       = 8,
  XML_DOCUMENT_NODE      = 9,
  XML_DOCUMENT_TYPE_NODE = 10,
  XML_DOCUMENT_FRAG_NODE = 11,
  XML_NOTATION_NODE = 12,
  XML_HTML_DOCUMENT_NODE = 13,
  XML_DTD_NODE = 14,
  XML_ELEMENT_DECL = 15,
  XML_ATTRIBUTE_DECL = 16,
  XML_ENTITY_DECL = 17,
  XML_NAMESPACE_DECL = 18,
  XML_XINCLUDE_START = 19,
  XML_XINCLUDE_END = 20,
  XML_DOCB_DOCUMENT_NODE = 21);

  (**
   * xmlChar:
   *
   * This is a basic byte in an UTF-8 encoded string.
   * It's unsigned allowing to pinpoint case where char * are assigned
   * to xmlChar * (possibly making serialization back impossible).
   *)
{[pk] moved to libxml2.pas
  xmlChar = Char;
  PxmlChar = PChar;
  PPxmlChar = ^PxmlChar;
}
// BAD_CAST: not necessary in Pascal

const
  (**
   * XML_LOCAL_NAMESPACE:
   *
   * A namespace declaration node.
   *)
  XML_LOCAL_NAMESPACE = xmlElementType.XML_NAMESPACE_DECL;

type

  (**
   * xmlNotation:
   *
   * A DTD Notation definition.
   *)
  xmlNotationPtr = ^xmlNotation;
  xmlNotation = record
    name: PxmlChar;                 (* Notation name  *)
    PublicID: PxmlChar;             (* Public identifier, if any  *)
    SystemID: PxmlChar;             (* System identifier, if any  *)
  end;

  (**
   * xmlAttributeType:
   *
   * A DTD Attribute type definition.
   *)

  xmlAttributeType = (
    DUMMY_XML_ATTRIBUTE_TYPE_0, // = 0 // this is for D5 compatibility
    XML_ATTRIBUTE_CDATA,        // = 1,
    XML_ATTRIBUTE_ID,
    XML_ATTRIBUTE_IDREF,
    XML_ATTRIBUTE_IDREFS,
    XML_ATTRIBUTE_ENTITY,
    XML_ATTRIBUTE_ENTITIES,
    XML_ATTRIBUTE_NMTOKEN,
    XML_ATTRIBUTE_NMTOKENS,
    XML_ATTRIBUTE_ENUMERATION,
    XML_ATTRIBUTE_NOTATION
  );

  (**
   * xmlAttributeDefault:
   *
   * A DTD Attribute default definition.
   *)
  xmlAttributeDefault = (
    DUMMY_XML_ATTRIBUTE_DEFAULT_0, // = 0 // this is for D5 compatibility
    XML_ATTRIBUTE_NONE,            // = 1,
    XML_ATTRIBUTE_REQUIRED,
    XML_ATTRIBUTE_IMPLIED,
    XML_ATTRIBUTE_FIXED
  );

  (**
   * xmlEnumeration:
   *
   * List structure used when there is an enumeration in DTDs.
   *)
  xmlEnumerationPtr = ^xmlEnumeration;
  xmlEnumeration = record
    next: xmlEnumerationPtr;        (* next one  *)
    name: PxmlChar;                 (* Enumeration name  *)
  end;

  xmlNodePtr = ^xmlNode;
  xmlDtdPtr = ^xmlDtd;
  xmlDocPtr = ^xmlDoc;
  (**
   * xmlAttribute:
   *
   * An Attribute declaration in a DTD.
   *)
  xmlAttributePtr = ^xmlAttribute;
  xmlAttribute = record
    _private: Pointer;              (* application data *)
    _type : xmlElementType;          (* XML_ATTRIBUTE_DECL, must be second !  *)
    name: PxmlChar;                 (* Attribute name  *)
    children: xmlNodePtr;           (* NULL  *)
    last: xmlNodePtr;               (* NULL  *)
    parent: xmlDtdPtr;              (* -> DTD  *)
    next: xmlNodePtr;               (* next sibling link   *)
    prev: xmlNodePtr;               (* previous sibling link   *)
    doc: xmlDocPtr;                 (* the containing document  *)
    nexth: xmlAttributePtr;         (* next in hash table  *)
    atype: xmlAttributeType;        (* The attribute type  *)
    def: xmlAttributeDefault;       (* the default  *)
    defaultValue: PxmlChar;         (* or the default value  *)
    tree: xmlEnumerationPtr;        (* or the enumeration tree if any  *)
    prefix: PxmlChar;               (* the namespace prefix if any  *)
    elem: PxmlChar;                 (* Element holding the attribute  *)
  end;

  (**
   * xmlElementContentType:
   *
   * Possible definitions of element content types.
   *)
  xmlElementContentType = (
    DUMMY_XML_ELEMENT_CONTENT_TYPE_0, // = 0 // this is for D5 compatibility
    XML_ELEMENT_CONTENT_PCDATA,       // = 1,
    XML_ELEMENT_CONTENT_ELEMENT,
    XML_ELEMENT_CONTENT_SEQ,
    XML_ELEMENT_CONTENT_OR
  );

  (**
   * xmlElementContentOccur:
   *
   * Possible definitions of element content occurences.
   *)
  xmlElementContentOccur = (
    DUMMY_XML_ELEMENT_CONTENT_OCCUR_0, // = 0 // this is for D5 compatibility
    XML_ELEMENT_CONTENT_ONCE,          // = 1,
    XML_ELEMENT_CONTENT_OPT,
    XML_ELEMENT_CONTENT_MULT,
    XML_ELEMENT_CONTENT_PLUS
  );

  (**
   * xmlElementContent:
   *
   * An XML Element content as stored after parsing an element definition
   * in a DTD.
   *)
  xmlElementContentPtr = ^xmlElementContent;
  xmlElementContent = record
    _type : xmlElementContentType;        (* PCDATA, ELEMENT, SEQ or OR  *)
    ocur: xmlElementContentOccur;   (* ONCE, OPT, MULT or PLUS *)
    name: PxmlChar;                 (* Element name *)
    c1: xmlElementContentPtr;       (* first child *)
    c2: xmlElementContentPtr;       (* second child *)
    parent: xmlElementContentPtr;   (* parent *)
    prefix: PxmlChar;               (* Namespace prefix *)
  end;

  (**
   * xmlElementTypeVal:
   *
   * The different possibilities for an element content type.
   *)
  xmlElementTypeVal = (
    XML_ELEMENT_TYPE_UNDEFINED, // = 0,
    XML_ELEMENT_TYPE_EMPTY,
    XML_ELEMENT_TYPE_ANY,
    XML_ELEMENT_TYPE_MIXED,
    XML_ELEMENT_TYPE_ELEMENT
  );

  (**
   * xmlElement:
   *
   * An XML Element declaration from a DTD.
   *)
  xmlElementPtr = ^xmlElement;
  xmlElement = record
    _private: Pointer;              (* application data *)
    _type : xmlElementType;               (* XML_ELEMENT_DECL, must be second !  *)
    name: PxmlChar;                 (* Element name  *)
    children: xmlNodePtr;           (* NULL  *)
    last: xmlNodePtr;               (* NULL  *)
    parent: xmlDtdPtr;              (* -> DTD  *)
    next: xmlNodePtr;               (* next sibling link   *)
    prev: xmlNodePtr;               (* previous sibling link   *)
    doc: xmlDocPtr;                 (* the containing document  *)
    etype: xmlElementTypeVal;       (* The type  *)
    content: xmlElementContentPtr;  (* the allowed element content  *)
    attributes: xmlAttributePtr;    (* List of the declared attributes  *)
    prefix: PxmlChar;               (* the namespace prefix if any  *)
{$ifdef LIBXML_REGEXP_ENABLED}            
    contModel: xmlRegexpPtr;        (* the validating regexp *)
{$else}
    contModel: Pointer;
{$endif}
  end;

  xmlNsType = xmlElementType;
  (**
   * xmlNs:
   *
   * An XML namespace.
   * Note that prefix == NULL is valid, it defines the default namespace
   * within the subtree (until overridden).
   *
   * xmlNsType is unified with xmlElementType.
   *)
  xmlNsPtr = ^xmlNs;
  PxmlNsPtr = ^xmlNsPtr;
  xmlNs = record
    next: xmlNsPtr;                 (* next Ns link for this node   *)
    _type : xmlNsType;            (* global or local  *)
    href: PxmlChar;                 (* URL for the namespace  *)
    prefix: PxmlChar;               (* prefix for the namespace  *)
    _private: Pointer;              (* application data *)
    context : xmlDocPtr;          (* normally an xmlDoc  *)
  end;

  (**
   * xmlDtd:
   *
   * An XML DTD, as defined by <!DOCTYPE ... There is actually one for
   * the internal subset and for the external subset.
   *)
  xmlDtd = record
    _private: Pointer;              (* application data *)
    _type : xmlElementType;                (* XML_DTD_NODE, must be second !  *)
    name: PxmlChar;                 (* Name of the DTD  *)
    children: xmlNodePtr;           (* the value of the property link  *)
    last: xmlNodePtr;               (* last child link  *)
    parent: xmlDocPtr;              (* child->parent link  *)
    next: xmlNodePtr;               (* next sibling link   *)
    prev: xmlNodePtr;               (* previous sibling link   *)
    doc: xmlDocPtr;                 (* the containing document  *)
    (* End of common part  *)
    notations: Pointer;             (* Hash table for notations if any  *)
    elements: Pointer;              (* Hash table for elements if any  *)
    attributes: Pointer;            (* Hash table for attributes if any  *)
    entities: Pointer;              (* Hash table for entities if any  *)
    ExternalID: PxmlChar;           (* External identifier for PUBLIC DTD  *)
    SystemID: PxmlChar;             (* URI for a SYSTEM or PUBLIC DTD  *)
    pentities: Pointer;             (* Hash table for param entities if any  *)
  end;

  (**
   * xmlAttr:
   *
   * An attribute on an XML node.
   *)

  xmlAttrPtr = ^xmlAttr;
  xmlAttr = record
    _private: Pointer;              (* application data *)
    _type : xmlElementType;         (* XML_ATTRIBUTE_NODE, must be second !  *)
    name: PxmlChar;                 (* the name of the property  *)
    children: xmlNodePtr;           (* the value of the property  *)
    last: xmlNodePtr;               (* NULL  *)
    parent: xmlNodePtr;             (* child->parent link  *)
    next: xmlAttrPtr;               (* next sibling link   *)
    prev: xmlAttrPtr;               (* previous sibling link   *)
    doc: xmlDocPtr;                 (* the containing document  *)
    ns: xmlNsPtr;                   (* Pointer to the associated namespace  *)
    atype: xmlAttributeType;        (* the attribute type if validating  *)
    psvi : Pointer;                 (* for type/PSVI information  *)
  end;

  (**
   * xmlID:
   *
   * An XML ID instance.
   *)
  xmlIDPtr = ^xmlID;
  xmlID = record
    next: xmlIDPtr;                 (* next ID *)
    value: PxmlChar;                (* The ID name *)
    attr: xmlAttrPtr;                  (* The attribute holding it  *)
    name: PxmlChar;                 (* The attribute if attr is not available *)
    lineno: Longint;                (* The line number if attr is not available *)
    doc : xmlDocPtr;                    (* The document holding the ID  *)
  end;

  (**
   * xmlRef:
   * An XML IDREF instance.
   *)
  xmlRefPtr = ^xmlRef;
  xmlRef = record
    next: xmlRefPtr;                (* next Ref  *)
    value: PxmlChar;                (* The Ref name  *)
    attr: xmlAttrPtr;               (* The attribute holding it  *)
    name: PxmlChar;                 (* The attribute if attr is not available *)
    lineno: Longint;                (* The line number if attr is not available *)
  end;

  (**
   * xmlNode:
   *
   * A node in an XML tree.
   *)
  xmlNode = record
    _private: Pointer;              (* application data *)
    _type : xmlElementType;         (* type number, must be second !  *)
    name: PxmlChar;                 (* the name of the node, or the entity  *)
    children: xmlNodePtr;           (* parent->childs link  *)
    last: xmlNodePtr;               (* last child link  *)
    parent: xmlNodePtr;             (* child->parent link  *)
    next: xmlNodePtr;               (* next sibling link   *)
    prev: xmlNodePtr;               (* previous sibling link   *)
    doc: xmlDocPtr;                 (* the containing document  *)
    (* End of common part  *)
    ns: xmlNsPtr;                   (* Pointer to the associated namespace  *)
    content: PxmlChar;              (* the content  *)
    properties: xmlAttrPtr;         (* properties list  *)
    nsDef: xmlNsPtr;                (* namespace definitions on this node  *)
    psvi : Pointer;                 (* for type/PSVI information  *)
    line : word;                    (* line number  *)
    extra : word;                   (* extra data for XPath/XSLT  *)
  end;

  (**
   * xmlDocProperty
   *
   * Set of properties of the document as found by the parser
   * Some of them are linked to similarly named xmlParserOption
   *)
    xmlDocPropertiesPtr = ^xmlDocProperties;
    xmlDocProperties = (
    XML_DOC_WELLFORMED = 1 shl 0,          (* document is XML well formed  *)
    XML_DOC_NSVALID = 1 shl 1,             (* document is Namespace valid  *)
    XML_DOC_OLD10 = 1 shl 2,               (* parsed with old XML-1.0 parser  *)
    XML_DOC_DTDVALID = 1 shl 3,            (* DTD validation was successful  *)
    XML_DOC_XINCLUDE = 1 shl 4,            (* XInclude substitution was done  *)
    XML_DOC_USERBUILT = 1 shl 5,           (* Document was built using the API and not by parsing an instance  *)
    XML_DOC_INTERNAL = 1 shl 6,            (* built for internal processing  *)
    XML_DOC_HTML = 1 shl 7                 (* parsed or built HTML document  *)
    );
  (**
   * xmlDoc:
   *
   * An XML document.
   *)
  xmlDoc = record
    _private: Pointer;              (* application data *)
    _type : xmlElementType;               (* XML_DOCUMENT_NODE, must be second !  *)
    name: PChar;                    (* name/filename/URI of the document  *)
    children: xmlNodePtr;           (* the document tree  *)
    last: xmlNodePtr;               (* last child link  *)
    parent: xmlNodePtr;             (* child->parent link  *)
    next: xmlNodePtr;               (* next sibling link   *)
    prev: xmlNodePtr;               (* previous sibling link   *)
    doc: xmlDocPtr;                 (* autoreference to itself  *)
    (* End of common part  *)
    compression: Longint;           (* level of zlib compression  *)
    standalone: Longint;            (* standalone document (no external refs)  *)
    intSubset: xmlDtdPtr;           (* the document internal subset  *)
    extSubset: xmlDtdPtr;           (* the document external subset  *)
    oldNs: xmlNsPtr;                (* Global namespace, the old way  *)
    version: PxmlChar;              (* the XML version string  *)
    encoding: PxmlChar;             (* external initial encoding, if any  *)
    ids: Pointer;                   (* Hash table for ID attributes if any  *)
    refs: Pointer;                  (* Hash table for IDREFs attributes if any  *)
    URL: PxmlChar;                  (* The URI for that document  *)
    charset : Longint;                     (* Internal flag for charset handling,
  				   actually an xmlCharEncoding  *)
    dict : xmlDictPtr;                      (* dict used to allocate names or NULL  *)
    psvi : Pointer;                         (* for type/PSVI information  *)
    parseFlags : Longint;                   (* set of xmlParserOption used to parse the
      				   document  *)
    properties : Longint;                   (* set of xmlDocProperties for this document
  				   set at the end of parsing  *)
  end;

  xmlDOMWrapCtxtPtr = ^xmlDOMWrapCtxt;
(**
   * xmlDOMWrapAcquireNsFunction:
   * @ctxt:  a DOM wrapper context
   * @node:  the context node (element or attribute)
   * @nsName:  the requested namespace name
   * @nsPrefix:  the requested namespace prefix
   *
   * A function called to acquire namespaces (xmlNs) from the wrapper.
   *
   * Returns an xmlNsPtr or NULL in case of an error.
   *)
    xmlDOMWrapAcquireNsFunction = function (ctxt: xmlDOMWrapCtxtPtr; node: xmlNodePtr; nsName: PxmlChar; nsPrefix: xmlChar): xmlNsPtr;cdecl;
  (**
   * xmlDOMWrapCtxt:
   *
   * Context for DOM wrapper-operations.
   *) 
    xmlDOMWrapCtxt = record
    _private : Pointer;
    _type : Longint;                    (*
                                         * The type of this context, just in case we need specialized
                                         * contexts in the future.
                                         *)
    namespaceMap : Pointer;             (*
                                         * Internal namespace map used for various operations.
                                         *)
    getNsForNodeFunc : xmlDOMWrapAcquireNsFunction; (*
                                                     * Use this one to acquire an xmlNsPtr intended for node->ns.
                                                     * (Note that this is not intended for elem->nsDef).
                                                     *)
      end;
(*     
 * Variables.
 *)
{$IFDEF HAS_SO_VARS}
LIBXML_DLL_IMPORT extern int oldXMLWDcompatibility; (* maintain compatibility with old WD *)
LIBXML_DLL_IMPORT extern int xmlIndentTreeOutput;  (* try to indent the tree dumps *)
LIBXML_DLL_IMPORT extern xmlBufferAllocationScheme xmlBufferAllocScheme; (* alloc scheme to use *)
LIBXML_DLL_IMPORT extern int xmlSaveNoEmptyTags; (* save empty tags as <empty></empty> *)
LIBXML_DLL_IMPORT extern int xmlDefaultBufferSize; (* default buffer size *)
{$ENDIF}

(*
 * Some helper functions
 *)
function  xmlValidateNCName(value: PxmlChar; space: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlValidateQName(value: PxmlChar; space: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlValidateName(value: PxmlChar; space: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlValidateNMToken(value: PxmlChar; space: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlBuildQName(ncname: PxmlChar; prefix: PxmlChar; memory: PxmlChar; len: Longint): PxmlChar; cdecl; external LIBXML2_SO;
function  xmlSplitQName2(name: PxmlChar; prefix: PPxmlChar): PxmlChar; cdecl; external LIBXML2_SO;
function  xmlSplitQName3(name: PxmlChar; len: PLongint): PxmlChar; cdecl; external LIBXML2_SO; 
  (**
   * Handling Buffers, the old ones see @xmlBuf for the new ones.
   *)
procedure xmlSetBufferAllocationScheme(scheme: xmlBufferAllocationScheme); cdecl; external LIBXML2_SO;
function  xmlGetBufferAllocationScheme: xmlBufferAllocationScheme; cdecl; external LIBXML2_SO;
function  xmlBufferCreate: xmlBufferPtr; cdecl; external LIBXML2_SO;
function  xmlBufferCreateSize(size: Integer): xmlBufferPtr; cdecl; external LIBXML2_SO;
function  xmlBufferResize(buf: xmlBufferPtr; size: DWORD): Longint; cdecl; external LIBXML2_SO;
procedure xmlBufferFree(buf: xmlBufferPtr); cdecl; external LIBXML2_SO;
function  xmlBufferDump(aFile: PLibXml2File; buf: xmlBufferPtr): Longint; cdecl; external LIBXML2_SO;
function  xmlBufferAdd(buf: xmlBufferPtr; str: PxmlChar; len: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlBufferAddHead(buf: xmlBufferPtr; str: PxmlChar; len: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlBufferCat(buf: xmlBufferPtr; str: xmlChar): Longint; cdecl; external LIBXML2_SO;
function  xmlBufferCCat(buf: xmlBufferPtr; str: Pchar): Longint; cdecl; external LIBXML2_SO;
function  xmlBufferShrink(buf: xmlBufferPtr; len: DWORD): Longint; cdecl; external LIBXML2_SO;
function  xmlBufferGrow(buf: xmlBufferPtr; len: DWORD): Longint; cdecl; external LIBXML2_SO;
procedure xmlBufferEmpty(buf: xmlBufferPtr); cdecl; external LIBXML2_SO;
function  xmlBufferContent(buf: xmlBufferPtr): PxmlChar; cdecl; external LIBXML2_SO;
procedure xmlBufferSetAllocationScheme(buf: xmlBufferPtr; scheme: xmlBufferAllocationScheme); cdecl; external LIBXML2_SO;
function  xmlBufferLength(buf: xmlBufferPtr): Longint; cdecl; external LIBXML2_SO;

(*
 * Creating/freeing new structures.
 *)
function  xmlCreateIntSubset(doc: xmlDocPtr; name: PxmlChar; ExternalID: PxmlChar; SystemID: PxmlChar): xmlDtdPtr; cdecl; external LIBXML2_SO;
function  xmlNewDtd(doc: xmlDocPtr; name: PxmlChar; ExternalID: PxmlChar; SystemID: PxmlChar): xmlDtdPtr; cdecl; external LIBXML2_SO;
function  xmlGetIntSubset(doc: xmlDocPtr): xmlDtdPtr; cdecl; external LIBXML2_SO;
procedure xmlFreeDtd(cur: xmlDtdPtr); cdecl; external LIBXML2_SO;
{$ifdef LIBXML_LEGACY_ENABLED}
function  xmlNewGlobalNs(doc: xmlDocPtr; href: PxmlChar; prefix: PxmlChar): xmlNsPtr; cdecl; external LIBXML2_SO; {$IFDEF HAS_DEPR} deprecated; {$ENDIF}
{$endif}
(* LIBXML_LEGACY_ENABLED  *)
function  xmlNewNs(node: xmlNodePtr; href: PxmlChar; prefix: PxmlChar): xmlNsPtr; cdecl; external LIBXML2_SO;
procedure xmlFreeNs(cur: xmlNsPtr); cdecl; external LIBXML2_SO;
procedure xmlFreeNsList(cur: xmlNsPtr); cdecl; external LIBXML2_SO;
function  xmlNewDoc(version: PxmlChar): xmlDocPtr; cdecl; external LIBXML2_SO;
procedure xmlFreeDoc(cur: xmlDocPtr); cdecl; external LIBXML2_SO;
function  xmlNewDocProp(doc: xmlDocPtr; name: PxmlChar; value: PxmlChar): xmlAttrPtr; cdecl; external LIBXML2_SO;
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_HTML_ENABLED) ||     defined(LIBXML_SCHEMAS_ENABLED)}
function  xmlNewProp(node: xmlNodePtr; name: PxmlChar; value: PxmlChar): xmlAttrPtr; cdecl; external LIBXML2_SO;
{$endif}
function  xmlNewNsProp(node: xmlNodePtr; ns: xmlNsPtr; name: PxmlChar; value: PxmlChar): xmlAttrPtr; cdecl; external LIBXML2_SO;
function  xmlNewNsPropEatName(node: xmlNodePtr; ns: xmlNsPtr; name: PxmlChar; value: PxmlChar): xmlAttrPtr; cdecl; external LIBXML2_SO;
procedure xmlFreePropList(cur: xmlAttrPtr); cdecl; external LIBXML2_SO;
procedure xmlFreeProp(cur: xmlAttrPtr); cdecl; external LIBXML2_SO;
function  xmlCopyProp(target: xmlNodePtr; cur: xmlAttrPtr): xmlAttrPtr; cdecl; external LIBXML2_SO;
function  xmlCopyPropList(target: xmlNodePtr; cur: xmlAttrPtr): xmlAttrPtr; cdecl; external LIBXML2_SO;
{$ifdef LIBXML_TREE_ENABLED}
function  xmlCopyDtd(dtd: xmlDtdPtr): xmlDtdPtr; cdecl; external LIBXML2_SO;
{$endif}
(* LIBXML_TREE_ENABLED  *)
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_SCHEMAS_ENABLED)}
function  xmlCopyDoc(doc: xmlDocPtr; recursive: Longint): xmlDocPtr; cdecl; external LIBXML2_SO;
{$endif}
(* defined(LIBXML_TREE_ENABLED) || defined(LIBXML_SCHEMAS_ENABLED)  *)
  (**
 * Creating new nodes.
 *)
function  xmlNewDocNode(doc: xmlDocPtr; ns: xmlNsPtr; name: PxmlChar; content: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewDocNodeEatName(doc: xmlDocPtr; ns: xmlNsPtr; name: PxmlChar; content: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewDocRawNode(doc: xmlDocPtr; ns: xmlNsPtr; name: PxmlChar; content: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewNode(ns: xmlNsPtr; name: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewNodeEatName(ns: xmlNsPtr; name: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO; 
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_SCHEMAS_ENABLED)}
function  xmlNewChild(parent: xmlNodePtr; ns: xmlNsPtr; name: PxmlChar; content: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
{$endif}
function  xmlNewDocText(doc: xmlDocPtr; content: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewTextChild(parent: xmlNodePtr; ns: xmlNsPtr; name: PxmlChar; content: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewText(content: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewPI(name: PxmlChar; content: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewDocTextLen(doc: xmlDocPtr; content: PxmlChar; len: Longint): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewTextLen(content: PxmlChar; len: Longint): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewDocComment(doc: xmlDocPtr; content: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewComment(content: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewCDataBlock(doc: xmlDocPtr; content: PxmlChar; len: Longint): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewCharRef(doc: xmlDocPtr; name: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNewReference(doc: xmlDocPtr; name: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlCopyNode(node: xmlNodePtr; recursive: Longint): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlDocCopyNode(const node: xmlNodePtr; doc: xmlDocPtr; recursive: Longint): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlCopyNodeList(const node: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
{$ifdef LIBXML_TREE_ENABLED}
function  xmlNewTextChild(parent: xmlNodePtr; ns: xmlNsPtr; name: PxmlChar; content: xmlChar): xmlNodePtrPtr; cdecl; external LIBXML2_SO;
function  xmlNewDocRawNode(doc: xmlDocPtr; ns: xmlNsPtr; name: PxmlChar; content: xmlChar): xmlNodePtrPtr; cdecl; external LIBXML2_SO;
function  xmlNewDocFragment(doc: xmlDocPtr): xmlNodePtr; cdecl; external LIBXML2_SO;
{$endif}
(* LIBXML_TREE_ENABLED  *)
  (**
 * Navigating.
 *)
function  xmlGetLineNo(node: xmlNodePtr): Longint; cdecl; external LIBXML2_SO;
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_DEBUG_ENABLED)}
function  xmlGetNodePath(node: xmlNodePtr): PxmlChar; cdecl; external LIBXML2_SO;
{$endif}
(* defined(LIBXML_TREE_ENABLED) || defined(LIBXML_DEBUG_ENABLED)  *)
function  xmlDocGetRootElement(doc: xmlDocPtr): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlGetLastChild(parent: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNodeIsText(node: xmlNodePtr): Longint; cdecl; external LIBXML2_SO;
function  xmlIsBlankNode(node: xmlNodePtr): Longint; cdecl; external LIBXML2_SO;

(**
 * Changing the structure.
 *)
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_WRITER_ENABLED)}
function  xmlDocSetRootElement(doc: xmlDocPtr; root: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
{$endif}
(* defined(LIBXML_TREE_ENABLED) || defined(LIBXML_WRITER_ENABLED)  *)
{$ifdef LIBXML_TREE_ENABLED}
procedure xmlNodeSetName(cur: xmlNodePtr; name: PxmlChar); cdecl; external LIBXML2_SO;
{$endif}
(* LIBXML_TREE_ENABLED  *)
function  xmlAddChild(parent: xmlNodePtr; cur: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlAddChildList(parent: xmlNodePtr; cur: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_WRITER_ENABLED)}
function  xmlReplaceNode(old: xmlNodePtr; cur: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
{$endif}
(* defined(LIBXML_TREE_ENABLED) || defined(LIBXML_WRITER_ENABLED)  *)
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_HTML_ENABLED) ||     defined(LIBXML_SCHEMAS_ENABLED) || defined(LIBXML_XINCLUDE_ENABLED)}
function  xmlAddPrevSibling(cur: xmlNodePtr; elem: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
{$endif}
(* LIBXML_TREE_ENABLED || LIBXML_HTML_ENABLED || LIBXML_SCHEMAS_ENABLED  *)
function  xmlAddSibling(cur: xmlNodePtr; elem: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlAddNextSibling(cur: xmlNodePtr; elem: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
procedure xmlUnlinkNode(cur: xmlNodePtr); cdecl; external LIBXML2_SO;
function  xmlTextMerge(first: xmlNodePtr; second: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlTextConcat(node: xmlNodePtr; content: PxmlChar; len: Longint): Longint; cdecl; external LIBXML2_SO;
procedure xmlFreeNodeList(cur: xmlNodePtr); cdecl; external LIBXML2_SO;
procedure xmlFreeNode(cur: xmlNodePtr); cdecl; external LIBXML2_SO;
procedure xmlSetTreeDoc(tree: xmlNodePtr; doc: xmlDocPtr); cdecl; external LIBXML2_SO;
procedure xmlSetListDoc(list: xmlNodePtr; doc: xmlDocPtr); cdecl; external LIBXML2_SO;
  (**
 * Namespaces.
 *)
function  xmlSearchNs(doc: xmlDocPtr; node: xmlNodePtr; nameSpace: PxmlChar): xmlNsPtr; cdecl; external LIBXML2_SO;
function  xmlSearchNsByHref(doc: xmlDocPtr; node: xmlNodePtr; href: PxmlChar): xmlNsPtr; cdecl; external LIBXML2_SO;
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_XPATH_ENABLED) ||     defined(LIBXML_SCHEMAS_ENABLED)}
function  xmlGetNsList(doc: xmlDocPtr; node: xmlNodePtr): PxmlNsPtr; cdecl; external LIBXML2_SO;
{$endif}
(* defined(LIBXML_TREE_ENABLED) || defined(LIBXML_XPATH_ENABLED)  *)
procedure xmlSetNs(node: xmlNodePtr; ns: xmlNsPtr); cdecl; external LIBXML2_SO;
function  xmlCopyNamespace(cur: xmlNsPtr): xmlNsPtr; cdecl; external LIBXML2_SO;
function  xmlCopyNamespaceList(cur: xmlNsPtr): xmlNsPtr; cdecl; external LIBXML2_SO;

(**
 * Changing the content.
 *)
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_XINCLUDE_ENABLED) ||     defined(LIBXML_SCHEMAS_ENABLED) || defined(LIBXML_HTML_ENABLED)}
function  xmlSetProp(node: xmlNodePtr; name: PxmlChar; value: PxmlChar): xmlAttrPtr; cdecl; external LIBXML2_SO;
function  xmlSetNsProp(node: xmlNodePtr; ns: xmlNsPtr; name: PxmlChar; value: PxmlChar): xmlAttrPtr; cdecl; external LIBXML2_SO;
{$endif}
(* defined(LIBXML_TREE_ENABLED) || defined(LIBXML_XINCLUDE_ENABLED) || 	  defined(LIBXML_SCHEMAS_ENABLED) || defined(LIBXML_HTML_ENABLED)  *)
function  xmlGetNoNsProp(node: xmlNodePtr; name: PxmlChar): PxmlChar; cdecl; external LIBXML2_SO;
function  xmlGetProp(node: xmlNodePtr; name: PxmlChar): PxmlChar; cdecl; external LIBXML2_SO;
function  xmlHasProp(node: xmlNodePtr; name: PxmlChar): xmlAttrPtr; cdecl; external LIBXML2_SO;
function  xmlHasNsProp(node: xmlNodePtr; name: PxmlChar; nameSpace: PxmlChar): xmlAttrPtr; cdecl; external LIBXML2_SO;
function  xmlGetNsProp(node: xmlNodePtr; name: PxmlChar; nameSpace: PxmlChar): PxmlChar; cdecl; external LIBXML2_SO;
function  xmlStringGetNodeList(doc: xmlDocPtr; value: PxmlChar): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlStringLenGetNodeList(doc: xmlDocPtr; value: PxmlChar; len: Longint): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlNodeListGetString(doc: xmlDocPtr; list: xmlNodePtr; ainLine: Longint): PxmlChar; cdecl; external LIBXML2_SO;
{$ifdef LIBXML_TREE_ENABLED}
function  xmlNodeListGetRawString(doc: xmlDocPtr; list: xmlNodePtr; ainLine: Longint): PxmlChar; cdecl; external LIBXML2_SO;
{$endif}
(* LIBXML_TREE_ENABLED  *)
procedure  xmlNodeSetContent(cur: xmlNodePtr; content: PxmlChar); cdecl; external LIBXML2_SO;
{$ifdef LIBXML_TREE_ENABLED}
procedure xmlNodeSetContentLen(cur: xmlNodePtr; content: PxmlChar; len: Longint); cdecl; external LIBXML2_SO;
{$endif}
(* LIBXML_TREE_ENABLED  *)
procedure  xmlNodeAddContent(cur: xmlNodePtr; content: PxmlChar); cdecl; external LIBXML2_SO;
procedure xmlNodeAddContentLen(cur: xmlNodePtr; content: PxmlChar; len: Longint); cdecl; external LIBXML2_SO;
function  xmlNodeGetContent(cur: xmlNodePtr): PxmlChar; cdecl; external LIBXML2_SO;
function  xmlNodeBufGetContent(buffer: xmlBufferPtr; cur: xmlNodePtr): Longint; cdecl; external LIBXML2_SO;
function  xmlBufGetNodeContent(buf: xmlBufPtr; cur: xmlNodePtr): Longint; cdecl; external LIBXML2_SO;
function  xmlNodeGetLang(cur: xmlNodePtr): PxmlChar; cdecl; external LIBXML2_SO;
function  xmlNodeGetSpacePreserve(cur: xmlNodePtr): Longint; cdecl; external LIBXML2_SO;
{$ifdef LIBXML_TREE_ENABLED}
procedure xmlNodeSetLang(cur: xmlNodePtr; lang: PxmlChar); cdecl; external LIBXML2_SO;
function  xmlNodeGetSpacePreserve(cur: xmlNodePtr): Longint; cdecl; external LIBXML2_SO;
procedure xmlNodeSetSpacePreserve(cur: xmlNodePtr; val: Longint); cdecl; external LIBXML2_SO;
{$endif}
(* LIBXML_TREE_ENABLED  *)
function  xmlNodeGetBase(doc: xmlDocPtr; cur: xmlNodePtr): PxmlChar; cdecl; external LIBXML2_SO;
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_XINCLUDE_ENABLED)}
procedure xmlNodeSetBase(cur: xmlNodePtr; uri: PxmlChar); cdecl; external LIBXML2_SO;
{$endif}

(**
 * Removing content.
 *)
function  xmlRemoveProp(attr: xmlAttrPtr): Longint; cdecl; external LIBXML2_SO;
{$if defined(LIBXML_TREE_ENABLED) || defined(LIBXML_SCHEMAS_ENABLED)}
function  xmlUnsetNsProp(node: xmlNodePtr; ns: xmlNsPtr; name: PxmlChar): Longint; cdecl; external LIBXML2_SO;
function  xmlUnsetProp(node: xmlNodePtr; name: PxmlChar): Longint; cdecl; external LIBXML2_SO;
{$endif}
(* defined(LIBXML_TREE_ENABLED) || defined(LIBXML_SCHEMAS_ENABLED)  *)

(**
 * Internal, don't use.
 *)
procedure xmlBufferWriteChar(buf: xmlBufferPtr; aString: PChar); cdecl; external LIBXML2_SO;
procedure xmlBufferWriteQuotedString(buf: xmlBufferPtr; aString: PxmlChar); cdecl; external LIBXML2_SO;
{$ifdef LIBXML_OUTPUT_ENABLED}
procedure  xmlAttrSerializeTxtContent(buf: xmlBufferPtr; doc: xmlDocPtr; attr: xmlAttrPtr; _string: PxmlChar); cdecl; external LIBXML2_SO;
{$endif}
(* LIBXML_OUTPUT_ENABLED  *)

{$ifdef LIBXML_TREE_ENABLED}

(**
 * Namespace handling.
 *)
function  xmlReconciliateNs(doc: xmlDocPtr; tree: xmlNodePtr): Longint; cdecl; external LIBXML2_SO;
{$endif}
{$ifdef LIBXML_OUTPUT_ENABLED}

(**
 * Saving.
 *)
procedure  xmlDocDumpFormatMemory(cur: xmlDocPtr; var mem: PxmlChar; size: PLongint; format: Longint); cdecl; external LIBXML2_SO;
procedure  xmlDocDumpMemory(cur: xmlDocPtr; var mem: PxmlChar; size: PLongint); cdecl; external LIBXML2_SO;
procedure  xmlDocDumpMemoryEnc(out_doc: xmlDocPtr; var doc_txt_ptr: PxmlChar; doc_txt_len: PLongint; txt_encoding: PChar); cdecl; external LIBXML2_SO;
procedure  xmlDocDumpFormatMemoryEnc(out_doc: xmlDocPtr; var doc_txt_ptr: PxmlChar; doc_txt_len: PLongint; txt_encoding: PChar; format: Longint); cdecl; external LIBXML2_SO;
function  xmlDocFormatDump(f: PLibXml2File; cur: xmlDocPtr; format: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlDocDump(f: PLibXml2File; cur: xmlDocPtr): Longint; cdecl; external LIBXML2_SO;
procedure  xmlElemDump(f: PLibXml2File; doc: xmlDocPtr; cur: xmlNodePtr); cdecl; external LIBXML2_SO;
function  xmlSaveFile(filename: PChar; cur: xmlDocPtr): Longint; cdecl; external LIBXML2_SO;
function  xmlSaveFormatFile(filename: PChar; cur: xmlDocPtr; format: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlBufNodeDump(buf: xmlBufPtr; doc: xmlDocPtr; cur: xmlNodePtr; level: Longint; format: Longint): size_t; cdecl; external LIBXML2_SO;
function  xmlNodeDump(buf: xmlBufferPtr; doc: xmlDocPtr; cur: xmlNodePtr; level: Longint; format: Longint): Longint; cdecl; external LIBXML2_SO;
{ [pk] moved to libxml2.pas - needs declarations from xmlIO
function  xmlSaveFileTo(buf: xmlOutputBufferPtr; cur: xmlDocPtr; encoding: Pchar): Longint; cdecl; external LIBXML2_SO;
function  xmlSaveFormatFileTo(buf: xmlOutputBufferPtr; cur: xmlDocPtr; encoding: Pchar; format: Longint): Longint; cdecl; external LIBXML2_SO;
procedure  xmlNodeDumpOutput(buf: xmlOutputBufferPtr; doc: xmlDocPtr; cur: xmlNodePtr; level: Longint; format: Longint; 
          encoding: Pchar); cdecl; external LIBXML2_SO;
}
function  xmlSaveFormatFileEnc(filename: Pchar; cur: xmlDocPtr; encoding: Pchar; format: Integer): Integer; cdecl; external LIBXML2_SO;
function  xmlSaveFileEnc(filename: Pchar; cur: xmlDocPtr; encoding: PChar): Longint; cdecl; external LIBXML2_SO;
{$endif}
(* LIBXML_OUTPUT_ENABLED  *)


(**
 * XHTML
 *)
function  xmlIsXHTML(systemID, publicID: PxmlChar): Longint; cdecl; external LIBXML2_SO;

(**
 * Compression.
 *)
function  xmlGetDocCompressMode(doc: xmlDocPtr): Longint; cdecl; external LIBXML2_SO;
procedure xmlSetDocCompressMode(doc: xmlDocPtr; mode: Longint); cdecl; external LIBXML2_SO;
function  xmlGetCompressMode: Longint; cdecl; external LIBXML2_SO;                           
procedure xmlSetCompressMode(mode: Longint); cdecl; external LIBXML2_SO;
  (**
  * DOM-wrapper helper functions.
   *)
function  xmlDOMWrapNewCtxt: xmlDOMWrapCtxtPtr; cdecl; external LIBXML2_SO;
procedure  xmlDOMWrapFreeCtxt(ctxt: xmlDOMWrapCtxtPtr); cdecl; external LIBXML2_SO;
function  xmlDOMWrapReconcileNamespaces(ctxt: xmlDOMWrapCtxtPtr; elem: xmlNodePtr; options: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlDOMWrapAdoptNode(ctxt: xmlDOMWrapCtxtPtr; sourceDoc: xmlDocPtr; node: xmlNodePtr; destDoc: xmlDocPtr; destParent: xmlNodePtr; 
         options: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlDOMWrapRemoveNode(ctxt: xmlDOMWrapCtxtPtr; doc: xmlDocPtr; node: xmlNodePtr; options: Longint): Longint; cdecl; external LIBXML2_SO;
function  xmlDOMWrapCloneNode(ctxt: xmlDOMWrapCtxtPtr; sourceDoc: xmlDocPtr; node: xmlNodePtr; clonedNode: xmlNodePtr; destDoc: xmlDocPtr;
         destParent: xmlNodePtr; deep: Longint; options: Longint): Longint; cdecl; external LIBXML2_SO;
{$ifdef LIBXML_TREE_ENABLED}
  (**
   * 5 interfaces from DOM ElementTraversal, but different in entities
   * traversal.
   *)
function  xmlChildElementCount(parent: xmlNodePtr): DWORD; cdecl; external LIBXML2_SO;
function  xmlNextElementSibling(node: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlFirstElementChild(parent: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlLastElementChild(parent: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;
function  xmlPreviousElementSibling(node: xmlNodePtr): xmlNodePtr; cdecl; external LIBXML2_SO;

{ function  XML_GET_CONTENT(n : xmlNodePtr) : PxmlChar;
  function  XML_GET_LINE(n : xmlNodePtr) : Longint; }
{$endif}
{ implementation

function  XML_GET_CONTENT(n : xmlNodePtr) : PxmlChar;
  begin
    if (n^._type)=xmlElementType.XML_ELEMENT_NODE then
      result:=NULL
    else
      result:=n^.content;
  end;
  
function  XML_GET_LINE(n : xmlNodePtr) : Longint;
  begin
    result := xmlGetLineNo(n);
  end;
end. }