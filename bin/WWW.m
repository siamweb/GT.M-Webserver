WWW; 


Start   

 Do Init^WWWconf

 Do Log("Server starting")

 Set ^WWW("sockdev")=^WWW("localhost")_":"_^WWW("port")

 Open ^WWW("sockdev"):(ZLISTEN=^WWW("port")_":TCP":ATTACH=^WWW("socket"))::"SOCKET" 
 
 Use ^WWW("sockdev"):SOCKET=^WWW("socket") Write /listen(5)

 Do Loop

 Close ^WWW("sockdev") 

 Quit

Loop
 
 Use ^WWW("sockdev"):SOCKET=^WWW("socket") 

 Write /wait(5)

 Set key=$KEY
 Set state=$Piece(key,"|",1)
 Set child=$Piece(key,"|",2)
 Set ip=$Piece($Piece(key,"|",3),":",4)
                                           
 If (^WWW("trigger")=1)&(ip=^WWW("localhost")) Do 
 . Do Trigger(child)
 . Goto Loop 

 If state="CONNECT" Do
 . Do Log("Connection established, Connection="_child_", ip="_ip)
 . Set ^WWW("http","connections",child)="OPEN"
 . Set ^WWW("http","connections",child,"time")=$HOROLOG                  

 If state="READ" Do
 . If $$Contains^WWWws(child) Do Read^WWWws(child) Quit
 . Do Read^WWWhttp(child,ip)

 Do TimeOut

 If ^WWW("cmd")'="STOP" Goto Loop

 Quit


TimeOut

 Set x=""

 For  Do  Quit:x=""
 . Set x=$Order(^WWW("websocket","connections",x))
 . Quit:x=""
 . Set timedif=$$Timer(^WWW("websocket","connections",x,"time"))
 . If (^WWW("websocket","connections",x)="CLOSING")&(timedif>5) Do
 . . Do Close^WWWws(x)
 . . Do Log("Close was not clean socket="_x)

 For  Do  Quit:x=""
 . Set x=$Order(^WWW("http","connections",x))
 . Quit:x=""
 . Set timedif=$$Timer(^WWW("http","connections",x,"time"))
 . If (^WWW("http","connections",x)="RECEIVING")&(timedif>15) Do  Quit
 . . Do Error^WWWres(x,408)

 Quit


Trigger(sockid)

 Use ^WWW("sockdev"):SOCKET=sockid 
 
 Read in 
 
 Close ^WWW("sockdev"):SOCKET=sockid
 
 Do Log("Sendetrigger received msg="_in)
 Do Send^WWWws 
 
 Quit


Timer(time)
 
 If time="" Quit 0

 Set current=$HOROLOG

 Set days=$Piece(current,",",1)-$Piece(time,",",1)
 Set seconds=$Piece(current,",",2)-$Piece(time,",",2)

 If days>0 Do
 . Set seconds=((days*100000)+$Piece(current,",",2))-$Piece(time,",",2)

 Quit seconds


Stop
 Set ^WWW("cmd")="STOP"
 Quit
 

Log(str)
 New previo
 Set previo=$IO
 Use $Principal
 Write $Zdate($horolog,"MON DD, YYYY 24:60:SS")," ",str,!
 Use previo
 Quit
