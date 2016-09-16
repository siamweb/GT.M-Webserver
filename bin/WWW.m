WWW; 


Start

 Do Init^WWWinit

 Set ^WWW("sockdev")=^WWW("localhost")_":"_^WWW("port")

 Open ^WWW("sockdev"):(ZLISTEN=^WWW("port")_":TCP":ATTACH=^WWW("socket"))::"SOCKET"

 Use ^WWW("sockdev"):SOCKET=^WWW("socket") Write /listen(5)

 Do Log^WWWlog("Server started on port "_^WWW("port"))

 Do Loop

 Close ^WWW("sockdev")

 Quit


Loop

 If (^WWW("cmd")="STOP") Quit

 Use ^WWW("sockdev"):SOCKET=^WWW("socket") 

 Write /wait(5)

 Set key=$KEY
 Set state=$Piece(key,"|",1)
 Set child=$Piece(key,"|",2)
 Set ip=$Piece($Piece(key,"|",3),":",4)
                                           
 If ((^WWW("trigger")=1)&(ip=^WWW("localhost"))) Do 
 . Do Trigger(child)
 . Goto Loop 

 If (state="CONNECT") Do
 . Do Log^WWWlog("Connection established, Connection="_child_", ip="_ip)
 . Set ^WWW("con",child)="OPEN"
 . Set ^WWW("con",child,"time")=$Zdate($Horolog,"SS6024DDMMYEAR")
 . Set ^WWW("con",child,"websocket")=0

 If (state="READ") Do
 . If ($$Websocket(child)) Do Read^WWWwebsocket(child) Quit
 . Do Read^WWWhttp(child)

 Do Timeout

 Goto Loop

 Quit


Websocket(sockid)

 If ($Data(^WWW("con",sockid,"websocket"))=0) Quit 0

 Quit ^WWW("con",sockid,"websocket")


Timeout

 Set x=""

 For  Do  Quit:x=""
 . Set x=$Order(^WWW("con",x))
 . Quit:x=""
 . Set timedif=$Zdate($Horolog,"SS6024DDMMYEAR")-^WWW("con",x,"time")
 . If (^WWW("con",x)="CLOSING")&(timedif>5) Do
 . . Do Close^WWWws(x)
 . If (^WWW("con",x)="RECEIVING")&(timedif>15) Do  Quit
 . . Do Error^WWWres(x,408)

 Quit


Trigger(sockid)

 Use ^WWW("sockdev"):SOCKET=sockid Read in 
 Close ^WWW("sockdev"):SOCKET=sockid
 
 Do Log^WWWlog("Eventtrigger received: "_in)
 Do SendStack^WWWwebsocket
 
 Quit


Stop

 Set ^WWW("state")="Server Stopped"
 Set ^WWW("cmd")="STOP"
 Quit


Status

 Use $Principal Write ^WWW("state"),!
 Quit
