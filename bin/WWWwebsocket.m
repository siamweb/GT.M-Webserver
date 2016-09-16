WWWwebsocket;

Open(sockid)

 Set path=^WWW("con",sockid,"path")

 Set head=^WWW("http","states",101)_$Char(13,10)

 Set head=head_"Server: "_^WWW("server")_$Char(13,10)
 Set head=head_"Upgrade: websocket"_$Char(13,10)
 Set head=head_"Connection: Upgrade"_$Char(13,10)
 Set head=head_"Content-Length: 0"_$Char(13,10)

 If $Data(^WWW("con",sockid,"head","Sec-WebSocket-Key"))'=0 Do
 . Set key=$$EncodingKey(^WWW("con",sockid,"head","Sec-WebSocket-Key"))
 . Set head=head_"Sec-WebSocket-Accept: "_key_$Char(13,10)

 Set head=head_"Sec-WebSocket-Protocol: "_^WWW("websocket","routines",path,"subroutine")_$Char(13,10)
 Set head=head_$Char(13,10)

 Do Send^WWWutils($IO,head)

 Kill ^WWW("con",sockid)

 Do Log^WWWlog("Opened Websocket: "_sockid)

 Set ^WWW("con",sockid)="OPEN"
 Set ^WWW("con",sockid,"time")=$Zdate($Horolog,"SS6024DDMMYEAR")
 Set ^WWW("con",sockid,"websocket")=1
 Set ^WWW("con",sockid,"protocol")=path

 Set channel=^WWW("websocket","routines",path,"channel")
 Do Register(sockid,channel)

 Quit


Read(sockid)

 Do Log^WWWlog("Receive Message from Websocket: "_sockid)

 Use ^WWW("sockdev"):SOCKET=sockid

 Read in

 If (in="")&(^WWW("con",sockid)="OPEN") Do Error(sockid,1002,"ERROR:Empty Message!") Quit
 If (in="")&(^WWW("con",sockid)="CLOSING") Do  Quit
 . Close ^WWW("sockdev"):(SOCKET=sockid)
 . Kill ^WWW("con",sockid)

 Do ProcessMessage(sockid,in)

 Quit


ProcessMessage(sockid,msg)

 Kill ^WWW("con",sockid,"head")

 Set msg=$$UnMasking(msg)

 If (^WWW("con",sockid,"head","completed")=0)&($Data(^WWW("con",sockid,"buffer"))=0) Do  Quit
 . Set ^WWW("con",sockid,"buffer")=msg

 If (^WWW("con",sockid,"head","completed")=0)&($Data(^WWW("con",sockid,"buffer"))'=0) Do  Quit
 . Set msg=^WWW("con",sockid,"buffer")_msg
 . Kill ^WWW("con",sockid,"buffer")
 . Do ProcessMessage(sockid,msg)
 
 Kill ^WWW("con",sockid,"buffer")

 Do Response(sockid,msg)

 If ($Data(^WWW("con",sockid))=0) Quit

 If ((^WWW("con",sockid)'="CLOSING")&(^WWW("con",sockid,"head","completed")=2)) Do 
 . Do ProcessMessage(sockid,^WWW("con",sockid,"head","tail"))

 Quit


Response(sockid,msg)

 Do Log^WWWlog("Preparing response")

 Set protocol=^WWW("con",sockid,"protocol")

 If (^WWW("con",sockid)="CLOSING")&(^WWW("con",sockid,"head","opcode")'=8) Do  Quit
 . Close ^WWW("sockdev"):(SOCKET=sockid)
 . Kill ^WWW("con",sockid)

 If ^WWW("con",sockid,"head","mask")'=1 Do Error(sockid,1002,"ERROR:Missing Mask!") Quit

 If ^WWW("con",sockid,"head","opcode")=8 Do ReceiveClose(sockid,msg) Quit
 If ^WWW("con",sockid,"head","opcode")=9 Do ReceivePing(sockid,msg) Quit

 If ^WWW("con",sockid,"head","opcode")=10 Do Log^WWWlog("Received Pong socket="_sockid) Quit

 Set ^WWW("con",sockid,"message")=msg
 Set key=^WWW("con",sockid,"head","key")

 If (^WWW("websocket","routines",protocol,"sync")=1) Do  Quit
 . Do Routine(sockid)

 Job Routine(sockid)

 Quit


ReceiveClose(sockid,msg)

 Do Log^WWWlog("Received Close from: "_sockid)

 Set msg=$$Decipher(msg,^WWW("con",sockid,"head","key"))
 Set state=$$IntToNum^WWWutils($ZExtract(msg,1,2))
 Set reason=$ZExtract(msg,3,^WWW("con",sockid,"head","length"))

 If ^WWW("con",sockid)'="CLOSING" Do 
 . Set msg=$$Masking("close",msg,1)
 . Do Send(sockid,msg)

 Close ^WWW("sockdev"):(SOCKET=sockid)
 Kill ^WWW("con",sockid)
 
 Quit


ReceivePing(sockid,msg)

 Set msg=$$Decipher(msg,^WWW("con",sockid,"head","key"))

 Set msg=$$Masking("pong",msg,1)

 Do Send(sockid,msg)

 Quit


Routine(sockid)

 If (^WWW("pid")'=$JOB) Set $Ztrap="Do ErrorTrap^WWWerror"

 Do Log^WWWlog("Routine started")

 Set protocol=^WWW("con",sockid,"protocol")
 Set msg=^WWW("con",sockid,"message")
 Set key=^WWW("con",sockid,"head","key")

 Set data=$$Decipher(msg,key)

 Set funcparam=^WWW("websocket","routines",protocol,"routine")

 Do @funcparam

 Kill ^WWW("con",sockid,"message")

 Quit


Error(sockid,state,reason)

 Set state=^WWW("websocket","states",state)

 Set msg=state_reason
 Set msg=$$Masking("close",msg,1)

 Do Send(sockid,msg)

 Set ^WWW("con",sockid)="CLOSING"
 Set ^WWW("con",sockid,"time")=$Zdate($Horolog,"SS6024DDMMYEAR")

 Quit


Send(sockid,msg)

 Set previo=$IO

 Use ^WWW("sockdev"):SOCKET=sockid Write msg
 Use previo

 Quit


SendStack

 Do Log^WWWlog("Send WWWwebsocket")

 For  Do  Quit:x=""
 . Set x=$Order(^WWW("stack",x))
 . If (x="") Set x=$Order(^WWW("stack",x))
 . Do Log^WWWlog("x:"_x)
 . Quit:x=""
 . Set frame=$$Control(x)
 . If (frame="") Set frame=$$Dequeue(x)
 . If (frame'="") Use ^WWW("sockdev"):SOCKET=x Write frame

 Set ^WWW("trigger")=0

 Quit


Control(sockid)

 Set frame=""

 If ($Data(^WWW("stack",sockid,"close"))'=0) Do  Quit frame
 . Set frame=^WWW("stack",sockid,"close")
 . Set ^WWW("con",sockid,"time")=$Zdate($Horolog,"SS6024DDMMYEAR")
 . Set ^WWW("con",sockid)="CLOSING"
 . Kill ^WWW("stack",sockid)

 If ($Data(^WWW("stack",sockid,"ping"))'=0) Do  Quit frame
 . Set frame=^WWW("stack",sockid,"ping")
 . Kill ^WWW("stack",sockid,"ping")

 If ($Data(^WWW("stack",sockid,"pong"))'=0) Do  Quit frame
 . Set frame=^WWW("stack",sockid,"pong")
 . Kill ^WWW("stack",sockid,"pong")

 Quit frame


Enqueue(sockid,frame,control)

 Do Log^WWWlog("Enqueue")

 If control="close" Do  Quit
 . Set ^WWW("stack",sockid,"close")=frame

 If control="ping" Do  Quit
 . Set ^WWW("stack",sockid,"ping")=frame

 If control="pong" Do  Quit
 . Set ^WWW("stack",sockid,"pong")=frame

 Set last=$Order(^WWW("stack",sockid,"data",""),-1)
 Set last=last+1

 Do Log^WWWlog("Enqueue last: "_last)

 Set ^WWW("stack",sockid,"data",last)=frame

 Quit


Dequeue(sockid)

 Do Log^WWWlog("Dequeue")

 Set first=$Order(^WWW("stack",sockid,"data",""),1)
 Set frame=""
 
 Quit:first="" frame

 Do Log^WWWlog("Dequeue first:"_first)

 Set frame=^WWW("stack",sockid,"data",first)

 Kill ^WWW("stack",sockid,"data",first)
 
 If $Order(^WWW("stack",sockid,"data",""),1)="" Do
 . Kill ^WWW("stack",sockid)

 Quit frame


Register(sockid,channel)

 Set found=0

 For i=0:1 Do  Quit:found=1
 . If ($Data(^WWW("websocket","channels",channel,i))=0) Do
 . . Set ^WWW("websocket","channels",channel,i)=sockid
 . . Set ^WWW("websocket","channels",channel)=^WWW("websocket","channels",channel)+1
 . . Set found=1

 Quit


Unregister(sockid,channel)

 Set found=0
 Set count=^WWW("websocket","channels",channel)
 Set i=0

 For  Do  Quit:i=count
 . Quit:$Data(^WWW("websocket","channels",channel,i))=0 
 . Set id=^WWW("websocket","channels",channel,i)
 . If (id=sockid) Do
 . . Kill ^WWW("websocket","channels",channel,i)
 . . Set i=count
 . Set i=i+1

 Quit


UnMasking(msg)

 Set ^WWW("con",sockid,"head","completed")=0

 Set hlen=2

 Quit:$Length(msg)<hlen msg

 Set finop=$ASCII(msg,1)

 If finop>=128 Set ^WWW("con",sockid,"head","fin")=1 Set finop=finop-128
 If finop>=64 Set ^WWW("con",sockid,"head","rsv1")=1 Set finop=finop-64
 If finop>=32 Set ^WWW("con",sockid,"head","rsv2")=1 Set finop=finop-32
 If finop>=16 Set ^WWW("con",sockid,"head","rsv3")=1 Set finop=finop-16
 Set ^WWW("con",sockid,"head","opcode")=finop

 Set masklen=$ASCII(msg,2)
 
 Set ^WWW("con",sockid,"head","mask")=0 

 If masklen>=128 Do 
 . Set ^WWW("con",sockid,"head","mask")=1
 . Set masklen=masklen-128

 If 0<=masklen<=125 Set ^WWW("con",sockid,"head","length")=masklen
 If masklen=126 Do 
 . Set ^WWW("con",sockid,"head","length")=$$IntToNum^WWWutils($Zextract(msg,hlen+1,hlen+2)) 
 . Set hlen=hlen+2
 If masklen=127 Do 
 . Set ^WWW("con",sockid,"head","length")=$$IntToNum^WWWutils($Zextract(msg,hlen+1,hlen+8)) 
 . Set hlen=hlen+8

 If ^WWW("con",sockid,"head","mask")=1 Do
 . Set ^WWW("con",sockid,"head","key")=$Zextract(msg,hlen+1,hlen+4)
 . Set hlen=hlen+4

 Quit:$Length(msg)<hlen msg
 Quit:$Length(msg)-hlen<^WWW("con",sockid,"head","length") msg

 Set msgstart=hlen+1
 Set msgend=msgstart+^WWW("con",sockid,"head","length")-1
                     
 If $Length(msg)>msgend Do
 . Set ^WWW("con",sockid,"head","completed")=2
 . Set ^WWW("con",sockid,"head","tail")=$Zextract(msg,msgend+1,^WWW("recordsize"))

 Set msg=$Zextract(msg,msgstart,msgend)
 
 If ($Length(msg)=^WWW("con",sockid,"head","length"))&(^WWW("con",sockid,"head","completed")'=2) Do
 . Set ^WWW("con",sockid,"head","completed")=1

 Quit msg


Masking(type,data,unfragmented)

 New fin,finop,len,masklen

 Set fin=0

 If unfragmented=1 Set fin=128

 If type="continuation" Set finop=$Char(fin+0)
 If type="text" Set finop=$Char(fin+1) 
 If type="binary" Set finop=$Char(fin+2)
 If type="close" Set finop=$Char(fin+8)
 If type="ping" Set finop=$Char(fin+9)
 If type="pong" Set finop=$Char(fin+10)

 Set len=$Length(data)

 If len<126 Set masklen=$$LengthToBit^WWWutils(len)
 If (len>125)&(len<65536) Do
 . Set len=$$LengthToBit^WWWutils(len)
 . Set masklen=$Char(126)_len 
 If len>65535 Do
 . Set len=$$LengthToBit^WWWutils(len)
 . Set masklen=$Char(127)_len

 Set data=finop_masklen_data

 Quit data


Decipher(cipher,key)

 New msg

 Set msgkey=key

 For  Do  Quit:$Length(msgkey)>=$Length(cipher)
 . Set msgkey=msgkey_key 

 Set msg=$Zbitxor($Char(0)_cipher,$Char(0)_msgkey)
 Set msg=$ZExtract(msg,2,$Length(msg))

 Quit msg


EncodingKey(key)

 New shellcmd,pipe,shellout,io
 Set io=$IO
 Set pipe="sha1base64"

 Set shellcmd="/bin/echo -n """_key_"258EAFA5-E914-47DA-95CA-C5AB0DC85B11"""
 Set shellcmd=shellcmd_" | openssl sha1 -binary | openssl base64 "

 Open pipe:(command=shellcmd:readonly)::"PIPE"
 Use pipe Read shellout
 Close pipe

 Use io

 Quit shellout


EventTrigger(event)

 If (^WWW("trigger")=1) Quit

 Set ^WWW("trigger")=1
 Set trigger="trigger"

 Open trigger:(CONNECT="localhost:"_^WWW("port")_":TCP")::"SOCKET"
 
 Use trigger Write event

 Close trigger 

 Quit 
