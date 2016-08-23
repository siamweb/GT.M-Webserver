WWWres;


Send(head,body)

 Write head_$Char(13,10)
 Write body

 Quit


SendFile(filename,head)

 New io Set io=$IO
 New max Set max=1024*1024 ; the maximum GT.M string size

 Use io

 Write head_$Char(13,10)

 Open filename:(READONLY:FIXED:WRAP:CHSET="M")

 For  Use filename Read line#max Quit:$ZEOF  Use io:NOWRAP Write line
 
 Close filename
	
 Quit


Error(sockid,state)

 Use ^WWW("sockdev"):SOCKET=sockid

 Do Log^WWW("Error state="_state_", connection="_sockid)

 Set head=^WWW("http","state",state)_$Char(13,10)
 Set head=head_^WWW("http","files","mime","html")_$Char(13,10)

 If $Data(^WWW("http","state",state,"head"))'=0 Do
 . Set head=head_^WWW("http","state",state,"head")_$Char(13,10)

 Set send=1

 If $Data(^WWW("http","state",state,"page"))'=0 Do
 . Set path=^WWW("localpath")_^WWW("http","state",state,"page")
 . Set size=$$FileSize(path)
 . If size'=-1 Do
 . . Use ^WWW("sockdev"):SOCKET=sockid
 . . Set head=head_"Content-Length: "_size_$Char(13,10)
 . . Do SendFile(path,head) 
 . . Set send=0

 If send=1 Write head

 Do Close^WWWhttp(sockid)

 Quit


Routine(path,head,data)

 Do @^WWW("http","protocol",path,"routine")

 Quit


Create(varparam,path,data)

 Set @varparam=data

 Set ^WWWHTTPDATA(path,"length")=$Length(body)
 Set ^WWWHTTPDATA(path,"date")=$Zdate($HOROLOG,"DAY, DD MON YEAR 24:60:SS")
 Set ^WWWHTTPDATA(path,"rev")=1
 Set ^WWWHTTPDATA(path,"auth")=0
 
 If $Data(REQUEST("head","Content-Type"))'=0 Do
 . Set type=$Piece(REQUEST("head","Content-Type"),"/",2)
 . If $Data(^WWW("http","files","mime",type))=0 Set type="plain"
 . Set ^WWWHTTPDATA(path,"type")=type
 
 If $Data(REQUEST("head","X-Authenticate"))'=0 Do
 . Set ^WWWHTTPDATA(path,"auth")=REQUEST("head","X-Authenticate")

 Set head=^WWW("http","state",201)_$Char(13,10)
 Set head=head_"Server: "_^WWW("server")_$Char(13,10)
 Set head=head_"Date: "_^WWWHTTPDATA(path,"date")_$Char(13,10)
 Set head=head_"X-Revision: "_^WWWHTTPDATA(path,"rev")_$Char(13,10)
 Set head=head_"X-Authenticate: "_^WWWHTTPDATA(path,"auth")_$Char(13,10)

 If $Data(^WWWHTTPDATA(path,"type"))'=0 Do
 . Set head=head_^WWW("http","files","mime",^WWWHTTPDATA(path,"type"))_$Char(13,10)

 Set body="Created! URL: """_path_""""

 Set head=head_"Content-Length: "_$Length(body)_$Char(13,10)

 Do Send(head,body)

 Do Log^WWW(varparam_" "_body)

 Quit


Update(sockid,varparam,path,data)

 If $Data(REQUEST("head","X-Revision"))=0 Do  Quit
 . Do Error(sockid,400)

 If REQUEST("head","X-Revision")'=^WWWHTTPDATA(path,"rev") Do  Quit
 . Do Error(sockid,409)

 Set ^WWWHTTPDATA(path,"rev")=^WWWHTTPDATA(path,"rev")+1

 Set @varparam=data

 Set ^WWWHTTPDATA(path,"length")=$Length(body)
 Set ^WWWHTTPDATA(path,"date")=$Zdate($HOROLOG,"DAY, DD MON YEAR 24:60:SS")
 Set ^WWWHTTPDATA(path,"auth")=0
 
 If $Data(REQUEST("head","Content-Type"))'=0 Do
 . Set type=$Piece(REQUEST("head","Content-Type"),"/",2)
 . If $Data(^WWW("http","files","mime",type))=0 Set type="plain"
 . Set ^WWWHTTPDATA(path,"type")=type
 
 If $Data(REQUEST("head","X-Authenticate"))'=0 Do
 . Set ^WWWHTTPDATA(path,"auth")=REQUEST("head","X-Authenticate")

 Set head=^WWW("http","state",200)_$Char(13,10)
 Set head=head_"Server: "_^WWW("server")_$Char(13,10)
 Set head=head_"Last-Modified: "_^WWWHTTPDATA(path,"date")_$Char(13,10)
 Set head=head_"X-Revision: "_^WWWHTTPDATA(path,"rev")_$Char(13,10)
 Set head=head_"X-Authenticate: "_^WWWHTTPDATA(path,"auth")_$Char(13,10)

 If $Data(^WWWHTTPDATA(path,"type"))'=0 Do
 . Set head=head_^WWW("http","files","mime",^WWWHTTPDATA(path,"type"))_$Char(13,10)

 Set body="Updated! URL: """_path_""""

 Set head=head_"Content-Length: "_$Length(body)_$Char(13,10)

 Do Send(head,body)

 Do Log^WWW(varparam_" "_body)

 Do Close^WWWhttp(sockid)

 Quit


Response(sockid)

 Set RESPONSE("head")=""
 Set RESPONSE("body")=REQUEST("body")
 Set RESPONSE("path")=REQUEST("path")
 Set RESPONSE("type")=""

 If REQUEST("method")="PUT" Quit

 Set upgrade=""

 If $Data(REQUEST("head","Upgrade")) Set upgrade=REQUEST("head","Upgrade")

 If (upgrade="websocket")!(upgrade="Websocket")!(upgrade="WebSocket") Do  Quit
 . Set RESPONSE("type")="WEBSOCKET"
 . Do WebsocketHead(sockid)

 If $Data(^WWW("http","protocol",REQUEST("path"),"routine")) Do  Quit
 . Set RESPONSE("type")="ROUTINE"
 . Do RoutineHead

 If $Data(^WWWHTTPDATA(REQUEST("path"),"length")) Do  Quit
 . Set RESPONSE("type")="DATA"
 . Do DataHead(REQUEST("path"))

 Set RESPONSE("path")=^WWW("localpath")_REQUEST("path")

 If $Data(^WWW("http","path",REQUEST("path")))'=0 Do
 . Set RESPONSE("path")=^WWW("localpath")_^WWW("http","path",REQUEST("path"))

 Set RESPONSE("type")="FILE"
 Do FileHead(sockid)

 Quit


DataHead(path)

 Set RESPONSE("head")=^WWW("http","state",200)_$Char(13,10)

 Set RESPONSE("head")=RESPONSE("head")_"Server: "_^WWW("server")_$Char(13,10)
 Set RESPONSE("head")=RESPONSE("head")_"Last-Modified: "_^WWWHTTPDATA(path,"date")_$Char(13,10)
 Set RESPONSE("head")=RESPONSE("head")_"Content-Length: "_^WWWHTTPDATA(path,"length")_$Char(13,10)
 Set RESPONSE("head")=RESPONSE("head")_"X-Revision: "_^WWWHTTPDATA(path,"rev")_$Char(13,10)
 Set RESPONSE("head")=RESPONSE("head")_"X-Authenticate: "_^WWWHTTPDATA(path,"auth")_$Char(13,10)

 If $Data(^WWWHTTPDATA(path,"type"))'=0 Do
 . Set RESPONSE("head")=RESPONSE("head")_^WWW("http","files","mime",^WWWHTTPDATA(path,"type"))_$Char(13,10)

 Quit


FileHead(sockid)

 Set size=$$FileSize(RESPONSE("path"))
 Set mime=$Piece(RESPONSE("path"),".",2)

 If size=-1 Do  Quit
 . Do Error(sockid,404)
 . Set RESPONSE("type")="ERROR"

 Set RESPONSE("head")=^WWW("http","state",200)_$Char(13,10)

 Set RESPONSE("head")=RESPONSE("head")_"Server: "_^WWW("server")_$Char(13,10)
 Set RESPONSE("head")=RESPONSE("head")_"Content-Length: "_size_$Char(13,10)

 If $Data(^WWW("file","mime",mime))'=0 Do
 . Set RESPONSE("head")=RESPONSE("head")_^WWW("file","mime",mime)_$Char(13,10)

 Quit


RoutineHead

 Set RESPONSE("head")=^WWW("http","state",200)_$Char(13,10)

 Set RESPONSE("head")=RESPONSE("head")_"Server: "_^WWW("server")_$Char(13,10)
 Set RESPONSE("head")=RESPONSE("head")_^WWW("http","files","mime","html")_$Char(13,10)

 Quit


WebsocketHead(sockid)

 Set path=REQUEST("path")
 Set RESPONSE("path")=path

 If ($Data(REQUEST("head","Sec-WebSocket-Version"))=0)!(REQUEST("head","Sec-WebSocket-Version")'=13) Do  Quit
 . Do Error(sockid,400)
 . Set RESPONSE("type")="ERROR"

 If $Data(^WWW("websocket","protocol",path))=0 Do  Quit
 . Do Error(sockid,404)
 . Set RESPONSE("type")="ERROR"

 If ^WWWSOCKETLIST>=(^WWW("maxsockets")-5) Do  Quit
 . Do Error(sockid,503)
 . Set RESPONSE("type")="ERROR"

 Set RESPONSE("head")=^WWW("http","state",101)_$Char(13,10)

 Set RESPONSE("head")=RESPONSE("head")_"Server: "_^WWW("server")_$Char(13,10)
 Set RESPONSE("head")=RESPONSE("head")_"Upgrade: websocket"_$Char(13,10)
 Set RESPONSE("head")=RESPONSE("head")_"Connection: Upgrade"_$Char(13,10)
 Set RESPONSE("head")=RESPONSE("head")_"Content-Length: 0"_$Char(13,10)

 If $Data(REQUEST("head","Sec-WebSocket-Key"))'=0 Do
 . Set key=$$EncodingKey^WWWws(REQUEST("head","Sec-WebSocket-Key"))
 . Set RESPONSE("head")=RESPONSE("head")_"Sec-WebSocket-Accept: "_key_$Char(13,10)
  
 Set RESPONSE("head")=RESPONSE("head")_"Sec-WebSocket-Protocol: "_^WWW("websocket","protocol",path,"sub")_$Char(13,10)

 Quit


FileSize(filename)

 Set pipe="size"
 Set shellcmd="[ -f """_filename_""" ] && wc -c """_filename_""" || echo -1"

 Open pipe:(command=shellcmd:readonly)::"PIPE"

 Use pipe Read shellout

 Close pipe

 Set size=$Piece(shellout," ")

 Quit size
