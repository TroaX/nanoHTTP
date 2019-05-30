; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
; nanoHTTP - Tiny embedded Webserver
; By TroaX aká reVerB - 2019
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;

; -----------------------------------------------------------------------------------------;
; Module-Declaration
; -----------------------------------------------------------------------------------------;
DeclareModule nanoHTTP
  Define.u Port = 12345
  Define.s IPMask = "127.0.0.1"
  Define.s DefaultFile = "index.html"
  #NHTTP_DIRTYPE_FILESYSTEM = 100
  #NHTTP_DIRTYPE_ZIP = 101
  #NHTTP_DIRTYPE_NONE = 102
  Declare.b StartServer(DType.a = #NHTTP_DIRTYPE_FILESYSTEM, DPath.s = "webdir/")
  Declare SendResponseString(ResponseString.s, MimeType.s)
  Declare SendResponseData(*Adress, DataSize.i, MimeType.s)
  Declare SetHeader(Field.s, Value.s)
  Declare SetDynamicApp(Route.s, Callback.i)
  Declare ParseHTTPContent(ContentString.s, Map TargetMap())
EndDeclareModule

; -----------------------------------------------------------------------------------------;
; Module-Implementation
; -----------------------------------------------------------------------------------------;
Module nanoHTTP
  UseMD5Fingerprint()
  
;============================================================================================ Mime-Type Map
  NewMap HTTPFileTypes.s()
  HTTPFileTypes("jar") = "application/java-archive"
  HTTPFileTypes("json") = "application/json"
  HTTPFileTypes("pdf") = "application/pdf"
  HTTPFileTypes("crl") = "application/pkcs-crl"
  HTTPFileTypes("ps") = "application/postscript"
  HTTPFileTypes("ai") = "application/postscript"
  HTTPFileTypes("kml") = "application/vnd.google-earth.kml+xml"
  HTTPFileTypes("kmz") = "application/vnd.google-earth.kmz"
  HTTPFileTypes("xml") = "application/xml"
  HTTPFileTypes("xsl") = "application/xml"
  HTTPFileTypes("bin") = "application/x-binary"
  HTTPFileTypes("bz2") = "application/x-bzip2"
  HTTPFileTypes("deb") = "application/x-debian-package"
  HTTPFileTypes("dvi") = "application/x-dvi"
  HTTPFileTypes("gz") = "application/x-gzip"
  HTTPFileTypes("class") = "application/x-java-vm"
  HTTPFileTypes("latex") = "application/x-latex"
  HTTPFileTypes("com") = "application/x-msdos-program"
  HTTPFileTypes("exe") = "application/x-msdos-program"
  HTTPFileTypes("bat") = "application/x-msdos-program"
  HTTPFileTypes("rpm") = "application/x-redhat-packet-manager"
  HTTPFileTypes("swf") = "application/x-shockwave-flash"
  HTTPFileTypes("sh") = "application/x-sh"
  HTTPFileTypes("tgz") = "application/x-tar"
  HTTPFileTypes("bak") = "application/x-trash"
  HTTPFileTypes("crt") = "application/x-x509-ca-cert"
  HTTPFileTypes("cer") = "application/x-x509-ca-cert"
  HTTPFileTypes("zip") = "application/zip"
  HTTPFileTypes("xls") = "application/excel"
  HTTPFileTypes("xlb") = "application/excel"
  HTTPFileTypes("xlc") = "application/excel"
  HTTPFileTypes("mdb") = "application/msaccess"
  HTTPFileTypes("doc") = "application/msword"
  HTTPFileTypes("ppt") = "application/powerpoint"
  HTTPFileTypes("pps") = "application/powerpoint"
  HTTPFileTypes("pptx") = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
  HTTPFileTypes("xlsx") = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  HTTPFileTypes("docx") = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  HTTPFileTypes("odg") = "application/vnd.oasis.opendocument.graphics"
  HTTPFileTypes("odp") = "application/vnd.oasis.opendocument.presentation"
  HTTPFileTypes("ods") = "application/vnd.oasis.opendocument.spreadsheet"
  HTTPFileTypes("odt") = "application/vnd.oasis.opendocument.text"
  HTTPFileTypes("au") = "audio/basic"
  HTTPFileTypes("mid") = "audio/midi"
  HTTPFileTypes("midi") = "audio/midi"
  HTTPFileTypes("m4a") = "audio/mp4a-latm"
  HTTPFileTypes("m4b") = "audio/mp4a-latm"
  HTTPFileTypes("mp3") = "audio/mpeg"
  HTTPFileTypes("ogg") = "audio/ogg"
  HTTPFileTypes("aac") = "audio/x-aac"
  HTTPFileTypes("wav") = "audio/x-wav"
  HTTPFileTypes("bmp") = "image/bmp"
  HTTPFileTypes("gif") = "image/gif"
  HTTPFileTypes("jpg") = "image/jpeg"
  HTTPFileTypes("jpeg") = "image/jpeg"
  HTTPFileTypes("pcx") = "image/pcx"
  HTTPFileTypes("png") = "image/png"
  HTTPFileTypes("svg") = "image/svg+xml"
  HTTPFileTypes("tiff") = "image/tiff"
  HTTPFileTypes("nol") = "image/vnd.nok-oplogo-color"
  HTTPFileTypes("ico") = "image/x-icon"
  HTTPFileTypes("cache") = "text/cache-manifest"
  HTTPFileTypes("ics") = "text/calendar"
  HTTPFileTypes("css") = "text/css"
  HTTPFileTypes("csv") = "text/csv"
  HTTPFileTypes("htm") = "text/html"
  HTTPFileTypes("html") = "text/html"
  HTTPFileTypes("js") = "text/javascript"
  HTTPFileTypes("asc") = "text/plain"
  HTTPFileTypes("asm") = "text/plain"
  HTTPFileTypes("txt") = "text/plain"
  HTTPFileTypes("text") = "text/plain"
  HTTPFileTypes("diff") = "text/plain"
  HTTPFileTypes("java") = "text/plain"
  HTTPFileTypes("rtf") = "text/richtext"
  HTTPFileTypes("wml") = "text/vnd.wap.wml"
  HTTPFileTypes("c") = "text/x-c"
  HTTPFileTypes("c++") = "text/x-c++src"
  HTTPFileTypes("cpp") = "text/x-c++src"
  HTTPFileTypes("cxx") = "text/x-c++src"
  HTTPFileTypes("p") = "text/x-pascal"
  HTTPFileTypes("tcl") = "text/x-tcl"
  HTTPFileTypes("tex") = "text/x-tex"
  HTTPFileTypes("ltx") = "text/x-tex"
  HTTPFileTypes("sty") = "text/x-tex"
  HTTPFileTypes("3gp") = "video/3gpp"
  HTTPFileTypes("3gpp") = "video/3gpp"
  HTTPFileTypes("avi") = "video/avi"
  HTTPFileTypes("mkv") = "video/x-matroska"
  HTTPFileTypes("mpeg") = "video/mpeg"
  HTTPFileTypes("mpg") = "video/mpeg"
  HTTPFileTypes("mpe") = "video/mpeg"
  HTTPFileTypes("mp4") = "video/mp4"
  HTTPFileTypes("qt") = "video/quicktime"
  HTTPFileTypes("flv") = "video/flv"
  HTTPFileTypes("asf") = "video/x-ms-asf"
  HTTPFileTypes("asr") = "video/x-ms-asf"
  HTTPFileTypes("flr") = "x-world/x-vrml"
  HTTPFileTypes("vrm") = "x-world/x-vrml"
  HTTPFileTypes("vrml") = "x-world/x-vrml"
  HTTPFileTypes("wrl") = "x-world/x-vrml"
  HTTPFileTypes("wrz") = "x-world/x-vrml"
  HTTPFileTypes("xaf") = "x-world/x-vrml"
  
;============================================================================================ Constants, global variables
  #NHTTP_PACK_HANDLE = 1000
  #NHTTP_SERVER_HANDLE = 1001
  
  NewMap ResponseHeader.s()
  Global ClientID.i, Sended.b = #False
  
;============================================================================================ Callback-Prototype
  Prototype.i DynamicApp(Map hMap.s(), ContentString.s)
  NewMap Dynamics.i()
  
; -----------------------------------------------------------------------------------------;
; HTTP Content parser
; -----------------------------------------------------------------------------------------;
  Procedure ParseHTTPContent(ContentString.s, Map TargetMap.s())
    Define.i LoopCount, Count
    Define.s TempLine
    LoopCount = CountString(ContentString, "&")
    If LoopCount
      For Count = 1 To LoopCount
        TempLine = StringField(ContentString, Count, "&")
        TargetMap(URLDecoder(StringField(TempLine,1,"="), #PB_UTF8)) = URLDecoder(StringField(TempLine,2,"="), #PB_UTF8)
      Next
    Else
      If CountString(ContentString, "=")
        TargetMap(URLDecoder(StringField(ContentString,1,"="), #PB_UTF8)) = URLDecoder(StringField(ContentString,2,"="), #PB_UTF8)
      EndIf
    EndIf
  EndProcedure
  
; -----------------------------------------------------------------------------------------;
; PUBLIC: Headerfield Setup
; -----------------------------------------------------------------------------------------;
  Procedure SetHeader(Field.s, Value.s)
    Shared ResponseHeader()
    ResponseHeader(Field) = Value
  EndProcedure
  
; -----------------------------------------------------------------------------------------;
; PUBLIC: Set a dynamic Application
; -----------------------------------------------------------------------------------------;
  Procedure SetDynamicApp(Route.s, Callback.i)
    Define.s tStr
    Shared Dynamics()
    tStr = Mid(Route,1,1)
    If tStr = "/" Or tStr = "\"
      tStr = Mid(Route, 2)
      Dynamics(StringFingerprint(tStr, #PB_Cipher_MD5)) = Callback
    Else
      Dynamics(StringFingerprint(Route, #PB_Cipher_MD5)) = Callback
    EndIf
  EndProcedure
  
; -----------------------------------------------------------------------------------------;
; PRIVATE: Send the Responseheader
; -----------------------------------------------------------------------------------------;
  Procedure SendResponseHeader()
    Shared ResponseHeader()
    Define HeaderString.s = ResponseHeader("Protocol") + " " + ResponseHeader("Status") + " " + ResponseHeader("StatusMessage") + #CRLF$
    Define StrSize.i
    DeleteMapElement(ResponseHeader(),"Protocol")
    DeleteMapElement(ResponseHeader(),"Status")
    DeleteMapElement(ResponseHeader(),"StatusMessage")
    ForEach ResponseHeader()
      HeaderString + MapKey(ResponseHeader()) + ": " +  ResponseHeader() + #CRLF$
    Next
    HeaderString + #CRLF$
    StrSize = StringByteLength(HeaderString, #PB_UTF8)
    *HeaderBuffer = AllocateMemory(StrSize + 1)
    PokeS(*HeaderBuffer, HeaderString, StrSize, #PB_UTF8)
    SendNetworkData(ClientID, *HeaderBuffer, StrSize)
    FreeMemory(*HeaderBuffer)
  EndProcedure
  
; -----------------------------------------------------------------------------------------;
; PUBLIC: Send Response-Data
; -----------------------------------------------------------------------------------------;
  Procedure SendResponseData(Adress.i, DataSize.i, MimeType.s)
    Shared HTTPFileTypes()
    Shared ResponseHeader()
    If Not Sended
      ResponseHeader("Content-Length") = Str(DataSize)
      If FindMapElement(HTTPFileTypes(),MimeType)
        ResponseHeader("Content-Type") = HTTPFileTypes(MimeType)
      Else
        ResponseHeader("Content-Type") = "application/octet-stream"
      EndIf
      SendResponseHeader()
      SendNetworkData(ClientID, Adress, DataSize)
      Sended = #True
    EndIf
  EndProcedure
  
; -----------------------------------------------------------------------------------------;
; PUBLIC: Send Response-String
; -----------------------------------------------------------------------------------------;
  Procedure SendResponseString(ResponseString.s, MimeType.s)
    Shared HTTPFileTypes()
    Shared ResponseHeader()
    If Not Sended
      If FindMapElement(HTTPFileTypes(),MimeType)
        ResponseHeader("Content-Type") = HTTPFileTypes(MimeType)
      Else
        ResponseHeader("Content-Type") = "application/octet-stream"
      EndIf
      SendResponseHeader()
      Define StrSize.i
      StrSize = StringByteLength(ResponseString, #PB_UTF8)
      If StrSize
        *ContentBuffer = AllocateMemory(StrSize + 1)
        PokeS(*ContentBuffer, ResponseString, StrSize, #PB_UTF8)
        SendNetworkData(ClientID, *ContentBuffer, StrSize)
        FreeMemory(*ContentBuffer)
      EndIf
      Sended = #True
    EndIf
  EndProcedure
  
; -----------------------------------------------------------------------------------------;
; PUBLIC: The Server THREADBLOCKED!
; -----------------------------------------------------------------------------------------;
  Procedure.b StartServer(DType.a = #NHTTP_DIRTYPE_FILESYSTEM, DPath.s = "webdir/")
    
;============================================================================================ Variables, Structs, Zip-Map
    Shared ResponseHeader()
    Shared Dynamics()
    NewMap HeaderMap.s()
    Define.i BufferStep, ReceivedBytes, BufferOffset, DataOffset, ContentLength, HeaderLines, ServerEvent, FileHandle, FileSize
    Define.s ContentType, CurrentHeaderLine, HTTPHeaderString, TempString, RouteHash, ContentString
    BufferStep = 10000
    BufferLen = 0
    ReceivedBytes = 0
    
    Structure ZipStruct
      Filename.s
      Filesize.i
    EndStructure
    
    NewMap ZipFile.ZipStruct()
    
;============================================================================================ Prepare Zip-Archive
    If DType = #NHTTP_DIRTYPE_ZIP
      UseZipPacker()
      If OpenPack(#NHTTP_PACK_HANDLE, DPath, #PB_PackerPlugin_Zip)
        If ExaminePack(#NHTTP_PACK_HANDLE)
          While NextPackEntry(#NHTTP_PACK_HANDLE)
            If PackEntryType(#NHTTP_PACK_HANDLE) = #PB_Packer_File
              TempString = StringFingerprint(PackEntryName(#NHTTP_PACK_HANDLE),#PB_Cipher_MD5)
              ZipFile(TempString)\Filename = PackEntryName(#NHTTP_PACK_HANDLE)
              ZipFile(TempString)\Filesize = PackEntrySize(#NHTTP_PACK_HANDLE)
            EndIf
          Wend
        Else
          ProcedureReturn #False
        EndIf
      Else
        ProcedureReturn #False
      EndIf  
    EndIf
    
;============================================================================================ Init Server
    If CreateNetworkServer(#NHTTP_SERVER_HANDLE, nanoHTTP::Port, #PB_Network_TCP,nanoHTTP::IPMask)
      Repeat
        ServerEvent = NetworkServerEvent()
        If ServerEvent = #PB_NetworkEvent_Data
          ClientID = EventClient()
          
;============================================================================================ Request-Data
          *Buffer = AllocateMemory(BufferStep)
          BufferOffset = *Buffer
          Repeat
            ReceivedBytes = ReceiveNetworkData(ClientID, BufferOffset, BufferStep)
            If ReceivedBytes = BufferStep
              BufferLen + ReceivedBytes
              *Buffer = ReAllocateMemory(*Buffer, BufferLen + BufferStep)
              BufferOffset = *Buffer + BufferLen
            Else
              BufferLen + ReceivedBytes
            EndIf
          Until ReceivedBytes < BufferStep
          
;============================================================================================ Split Header from Content
          If BufferLen < 30000
            HTTPHeaderString = PeekS(*Buffer, BufferLen, #PB_UTF8)
          Else
            HTTPHeaderString = PeekS(*Buffer, 30000, #PB_UTF8)
          EndIf
          If CountString(HTTPHeaderString,#CRLF$+#CRLF$)
            HTTPHeaderString = StringField(HTTPHeaderString,1,#CRLF$+#CRLF$)
          EndIf
          
;============================================================================================ Parse Header
          HeaderLines = CountString(HTTPHeaderString,#CRLF$)
          If HeaderLines
            CurrentHeaderLine = StringField(HTTPHeaderString,1,#CRLF$)
            If CountString(CurrentHeaderLine," ")
              HeaderMap("Method") = StringField(CurrentHeaderLine,1," ")
              HeaderMap("File") = StringField(CurrentHeaderLine,2," ")
              HeaderMap("Protocol") = StringField(CurrentHeaderLine,3," ")
              If CountString(HeaderMap("File"), "?")
                HeaderMap("Query-String") = StringField(HeaderMap("File"),2,"?")
                HeaderMap("File") = StringField(HeaderMap("File"),1,"?")
              Else
                HeaderMap("Query-String") = ""
              EndIf
              For CountLines = 2 To HeaderLines
                CurrentHeaderLine = StringField(HTTPHeaderString,CountLines,#CRLF$)
                HeaderMap(Trim(StringField(CurrentHeaderLine,1,":"))) = Trim(StringField(CurrentHeaderLine,2,":"))
              Next
            Else
              ResponseHeader("Protocol") = "HTTP/1.1"
              ResponseHeader("Status") = "400"
              ResponseHeader("StatusMessage") = "Bad Request"
              ResponseHeader("X-UA-Compatible") = "IE=edge"
              SendResponseString("Bad Request", "html")
              CloseNetworkConnection(ClientID)
              Break
            EndIf
          Else
            ResponseHeader("Protocol") = "HTTP/1.1"
            ResponseHeader("Status") = "400"
            ResponseHeader("StatusMessage") = "Bad Request"
            ResponseHeader("X-UA-Compatible") = "IE=edge"
            SendResponseString("Bad Request", "html")
            CloseNetworkConnection(ClientID)
            Break        
          EndIf
          
;============================================================================================ Convert Bytedata to String
          If FindMapElement(HeaderMap(),"Content-Length") And (HeaderMap("Method") = "POST" Or HeaderMap("Method") = "Put")
            ContentLength = Val(HeaderMap("Content-Length"))
            If ContentLength > 0
              DataOffset = *Buffer + (BufferLen - ContentLength)
              ContentString = PeekS(DataOffset, ContentLength, #PB_UTF8)
              DataOffset = 0
              BufferLen = 0
              FreeMemory(*Buffer)
            Else
              ContentString = ""
              DataOffset = 0
              BufferLen = 0
              FreeMemory(*Buffer)
            EndIf
          Else
            ContentString = ""
            DataOffset = 0
            BufferLen = 0
            FreeMemory(*Buffer)
          EndIf
          
;============================================================================================ Detect requested URL
          ResponseHeader("Protocol") = "HTTP/1.1"
          ResponseHeader("Status") = "200"
          ResponseHeader("StatusMessage") = "OK"
          ResponseHeader("X-UA-Compatible") = "IE=edge"
          
          RouteHash = StringFingerprint(Mid(HeaderMap("File"),2), #PB_Cipher_MD5)
          
;============================================================================================ Execute dynamic App
          If FindMapElement(Dynamics(), RouteHash)
            Define.DynamicApp App = Dynamics(RouteHash)
            App(HeaderMap(), ContentString)
            CloseNetworkConnection(ClientID)
            Sended = #False
          Else
            Select DType
                
;============================================================================================ Send a File from Filesystem
              Case #NHTTP_DIRTYPE_FILESYSTEM
                TempString = GetExtensionPart(HeaderMap("File"))
                If TempString = ""
                  TempString = DPath + "/" + HeaderMap("File") + nanoHTTP::DefaultFile
                Else
                  TempString = DPath + "/" + HeaderMap("File")
                EndIf
                CompilerIf #PB_Compiler_OS = #PB_OS_Windows
                  ReplaceString(TempString,"/","\",#PB_String_InPlace)
                  TempString = ReplaceString(TempString,"\\","\")
                  TempString = ReplaceString(TempString,"\\","\")
                CompilerElse
                  ReplaceString(TempString,"\","/",#PB_String_InPlace)
                  TempString = ReplaceString(TempString,"//","/")
                  TempString = ReplaceString(TempString,"//","/")
                CompilerEndIf
                FileHandle = ReadFile(#PB_Any, TempString, #PB_File_SharedRead | #PB_File_SharedWrite)
                If FileHandle
                  FileSize = Lof(FileHandle)
                  *FileBuffer = AllocateMemory(FileSize)
                  ReadData(FileHandle,*FileBuffer,FileSize)
                  SendResponseData(*FileBuffer,FileSize,GetExtensionPart(TempString))
                  FreeMemory(*FileBuffer)
                  CloseNetworkConnection(ClientID)
                  Sended = #False
                Else
                  ResponseHeader("Protocol") = "HTTP/1.1"
                  ResponseHeader("Status") = "404"
                  ResponseHeader("StatusMessage") = "File not found"
                  ResponseHeader("X-UA-Compatible") = "IE=edge"
                  SendResponseString("File not found", "html")
                  CloseNetworkConnection(ClientID)
                  Sended = #False
                EndIf
                
;============================================================================================ Send a File from Archive
              Case #NHTTP_DIRTYPE_ZIP
                TempString = Mid(HeaderMap("File"),2)
                TempString = GetExtensionPart(HeaderMap("File"))
                If TempString = ""
                  TempString = Mid(HeaderMap("File"),2) + nanoHTTP::DefaultFile
                Else
                  TempString = Mid(HeaderMap("File"),2)
                EndIf
                RouteHash = StringFingerprint(TempString, #PB_Cipher_MD5)
                If FindMapElement(ZipFile(),RouteHash)
                  FileSize = ZipFile(RouteHash)\Filesize
                  *FileBuffer = AllocateMemory(FileSize)
                  UncompressPackMemory(#NHTTP_PACK_HANDLE,*FileBuffer,FileSize,TempString)
                  SendResponseData(*FileBuffer,FileSize,GetExtensionPart(TempString))
                  FreeMemory(*FileBuffer)
                  CloseNetworkConnection(ClientID)
                  Sended = #False
                Else
                  ResponseHeader("Protocol") = "HTTP/1.1"
                  ResponseHeader("Status") = "404"
                  ResponseHeader("StatusMessage") = "File not found"
                  ResponseHeader("X-UA-Compatible") = "IE=edge"
                  SendResponseString("File not found", "html")
                  CloseNetworkConnection(ClientID)
                  Sended = #False
                EndIf
              Case #NHTTP_DIRTYPE_NONE
                ResponseHeader("Protocol") = "HTTP/1.1"
                ResponseHeader("Status") = "404"
                ResponseHeader("StatusMessage") = "File not found"
                ResponseHeader("X-UA-Compatible") = "IE=edge"
                SendResponseString("File not found", "html")
                CloseNetworkConnection(ClientID)
                Sended = #False
            EndSelect
            
;============================================================================================ Reset Maps
            ClearMap(ResponseHeader())
            ClearMap(HeaderMap())
          EndIf
        EndIf
        
;============================================================================================ A Delay for our Poor CPU
        Delay(2)
      ForEver
      CloseNetworkServer(#NHTTP_SERVER_HANDLE) 
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
EndModule

OpenConsole()
InitNetwork()
nanoHTTP::StartServer(nanoHTTP::#NHTTP_DIRTYPE_FILESYSTEM,"C:\Users\droen\Desktop\nanoERP\UI")
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 418
; FirstLine = 394
; Folding = --
; EnableXP
; EnablePurifier
; Watchlist = nanoHTTP::SendResponseString()>ResponseString