const
  (**
   * BASE_BUFFER_SIZE:
   *
   * default buffer size 4096.
   *)
  BASE_BUFFER_SIZE = 4096;
  (**
   * xmlBufferAllocationScheme:
   *
   * A buffer allocation scheme can be defined to either match exactly the
   * need or double it's allocated size each time it is found too small.
   *)
type
  xmlBufferAllocationScheme = (
    XML_BUFFER_ALLOC_DOUBLEIT,          (* double each time one need to grow  *)
    XML_BUFFER_ALLOC_EXACT,             (* grow only to the minimal size  *)
    XML_BUFFER_ALLOC_IMMUTABLE,         (* immutable buffer  *)
    XML_BUFFER_ALLOC_IO,                (* special allocation scheme used for I/O  *)
    XML_BUFFER_ALLOC_HYBRID,            (* exact up to a threshold, and doubleit thereafter  *)
    XML_BUFFER_ALLOC_BOUNDED            (* limit the upper size of the buffer  *)
  );

  (**
   * xmlBuffer:
   *
   * A buffer structure, this old construct is limited to 2GB and
   * is being deprecated, use API with xmlBuf instead
   *)
  xmlBufferPtr = ^xmlBuffer;
  xmlBuffer = record
    content: PxmlChar; (* The buffer content UTF8  *)
    use: DWORD; (* The buffer size used  *)
    size: DWORD; (* The buffer size  *)
    alloc: xmlBufferAllocationScheme; (* The realloc method  *)
    contentIO : PxmlChar;                      (* in IO mode we may have a different base  *)
  end;

  (**
   * xmlBuf:
   *
   * A buffer structure, new one, the actual structure internals are not public
   *)
  (**
   * xmlBufPtr:
   *
   * A Pointer to a buffer structure, the actual structure internals are not
   * public
   *)
    xmlBufPtr = ^xmlBuf;
    xmlBuf = record end;
  (**
   * A few public routines for xmlBuf. As those are expected to be used
   * mostly internally the bulk of the routines are internal in buf.h
   *)
function  xmlBufContent(buf: xmlBuf): PPxmlChar; cdecl; external LIBXML2_SO;
function  xmlBufEnd(buf: xmlBufPtr): PxmlChar; cdecl; external LIBXML2_SO;
function  xmlBufUse(buf: xmlBufPtr): size_t; cdecl; external LIBXML2_SO;
function  xmlBufShrink(buf: xmlBufPtr; len: size_t): size_t; cdecl; external LIBXML2_SO;
  (**
   * LIBXML2_NEW_BUFFER:
   *
   * Macro used to express that the API use the new buffers for
   * xmlParserInputBuffer and xmlOutputBuffer. The change was
   * introduced in 2.9.0.
   *)
{$define LIBXML2_NEW_BUFFER}