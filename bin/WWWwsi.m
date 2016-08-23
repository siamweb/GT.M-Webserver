WWWwsi;

;WebSocket Interface


Send(type,msg,protocol,unfragmented)

 Set control=0
 Set frame=$$Masking^WWWws(type,msg,unfragmented)
 
 If (type="ping")!(type="pong") Set control=1

 Set funcparam="Enqueue^WWWws(sockid,frame,control)"

 If ^WWW("websocket","protocol",protocol,"sync")=1 Do
 . Set funcparam="SendSync^WWWws(sockid,frame)"

 For i=1:1:^WWWSOCKETLIST Do
 . If ^WWW("websocket","connections",^WWWSOCKETLIST(i),"protocol")=protocol Do
 . . Set sockid=^WWWSOCKETLIST(i)
 . . Do @funcparam

 If ^WWW("websocket","protocol",protocol,"sync")=0 Do
 . Do EventTrigger("SEND")

 Quit


SendSync(sockid,type,msg,unfragmented)

 Set frame=$$Masking^WWWws(type,msg,unfragmented)

 Do SendSync^WWWws(sockid,frame)

 Quit


SendAsync(sockid,type,msg,unfragmented)

 Set frame=$$Masking^WWWws(type,msg,unfragmented)

 Set control=0
 
 If (type="ping")!(type="pong") Set control=1

 Do Enqueue^WWWws(sockid,frame,control)
 Do EventTrigger("SEND")

 Quit


Close(state,reason,protocol)

 Set state=^WWW("WebSocket","state",state)

 Set msg=state_reason
 Set frame=$$Masking^WWWws("close",msg,1)

 Set funcparam="Enqueue^WWWws(sockid,frame,1)"

 If ^WWW("websocket","protocol",protocol,"sync") Do  Quit
 . Set funcparam="SendSync^WWWws(sockid,frame)"

 For i=1:1:^WWWSOCKETLIST Do
 . If ^WWW("websocket","connections",^WWWSOCKETLIST(i),"protocol")=protocol Do
 . . Do @funcparam
 . . Set ^WWW("websocket","connections",^WWWSOCKETLIST(i))="CLOSING"

 If ^WWW("websocket","protocol",protocol,"sync")=0 Do
 . Do EventTrigger("CLOSE")

 Quit


CloseSync(sockid,state,reason)

 Set unfragmented=1
 Set state=^WWW("WebSocket","state",state)

 Set msg=state_reason
 Set frame=$$Masking^WWWws("close",msg,unfragmented)

 Set ^WWW("websocket","connections",sockid)="CLOSING"

 Do SendSync^WWWws(sockid,frame)

 Quit
 
 
 CloseAsync(sockid,state,reason)
 
 Set control=1
 Set unfragmented=1

 Set state=^WWW("WebSocket","state",state)

 Set msg=state_reason
 Set frame=$$Masking^WWWws("close",msg,unfragmented)
 
 Set ^WWW("websocket","connections",sockid)="CLOSING"

 Do Enqueue^WWWws(sockid,frame,control)
 Do EventTrigger("CLOSE")
 
 Quit
 

Receive(sockid,key,protocol)

 Set msg=^WWW("websocket","connections",sockid,"message")
 Kill ^WWW("websocket","connections",sockid,"message")

 Set msg=$$Decipher^WWWws(msg,key)
 
 Do @^WWW("websocket","protocol",protocol,"routine")

 Quit


EventTrigger(event)

 If ^WWW("trigger")=1 Quit

 Set ^WWW("trigger")=1
 Set trigger="trigger"

 Open trigger:(CONNECT="localhost:"_^WWW("port")_":TCP")::"SOCKET"
 
 Use trigger Write event

 Close trigger 

 Quit 
