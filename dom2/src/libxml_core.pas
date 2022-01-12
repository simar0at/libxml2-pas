unit libxml_core;
//$Id: libxml_core.pas,v 1.3 2002-09-19 16:54:46 pkozelka Exp $
(*
 * libxml-based core implementation of DOM level 2.
 * This unit implements *only* the standard DOM features.
 *
 * Licensing: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * Developers:
 *   - the LIBXML2-PAS development team <libxml2-pas-devel@lists.sourceforge.net>
 *   namely
 *   - Petr Kozelka <pkozelka@email.cz>
 *   - Uwe Fechner <ufechner@csi.com>
 *)

interface

uses
  Classes,
  SysUtils,
  domimpl_utils,
  idom2,
  idom_ext,
{$IFDEF VER130}
  Unicode,
  ComObj,
  Windows,
{$ENDIF}
  libxml2i,
  libxml2,
  libxslt;

type
  TLDomChildNodeList = class;
  TLDomNode = class;
  TLDomElement = class;
  { TLDomObject class }

  TLDomObject = class(TInterfacedObject)
  protected
    function  returnNullDomNode: IDomNode;
    function  returnEmptyString: DomString;
    procedure DomAssert(aCondition: Boolean; aErrorCode:integer; aMsg: WideString='');
    procedure checkName(aPrefix, aLocalName: String);
    procedure checkNsName(aPrefix, aLocalName, aNamespaceURI: String);
  public
    function SafeCallException(aExceptObject: TObject; aExceptAddr: Pointer): HRESULT; override;
  end;

  { TLDomNodeExtension }

  TLDomNodeExtensionClass = class of TLDomNodeExtension;
  TLDomNodeExtension = class(TAggregatedObject)
  private
    fLDomNode: TLDomNode;  // weak reference to controller
    function  GetLDomNode: TLDomNode;
  protected // IInterface
    { implement methods of IUnknown }
    function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} aIID : tguid;out aObj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
  public
    constructor Create(const aLDomNode: TLDomNode);
    property LDomNode: TLDomNode read GetLDomNode;
  end;

  { TLDomNode class }

  TLDomNodeClass = class of TLDomNode;
  TLDomNode = class(TLDomObject, IDomNode, IDomNodeCompare, ILibXml2Node)
  private
    fMyNode: xmlNodePtr;
    fExtensionObj: TLDomNodeExtension;
    fChildNodes: TLDomChildNodeList; // non-counted reference
    function  isAncestorOrSelf(aNode:xmlNodePtr): Boolean; //new
  protected //IUnknown
    function QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} aIID : tguid;out aObj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
  protected //ILibXml2Node
    function  LibXml2NodePtr: xmlNodePtr;
  protected //IDomNode
    function  get_nodeName: DomString;
    function  get_nodeValue: DomString;
    procedure set_nodeValue(const value: DomString);
    function  get_nodeType: DomNodeType;
    function  get_parentNode: IDomNode;
    function  get_childNodes: IDomNodeList;
    function  get_firstChild: IDomNode;
    function  get_lastChild: IDomNode;
    function  get_previousSibling: IDomNode;
    function  get_nextSibling: IDomNode;
    function  get_attributes: IDomNamedNodeMap;
    function  get_ownerDocument: IDomDocument; virtual;
    function  get_namespaceURI: DomString;
    function  get_prefix: DomString;
    procedure set_Prefix(const prefix : DomString);
    function  get_localName: DomString;
    function  insertBefore(const newChild, refChild: IDomNode): IDomNode;
    function  replaceChild(const newChild, oldChild: IDomNode): IDomNode;
    function  removeChild(const childNode: IDomNode): IDomNode;
    function  appendChild(const newChild: IDomNode): IDomNode;
    function  hasChildNodes: Boolean;
    function  hasAttributes : Boolean;
    function  cloneNode(deep: Boolean): IDomNode;
    procedure normalize;
    function  isSupported(const feature, version: DomString): Boolean;
  protected //ready for IDomElement, IDomDocument
    function  getElementsByTagName(const name: DomString): IDomNodeList;
    function  getElementsByTagNameNS(const namespaceURI, localName: DomString): IDomNodeList;
  protected //IDomNodeCompare
    function IsSameNode(node: IDomNode): boolean;
  protected //IDomNodeSelect
    function selectNode(const nodePath: DomString): IDomNode;
    function selectNodes(const nodePath: DomString): IDomNodeList;
    procedure RegisterNS(const prefix, URI: DomString);
  protected
    constructor Create(aLibXml2Node: pointer); virtual;
  public
    property  MyNode: xmlNodePtr read fMyNode;
    destructor Destroy; override;
    function  requestNodePtr: xmlNodePtr; virtual;
  end;

  { TLDomAttr class }

  TLDomAttr = class(TLDomNode, IDomNode, IDomAttr)
  protected //IDomNode
    function  IDomNode.get_parentNode = returnNullDomNode;
    function  IDomNode.get_previousSibling = returnNullDomNode;
    function  IDomNode.get_nextSibling = returnNullDomNode;
  protected //IDomAttr
    function  IDomAttr.get_name = get_nodeName;
    function  get_specified: Boolean;
    function  IDomAttr.get_value = get_nodeValue;
    procedure IDomAttr.set_value = set_nodeValue;
    function  get_ownerElement: IDomElement;
  end;

  { TLDomAttributeMap }

  TLDomAttributeMap = class(TLDomObject, IDomNamedNodeMap)
  private
    fOwnerElement: TLDomElement; // non-counted reference
  protected //IDomNamedNodeMap
    function get_item(index: Integer): IDomNode;
    function get_length: Integer;
    function getNamedItem(const name: DomString): IDomNode;
    function setNamedItem(const newItem: IDomNode): IDomNode;
    function removeNamedItem(const name: DomString): IDomNode;
    function getNamedItemNS(const namespaceURI, localName: DomString): IDomNode;
    function setNamedItemNS(const newItem: IDomNode): IDomNode;
    function removeNamedItemNS(const namespaceURI, localName: DomString): IDomNode;
  protected
    constructor Create(aOwnerElement: TLDomElement);
  public
    destructor Destroy; override;
  end;

  { TLXPathDomNodeList }

  TLXPathDomNodeList = class(TInterfacedObject, IDomNodeList)
  private
    fParent: xmlNodePtr;               // if we have a list like node.childnodes,
                                       // the parent node is stored here
    fXPathObject: xmlXPathObjectPtr;   // if we have a list, that is the result of
                                       // an xpath query, the xmlXPathObjectPtr is
                                       // stored here
    fOwnerDocument: IDomDocument;
  protected
    { IDomNodeList }
    function get_Item(index: integer): IDomNode;
    function get_Length: integer;
  public
    constructor Create(AParent: xmlNodePtr; ADocument: IDomDocument); overload;
    constructor Create(AXpathObject: xmlXPathObjectPtr; ADocument: IDomDocument); overload;
    destructor Destroy; override;
    { IDomNodeListExt }
    function get_xml: DomString;
  end;

  { TLDomChildNodeList class }

  TLDomChildNodeList = class(TLDomObject, IDomNodeList)
  private
    fOwnerNode: TLDomNode; // non-counted reference
    function GetFirstChildNodePtr: xmlNodePtr; virtual;
  protected //IDomNodeList
    function get_item(index: Integer): IDomNode;
    function get_length: Integer;
  protected
    constructor Create(aOwnerNode: TLDomNode);
  public
    destructor Destroy; override;
  end;

  { TLDomEntRefChildNodes class }

  TLDomEntRefChildNodes = class(TLDomChildNodeList, IDomNodeList)
  private
    function GetFirstChildNodePtr: xmlNodePtr; override;
  end;
  { TLDomCharacterData class }

  TLDomCharacterData = class(TLDomNode, IDomCharacterData, IDomNode)
  private
  protected // IDomCharacterData
    function  IDomCharacterData.get_data = get_nodeValue;
    procedure IDomCharacterData.set_data = set_nodeValue;
    function  get_length: Integer;
    function  substringData(offset, count: Integer): DomString;
    procedure appendData(const data: DomString);
    procedure insertData(offset: Integer; const data: DomString);
    procedure deleteData(offset, count: Integer);
    procedure replaceData(offset, count: Integer; const data: DomString);
  public
  end;

  { TLDomText class }

  TLDomText = class(TLDomCharacterData, IDomText, IDomCharacterData, IDomNode)
  protected //IDomCharacterData
    function  IDomCharacterData.get_data = get_nodeValue;
    procedure IDomCharacterData.set_data = set_nodeValue;
  protected //IDomText
    function  IDomText.get_data = get_nodeValue;
    procedure IDomText.set_data = set_nodeValue;
    function  splitText(offset: Integer): IDomText;
  end;

  { TLDomCDATASection class }

  TLDomCDataSection = class(TLDomText, IDomCDataSection, IDomCharacterData, IDomNode)
  protected //IDomCharacterData
    function  IDomCharacterData.get_data = get_nodeValue;
    procedure IDomCharacterData.set_data = set_nodeValue;
  protected //IDomCDataSection
    function  IDomCDataSection.get_data = get_nodeValue;
    procedure IDomCDataSection.set_data = set_nodeValue;
  end;

  { TLDomComment class }

  TLDomComment = class(TLDomCharacterData, IDomComment, IDomCharacterData, IDomNode)
  protected //IDomCharacterData
    function  IDomCharacterData.get_data = get_nodeValue;
    procedure IDomCharacterData.set_data = set_nodeValue;
  protected //IDomComment
    function  IDomComment.get_data = get_nodeValue;
    procedure IDomComment.set_data = set_nodeValue;
  end;

  { TLDomDocumentFragment class }

  TLDomDocumentFragment = class(TLDomNode, IDomDocumentFragment, IDomNode)
  protected //IDomNode
    function  IDomNode.get_parentNode = returnNullDomNode;
  protected //IDomDocumentFragment
    function  IDomDocumentFragment.get_parentNode = returnNullDomNode;
  end;

  { TLDomElement class }

  TLDomElement = class(TLDomNode, IDomElement, IDomNode)
  private
    fFlyingNodes: TLDomAttributeMap; // non-counted reference
  protected //IDomNode
    function  get_attributes: IDomNamedNodeMap;
  protected //IDomElement
    function  IDomElement.get_tagName = get_nodeName;
    function  getAttribute(const name: DomString): DomString;
    procedure setAttribute(const name, value: DomString);
    procedure removeAttribute(const name: DomString);
    function  getAttributeNode(const name: DomString): IDomAttr;
    function  IDomElement.setAttributeNode = setAttributeNodeNS;
    function  removeAttributeNode(const oldAttr: IDomAttr):IDomAttr;
    function  getAttributeNS(const namespaceURI, localName: DomString): DomString;
    procedure setAttributeNS(const namespaceURI, qualifiedName, value: DomString);
    procedure removeAttributeNS(const namespaceURI, localName: DomString);
    function  getAttributeNodeNS(const namespaceURI, localName: DomString): IDomAttr;
    function  setAttributeNodeNS(const newAttr: IDomAttr): IDomAttr;
    function  hasAttribute(const name: DomString): Boolean;
    function  hasAttributeNS(const namespaceURI, localName: DomString): Boolean;
  protected
    constructor Create(aLibXml2Node: pointer); override;
  public
    destructor Destroy; override;
  end;

  { TLDomEntity class }

  TLDomEntity = class(TLDomNode, IDomNode, IDomEntity)
  protected //IDomNode
    function  get_nodeType: DomNodeType;
  protected //IDomEntity
    function  get_publicId: DomString;
    function  get_systemId: DomString;
    function  get_notationName: DomString;
  end;

  { TLDomEntityReference  class }

  TLDomEntityReference = class(TLDomNode, IDomEntityReference, IDomNode)
  protected //IDomNode
    function  get_childNodes: IDomNodeList;
    function  get_firstChild: IDomNode;
    function  get_lastChild: IDomNode;
    function  get_nodeValue: DomString;
  protected //IDomEntityReference
  protected
  end;

  { TLDomNotation class }

  TLDomNotation = class(TLDomNode, IDomNode, IDomNotation)
  protected //IDomNode
    function  IDomNode.get_parentNode = returnNullDomNode;
  protected //IDomNotation
    function  IDomNotation.get_parentNode = returnNullDomNode;
    function  get_publicId: DomString;
    function  get_systemId: DomString;
  end;

  { TLDomProcessingInstruction class }

  TLDomProcessingInstruction = class(TLDomNode, IDomProcessingInstruction)
  private
  protected //IDomProcessingInstruction
    function  IDomProcessingInstruction.get_target = get_nodeName;
    function  IDomProcessingInstruction.get_data = get_nodeValue;
    procedure IDomProcessingInstruction.set_data = set_nodeValue;
  public
  end;

  (*
   * neccesary to access internal neccessary methods of TDomDocument,
   * if you have a variable of type IDomDocument
   *)
  IDomInternal = interface
    ['{E9D505C3-D354-4D19-807A-8B964E954C09}']
    procedure set_reason(aReason: DomString);
    function get_reason: DomString; safecall;

    // managing the list of nodes and attributes, that must be freed manually
    procedure removeNode(node: xmlNodePtr);
    procedure removeAttr(attr: xmlAttrPtr);
    procedure appendAttr(attr: xmlAttrPtr);
    procedure appendNode(node: xmlNodePtr);
    procedure appendNs(ns: xmlNsPtr);
    function  getNewNamespace(const namespaceURI, prefix: DOMString): xmlNsPtr;
    function  findOrCreateNewNamespace(const node: xmlNodePtr; const ns: xmlNsPtr): xmlNsPtr; overload;
    function  findOrCreateNewNamespace(const node: xmlNodePtr; const namespaceURI, prefix: PChar): xmlNsPtr; overload;

    // managing a list of namespace declarations for xpath queries
    procedure registerNS(prefix,uri:string);
    function  getPrefixList:TStringList;

    // managing stylesheets, that must be freed differently
    procedure set_fTempXSL(tempXSL: xsltStylesheetPtr);
    property reason: DomString read get_reason write set_reason;

    // this procedure removes all text nodes, that contain whitespace only
    procedure removeWhitespace;
  end;

  { TLDomDocument class }

  TLDomDocumentClass = class of TLDomDocument;
  TLDomDocument = class(TLDomNode, IDomDocument, IDomNode, IDomInternal)
  protected //tmp
    fFlyingNodes: TList;          // on-demand created list of nodes not attached to the document tree (=they have no parent)
  private
    fMyImplementation: IDomImplementation;
    fPrefixList: TStringList;      // if you want to use prefixes in xpath expressions,
                                   // they must be registered and are then stored
                                   // on this list.
    fValidate: boolean;            // if true, returns nil on failure
                                   // if false, loads a dtd if it exists
    fReason:  DomString;           // reason of last parse error
    fLine:    integer;             // line of the first parse error
    fLinePos: integer;             // row of first parse error
    fUrl:     DomString;           // filename or URL of parsed file containing error
    function  GetFlyingNodes: TList;
  protected //IDomNode
    function  get_nodeName: DomString;
    function  IDomNode.get_nodeValue = returnEmptyString;
    procedure set_nodeValue(const value: DomString);
    function  get_nodeType: DomNodeType;
    function  IDomNode.get_parentNode = returnNullDomNode;
    function  IDomNode.get_previousSibling = returnNullDomNode;
    function  IDomNode.get_nextSibling = returnNullDomNode;
    function  get_ownerDocument: IDomDocument; override;
    function  IDomNode.get_namespaceURI = returnEmptyString;
    function  IDomNode.get_prefix = returnEmptyString;
    function  IDomNode.get_localName = returnEmptyString;
  protected //IDomDocument
    function  IDomDocument.get_nodeValue = returnEmptyString;
    function  IDomDocument.get_parentNode = returnNullDomNode;
    function  IDomDocument.get_previousSibling = returnNullDomNode;
    function  IDomDocument.get_nextSibling = returnNullDomNode;
    function  IDomDocument.get_namespaceURI = returnEmptyString;
    function  IDomDocument.get_prefix = returnEmptyString;
    function  IDomDocument.get_localName = returnEmptyString;
    function  get_doctype: IDomDocumentType;
    function  get_domImplementation: IDomImplementation;
    function  get_documentElement: IDomElement;
    function  createElement(const tagName: DomString): IDomElement;
    function  createDocumentFragment: IDomDocumentFragment;
    function  createTextNode(const data: DomString): IDomText;
    function  createComment(const data: DomString): IDomComment;
    function  createCDATASection(const data: DomString): IDomCDataSection;
    function  createProcessingInstruction(const target, data: DomString): IDomProcessingInstruction;
    function  createAttribute(const name: DomString): IDomAttr;
    function  createEntityReference(const name: DomString): IDomEntityReference;
    function  importNode(importedNode: IDomNode; deep: Boolean): IDomNode;
    function  createElementNS(const namespaceURI, qualifiedName: DomString): IDomElement;
    function  createAttributeNS(const namespaceURI, qualifiedName: DomString): IDomAttr;
    function  getElementById(const elementId: DomString): IDomElement;
  protected // deserialization stuff
    function  internalParse(var aCtxt: xmlParserCtxtPtr): xmlDocPtr; virtual;
    function  load(aUrl: DomString): Boolean;
    function  parse(const aXml: DomString): Boolean;
  protected // IDOMInternal
    procedure set_reason(aReason: DomString);
    function get_reason: DomString; safecall;
    procedure removeNode(node: xmlNodePtr);
    procedure removeAttr(attr: xmlAttrPtr);
    procedure appendAttr(attr: xmlAttrPtr);
    procedure appendNode(node: xmlNodePtr);
    procedure appendNs(ns: xmlNsPtr);
    function  getNewNamespace(const namespaceURI, prefix: DOMString): xmlNsPtr;
    function  findOrCreateNewNamespace(const node: xmlNodePtr; const ns: xmlNsPtr): xmlNsPtr; overload;
    function  findOrCreateNewNamespace(const node: xmlNodePtr; const namespaceURI, prefix: PChar): xmlNsPtr; overload;
    procedure registerNS(prefix,uri:string);
    function  getPrefixList:TStringList;
    procedure set_fTempXSL(tempXSL: xsltStylesheetPtr);
    procedure removeWhitespace;
  protected
    constructor Create(aLibXml2Node: pointer); override;
    (**
     * On-demand creation of the underlying document.
     *)
    function  requestDocPtr: xmlDocPtr;
    function  GetGDoc: xmlDocPtr;
    procedure SetGDoc(aNewDoc: xmlDocPtr);
    property  GDoc: xmlDocPtr read GetGDoc write SetGDoc;
    property  FlyingNodes: TList read GetFlyingNodes;
  public
    destructor Destroy; override;
    function  requestNodePtr: xmlNodePtr; override;

    property  DomImplementation: IDomImplementation read get_domImplementation write fMyImplementation; // internal mean to 'setup' implementation
  end;

  { TLDomDocumentType class }

  TLDomDocumentType = class(TLDomNode, IDomDocumentType, IDomNode)
  private
    function GetGDocumentType: xmlDtdPtr;
  protected //IDomNode
    function  get_nodeType: DomNodeType;
  protected //IDomDocumentType
    function IDomDocumentType.get_name = get_nodeName;
    function get_entities: IDomNamedNodeMap;
    function get_notations: IDomNamedNodeMap;
    function get_publicId: DomString;
    function get_systemId: DomString;
    function get_internalSubset: DomString;
  end;

  { TLDomElementDecl class }

  TLDomElementDecl = class(TLDomNode, IDomNode)
  private
  protected
  end;

  { TLDomAttributeDecl class }

  TLDomAttributeDecl = class(TLDomNode, IDomNode)
  private
  protected
  end;


  { TLDOMImplementation class }

  TLDomImplementationClass = class of TLDomImplementation;
  TLDomImplementation = class(TLDomObject, IDomImplementation)
  private
    fDocumentClass: TLDomDocumentClass;
  protected
    function  parse(const xml : DomString) : IDomDocument;
    function  load(const url : DomString) : IDomDocument;
  protected //IDomImplementation
    function  hasFeature(const feature, version: DomString): Boolean;
    function  createDocumentType(const qualifiedName, publicId, systemId: DomString): IDomDocumentType;
    function  createDocument(const namespaceURI, qualifiedName: DomString; doctype: IDomDocumentType): IDomDocument;
  protected
    constructor Create(aDocumentClass: TLDomDocumentClass);
  public
    destructor Destroy; override;
  end;

  { TLDomDocumentBuilder class }

  TLDomDocumentBuilderClass = class of TLDomDocumentBuilder;
  TLDomDocumentBuilder = class(TLDOMObject, IDomDocumentBuilder)
  private
    fImplInstance: TLDomImplementation; // non-counted reference
    fImplementationClass: TLDomImplementationClass;
    function  GetImplInstance: TLDomImplementation;
  protected //IDomDocumentBuilder
    function  Get_DomImplementation : IDomImplementation;
    function  Get_IsNamespaceAware : Boolean;
    function  Get_IsValidating : Boolean;
    function  Get_HasAsyncSupport : Boolean;
    function  Get_HasAbsoluteURLSupport : Boolean;
    function  newDocument : IDomDocument;
    function  parse(const xml : DomString) : IDomDocument;
    function  load(const url : DomString) : IDomDocument;
  protected
    constructor Create(aImplementationClass: TLDomImplementationClass);
  public
    destructor Destroy; override;
  end;

  { TLDomDocumentBuilderFactory class }

  TLDomDocumentBuilderFactoryClass = class of TLDomDocumentBuilderFactory;
  TLDomDocumentBuilderFactory = class(TInterfacedObject, IDomDocumentBuilderFactory)
  private
    fDomBuilderClass: TLDomDocumentBuilderClass;
    fVendorId: DomString;
  protected //IDomDocumentBuilderFactory
    function  NewDocumentBuilder : IDomDocumentBuilder;
    function  Get_VendorID : DomString;
  public
    constructor Create(aVendorId: DomString; aDomBuilderClass: TLDomDocumentBuilderClass);
  end;

  TErrCtx = record
     document: TLDomDocument;
     errMsg:   string;
  end;

  TErrCtxPtr = ^TErrCtx;

//overridable implementations
var
  GlbNodeClasses: array[XML_ELEMENT_NODE..XML_DOCB_DOCUMENT_NODE] of TLDomNodeClass = (
    TLDomElement, //XML_ELEMENT_NODE
    TLDomAttr, //XML_ATTRIBUTE_NODE
    TLDomText, //XML_TEXT_NODE
    TLDomCDataSection, //XML_CDATA_SECTION_NODE
    TLDomEntityReference, //XML_ENTITY_REF_NODE
    TLDomEntity, //XML_ENTITY_NODE
    TLDomProcessingInstruction, //XML_PI_NODE
    TLDomComment, //XML_COMMENT_NODE
    TLDomDocument, //XML_DOCUMENT_NODE
    TLDomDocumentType, //XML_DOCUMENT_TYPE_NODE
    TLDomDocumentFragment, //XML_DOCUMENT_FRAG_NODE
    TLDomNotation, //XML_NOTATION_NODE
    TLDomDocument, //XML_HTML_DOCUMENT_NODE
    TLDomDocumentType, //XML_DTD_NODE
    TLDomElementDecl, //XML_ELEMENT_DECL
    TLDomAttributeDecl, //XML_ATTRIBUTE_DECL
    TLDomEntity, //XML_ENTITY_DECL
    nil, //XML_NAMESPACE_DECL,
    nil, //XML_XINCLUDE_START,
    nil, //XML_XINCLUDE_END,
    TLDomDocument //XML_DOCB_DOCUMENT_NODE
  );
  GlbNodeExtensionClass: TLDomNodeExtensionClass = nil;
  
//temporarily exposed:
function  GetDomObject(aNode: pointer): IUnknown;

function getXmlNode(const Node: IDomNode): xmlNodePtr;

procedure errorHandler(ctx: pointer; msg: PChar; arg1: PChar; arg2: integer; arg3: PChar); cdecl;

implementation

const
  IMPLEMENTATION_FEATURES: array [0..9] of DomString = (
    'CORE', '2.0',
    'CORE', '',
    'XML', '2.0',
    'XML', '1.0',
    'XML', '');
const
  DEFAULT_IMPL_FREE_THREADED = false;

function GetDomObject(aNode: pointer): IUnknown;
var
  obj: TLDomNode;
  node: xmlNodePtr;
  ok: Boolean;
begin
  if aNode <> nil then begin
    node := xmlNodePtr(aNode);
    if (node^._private=nil) then begin
      ok := (node^.type_ >= Low(GlbNodeClasses))
        and (node^.type_ <= High(GlbNodeClasses))
        and Assigned(GlbNodeClasses[node^.type_]);
      DomAssert1(ok, INVALID_ACCESS_ERR, Format('LibXml2 node type "%d" is not supported', [Integer(node^.type_)]), 'GetDomObject()');
      obj := GlbNodeClasses[node^.type_].Create(node); // this assigns node._private
    end else begin
      // wrapper is already created, use it
      // first check if it is not a garbage
      ok := (node^.type_ >= Low(GlbNodeClasses))
        and (node^.type_ <= High(GlbNodeClasses))
        and Assigned(GlbNodeClasses[node^.type_]);
      DomAssert1(ok, INVALID_ACCESS_ERR, 'not a DOM wrapper', 'GetDomObject()');
      obj := TLDomNode(node^._private);
    end;
  end else begin
    obj := nil;
  end;
  Result := obj;
end;

function getXmlNode(const Node: IDomNode): xmlNodePtr;
begin
  DomAssert1(Assigned(Node), INVALID_ACCESS_ERR, 'Node cannot be null', 'getXmlNode(const Node: IDomNode)');
  Result := (Node as ILibXml2Node).LibXml2NodePtr;
end;

function countSubstringOccurance(s,sub: string): integer;
var
  n: integer;
begin
  result := 0;
  n := Pos(sub,s);
  while n <> 0 do begin
    Inc(result);
    s := Copy(s,n+Length(sub),Length(s)-(n+Length(sub))+1);
    n := Pos(sub,s);
  end;
end;

procedure errorHandler(ctx: pointer; msg: PChar; arg1: PChar; arg2: integer; arg3: PChar); cdecl;
// writes the formatted error message into the field document.fReason
// IMPORTANT:
// ctx.document must be initialized with a pointer to the document
// of type TDomDocument OR ctx.document is nil and
// ctx.errMsg is initialized with an empty string
// document.fLine must be initialized with -1;
var
  error:        string;
  sMsg, sArg1, sArg3:  string;
  cArg: char;
  iArg2: integer;
begin
  sMsg  := msg;
  sMsg  := adjustLinebreaks(sMsg);
  iArg2:=arg2;
  error:='';
  if pos('%s',sMsg) > 0 then begin
    if pos('%d',sMsg) > 0 then begin
      if countSubstringOccurance(sMsg,'%s') = 2 then begin
        sArg1 := arg1;
        sArg3 := arg3;
        try
          error := Format(sMsg,[sArg1,iArg2,sArg3]);
        except
          error := 'Unknown format of error msg: '+sMsg;
        end;
      end else begin
        sArg1 :=arg1;
        try
          error := format(sMsg, [sArg1, iArg2]);
        except
          error := 'Too many parameters in error msg: '+sMsg;
        end;
      end;
    end else begin
      sArg1 :=arg1;
      if sArg1<>''
        then error := format(sMsg, [sArg1]);
    end;
  end else if pos('%d',sMsg) > 0 then begin
    iArg2:=integer(arg1);
    error := format(sMsg, [iArg2]);
  end else begin if pos('%c',sMsg) > 0 then begin
    cArg:=char(arg1);
    sMsg:=stringReplace(sMsg,'%c','%s',[rfReplaceAll]);
    error:=format(sMsg, [cArg]);
  end else
    error := sMsg;
  end;

  error := adjustLinebreaks(error);

  // check if we are parsing a document or are evaluating an xpath expressions
  if ctx<>nil then begin
    if TErrCtxPtr(ctx)^.document<>nil then begin
      with TLDomDocument(TErrCtxPtr(ctx)^.document) do begin
        fReason := fReason + sLineBreak +error;
        // if a dezimal format char is in the format string and fLine was not set yet
        if (pos('%d',sMsg) > 0) and (fLine=-1) then begin
          // assign the line number of the error
          fLine:=iArg2;
        end;
        // a validity error isn't an error, if fValidate is false
        // reset the error line in this case
        if (pos('validity',error) > 0) and (not fValidate) then begin
          fLine:=-1;
        end;
      end;
    end else begin
      // deliver XPATH error string;
      TErrCtxPtr(ctx)^.ErrMsg:=TErrCtxPtr(ctx)^.ErrMsg+error;
    end;
  end;
end;

function GetGNode(const aNode: IDomNode): xmlNodePtr;
begin
  DomAssert1(Assigned(aNode), INVALID_ACCESS_ERR, 'Node cannot be null', 'GetGNode()');
  Result := (aNode as ILibXml2Node).LibXml2NodePtr;
end;

(**
 * Registers a flying node in its document node's wrapper.
 * If the node is already registered, does nothing.
 * Nodes of type that cannot be registered are silently ignored.
 * This is called from TLDomNode.Create when parent is nil.
 *)
procedure RegisterFlyingNode(aNode: xmlNodePtr);
var
  doc: TLDomDocument;
begin
  DomAssert1(aNode<>nil, INVALID_ACCESS_ERR, '', 'RegisterFlyingNode()');
  DomAssert1(aNode^.parent=nil, INVALID_STATE_ERR, 'Node has a parent, cannot be registered as flying', 'RegisterFlyingNode()');
  case aNode^.type_ of
  XML_HTML_DOCUMENT_NODE,
  XML_DOCB_DOCUMENT_NODE,
  XML_DOCUMENT_NODE:
    ; //silently ignore
  else
    GetDOMObject(aNode^.doc);  //temporary - ensure that the document's wrapper exists (though it should be almost unneccessary)
    doc := TLDomDocument(aNode^.doc^._private); //get the class internal interface
    if doc.FlyingNodes.IndexOf(aNode)<0 then begin
      doc.FlyingNodes.Add(aNode);
    end;
  end;
end;

(**
 * Unregisters the node from the owner document's wrapper.
 * Does not check if parent is already assigned.
 * Nothing happens if the node is not present in the registry.
 *)
procedure UnregisterFlyingNode(aNode: xmlNodePtr);
var
  doc: TLDomDocument;
  idx: integer;
begin
  GetDOMObject(aNode^.doc);  //temporary - ensure that the document's wrapper exists (though it should be almost unneccessary)
  doc := TLDomDocument(aNode^.doc^._private); //get the class internal interface
  idx := doc.FlyingNodes.IndexOf(aNode);
  if (idx>0) then begin
    doc.FlyingNodes.Delete(idx);
  end;
end;

{ TLXPathDomNodeList }

function TLXPathDomNodeList.get_item(index: integer): IDomNode;
// get an item from a nodelist
var
  node: xmlNodePtr;
  i:    integer;
begin
  // assign index to i
  i := index;
  // set node to nil
  node := nil;
  begin
    // if we have a nodelist with a parent
    if FParent <> nil then begin
      // get the first entry of the list
      node := FParent^.children;
      // walk through the list i times forward, but not beyond the end
      while (i > 0) and (node^.Next <> nil) do begin
        dec(i);
        node := node^.Next
      end;
      // raise an error, if we are at the end, but i isn't zero
      DomAssert1(i=0, INDEX_SIZE_ERR,'',classname);
    // if we have a nodelist as array from an xpath result
    end else begin
      if FXPathObject <> nil then node :=
          xmlXPathNodeSetItem(FXPathObject^.nodesetval, i)
      else DomAssert1(false, INVALID_ACCESS_ERR, '', classname);
    end;
  end;
  // create the result from the xmlNodePtr
  Result := GetDomObject(node) as IDomNode
end;

function TLXPathDomNodeList.get_length: integer;
// get the length of a nodelist
var
  node: xmlNodePtr;
  i:    integer;
begin
  // if it is a nodelist with a parent
  if FParent <> nil then begin
    i := 1;
    node := FParent^.children;
    // count the children
    if node <> nil then while (node^.Next <> nil) do begin
        inc(i);
        node := node^.Next
      end else i := 0;
    Result := i
  // if it is an xpath result array
  end else begin
    begin
      // and it does exist
      if FXPathObject^.nodesetval<>nil
        // get the size of the array
        then Result := FXPathObject^.nodesetval^.nodeNr
        else result := 0;
    end
  end;
end;

function TLXPathDomNodeList.get_xml: DomString;
var
  i: integer;
  delim: widestring;
begin
  // libxml returns unix-like strings in the moment;
  delim:=#10;
  result:='';
  // cyle trough the nodelist
  for i:=0 to self.get_length-1 do begin
    // append the xml of the current node to the result
    result:=result+delim+(self.get_item(i) as IDomNodeExt).get_xml;
  end;
end;

constructor TLXPathDomNodeList.Create(AParent: xmlNodePtr; ADocument: IDomDocument);
  // create a IDomNodeList from a var of type xmlNodePtr
  // xmlNodePtr is the same as xmlNodePtrList, because in libxml2 there is no
  // difference in the definition of both
begin
  inherited Create;
  FParent := AParent;
  FXpathObject := nil;
  fOwnerDocument := ADocument;
end;

constructor TLXPathDomNodeList.Create(AXpathObject: xmlXPathObjectPtr;
  ADocument: IDomDocument);
  // create a IDomNodeList from a var of type xmlNodeSetPtr
  //  xmlNodeSetPtr = ^xmlNodeSet;
  //  xmlNodeSet = record
  //    nodeNr : longint;                { number of nodes in the set  }
  //    nodeMax : longint;              { size of the array as allocated  }
  //    nodeTab : PxmlNodePtr;       { array of nodes in no particular order  }
  //  end;
begin
  inherited Create;
  FParent := nil;
  FXpathObject := AXpathObject;
  fOwnerDocument := ADocument;
end;

destructor TLXPathDomNodeList.Destroy;
begin
  fOwnerDocument := nil;
  if FXPathObject <> nil then begin
    try
      // todo 5: find out, why this causes a problem
      xmlXPathFreeObject(FXPathObject);
    except
    end;
  end;
  inherited Destroy;
end;

{ TLDomObject }

procedure TLDomObject.DomAssert(aCondition: Boolean; aErrorCode: integer; aMsg: WideString);
begin
  DomAssert1(aCondition, aErrorCode, aMsg, ClassName);
end;

procedure TLDomObject.checkName(aPrefix, aLocalName: String);
begin
  if (aPrefix<>'') then begin
    DomAssert(isNCName(aPrefix), INVALID_CHARACTER_ERR, 'Invalid character in prefix: "'+aPrefix+'"');
  end;
  DomAssert(isNCName(aLocalName), INVALID_CHARACTER_ERR, 'Invalid character in local name: "'+aLocalName+'"');
end;

procedure TLDomObject.checkNsName(aPrefix, aLocalName, aNamespaceURI: String);
begin
  if (aPrefix='') then begin
  end else if (aPrefix='xml') then begin
    DomAssert(aNamespaceURI=XML_NAMESPACE_URI, NAMESPACE_ERR, 'Invalid namespaceURI for prefix "xml": "'+aNamespaceURI+'"');
  end else if (aPrefix='xmlns') then begin
    DomAssert(aNamespaceURI=XMLNS_NAMESPACE_URI, NAMESPACE_ERR, 'Invalid namespaceURI for prefix "xmlns": "'+aNamespaceURI+'"');
  end else begin
    DomAssert(isNCName(aPrefix), INVALID_CHARACTER_ERR, 'Invalid character in prefix: "'+aPrefix+'"');
    DomAssert(aNamespaceURI<>'', NAMESPACE_ERR, 'Empty namespaceURI for prefix "'+aPrefix+'"');
  end;
  DomAssert(isNCName(aLocalName), INVALID_CHARACTER_ERR, 'Invalid character in local name: "'+aLocalName+'"');
end;

function TLDomObject.returnEmptyString: DomString;
begin
  Result := '';
end;

function TLDomObject.returnNullDomNode: IDomNode;
begin
  Result := nil;
end;

function TLDomObject.SafeCallException(aExceptObject: TObject; aExceptAddr: Pointer): HRESULT;
begin
  Result := 0; //todo
end;

{ TLDomNodeExtension }

function TLDomNodeExtension._AddRef : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  Result := IUnknown(fLDomNode)._AddRef;
end;

function TLDomNodeExtension._Release : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  Result := IUnknown(fLDomNode)._Release;
end;

constructor TLDomNodeExtension.Create(const aLDomNode: TLDomNode);
begin
  // weak reference to controller - don't keep it alive
  fLDomNode := aLDomNode;
end;

function TLDomNodeExtension.GetLDomNode: TLDomNode;
begin
  Result := fLDomNode;
end;

function TLDomNodeExtension.QueryInterface(
      {$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} aIID : tguid;out aObj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  if fLDomNode.GetInterface(aIID, aObj) then begin
    Result := 0;
  end else if GetInterface(aIID, aObj) then begin
    Result := 0;
  end else begin
    Result := E_NOINTERFACE;
  end;
end;

{ TLDomNode }

function TLDomNode.appendChild(const newChild: IDomNode): IDomNode;
begin
  Result := insertBefore(newChild, nil);
end;

function TLDomNode.cloneNode(deep: Boolean): IDomNode;
var
  node, clonedNode: xmlNodePtr;
  recursive: Integer;
begin
  if deep
  then recursive:= 1
  else recursive:= 2;
  node := requestNodePtr;
  clonedNode := xmlDocCopyNode(node, node^.doc, recursive);
  if node^.ns <> nil then clonedNode^.ns := xmlCopyNamespace(node^.ns);
  Result := GetDOMObject(clonedNode) as IDomNode;
end;

constructor TLDomNode.Create(aLibXml2Node: pointer);
begin
  inherited Create;
  fMyNode := aLibXml2Node;
  if not (self is TLDomDocument) then begin
    // this node is not a document
    DomAssert(Assigned(aLibXml2Node), INVALID_ACCESS_ERR, 'TLDomNode.Create: Cannot wrap null node');
    fMyNode^._private := self;

    if not (self is TLDomDocumentType) then begin
      DomAssert(fMyNode^.doc<>nil, INVALID_ACCESS_ERR, 'TLDomNode.Create: Cannot wrap node not attached to any document');
    end;
    if (fMyNode^.doc<>nil) then begin
      // if the node is flying, register it in the owner document
      if (fMyNode^.parent=nil) then begin
        RegisterFlyingNode(fMyNode);
      end;
      // if this is not the document itself, pretend having a reference to the owner document.
      // This ensures that the document lives exactly as long as any wrapper node (created by this doc) exists
      get_ownerDocument._AddRef;
    end;
  end;
  // create object implementing additional interfaces
  if Assigned(GlbNodeExtensionClass) then begin
    fExtensionObj := GlbNodeExtensionClass.Create(self);
  end;
  Inc(GlbNodeCount);
end;

destructor TLDomNode.Destroy;
begin
  if not (self is TLDomDocument) then begin
    if (fMyNode^.doc<>nil) then begin
      // if this is not the document itself, release the pretended reference to the owner document:
      // This ensures that the document lives exactly as long as any wrapper node (created by this doc) exists
      get_ownerDocument._Release;
    end;
  end;
  if (fMyNode<>nil) then begin
    fMyNode^._private := nil;
  end;
  //destroy extension object
  if (fExtensionObj<>nil) then begin
    fExtensionObj.Free;
    fExtensionObj := nil;
  end;
  fChildNodes.Free;
  Dec(GlbNodeCount);
  inherited Destroy;
end;

function TLDomNode.get_attributes: IDomNamedNodeMap;
begin
  Result := nil;
end;

function TLDomNode.getElementsByTagName(const name: DomString): IDomNodeList;
begin
  Result := nil;
  if (name = '*') then begin
    Result := selectNodes('.//*');
  end else begin
    Result := selectNodes('.//'+name);
  end;
end;

function TLDomNode.getElementsByTagNameNS(const namespaceURI, localName: DomString): IDomNodeList;
var
  i: Integer;
  ownerDocument: IDomInternal;
  PrefixList: TStringList;
  XPath: string;
begin
  Result := nil;
  if namespaceURI='*' then begin
    // get the prefix and uri list
    if get_ownerDocument = nil
    then ownerDocument:=Self as IDomInternal
    else ownerDocument:=get_ownerDocument as IDomInternal;
    PrefixList:=ownerDocument.getPrefixList;
    XPath := './/'+PrefixList.Names[0]+':'+localName;
    for i := 1 to PrefixList.Count - 1 do
    begin
      XPath := XPath+'|.//'+PrefixList.Names[i]+':'+localName;;
    end;
    Result := selectNodes(XPath);
  end else begin 
    RegisterNs('xyz4ct', namespaceURI);
    Result := selectNodes('.//xyz4ct:'+localName);
  end;
end;

function TLDomNode.IsSameNode(node: IDomNode): boolean;
var
  xnode1, xnode2: xmlNodePtr;
begin
  Result := True;
  if (self = nil) and (node = nil) then exit;
  Result := False;
  if (self = nil) or (node = nil) then exit;
  xnode1 := GetXmlNode(self);
  xnode2 := GetXmlNode(node);
  if xnode1 = xnode2 then Result := True
  else Result := False;
end;

function TLDomNode.selectNode(const nodePath: DomString): IDomNode;
begin
  Result := selectNodes(nodePath)[0];
end;

function TLDomNode.selectNodes(const nodePath: DomString): IDomNodeList;
// raises SYNTAX_ERR,
// if invalid xpath expression or
// if the result type is string or number
var
  doc:  xmlDocPtr;
  ctxt: xmlXPathContextPtr;
  res:  xmlXPathObjectPtr;
  temp: string;
  tmpdoc: xmlDocPtr;
  tmpnode: xmlNodePtr;
  nodetype: xmlXPathObjectType;
  i: integer;
  Prefix,Uri,Uri1: string;
  FPrefixList:TStringList;
  errCtx: TErrCtx;
  ownerDocument: IDomInternal;
begin
  // encode the nodePath
  temp := UTF8Encode(nodePath);
  // get the xmlDocumentPtr
  doc := fMyNode^.doc;
  if (doc = nil) and (fMyNode^.type_ = XML_DOCUMENT_NODE) then
    doc := xmlDocPtr(fMyNode);
  // raise an error, if it's nil
  DomAssert(doc<>nil, INVALID_ACCESS_ERR,classname);
  // create an XPathContext
  ctxt := xmlXPathNewContext(doc);
  // assign the context node
  ctxt^.node := fMyNode;
  // get the prefix and uri list
  if get_ownerDocument = nil
  then ownerDocument:=Self as IDomInternal
  else ownerDocument:=get_ownerDocument as IDomInternal;
  FPrefixList:=ownerDocument.getPrefixList;
  // register these namespaces in th XPATH context
  for i:=0 to FPrefixList.Count-1 do begin
    Prefix:=FPrefixList.Names[i];
    Uri:=FPrefixList.Values[Prefix];
    // check wether it was already registered
    Uri1:=xmlXPathNsLookup(ctxt,pchar(prefix));
    // register it only, if it wasn't registered yet
    // (otherwise you get an access violation)
    if (Prefix <> '') and (Uri <> '') and (Uri<>Uri1)
      then xmlXPathRegisterNs(ctxt, PChar(Prefix), PChar(URI));
  end;
  // clear last error message
  ownerDocument.reason := '';
  ErrCtx.document:=nil;
  ErrCtx.errMsg:='';
  // initialize the errorHandler
  xmlSetGenericErrorFunc(@ErrCtx, xmlGenericErrorFunc(@errorHandler));
  // evaluate the xpath expression
  res := xmlXPathEvalExpression(PChar(temp), ctxt);
  // check if the expression was valid
  if res <> nil then begin
    // if there was a result, get it's type
    nodetype := res^.type_;
    case nodetype of
      // if it was a nodeset, create a nodelist
      XPATH_NODESET:
        begin
          Result := TLXPathDomNodeList.Create(res, TLDomDocument(doc^._private))
        end
     // otherwise raise an syntax error
     else begin
       Result := nil;
       // cleanUp
       xmlXPathFreeContext(ctxt);
       DomAssert(false, SYNTAX_ERR);
     end;
    end;
  // if the xpath expression was invalid
  end else begin
    Result := nil;
    ownerDocument.reason := ErrCtx.errMsg;
    // cleanUp
    xmlXPathFreeContext(ctxt);
    DomAssert(false, SYNTAX_ERR, ownerDocument.reason);
  end;
  // cleanUp
  tmpdoc:=ctxt^.doc;
  tmpnode:=ctxt^.node;
  //try
  // todo: check, why this line causes problems
  xmlXPathFreeContext(ctxt);
  //except
  //  temp:=tmpdoc.name;
  //  temp:=tmpnode.name;
  //end;
end;

procedure TLDomNode.RegisterNS(const prefix, URI: DomString);
var
  ownerDocument: IDomInternal;
begin
  if get_ownerDocument = nil
  then ownerDocument := Self as IDomInternal
  else ownerDocument := get_ownerDocument as IDomInternal;
  ownerDocument.registerNS(UTF8Encode(prefix),UTF8Encode(Uri));
end;

function TLDomNode.get_firstChild: IDomNode;
begin
  if fMyNode=nil then begin
    Result := nil;
  end else begin
    Result := GetDOMObject(fMyNode^.children) as IDomNode;
  end;
end;

function TLDomNode.get_childNodes: IDomNodeList;
begin
  case get_nodeType of
  TEXT_NODE,
  COMMENT_NODE,
  PROCESSING_INSTRUCTION_NODE,
  CDATA_SECTION_NODE:
    Result := nil;
  else
    if (fChildNodes=nil) then begin
      TLDomChildNodeList.Create(self); // assigns fChildNodes
    end;
    Result := fChildNodes;
  end;
end;

function TLDomNode.get_lastChild: IDomNode;
begin
  if fMyNode=nil then begin
    Result := nil;
  end else begin
    Result := GetDOMObject(fMyNode^.last) as IDomNode;
  end;
end;

function TLDomNode.get_localName: DomString;
begin
  Result := '';
  if (fMyNode=nil) then Exit;
  case fMyNode^.type_ of
  XML_ELEMENT_NODE,
  XML_ATTRIBUTE_NODE:
    // this is neccessary, because according to the dom2
    // specification localName has to be nil for nodes,
    // that don't have a namespace
    if (fMyNode^.ns <> nil) then begin
      Result := UTF8Decode(fMyNode^.name);
    end;
  end;
end;

function TLDomNode.get_namespaceURI: DomString;
begin
  Result := '';
  if (fMyNode=nil) then begin
    Result := '(null)';
  end else begin
    case fMyNode^.type_ of
    XML_ELEMENT_NODE,
    XML_ATTRIBUTE_NODE:
      begin
        if fMyNode^.ns=nil then exit;
        Result := UTF8Decode(fMyNode^.ns^.href);
      end;
    end;
  end;
end;

function TLDomNode.get_nextSibling: IDomNode;
begin
  if (fMyNode=nil) then begin
    Result := nil;
  end else begin
    Result := GetDOMObject(fMyNode^.next) as IDomNode;
  end;
end;

function TLDomNode.get_nodeName: DomString;
begin
  if (fMyNode=nil) then begin
    Result := '(null)';
  end else begin
    case fMyNode^.type_ of
    XML_HTML_DOCUMENT_NODE,
    XML_DOCB_DOCUMENT_NODE,
    XML_DOCUMENT_NODE:
      Result := '#document';
    XML_CDATA_SECTION_NODE:
      Result := '#cdata-section';
    XML_DOCUMENT_FRAG_NODE:
      Result := '#document-fragment';
    XML_TEXT_NODE,
    XML_COMMENT_NODE:
      Result := '#'+UTF8Decode(fMyNode^.name);
    XML_ELEMENT_NODE,
    XML_ATTRIBUTE_NODE:
      begin
        Result := UTF8Decode(fMyNode^.name);
        if (fMyNode^.ns<>nil) and (fMyNode^.ns^.prefix<>nil) then begin
          Result := UTF8Decode(fMyNode^.ns^.prefix)+':'+Result;
        end;
      end;
    else
      Result := UTF8Decode(fMyNode^.name);
    end;
  end;
end;

function TLDomNode.get_nodeType: DomNodeType;
begin
  if (fMyNode=nil) then begin
    Result := 0; //UGLY
  end else begin
    Result := DomNodeType(fMyNode^.type_);
  end;
end;

function TLDomNode.get_nodeValue: DomString;
var
  p: PxmlChar;
begin
  if (fMyNode=nil) then begin
    p := nil;
  end else begin
    case fMyNode^.type_ of
    XML_ATTRIBUTE_NODE,
    XML_TEXT_NODE,
    XML_CDATA_SECTION_NODE,
    XML_COMMENT_NODE,
    XML_PI_NODE:
      p := xmlNodeGetContent(fMyNode);
    else
      p := nil;
    end;
  end;
  if (p<>nil) then begin
    Result := UTF8Decode(p);
    xmlFree(p);
  end else begin
    Result := '';
  end;
end;

function TLDomNode.get_ownerDocument: IDomDocument;
begin
  if (fMyNode=nil) then begin
    Result := nil;
  end else begin
    Result := GetDOMObject(fMyNode^.doc) as IDomDocument;
  end;
end;

function TLDomNode.get_parentNode: IDomNode;
begin
  if (fMyNode=nil) then begin
    Result := nil;
  end else begin
    Result := GetDOMObject(fMyNode^.parent) as IDomNode;
  end;
end;

function TLDomNode.get_prefix: DomString;
begin
  if (fMyNode=nil) then begin
    Result := '';
  end else begin
    case fMyNode^.type_ of
    XML_ELEMENT_NODE,
    XML_ATTRIBUTE_NODE:
      begin
        if fMyNode^.ns=nil then exit;
        Result := UTF8Decode(fMyNode^.ns^.prefix);
      end;
    end;
  end;
end;

function TLDomNode.get_previousSibling: IDomNode;
begin
  if (fMyNode=nil) then begin
    Result := nil;
  end else begin
    Result := GetDOMObject(fMyNode^.prev) as IDomNode;
  end
end;

function TLDomNode.hasAttributes: Boolean;
begin
  Result := False;
  if fMyNode=nil then exit;
  if fMyNode^.properties=nil then exit;
  Result := True;
end;

function TLDomNode.hasChildNodes: Boolean;
begin
  Result := False;
  if fMyNode=nil then exit;
  if fMyNode^.children=nil then exit;
  Result := True;
end;

function TLDomNode.insertBefore(const newChild, refChild: IDomNode): IDomNode;
var
  node: xmlNodePtr;
  child, nextChild: xmlNodePtr;
const
  CHILD_TYPES = [
    ELEMENT_NODE,
    TEXT_NODE,
    CDATA_SECTION_NODE,
    ENTITY_REFERENCE_NODE,
    PROCESSING_INSTRUCTION_NODE,
    COMMENT_NODE,
    DOCUMENT_TYPE_NODE,
    DOCUMENT_FRAGMENT_NODE,
    NOTATION_NODE
  ];
begin
  DomAssert(newChild<>nil, INVALID_ACCESS_ERR, 'insertBefore: cannot append null');
  DomAssert((newChild.nodeType in CHILD_TYPES), HIERARCHY_REQUEST_ERR, 'insertBefore: newChild cannot be inserted, nodetype = '+IntToStr(get_nodeType));
  DomAssert(not IsReadOnlyNode(requestNodePtr), NO_MODIFICATION_ALLOWED_ERR);
  if (requestNodePtr^.type_=XML_DOCUMENT_NODE) and (newChild.nodeType = ELEMENT_NODE) then begin
    DomAssert((xmlDocGetRootElement(xmlDocPtr(fMyNode))=nil), HIERARCHY_REQUEST_ERR, 'insertBefore: document already has a documentElement');
  end;

  child := GetGNode(newChild);
  DomAssert(not IsAncestorOrSelf(child), HIERARCHY_REQUEST_ERR);
  DomAssert(child^.doc=fMyNode^.doc, WRONG_DOCUMENT_ERR, 'insertBefore: cannot insert a node from other document');
  DomAssert(not IsReadOnlyNode(child^.parent), NO_MODIFICATION_ALLOWED_ERR, 'insertBefore: modification not allowed here');

  UnregisterFlyingNode(child);
  if child^.type_ = XML_DOCUMENT_FRAG_NODE then
    child := child^.children;
  repeat
    nextChild := child^.next;
    if (refChild=nil) then begin
      xmlUnlinkNode(child);
      node := xmlAddChild(fMyNode, child);
    end else begin
      node := xmlAddPrevSibling(GetGNode(refChild), child);
    end;
    child := nextChild;
  until nextChild = nil;
  Result := GetDOMObject(node) as IDomNode;
end;

function TLDomNode.isAncestorOrSelf(aNode: xmlNodePtr): Boolean;
var
  node: xmlNodePtr;
begin
  node := fMyNode;
  Result := True;
  while (node<>nil) do begin
    if (node=aNode) then exit;
    node := node^.parent;
  end;
  Result := False;
end;

function TLDomNode.isSupported(const feature, version: DomString): Boolean;
begin
  Result := featureIsSupported(feature, version, IMPLEMENTATION_FEATURES);
end;

function TLDomNode.LibXml2NodePtr: xmlNodePtr;
begin
  Result := fMyNode;
end;

(**
 * @todo check carefully
 *)
procedure TLDomNode.normalize;
var
  node,next,new_next: xmlNodePtr;
  nodeType: xmlElementType;
begin
  node:=fMyNode^.children;
  next:=nil;
  while node<>nil do begin
    nodeType:=node^.type_;
    if nodeType=XML_TEXT_NODE then begin
      next:=node^.next;
      while next<>nil do begin
        if next^.type_<>XML_TEXT_NODE then break;
        xmlTextConcat(node,next^.content,length(next^.content));
        new_next:=next^.next;
        xmlUnlinkNode(next);
        xmlFreeNode(next); //carefull!!
        next:=new_next;
      end;
    end else if nodeType=XML_ELEMENT_NODE then begin
      //todo
    end;
    node:=next;
  end;
end;

function TLDomNode.QueryInterface({$IFDEF FPC_HAS_CONSTREF}constref{$ELSE}const{$ENDIF} aIID : tguid;out aObj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
begin
  if GetInterface(aIID, aObj) then begin
    Result := 0;
  end else if (fExtensionObj=nil) then begin
    Result := E_NOINTERFACE;
  end else if (fExtensionObj.GetInterface(aIID, aObj)) then begin
    Result := 0;
  end else begin
    Result := E_NOINTERFACE;
  end;
end;

function TLDomNode.removeChild(const childNode: IDomNode): IDomNode;
var
  child: xmlNodePtr;
begin
  DomAssert(childNode<>nil, INVALID_CHARACTER_ERR, 'removeChild: childNode is null');
  child := GetGNode(childNode);
  xmlUnlinkNode(child);
  RegisterFlyingNode(child);
  Result := childNode;
end;

function TLDomNode.replaceChild(const newChild, oldChild: IDomNode): IDomNode;
var
  old, cur, node: xmlNodePtr;
begin
  DomAssert(oldChild<>nil, INVALID_CHARACTER_ERR, 'replaceChild: oldChild is null');
  DomAssert(newChild<>nil, INVALID_CHARACTER_ERR, 'replaceChild: newChild is null');
  old := GetGNode(oldChild);
  cur := GetGNode(newChild);
  node := xmlReplaceNode(old, cur);
  RegisterFlyingNode(old);
  UnregisterFlyingNode(cur);
  Result := GetDOMObject(node) as IDomNode
end;

function TLDomNode.requestNodePtr: xmlNodePtr;
begin
  DomAssert(fMyNode<>nil, INVALID_ACCESS_ERR, ClassName+'.requestNodePtr: wrapping null node');
  Result := fMyNode;
end;

procedure TLDomNode.set_nodeValue(const value: DomString);
begin
  case fMyNode^.type_ of
  XML_ATTRIBUTE_NODE,
  XML_TEXT_NODE,
  XML_CDATA_SECTION_NODE,
  XML_ENTITY_REF_NODE,
  XML_COMMENT_NODE,
  XML_PI_NODE:
    begin
      xmlNodeSetContent(fMyNode, PChar(UTF8Encode(value)));
    end;
  XML_ELEMENT_NODE: begin end;
  else
    DomAssert(false, NO_MODIFICATION_ALLOWED_ERR);
  end;
end;

procedure TLDomNode.set_Prefix(const prefix: DomString);
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

{ TLDomChildNodeList }

constructor TLDomChildNodeList.Create(aOwnerNode: TLDomNode);
begin
  inherited Create;
  DomAssert(aOwnerNode<>nil, HIERARCHY_REQUEST_ERR, 'Child list must have a parent');
  fOwnerNode := aOwnerNode;
  fOwnerNode.fChildNodes := self;
  fOwnerNode._AddRef; //as long as the list exists, its owner must exist too
end;

destructor TLDomChildNodeList.Destroy;
begin
  fOwnerNode.fChildNodes := nil;
  fOwnerNode._Release;
  fOwnerNode := nil;
  inherited Destroy;
end;

function TLDomChildNodeList.GetFirstChildNodePtr: xmlNodePtr;
begin
  Result := fOwnerNode.requestNodePtr^.children;
end;

function TLDomChildNodeList.get_item(index: Integer): IDomNode;
var
  node: xmlNodePtr;
  cnt: integer;
begin
  DomAssert(index>=0, INDEX_SIZE_ERR);
  node := GetFirstChildNodePtr;
  cnt := 0;
  while (cnt<index) do begin
    if (node=nil) then begin
      DomAssert(false, INDEX_SIZE_ERR, Format('Trying to access item %d [zero based] of %d items', [index, cnt]));
    end;
    Inc(cnt);
    node := node^.next;
  end;
  Result := GetDOMObject(node) as IDomNode;
end;

function TLDomChildNodeList.get_length: Integer;
var
  node: xmlNodePtr;
begin
  Result := 0;
  node := GetFirstChildNodePtr;
  while (node<>nil) do begin
    Inc(Result);
    node := node^.next;
  end;
end;

{ TLDomEntRefChildNodes }

function TLDomEntRefChildNodes.GetFirstChildNodePtr: xmlNodePtr;
begin
  Result := fOwnerNode.requestNodePtr^.children;
  if (Result <> nil) then begin
    Result := Result^.children;
  end;
end;

{ TLDomDocument }

constructor TLDomDocument.Create(aLibXml2Node: pointer);
begin
  inherited Create(aLibXml2Node);
  Inc(GlbDocCount);
  fPrefixList := TStringList.Create;
  fPrefixList.Sorted:=True;
end;

function TLDomDocument.createAttribute(const name: DomString): IDomAttr;
var
  attr: xmlAttrPtr;
  uprefix, ulocal: String;
begin
  SplitQName(UTF8Encode(name), uprefix, ulocal);
  checkName(uprefix, ulocal);
  attr := xmlNewDocProp(requestDocPtr, PChar(ulocal), nil);
  Result := GetDOMObject(attr) as IDomAttr;
end;

function TLDomDocument.createAttributeNS(const namespaceURI, qualifiedName: DomString): IDomAttr;
var
  attr: xmlAttrPtr;
  ns: xmlNsPtr;
  uprefix, ulocal, uuri: String;
begin
  SplitQName(UTF8Encode(qualifiedName), uprefix, ulocal);
  uuri := UTF8Encode(namespaceURI);
  checkNsName(uprefix, ulocal, uuri);
  if (uuri<>'') then begin
    // one more special check for attributes
    if (uprefix='') and (ulocal='xmlns') then begin
      DomAssert(uuri=XMLNS_NAMESPACE_URI, NAMESPACE_ERR, 'Invalid namespaceURI for attribute "xmlns": "'+uuri+'"');
    end;
    //
    ns := xmlNewNs(nil, PChar(uuri), PChar(uprefix));
    attr := xmlNewNsProp(nil, ns, PChar(ulocal), nil);
    attr^.doc := requestDocPtr;
  end else begin
    attr := xmlNewDocProp(requestDocPtr, PChar(ulocal), nil);
  end;
  Result := GetDOMObject(attr) as IDomAttr;
end;

function TLDomDocument.createCDATASection(const data: DomString): IDomCDataSection;
var
  node: xmlNodePtr;
  udata: String;
begin
  udata := UTF8Encode(data);
  DomAssert(Pos(']]>', udata)=0, INVALID_CHARACTER_ERR, 'cdata section cannot contain "]]>"');
  node := xmlNewCDataBlock(requestDocPtr, PChar(udata), length(udata));
  Result := GetDOMObject(node) as IDomCDataSection;
end;

function TLDomDocument.createComment(const data: DomString): IDomComment;
var
  node: xmlNodePtr;
  udata: String;
begin
  udata := UTF8Encode(data);
  DomAssert(Pos('--', udata)=0, INVALID_CHARACTER_ERR, 'comment cannot contain "--"');
  node := xmlNewDocComment(requestDocPtr, PChar(UTF8Encode(data)));
  Result := GetDOMObject(node) as IDomComment;
end;

function TLDomDocument.createDocumentFragment: IDomDocumentFragment;
var
  node: xmlNodePtr;
begin
  node := xmlNewDocFragment(requestDocPtr);
  Result := GetDOMObject(node) as IDomDocumentFragment;
end;

function TLDomDocument.createElement(const tagName: DomString): IDomElement;
var
  node: xmlNodePtr;
  uprefix, ulocal: String;
begin
  SplitQName(UTF8Encode(tagName), uprefix, ulocal);
  checkName(uprefix, ulocal);
  node := xmlNewDocNode(requestDocPtr, nil, PChar(ulocal),nil);
  Result := GetDOMObject(node) as IDomElement;
end;

function TLDomDocument.createElementNS(const namespaceURI, qualifiedName: DomString): IDomElement;
var
  node: xmlNodePtr;
  ns: xmlNsPtr;
  uprefix, ulocal, uuri: String;
begin
  SplitQName(UTF8Encode(qualifiedName), uprefix, ulocal);
  uuri := UTF8Encode(namespaceURI);
  checkNsName(uprefix, ulocal, uuri);
  node := xmlNewDocNode(requestDocPtr, nil, PChar(ulocal), nil);
  if (uuri<>'') then begin
    ns := xmlNewNs(node, PChar(uuri), PChar(uprefix));
    registerNS(uprefix, uuri);
    xmlSetNs(node, ns);
  end;
  Result := GetDOMObject(node) as IDomElement;
end;

function TLDomDocument.createEntityReference(const name: DomString): IDomEntityReference;
var
  node: xmlNodePtr;
  uname: String;
begin
  uname := UTF8Encode(name);
  checkName('', uname);
  node := xmlNewReference(requestDocPtr, PChar(uname));
  Result := GetDOMObject(node) as IDomEntityReference;
end;

function TLDomDocument.createProcessingInstruction(const target, data: DomString): IDomProcessingInstruction;
var
  pi: xmlNodePtr;
  utarget: String;
begin
  utarget := UTF8Encode(target);
  checkName('', utarget);
  pi := xmlNewPI(PChar(utarget), PChar(UTF8Encode(data)));
  pi^.doc := requestDocPtr;
  Result := GetDOMObject(pi) as IDomProcessingInstruction;
end;

function TLDomDocument.createTextNode(const data: DomString): IDomText;
var
  node: xmlNodePtr;
begin
  node := xmlNewDocText(requestDocPtr, PChar(UTF8Encode(data)));
  Result := GetDOMObject(node) as IDomText;
end;

destructor TLDomDocument.Destroy;
begin
  GDoc := nil;
  //
  Dec(GlbDocCount);
  fFlyingNodes.Free;
  fFlyingNodes := nil;
  fMyImplementation := nil;
  FreeAndNil(fPrefixList);
  inherited Destroy;
end;

function TLDomDocument.getElementById(const elementId: DomString): IDomElement;
var
  attr: xmlAttrPtr;
begin
  attr := xmlGetID(requestDocPtr, PChar(UTF8Encode(elementId)));
  if (attr<>nil) then begin
    Result := GetDOMObject(attr^.parent) as IDomElement;
  end else begin
    Result := nil;
  end;
end;

function TLDomDocument.GetFlyingNodes: TList;
begin
  if fFlyingNodes=nil then begin
    fFlyingNodes := TList.Create;
  end;
  Result := fFlyingNodes;
end;

function TLDomDocument.GetGDoc: xmlDocPtr;
begin
  Result := xmlDocPtr(fMyNode);
end;

function TLDomDocument.get_doctype: IDomDocumentType;
var
  dtd: xmlDtdPtr;
begin
  Result := nil;
  if GDoc=nil then exit;
  dtd := GDoc^.intSubset;
  if dtd = nil then exit;
  Result := GetDomObject(dtd) as IDomDocumentType;
end;

function TLDomDocument.get_documentElement: IDomElement;
begin
  Result := GetDOMObject(xmlDocGetRootElement(GDoc)) as IDomElement;
end;

function TLDomDocument.get_domImplementation: IDomImplementation;
begin
  if fMyImplementation=nil then begin
    fMyImplementation := TLDomImplementation.Create(TLDomDocumentClass(GlbNodeClasses[XML_DOCUMENT_NODE])); //todo: ??? default class, global instance ???
  end;
  Result := fMyImplementation;
end;

function TLDomDocument.get_nodeName: DomString;
begin
  Result := '#document';
end;

function TLDomDocument.get_nodeType: DomNodeType;
begin
  Result := DOCUMENT_NODE;
end;

function TLDomDocument.get_ownerDocument: IDomDocument;
begin
  Result := nil; // required by DOM spec.
end;

function TLDomDocument.importNode(importedNode: IDomNode; deep: Boolean): IDomNode;
var
  recurse: integer;
  node, impNode: xmlNodePtr;
begin
  Result:=nil;
  if importedNode=nil then exit;
  case integer(importedNode.nodeType) of
    DOCUMENT_NODE,
    DOCUMENT_TYPE_NODE,
    NOTATION_NODE,
    ENTITY_NODE:
      DomAssert(false, NOT_SUPPORTED_ERR);
//    ATTRIBUTE_NODE:
//      DomAssert(false, NOT_SUPPORTED_ERR); //ToDo: implement this case
  else
    if deep
    then recurse:=1
    else recurse:=0;
    impNode := GetGNode(importedNode);
    node:=xmlDocCopyNode(impNode, requestDocPtr, recurse);
    if impNode^.ns <> nil then node^.ns := xmlCopyNamespace(impNode^.ns);
    Result := GetDOMObject(node) as IDomNode;
  end;
end;

function TLDomDocument.internalParse(var aCtxt: xmlParserCtxtPtr): xmlDocPtr;
begin
  xmlParseDocument(aCtxt);
  if (aCtxt^.wellFormed=0) then begin
    xmlFreeDoc(aCtxt^.myDoc);
    aCtxt^.myDoc := nil;
  end;
  Result := aCtxt^.myDoc;
end;

function TLDomDocument.load(aUrl: DomString): Boolean;
var
  fn: String;
  ctxt: xmlParserCtxtPtr;
  doc: xmlDocPtr;
begin
{$ifdef WIN32}
  fn := StringReplace(UTF8Encode(aUrl), '\', '\\', [rfReplaceAll]);
{$else}
  fn := UTF8Encode(aUrl);
{$endif}
  xmlInitParser();
  ctxt := xmlCreateFileParserCtxt(PChar(fn));
  Result := False;
  if (ctxt = nil) then exit;
  try
    doc := internalParse(ctxt);
    Result := doc<>nil;
    if (Result) then begin
      GDoc := doc;
    end;
  finally
    xmlFreeParserCtxt(ctxt);
  end;
end;

function TLDomDocument.parse(const aXml: DomString): Boolean;
var
  data: String;
  ctxt: xmlParserCtxtPtr;
  doc: xmlDocPtr;
begin
  data := UTF8Encode(aXml);
  xmlInitParser();
  ctxt := xmlCreateMemoryParserCtxt(PChar(data), Length(data));
  Result := False;
  if (ctxt = nil) then exit;
  try
    doc := internalParse(ctxt);
    Result := doc<>nil;
    if (Result) then begin
      GDoc := doc;
    end;
  finally
    xmlFreeParserCtxt(ctxt);
  end;
end;

procedure TLDomDocument.set_reason(aReason: DomString);
begin
  fReason := aReason;
end;

function TLDomDocument.get_reason: DomString; safecall;
begin
  Result := fReason;
end;

procedure TLDomDocument.removeNode(node: xmlNodePtr);
begin

end;

procedure TLDomDocument.removeAttr(attr: xmlAttrPtr);
begin

end;

procedure TLDomDocument.appendAttr(attr: xmlAttrPtr);
begin

end;

procedure TLDomDocument.appendNode(node: xmlNodePtr);
begin

end;

procedure TLDomDocument.appendNs(ns: xmlNsPtr);
begin

end;

function TLDomDocument.getNewNamespace(const namespaceURI, prefix: DOMString
  ): xmlNsPtr;
begin

end;

function TLDomDocument.findOrCreateNewNamespace(const node: xmlNodePtr;
  const ns: xmlNsPtr): xmlNsPtr;
begin

end;

function TLDomDocument.findOrCreateNewNamespace(const node: xmlNodePtr;
  const namespaceURI, prefix: PChar): xmlNsPtr;
begin

end;

procedure TLDomDocument.registerNS(prefix, uri: string);
var
  index: Integer;
begin
  index := FPrefixList.IndexOfName(prefix);
  if index <> -1 then
    FPrefixList.Delete(index);
  FPrefixList.Add(prefix+'='+uri);
end;

function TLDomDocument.getPrefixList: TStringList;
begin
  result:=FPrefixList;
end;

procedure TLDomDocument.set_fTempXSL(tempXSL: xsltStylesheetPtr);
begin

end;

procedure TLDomDocument.removeWhitespace;
begin

end;

function TLDomDocument.requestDocPtr: xmlDocPtr;
begin
  Result := GetGDoc;
  if Result<>nil then exit; //the document is already created so we have to use it
  // otherwise, we create the document, using all the parameters specified so far

  //todo: distinguish empty doc, parsing, and push-parsing cases (for async)
  Result := xmlNewDoc(XML_DEFAULT_VERSION);
  SetGDoc(Result);
end;

function TLDomDocument.requestNodePtr: xmlNodePtr;
begin
  requestDocPtr;
  Result := fMyNode;
end;

procedure TLDomDocument.SetGDoc(aNewDoc: xmlDocPtr);
  procedure _DestroyFlyingNodes;
  var
    i: integer;
    node: xmlNodePtr;
    p: pointer;
  begin
    if fFlyingNodes=nil then exit;
    for i:=fFlyingNodes.Count-1 downto 0 do begin
      p := fFlyingNodes[i];
      node := p;
      if (node^._private<>nil) then begin
        TLDomNode(node^._private).fMyNode := nil;
        node^._private := nil;
      end;
      case node^.type_ of
      XML_HTML_DOCUMENT_NODE,
      XML_DOCB_DOCUMENT_NODE,
      XML_DOCUMENT_NODE:
        DomAssert(false, -1, 'This node may never be flying');
      XML_ATTRIBUTE_NODE:
        begin
          xmlUnlinkNode(p);
          xmlFreeProp(p);
        end;
      XML_DTD_NODE:
        begin
          xmlUnlinkNode(p);
          xmlFreeDtd(p);
        end;
      else
        xmlUnlinkNode(p);
        xmlFreeNode(p);
      end;
    end;
  end;

  procedure _ReallocateFlyingNodes;
  var
    i: integer;
    node: xmlNodePtr;
  begin
    if fFlyingNodes=nil then exit;
    for i:=fFlyingNodes.Count-1 downto 0 do begin
      node := fFlyingNodes[i];
      case node^.type_ of
      XML_HTML_DOCUMENT_NODE,
      XML_DOCB_DOCUMENT_NODE,
      XML_DOCUMENT_NODE:
        DomAssert(false, -1, 'This node may never be flying');
      else
        node^.doc := aNewDoc;
      end;
    end;
  end;

var
  old: xmlDocPtr;
begin
  old := GetGDoc;
  if (aNewDoc<>nil) then begin
    _ReallocateFlyingNodes;
    aNewDoc^._private := self;
  end else begin
// for some strange reason, the following line makes troubles
		_DestroyFlyingNodes;
  end;
  fMyNode := xmlNodePtr(aNewDoc);
  if (old<>nil) then begin
    old^._private := nil;
    xmlFreeDoc(old);
  end;
end;

procedure TLDomDocument.set_nodeValue(const value: DomString);
begin
  // ignore: should have no effect at all
  // DomAssert(False, NO_MODIFICATION_ALLOWED_ERR);
end;

{ TLDomCharacterData }

procedure TLDomCharacterData.appendData(const data: DomString);
begin
  xmlNodeAddContent(fMyNode, PChar(UTF8Encode(data)));
end;

procedure TLDomCharacterData.deleteData(offset, count: Integer);
begin
  replaceData(offset, count, '');
end;

function TLDomCharacterData.get_length: Integer;
begin
  Result := Length(get_nodeValue);
end;

procedure TLDomCharacterData.insertData(offset: Integer; const data: DomString);
begin
  replaceData(offset, 0, PChar(UTF8Encode(data)));
end;

procedure TLDomCharacterData.replaceData(offset, count: Integer; const data: DomString);
var
  s1,s2,s: WideString;
begin
  s := get_nodeValue;
  s1 := Copy(s, 1, offset);
  s2 := Copy(s, offset + count+1, Length(s)-offset-count);
  set_nodeValue(s1 + data + s2);
end;

function TLDomCharacterData.substringData(offset, count: Integer): DomString;
begin
  Result := Copy(get_nodeValue, offset, count);
end;

{ TLDomText }

function TLDomText.splitText(offset: Integer): IDomText;
var
  v: DomString;
  rest: DomString;
  p: IDomNode;
begin
  v := get_nodeValue;
  rest := Copy(v, offset+1, Length(v)-offset);
  set_nodeValue(Copy(v, 1, offset));
  Result := get_ownerDocument.createTextNode(rest);
  p := get_parentNode;
  if p=nil then exit;
  // nodes must be kept as siblings
  Result := p.insertBefore(Result, get_nextSibling) as IDomText;
end;

{ TLDomEntity }

function TLDomEntity.get_nodeType: DomNodeType;
begin
  Result := ENTITY_NODE;
end;

function TLDomEntity.get_notationName: DomString;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

function TLDomEntity.get_publicId: DomString;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

function TLDomEntity.get_systemId: DomString;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

{ TLDomDocumentType }

function TLDomDocumentType.get_entities: IDomNamedNodeMap;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

function TLDomDocumentType.get_internalSubset: DomString;
var
  buff: xmlBufferPtr;
begin
  buff := xmlBufferCreate();
  xmlNodeDump(buff,nil,xmlNodePtr(GetGDocumentType),0,0);
  Result := UTF8Decode(buff^.content);
  xmlBufferFree(buff);
end;

function TLDomDocumentType.get_notations: IDomNamedNodeMap;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

function TLDomDocumentType.get_publicId: DomString;
begin
  Result := UTF8Decode(GetGDocumentType^.ExternalID);
end;

function TLDomDocumentType.get_systemId: DomString;
begin
  Result := UTF8Decode(GetGDocumentType^.SystemID);
end;

function TLDomDocumentType.GetGDocumentType: xmlDtdPtr;
begin
  Result := xmlDtdPtr(MyNode);
end;

function TLDomDocumentType.get_nodeType: DomNodeType;
begin
  Result := DOCUMENT_TYPE_NODE;
end;

{ TLDomNotation }

function TLDomNotation.get_publicId: DomString;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

function TLDomNotation.get_systemId: DomString;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

{ TLDomAttr }

function TLDomAttr.get_ownerElement: IDomElement;
begin
  Result := GetDOMObject(fMyNode^.parent) as IDomElement;
end;

function TLDomAttr.get_specified: Boolean;
begin
  //todo: implement it correctly
  Result := true;
  if fMyNode^.parent<>nil then
    DomAssert(false, NOT_SUPPORTED_ERR);
end;

{ TLDomAttributeMap }

constructor TLDomAttributeMap.Create(aOwnerElement: TLDomElement);
begin
  inherited Create;
  DomAssert(aOwnerElement<>nil, HIERARCHY_REQUEST_ERR, 'Attribute list must have an owner element');
  fOwnerElement := aOwnerElement;
  fOwnerElement.fFlyingNodes := self;
  fOwnerElement._AddRef; //as long as the map exists, its owner must exist too
end;

destructor TLDomAttributeMap.Destroy;
begin
  fOwnerElement.fFlyingNodes := nil;
  fOwnerElement._Release;
  fOwnerElement := nil;
  inherited destroy;
end;

function TLDomAttributeMap.get_item(index: Integer): IDomNode;
var
  node: xmlAttrPtr;
  cnt: integer;
begin
  DomAssert(index>=0, INDEX_SIZE_ERR);
  node := fOwnerElement.requestNodePtr^.properties;
  cnt := 0;
  while (cnt<index) do begin
    if (node=nil) then begin
      DomAssert(false, INDEX_SIZE_ERR, Format('Trying to access item %d [zero based] of %d items', [index, cnt]));
    end;
    Inc(cnt);
    node := node^.next;
  end;
  Result := GetDOMObject(node) as IDomNode;
end;

function TLDomAttributeMap.get_length: Integer;
var
  node: xmlAttrPtr;
begin
  Result := 0;
  node := fOwnerElement.MyNode^.properties;
  while (node<>nil) do begin
    Inc(Result);
    node := node^.next;
  end;
end;

function TLDomAttributeMap.getNamedItem(const name: DomString): IDomNode;
begin
  Result := fOwnerElement.getAttributeNode(name);
end;

function TLDomAttributeMap.getNamedItemNS(const namespaceURI, localName: DomString): IDomNode;
begin
  Result := fOwnerElement.getAttributeNodeNS(namespaceURI, localName);
end;

function TLDomAttributeMap.removeNamedItem(const name: DomString): IDomNode;
begin
  Result := fOwnerElement.removeAttributeNode(fOwnerElement.getAttributeNode(name) as IDomAttr);
end;

function TLDomAttributeMap.removeNamedItemNS(const namespaceURI, localName: DomString): IDomNode;
begin
  Result := fOwnerElement.removeAttributeNode(fOwnerElement.getAttributeNodeNS(namespaceURI, localName) as IDomAttr);
end;

function TLDomAttributeMap.setNamedItem(const newItem: IDomNode): IDomNode;
begin
  Result := fOwnerElement.setAttributeNodeNS(newItem as IDomAttr);
end;

function TLDomAttributeMap.setNamedItemNS(const newItem: IDomNode): IDomNode;
begin
  Result := fOwnerElement.setAttributeNodeNS(newItem as IDomAttr);
end;

{ TLDomElement }

constructor TLDomElement.Create(aLibXml2Node: pointer);
begin
  inherited Create(aLibXml2Node);
  Inc(GlbElementCount);
end;

destructor TLDomElement.Destroy;
begin
  Dec(GlbElementCount);
  inherited Destroy;
end;

function TLDomElement.get_attributes: IDomNamedNodeMap;
begin
  if (fFlyingNodes=nil) then begin
    TLDomAttributeMap.Create(self); // assigns fFlyingNodes
  end;
  Result := fFlyingNodes;
end;

function TLDomElement.getAttribute(const name: DomString): DomString;
var
  p: PxmlChar;
begin
  p := xmlGetProp(fMyNode,PChar(UTF8Encode(name)));
  Result := UTF8Decode(p);
  xmlFree(p);
end;

function TLDomElement.getAttributeNode(const name: DomString): IDomAttr;
var
  attr: xmlAttrPtr;
begin
  attr := xmlHasProp(fMyNode, PChar(UTF8Encode(name)));
  Result := GetDOMObject(attr) as IDomAttr;
end;

function TLDomElement.getAttributeNodeNS(const namespaceURI, localName: DomString): IDomAttr;
var
  attr: xmlAttrPtr;
begin
  attr := xmlHasNSProp(fMyNode, PChar(UTF8Encode(localName)), PChar(UTF8Encode(namespaceURI)));
  Result := GetDOMObject(attr) as IDomAttr;
end;

function TLDomElement.getAttributeNS(const namespaceURI, localName: DomString): DomString;
var
  p: PxmlChar;
begin
  p := xmlGetNSProp(fMyNode, PChar(UTF8Encode(localName)), PChar(UTF8Encode(namespaceURI)));
  Result := UTF8Decode(p);
  xmlFree(p);
end;

function TLDomElement.hasAttribute(const name: DomString): Boolean;
begin
  Result := xmlHasProp(fMyNode, PChar(UTF8Encode(name)))<>nil;
end;

function TLDomElement.hasAttributeNS(const namespaceURI, localName: DomString): Boolean;
begin
  Result := (nil<>xmlHasNsProp(fMyNode, PChar(UTF8Encode(localName)), PChar(UTF8Encode(namespaceURI))));
end;

procedure TLDomElement.removeAttribute(const name: DomString);
var
  attr: xmlAttrPtr;
begin
  attr := xmlHasProp(fMyNode, PChar(UTF8Encode(name)));
  if attr <> nil then begin
    xmlUnlinkNode(xmlNodePtr(attr));
    RegisterFlyingNode(xmlNodePtr(attr));
  end;
end;

function TLDomElement.removeAttributeNode(const oldAttr: IDomAttr): IDomAttr;
var
  attr: xmlAttrPtr;
begin
  Result := oldAttr;
  if oldAttr=nil then exit;
  attr := xmlAttrPtr(GetGNode(oldAttr));
  xmlUnlinkNode(xmlNodePtr(attr));
  RegisterFlyingNode(xmlNodePtr(attr));
end;

procedure TLDomElement.removeAttributeNS(const namespaceURI, localName: DomString);
var
  attr: xmlAttrPtr;
begin
  attr := xmlHasNsProp(fMyNode, PChar(UTF8Encode(localName)), PChar(UTF8Encode(namespaceURI)));
  if (attr <> nil) then begin
    xmlUnlinkNode(xmlNodePtr(attr));
    RegisterFlyingNode(xmlNodePtr(attr));
  end;
end;

procedure TLDomElement.setAttribute(const name, value: DomString);
begin
  xmlSetProp(fMyNode, PChar(UTF8Encode(name)), PChar(UTF8Encode(value)));
end;

function TLDomElement.setAttributeNodeNS(const newAttr: IDomAttr): IDomAttr;
begin
  if newAttr<>nil then begin
    Result := GetDomObject(xmlSetPropNode(fMyNode, xmlAttrPtr(GetGNode(newAttr)))) as IDomAttr;
  end else begin
    Result := nil;
  end;
end;

procedure TLDomElement.setAttributeNS(const namespaceURI, qualifiedName, value: DomString);
var
  uprefix, ulocal: String;
  ns: xmlNsPtr;
begin
  SplitQName(UTF8Encode(qualifiedName), uprefix, ulocal);
  ns := xmlNewNs(fMyNode, PChar(UTF8Encode(namespaceURI)), PChar(uprefix));
  xmlSetNSProp(fMyNode, ns, PChar(ulocal), PChar(UTF8Encode(value)));
end;

{ TLDomImplementation }

constructor TLDomImplementation.Create(aDocumentClass: TLDomDocumentClass);
begin
  inherited Create;
  fDocumentClass := aDocumentClass;
end;

destructor TLDomImplementation.Destroy;
begin
  inherited Destroy;
end;

function TLDomImplementation.createDocumentType(const qualifiedName, publicId, systemId: DomString): IDomDocumentType;
var
  dtd:xmlDtdPtr;
  upubid, usysid: String;
  uprefix, ulocal: String;
begin
  SplitQName(UTF8Encode(qualifiedName), uprefix, ulocal);
  checkName(uprefix, ulocal);
  upubid := UTF8Encode(publicId);
  usysid := UTF8Encode(systemId);
  dtd := xmlCreateIntSubSet(nil, PChar(UTF8Encode(qualifiedName)), PChar(upubid), PChar(usysid));
  Result := GetDomObject(dtd) as IDomDocumentType;
end;

function TLDomImplementation.createDocument(const namespaceURI, qualifiedName: DomString; doctype: IDomDocumentType): IDomDocument;
var
  doc: TLDomDocument;
begin
  doc := fDocumentClass.Create(nil);
  doc.fMyImplementation := self;
  Result := doc;
  if (doctype<>nil) then begin
    DomAssert(doctype.ownerDocument=nil, WRONG_DOCUMENT_ERR, 'doctype already belongs to another document');
    Result.appendChild(doctype);
  end;
  // prepare documentElement if necessary
  if (qualifiedName<>'') then begin
    Result.appendChild(Result.createElementNS(namespaceURI, qualifiedName));
  end else begin
    DomAssert(namespaceURI='', NAMESPACE_ERR, 'cannot create documentElement in namespace "'+namespaceURI+'", because qualifiedName was not specified.');
  end;
end;

function TLDomImplementation.hasFeature(const feature, version: DomString): Boolean;
begin
  Result := featureIsSupported(feature, version, IMPLEMENTATION_FEATURES);
end;

function TLDomImplementation.load(const url: DomString): IDomDocument;
var
  doc: TLDomDocument;
begin
  doc := fDocumentClass.Create(nil);
  doc.fMyImplementation := self;
  doc.load(url);
  Result := doc;
end;

function TLDomImplementation.parse(const xml: DomString): IDomDocument;
var
  doc: TLDomDocument;
begin
  doc := fDocumentClass.Create(nil);
  doc.fMyImplementation := self;
  doc.parse(xml);
  Result := doc;
end;

{ TLDomDocumentBuilder }

constructor TLDomDocumentBuilder.Create(aImplementationClass: TLDomImplementationClass);
begin
  inherited Create;
  fImplementationClass := aImplementationClass;
end;

destructor TLDOMDocumentBuilder.Destroy;
begin
  if (fImplInstance<>nil) then begin
    fImplInstance._Release;
    fImplInstance := nil;
  end;
  inherited Destroy;
end;

function TLDomDocumentBuilder.GetImplInstance: TLDomImplementation;
begin
  // on-demand creation
  if (fImplInstance=nil) then begin
    fImplInstance := fImplementationClass.Create(TLDomDocumentClass(GlbNodeClasses[XML_DOCUMENT_NODE])); //???
    fImplInstance._AddRef;
  end;
  Result := fImplInstance;
end;

function TLDomDocumentBuilder.Get_DomImplementation : IDomImplementation;
begin
  Result := GetImplInstance;
end;

function TLDomDocumentBuilder.Get_IsNamespaceAware : Boolean;
begin
  Result := True;
end;

function TLDomDocumentBuilder.Get_IsValidating : Boolean;
begin
  Result := True;
end;

function TLDomDocumentBuilder.Get_HasAbsoluteURLSupport : Boolean;
begin
  Result := False;
end;

function TLDomDocumentBuilder.Get_HasAsyncSupport : Boolean;
begin
  Result := False;
end;

function TLDomDocumentBuilder.load(const url: DomString): IDomDocument;
begin
  Result := GetImplInstance.load(url);
end;

function TLDomDocumentBuilder.newDocument: IDomDocument;
begin
  Result := GetImplInstance.createDocument('', '', nil);
end;

function TLDomDocumentBuilder.parse(const xml: DomString): IDomDocument;
begin
  Result := GetImplInstance.parse(xml);
end;

{ TLDomDocumentBuilderFactory }

constructor TLDomDocumentBuilderFactory.Create(aVendorId: DomString; aDomBuilderClass: TLDomDocumentBuilderClass);
begin
  inherited Create;
  fVendorId := aVendorId;
  fDomBuilderClass := aDomBuilderClass;
end;

function TLDomDocumentBuilderFactory.NewDocumentBuilder : IDomDocumentBuilder;
begin
  Result := fDomBuilderClass.Create(TLDomImplementation{todo: default class???});
end;

function TLDomDocumentBuilderFactory.Get_VendorID : DomString;
begin
  Result := fVendorId;
end;

{ TLDomEntityReference }

function TLDomEntityReference.get_firstChild: IDomNode;
begin
  Result := GetDOMObject(fMyNode^.children^.children) as IDomNode;
end;

function TLDomEntityReference.get_lastChild: IDomNode;
begin
//TODO: check - this sometimes returns null when firstChild is not null.
  Result := GetDOMObject(fMyNode^.children^.last) as IDomNode;
end;

function TLDomEntityReference.get_nodeValue: DomString;
var
  firstChild: xmlEntityPtr;
begin
  firstChild := xmlEntityPtr(fMyNode^.children);
  if (firstChild = nil) then begin
    Result := '';
  end else begin
    Result := UTF8Decode(firstChild^.content);
  end;
end;

function TLDomEntityReference.get_ChildNodes: IDomNodeList;
begin
  if (fChildNodes=nil) then begin
    TLDomEntRefChildNodes.Create(Self); // assigns fChildNodes
  end;
  Result := fChildNodes;
end;

initialization
finalization
end.

