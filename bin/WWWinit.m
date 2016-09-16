WWWinit;


Init

 Set $Ztrap="Do ErrorTrap^WWWerror"

 Kill ^WWW

 ;HTTP Methoddistributor
 Set ^WWW("http","distributor","GET")="GET^WWWget(sockid)"
 Set ^WWW("http","distributor","POST")="POST^WWWpost(sockid)"
 Set ^WWW("http","distributor","PUT")="PUT^WWWput(sockid)"
 Set ^WWW("http","distributor","DELETE")="DELETE^WWWdelete(sockid)"
 Set ^WWW("http","distributor","HEAD")="HEAD^WWWhead(sockid)" 

 ;Websocket Errorstates
 Set ^WWW("websocket","states",1000)=$Char(3,232)
 Set ^WWW("websocket","states",1001)=$Char(3,233)
 Set ^WWW("websocket","states",1002)=$Char(3,234)
 Set ^WWW("websocket","states",1003)=$Char(3,235)
 Set ^WWW("websocket","states",1007)=$Char(3,239)
 Set ^WWW("websocket","states",1008)=$Char(3,240)
 Set ^WWW("websocket","states",1009)=$Char(3,241)
 Set ^WWW("websocket","states",1011)=$Char(3,243)

 Set ^WWW("localhost")="127.0.0.1"
 Set ^WWW("trigger")=0
 Set ^WWW("stringmax")=1024*1024 
 Set ^WWW("cmd")="START"
 Set ^WWW("pid")=$JOB
 Set ^WWW("socket")="listener"
 Set ^WWW("maxsockets")=$View("MAX_SOCKETS")
 Set ^WWW("state")="Webserver is running"

 Do Start^WWWparse($ZDirectory_"/../config")

 Set x=""
 For  Do  Quit:x=""
 . Set x=$Order(^WWW("websocket","routines",x))
 . Quit:x=""
 . Set channel=^WWW("websocket","routines",x,"channel")
 . Set ^WWW("websocket","channels",channel)=0

 Set ^WWWUSER("admin")="Basic YWRtaW46MTIzNA=="

 Set ^ID000001("data",0)="{""Name"": ""Mustermann"",""Vorname"": ""Max""}"
 Set ^ID000001("path")="/example"

 Set ^WWWDATA("/example")="^ID000001"
 Set ^WWWDATA("/example","length")=41
 Set ^WWWDATA("/example","type")="json"
 Set ^WWWDATA("/example","date")="Mon, 21 Dez 2015 09:38:23"
 Set ^WWWDATA("/example","rev")=1
 Set ^WWWDATA("/example","auth")=0

 Do Create^WWWlog

 Quit

