WWWws;

;WebSocket implementation


Read(sockid)
                     
 Do Log^WWW("Receive Message from socket="_sockid)

 Use ^WWW("sockdev"):SOCKET=sockid

 Read in

 If (in="")&(^WWW("websocket","connections",sockid)="OPEN") Do SendClose(sockid,1002,"ERROR:Empty Message!") Quit
 If (in="")&(^WWW("websocket","connections",sockid)="CLOSING") Do  Quit
 . Do Close(sockid)
 . Do Log^WWW("Close was not clean socket="_sockid)

 Do BufferedRead(sockid,in)

 Quit


BufferedRead(sockid,msg)

 New HEAD

 Set msg=$$UnMasking(msg)

 If (HEAD("completed")=0)&($Data(^WWW("websocket","connections",sockid,"buffer"))=0) Do  Quit
 . Set ^WWW("websocket","connections",sockid,"buffer")=msg
 . Do Log^WWW("Used Buffer msg="_msg)

 If (HEAD("completed")=0)&($Data(^WWW("websocket","connections",sockid,"buffer"))'=0) Do  Quit
 . Set msg=^WWW("websocket","connections",sockid,"buffer")_msg
 . Kill ^WWW("websocket","connections",sockid,"buffer")
 . Do BufferedRead(sockid,msg)                    
 
 Kill ^WWW("websocket","connections",sockid,"buffer")

 Do Response(sockid,msg)

 If (HEAD("completed")=2)&(^WWW("websocket","connections",sockid)'="CLOSING") Do 
 . Do BufferedRead(sockid,HEAD("tail"))

 Quit


Response(sockid,msg)

 Set protocol=^WWW("websocket","connections",sockid,"protocol")

 If (^WWW("websocket","connections",sockid)="CLOSING")&(HEAD("opcode")'=8) Do Quit
 . Do Close(sockid)
 . Do Log^WWW("Close was not clean socket="_sockid)

 If HEAD("mask")'=1 Do SendClose(sockid,1002,"ERROR:Missing Mask!") Quit

 If HEAD("opcode")=8 Do ReceiveClose(sockid,msg) Quit
 If HEAD("opcode")=9 Do ReceivePing(sockid,msg) Quit
 If HEAD("opcode")=10 Do Log^WWW("Received Pong socket="_sockid) Quit

 Set ^WWW("websocket","connections",sockid,"message")=msg
 Set key=HEAD("key")

 If ^WWW("websocket","protocol",protocol,"sync")=1 Do  Quit
 . Do Receive^WWWwsi(sockid,key,protocol)

 Job Receive^WWWwsi(sockid,key,protocol)

 Quit


ReceivePing(sockid,msg)

 Set msg=$$Decipher(msg,HEAD("key"))

 Do Log^WWW("Received Ping by socket="_sockid_", msg="_msg)

 Set msg=$$Masking("pong",msg,1)

 Use ^WWW("sockdev"):SOCKET=sockid 

 Write msg

 Do Log^WWW("Send Pong to socket="_sockid)

 Quit


ReceiveClose(sockid,msg)

 Do Log^WWW("Received Close by socket="_sockid)

 Set msg=$$Decipher(msg,HEAD("key"))
 Set state=$$IntToNum($ZExtract(msg,1,2))
 Set reason=$ZExtract(msg,3,HEAD("length"))

 If ^WWW("websocket","connections",sockid)'="CLOSING" Do 
 . Set msg=$$Masking("close",msg,1)
 . Use ^WWW("sockdev"):SOCKET=sockid 
 . Write msg

 Do Close(sockid)

 Do Log^WWW("WebSocket Closed socket="_sockid_", Statuscode="_state_", Reason="_reason)
 
 Quit  


SendClose(sockid,state,reason)

 Set state=^WWW("websocket","state",state)

 Set msg=state_reason
 Set msg=$$Masking("close",msg,1)

 Use ^WWW("sockdev"):SOCKET=sockid 
 Write msg

 Set ^WWW("websocket","connections",sockid)="CLOSING"
 Set ^WWW("websocket","connections",sockid,"time")=$HOROLOG

 Do Log^WWW("Send Close to socket="_sockid_", reason="_reason)

 Quit


Close(sockid)

 Close ^WWW("sockdev"):(SOCKET=sockid)

 Kill ^WWWSOCKETLIST(^WWW("websocket","connections",sockid,"list"))
 If ^WWWSOCKETLIST>0 Set ^WWWSOCKETLIST=^WWWSOCKETLIST-1

 Kill ^WWW("websocket","connections",sockid)

 Quit


Send

 Set frame=""
 Set x=""

 For  Do  Quit:x=""
 . Set x=$Order(^WWWSOCKETDATA(x))
 . If x="" Set x=$Order(^WWWSOCKETDATA(x))
 . Quit:x=""
 . Set frame=$$Control(x)
 . If frame="" Set frame=$$Dequeue(x)
 . If frame'="" Use ^WWW("sockdev"):(SOCKET=x) Write frame

 Set ^WWW("trigger")=0

 Quit


SendSync(sockid,frame)

 Use ^WWW("sockdev"):SOCKET=sockid

 Write frame

 Quit
       

Control(sockid)

 New frame Set frame=""

 If $Data(^WWWSOCKETDATA(sockid,"control"))'=0 Do
 . Set frame=^WWWSOCKETDATA(sockid,"control")
 . Set ^WWW("websocket","connections",sockid,"time")=$HOROLOG
 . Do Log^WWW("Sending Control Frame to socket="_sockid)
 . Kill ^WWWSOCKETDATA(sockid,"control")

 Quit frame


Create(sockid,protocol)

 New listed Set listed=0

 For i=1:1 Do  Quit:listed=1
 . If $Data(^WWWSOCKETLIST(i))=0 Do
 . . Set listed=1
 . . Set ^WWWSOCKETLIST(i)=sockid
 . . Set ^WWW("websocket","connections",sockid)="OPEN"
 . . Set ^WWW("websocket","connections",sockid,"list")=i
 . . Set ^WWW("websocket","connections",sockid,"protocol")=protocol
 . . Set ^WWW("websocket","connections",sockid,"time")=$HOROLOG
 
 Set ^WWWSOCKETLIST=^WWWSOCKETLIST+1
 
 Quit


Contains(sockid)

 If $Data(^WWW("websocket","connections",sockid))=0 Quit 0
 Quit 1


Enqueue(sockid,frame,control)

 New last

 If control=1 Do  Quit
 . Set ^WWWSOCKETDATA(sockid,"control")=frame

 Set last=$Order(^WWWSOCKETDATA(sockid,""),-1)
 Set last=last+1
 Set ^WWWSOCKETDATA(sockid,last)=frame

 Quit


Dequeue(sockid)

 New first,frame

 Set first=$Order(^WWWSOCKETDATA(sockid,""),1)
 Set frame=""
 
 Quit:$Data(^WWWSOCKETDATA(sockid,first))=0 frame

 Set frame=^WWWSOCKETDATA(sockid,first)

 Kill ^WWWSOCKETDATA(sockid,first)
 
 If $Order(^WWWSOCKETDATA(sockid,""),1)="" Do
 . Kill ^WWWSOCKETDATA(sockid)

 Quit frame 


IntToNum(int)

 New len,num

 Set int=$Char(0)_int

 Set len=$Zbitlen(int)
 Set num=0
 For i=1:1:len Do
 . If $Zbitget(int,(len+1)-i) Set num=num+(2**(i-1))
 
 Quit num


UnMasking(msg)

 New finop,masklen,offset,msgstart,msgend
 Kill HEAD
 
 Set HEAD("completed")=0

 Set hlen=2

 Quit:$Length(msg)<hlen msg

 Set finop=$ASCII(msg,1)

 If finop>=128 Set HEAD("fin")=1 Set finop=finop-128
 If finop>=64 Set HEAD("rsv1")=1 Set finop=finop-64
 If finop>=32 Set HEAD("rsv2")=1 Set finop=finop-32
 If finop>=16 Set HEAD("rsv3")=1 Set finop=finop-16
 Set HEAD("opcode")=finop

 Set masklen=$ASCII(msg,2)
 
 Set HEAD("mask")=0 

 If masklen>=128 Do 
 . Set HEAD("mask")=1
 . Set masklen=masklen-128

 If 0<=masklen<=125 Set HEAD("length")=masklen
 If masklen=126 Do 
 . Set HEAD("length")=$$IntToNum($Zextract(msg,hlen+1,hlen+2)) 
 . Set hlen=hlen+2
 If masklen=127 Do 
 . Set HEAD("length")=$$IntToNum($Zextract(msg,hlen+1,hlen+8)) 
 . Set hlen=hlen+8

 If HEAD("mask")=1 Do
 . Set HEAD("key")=$Zextract(msg,hlen+1,hlen+4)
 . Set hlen=hlen+4

 Quit:$Length(msg)<hlen msg
 Quit:$Length(msg)-hlen<HEAD("length") msg

 Set msgstart=hlen+1
 Set msgend=msgstart+HEAD("length")-1
                     
 If $Length(msg)>msgend Do
 . Set HEAD("completed")=2
 . Set HEAD("tail")=$Zextract(msg,msgend+1,^WWW("recordsize"))

 Set msg=$Zextract(msg,msgstart,msgend)
 
 If ($Length(msg)=HEAD("length"))&(HEAD("completed")'=2) Set HEAD("completed")=1

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

 If len<126 Set masklen=$$LengthToBit(len)
 If (len>125)&(len<65536) Do
 . Set len=$$LengthToBit(len)
 . Set masklen=$Char(126)_len 
 If len>65535 Do
 . Set len=$$LengthToBit(len)
 . Set masklen=$Char(127)_len

 Set data=finop_masklen_data

 Quit data


LengthToBit(length)

 New bit,bitlen,tmpbit

 If length<126 Set bit=$Zbitstr(8,0) Set bitlen=8
 Else  If length<65535 Set bit=$Zbitstr(16,0) Set bitlen=16
 Else  Set bit=$Zbitstr(64,0) Set bitlen=64

 For i=0:1 Do  Quit:length=0
 . Set tmpbit(i)=0
 . If length#2=1 Set length=length-1 Set tmpbit(i)=1
 . Set length=length/2

 For j=0:1:i Do
 . Set bit=$Zbitset(bit,bitlen-j,tmpbit(j))

 Set bit=$Zextract(bit,2,99)
 
 Quit bit


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
