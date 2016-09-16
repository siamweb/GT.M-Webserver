WWWhttp;


Read(sockid)

 Do Log^WWWlog("Receive Message from Connection="_sockid)
 
 Use ^WWW("sockdev"):SOCKET=sockid

 Set ^WWW("con",sockid)="RECEIVING"
 Set ^WWW("con",sockid,"time")=$Zdate($Horolog,"SS6024DDMMYEAR")
 Set ^WWW("con",sockid,"websocket")=0

 Read in

 If (in="") Quit

 Do Log^WWWlog("Read Message")

 If (($Data(^WWW("con",sockid,"head","complete"))=0)!(^WWW("con",sockid,"head","complete")=0)) Do
 . Do ProcessHead(sockid,in)

 If (^WWW("con",sockid,"head","complete")=0) Quit

 If (^WWW("con",sockid,"method")="") Do Error(sockid,400) Quit
 If (^WWW("con",sockid,"path")="") Do Error(sockid,400) Quit

 Do Log^WWWlog("Head complete Succeded")

 If (($Data(^WWW("con",sockid,"body","complete"))=0)!(^WWW("con",sockid,"body","complete")=0)) Do
 . Do ProcessBody(sockid,in)

 If (^WWW("con",sockid,"body","complete")=0) Quit

 Do Log^WWWlog("Body complete Succeded")

 If ($$Authentication(sockid)) Do Error(sockid,401) Quit

 Do Log^WWWlog("Authentification Succeded")

 Set state=$$Websocket(sockid)

 If ((state'=1)&(state'=0)) Do Error(sockid,state) Quit

 If (state=1) Quit

 Do Log^WWWlog("Websocket Succeded")

 Set ^WWW("con",sockid)="PROCESSING"
 Set ^WWW("con",sockid,"time")=$Zdate($Horolog,"SS6024DDMMYEAR")

 Set method=^WWW("con",sockid,"method")

 Do Log^WWWlog("Generating Response for method:"_method)

 If ($Data(^WWW("http","distributor",method))) Do  Quit
 . Use ^WWW("sockdev"):DETACH=sockid
 . Set jobprocessparam=^WWW("http","distributor",method)_":(output="_"""SOCKET:"_sockid_""""_":input="_"""SOCKET:"_sockid_""""_")"
 . Job @jobprocessparam 

 Do Error(sockid,501)

 Quit


ProcessHead(sockid,in)

 If $Data(^WWW("con",sockid,"head","buffer")) Do
 . Set in=^WWW("con",sockid,"head","buffer")_in
 . Kill ^WWW("con",sockid,"head","buffer")

 If in'[$Char(13,10,13,10) Do  Quit
 . Set ^WWW("con",sockid,"head","buffer")=in
 . Set ^WWW("con",sockid,"head","complete")=0

 Set head=$Piece(in,$Char(13,10,13,10))

 Set lines=$Length(head,$Char(13,10))
 Set line=$Piece(head,$Char(13,10))

 Set path=$Piece($Piece(line," ",2),"?")

 Set length=$Length(path)

 If (length>1)&($Extract(path,length,length)="/") Do
 . Set path=$Extract(path,1,length-1) 

 Set ^WWW("con",sockid,"method")=$Piece(line," ")
 Set ^WWW("con",sockid,"path")=path
 Set ^WWW("con",sockid,"query")=$Piece($Piece(line," ",2),"?",2,999)

 For i=2:1:lines Do
 . Set line=$Piece(head,$Char(13,10),i)
 . Set ^WWW("con",sockid,"head",$Piece(line,":"))=$Piece(line,": ",2)

 Set ^WWW("con",sockid,"head","complete")=1

 Quit


ProcessBody(sockid,in)

 Set body=$Piece(in,$Char(13,10,13,10),2,^WWW("stringmax"))

 If $Data(^WWW("con",sockid,"body","buffer")) Do
 . Set body=^WWW("con",sockid,"body","buffer")_in
 . Kill ^WWW("con",sockid,"body","buffer")

 Set length=$Length(body)

 If (length=0) Do  Quit
 . Set ^WWW("con",sockid,"body","complete")=1
 . Set ^WWW("con",sockid,"body","length")=length


 ;TODO length passt nicht muss das noch besser überarbeiten
 Set clength=^WWW("con",sockid,"head","Content-Length")

 If ($Data(^WWW("con",sockid,"body","complete"))) Do
 . Set length=^WWW("con",sockid,"body","length")



 If (clength<^WWW("stringmax")) Do  Quit
 . Set ^WWW("con",sockid,"body","length")=length
 . If (length<clength) Do  Quit 
 . . Set ^WWW("con",sockid,"body","complete")=0
 . . Set ^WWW("con",sockid,"body","buffer")=body
 . Set ^WWW("con",sockid,"body")=body
 . Set ^WWW("con",sockid,"body","complete")=1

 Set ^WWW("con",sockid,"body","split")=1

 Set i=0

 For  Do  Quit:length>=clength!x=""
 . Read x#^WWW("stringmax")
 . Quit:x=""
 . Set length=length+$Length(x)
 . Set ^WWW("con",sockid,"body",i)=x 
 . Set i=i+1

 Set ^WWW("con",sockid,"body","complete")=1
 Set ^WWW("con",sockid,"body","length")=length

 If (length<clength)
 . Set ^WWW("con",sockid,"body","complete")=0

 Quit


Authentication(sockid)

 Set path=^WWW("con",sockid,"path")
 Set method=^WWW("con",sockid,"method")

 Set authorization=-1

 If ($Data(^WWW("con",sockid,"head","Authorization"))) Do
 . Set authorization=^WWW("con",sockid,"head","Authorization")

 Set auth=0

 If ($Data(^WWW("http","files",path,"auth"))'=0) Do
 . Set auth=^WWW("http","files",path,"auth")

 If ($Data(^WWW("http","routines",path,"auth"))'=0) Do
 . Set auth=^WWW("http","routines",path,"auth")
 
 If ($Data(^WWWDATA(path,"auth"))'=0) Do
 . Set auth=^WWWDATA(path,"auth")

 If (method="PUT")!(method="POST")!(method="DELETE") Set auth=1

 If ((auth=1)&(authorization'=-1)) Do
 . Set auth=$$Login^WWWutils(authorization)

 Quit auth


Websocket(sockid)

 If (^WWW("con",sockid,"method")'="GET") Quit 0

 Set upgrade=""

 If ($Data(^WWW("con",sockid,"head","Upgrade"))) Do
 . Set upgrade=^WWW("con",sockid,"head","Upgrade")

 If ((upgrade'="websocket")&(upgrade'="Websocket")&(upgrade'="WebSocket")) Quit 0

 Set version=""

 If ($Data(^WWW("con",sockid,"head","Sec-WebSocket-Version"))) Do
 . Set version=^WWW("con",sockid,"head","Sec-WebSocket-Version")

 If (version'=13) Quit 400

 Set path=^WWW("con",sockid,"path")

 If ($Data(^WWW("websocket","routines",path,"routine"))=0) Quit 404

 Do Open^WWWwebsocket(sockid)

 Quit 1


Error(sockid,code)

 Use ^WWW("sockdev"):DETACH=sockid
 Set jobprocessparam="ERROR^WWWerror(code):(output="_"""SOCKET:"_sockid_""""_":input="_"""SOCKET:"_sockid_""""_")"
 Job @jobprocessparam

 Kill ^WWW("con",sockid)

 Quit
