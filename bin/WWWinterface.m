WWWinterface;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;http
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Response(head,body)

 Do Send^WWWutils($IO,head)
 Do Send^WWWutils($IO,body)

 Quit


Error(code)

 Do ERROR^WWWerror(code)

 Quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;websocket
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Send(channel,msg)

 Do Log^WWWlog("Sending")

 Set frame=$$Masking^WWWwebsocket("text",msg,1)
 Set count=^WWW("websocket","channels",channel)
 Set type="normal"

 Set funcparam="Send^WWWwebsocket(sockid,frame)"
 If (^WWW("pid")'=$JOB) Set funcparam="Enqueue^WWWwebsocket(sockid,frame,type)"

 Do Log^WWWlog("Funcparam: "_funcparam)

 For i=0:1:count-1 Do
 . Set sockid=^WWW("websocket","channels",channel,i)
 . Do Log^WWWlog("Enqueue in sockid: "_sockid)
 . Do @funcparam

 If (^WWW("pid")'=$JOB) Do EventTrigger^WWWwebsocket("SEND")

 Quit


Close(sockid,state,reason)

 Set state=^WWW("WebSocket","states",state)

 Set msg=state_reason
 Set frame=$$Masking^WWWws("close",msg,1)

 If (^WWW("pid")'=$ZJOB) Do  Quit
 . Do Enqueue^WWWwebsocket(sockid,msg,"close")
 . Do EventTrigger^WWWwebsocket("CLOSE")

 Do Send^WWWwebsocket(sockid,msg)

 Set ^WWW("con",sockid)="CLOSING"
 Set ^WWW("con",sockid,"time")=$Zdate($Horolog,"SS6024DDMMYEAR")

 Quit


Ping(sockid)

 Set frame=$$Masking^WWWws("ping",msg,1)

 If (^WWW("pid")'=$JOB) Do  Quit
 . Do Enqueue^WWWwebsocket(sockid,msg,"ping")
 . Do EventTrigger^WWWwebsocket("PING")

 Do Send^WWWwebsocket(sockid,msg)

 Quit


Pong(sockid)

 Set frame=$$Masking^WWWws("pong",msg,1)

 If (^WWW("pid")'=$JOB) Do  Quit
 . Do Enqueue^WWWwebsocket(sockid,msg,"pong")
 . Do EventTrigger^WWWwebsocket("PONG")

 Do Send^WWWwebsocket(sockid,msg)

 Quit


CreateChannel(channel)

 Set ^WWW("websocket","channels",channel)=0

 Quit


Register(sockid,channel)

 Do Register^WWWwebsocket(sockid,channel)

 Quit


Unregister(sockid,channel)

 Do Unregister^WWWwebsocket(sockid,channel)

 Quit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;database
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetData(path,index)

 Set varparam=^WWWDATA(path)_"(index)"

 Quit @varparam


SetData(path,data,index)

 Set varparam=^WWWDATA(path)
 Set varparam=varparam_"(index)"

 Set @varparam=data

 Quit


CreateData(path,length,type,auth)

 For  Do  Quit:$Data(@varparam)=0
 . Set varparam="^ID"_$Random(999999)

 Set varparam=varparam_"("""_path_""")"
 Set @varparam=path

 Set ^WWWDATA(path,"length")=length
 Set ^WWWDATA(path,"type")=type
 Set ^WWWDATA(path,"auth")=auth
 Set ^WWWDATA(path,"date")=$Zdate($HOROLOG,"DAY, DD MON YEAR 24:60:SS")
 Set ^WWWDATA(path,"rev")=1

 Quit


DeleteData(path)

 Set varparam=^WWWDATA(path)

 Kill @varparam
 Kill ^WWWDATA(path)

 Quit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;user
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CreateUser(name,password)

 Set ^WWWUSER(name)=$$EncodingUser^WWWutils(name,password)

 Quit


UpdateUser(name,passold,passnew)

 Set dummy=$$EncodingUser^WWWutils(name,passold)

 If dummy'=^WWWUSER(name) Quit 0

 Set ^WWWUSER(name)=$$EncodingUser^WWWutils(name,passnew)

 Quit 1


DeleteUser()

 Kill ^WWWUSER(name)

 Quit
