WWWhttp;


Read(sockid,ip)

 New REQUEST,RESPONSE

 Do Log^WWW("Receive Message from Connection="_sockid)
 
 Use ^WWW("sockdev"):SOCKET=sockid

 Read in

 If $Data(^WWW("http","connections",sockid,"buffer"))&(in'="") Do
 . Set in=^WWW("http","connections",sockid,"buffer")_in

 If in'[$Char(13,10,13,10) Do  Quit 
 . Set ^WWW("http","connections",sockid)="RECEIVING"
 . Set ^WWW("http","connections",sockid,"buffer")=in
 . Set ^WWW("http","connections",sockid,"time")=$HOROLOG
 . Do Log^WWW("Use Buffer connection="_sockid)

 Do Request(sockid,in)

 If (REQUEST("method")="")!(REQUEST("path")="") Do Error^WWWres(sockid,400) Quit
 If REQUEST("head","Content-Length")>^WWW("recordsize") Do Error^WWWres(sockid,413) Quit

 Set REQUEST("body")=$Piece(in,$Char(13,10,13,10),2,^WWW("recordsize"))

 If (REQUEST("head","Content-Length")'=-1)&(REQUEST("head","Content-Length")>$Length(REQUEST("body"))) Do  Quit 
 . Set ^WWW("http","connections",sockid)="RECEIVING"
 . Set ^WWW("http","connections",sockid,"buffer")=in
 . Set ^WWW("http","connections",sockid,"time")=$HOROLOG
 . Do Log^WWW("Use Buffer connection="_sockid)
 
 Kill ^WWW("http","connections",sockid,"buffer")

 Do Response^WWWres(sockid)

 If RESPONSE("type")="ERROR" Quit

 Do Authentication(sockid,ip)              

 Quit


Request(sockid,in)

 Set head=$Piece(in,$Char(13,10,13,10))

 Set lines=$Length(head,$Char(13,10))
 Set line=$Piece(head,$Char(13,10))

 Set REQUEST("method")=$Piece(line," ")
 Set REQUEST("path")=$Piece($Piece(line," ",2),"?")
 Set REQUEST("query")=$Piece($Piece(line," ",2),"?",2,999)

 Set length=$Length(REQUEST("path"))

 If (length>1)&($Extract(REQUEST("path"),length,length)="/") Do
 . Set REQUEST("path")=$Extract(REQUEST("path"),1,length-1) 

 For i=2:1:lines Do
 . Set line=$Piece(head,$Char(13,10),i)
 . Set REQUEST("head",$Piece(line,":"))=$Piece(line,": ",2)

 If $Data(REQUEST("head","Content-Length"))=0 Set REQUEST("head","Content-Length")=-1

 Quit


Authentication(sockid,ip)

 Set path=REQUEST("path") 
 Set method=REQUEST("method")
 Set auth=0

 If $Data(^WWW("http","path",path,"auth"))'=0 Do
 . Set auth=^WWW("http","path",path,"auth")

 If $Data(^WWW("http","protocol",path,"auth"))'=0 Do
 . Set auth=^WWW("http","protocol",path,"auth")
 
 If $Data(^WWWHTTPDATA(path,"auth"))'=0 Do
 . Set auth=^WWWHTTPDATA(path,"auth")

 If (method="PUT")!(method="POST")!(method="DELETE") Set auth=1

 If (auth=1)&($Data(REQUEST("head","Authorization"))'=0) Do
 . Set auth=$$Login(REQUEST("head","Authorization"))
 
 If auth=1 Do Error^WWWres(sockid,401) Quit

 If $Data(^WWW("http","distributor",REQUEST("method"))) Do  Quit
 . Do @^WWW("http","distributor",REQUEST("method"))
 
 Do Error^WWWres(sockid,501) 

 Quit

 
Login(user)

 Set permission=1
 Set x=""

 For  Do  Quit:x=""
 . Set x=$Order(^WWWUSER(x))
 . Quit:x=""
 . If user=^WWWUSER(x) Do
 . . Set permission=0
 . . Set x=""
 . . Do Log^WWW("User "_x_"logged in")

 Quit permission


Pathtovar(path)

 Set x=""

 Set varparam="^WWWDATABASE("""

 For i=2:1 Do  Quit:x=""
 . Set x=$Piece(path,"/",i)
 . Quit:x=""
 . If i'=2 Set varparam=varparam_""","""
 . Set varparam=varparam_x

 Set varparam=varparam_""")"

 Quit varparam


Close(sockid)

 Close ^WWW("sockdev"):SOCKET=sockid

 Kill ^WWW("http","connections",sockid)

 Quit


GET(sockid)
 
 Use ^WWW("sockdev"):SOCKET=sockid

 Set path=RESPONSE("path")
 Set head=RESPONSE("head")
 Set body=RESPONSE("body")

 If RESPONSE("type")="DATA" Do  Quit
 . Set varparam=$$Pathtovar(path)
 . Set body=@varparam
 . Do Send^WWWres(head,body)
 . Do Close(sockid)

 If RESPONSE("type")="WEBSOCKET" Do
 . Do Create^WWWws(sockid,path)
 . Do Send^WWWres(head,body)
 . Do Log^WWW("WebSocket Established socket="_sockid)

 If RESPONSE("type")="ROUTINE" Do
 . Set data=REQUEST("query") 
 . Use ^WWW("sockdev"):DETACH=sockid
 . Set jobprocessparam="Routine^WWWres(path,head,data):(output="_"""SOCKET:"_sockid_""""_":input="_"""SOCKET:"_sockid_""""_")"
 . Job @jobprocessparam 
 . Do Log^WWW("Executed Routine="_path)

 If RESPONSE("type")="FILE" Do
 . Use ^WWW("sockdev"):DETACH=sockid
 . Set jobprocessparam="SendFile^WWWres(path,head):(output="_"""SOCKET:"_sockid_""""_":input="_"""SOCKET:"_sockid_""""_")"
 . Job @jobprocessparam                       

 Kill ^WWW("http","connections",sockid)

 Quit


POST(sockid)

 Use ^WWW("sockdev"):SOCKET=sockid

 Set path=RESPONSE("path")
 Set head=RESPONSE("head")
 Set body=RESPONSE("body")

 If RESPONSE("type")="ROUTINE" Do  Quit
 . Set data=body
 . Use ^WWW("sockdev"):DETACH=sockid
 . Set jobprocessparam="Routine^WWWres(path,head,data):(output="_"""SOCKET:"_sockid_""""_":input="_"""SOCKET:"_sockid_""""_")"
 . Job @jobprocessparam 
 . Do Log^WWW("Executed Routine="_path)
 . Kill ^WWW("http","connections",sockid)

 If RESPONSE("type")="DATA" Do  Quit
 . Set varparam=""
 . For  Do  Quit:$Data(@varparam)=0
 . . Set ident="doc"_$Random(999999)
 . . Set newpath=path_"/"_ident
 . . Set varparam=$$Pathtovar(newpath)
 . Do Create^WWWres(varparam,newpath,body) 
 . Do Close(sockid)

 Do Error^WWWres(sockid,409)

 Quit


PUT(sockid)

 Use ^WWW("sockdev"):SOCKET=sockid

 Set path=RESPONSE("path")
 Set body=RESPONSE("body")

 If $Data(^WWW("http","protocol",path,"routine"))'=0 Do  Quit
 . Do Error^WWWres(sockid,409)

 If $Data(^WWW("http","path",path))'=0 Do  Quit
 . Do Error^WWWres(sockid,409)

 Set varparam=$$Pathtovar(path)

 If $Data(^WWWHTTPDATA(path))'=0 Do  Quit
 . Do Update^WWWres(sockid,varparam,path,body)

 Do Create^WWWres(varparam,path,body)
 Do Close(sockid)
 
 Quit


DELETE(sockid)

 Use ^WWW("sockdev"):SOCKET=sockid

 Set path=RESPONSE("path")
 Set head=RESPONSE("head")
 Set body=RESPONSE("body")

 If RESPONSE("type")="DATA" Do  Quit
 . Set varparam=$$Pathtovar(path)
 . Set head=^WWW("http","state",200)_$Char(13,10)
 . Set body="Deleted URL: "_path
 . ZKill @varparam
 . Kill ^WWWHTTPDATA(path)
 . Do Send^WWWres(head,body)
 . Do Close(sockid)
 . Do Log^WWW("Deleted "_varparam_" path="_path)

 Do Error^WWWres(sockid,409)

 Quit


HEAD(sockid)

 Use ^WWW("sockdev"):SOCKET=sockid
 
 Set head=RESPONSE("head")
 Set body=""

 Do Send^WWWres(head,body)

 Do Log^WWW("Send HEAD")

 Do Close(sockid)
 Quit
