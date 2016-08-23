wwwconf;


Init

 Kill ^WWW,^WWWSOCKETDATA,^WWWSOCKETLIST

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;Changable Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;Environment Variables
 Set ^WWW("localpath")=$ZDirectory_"/www"
 Set ^WWW("localhost")="127.0.0.1"
 Set ^WWW("port")=9080
 Set ^WWW("recordsize")=1048576 
 Set ^WWW("domain")="www.example.com"
 Set ^WWW("server")="GTMServer/1.0 (Unix)"

 ;URIs
 Set ^WWW("http","path","/")="/index.html"
 Set ^WWW("http","path","/","auth")=0

 Set ^WWW("http","path","/chat")="/chat.html"
 Set ^WWW("http","path","/chat","auth")=0

 ;CGI Routines
 ;Set ^WWW("http","protocol","/routine/example","routine")="exampleFunction^exampleFile(head,data)"
 ;Set ^WWW("http","protocol","/routine/example","auth")=1

 ;WebSocket Routines
 ;Set ^WWW("websocket","protocol","/example","routine")="exampleFunction^exampleFile(sockid,msg)"
 ;Set ^WWW("websocket","protocol","/example","sub")="example"
 ;Set ^WWW("websocket","protocol","/example","sync")=0

 Set ^WWW("websocket","protocol","/chat","routine")="Chat^Routines(sockid,msg)"
 Set ^WWW("websocket","protocol","/chat","sub")="chat, superchat"
 Set ^WWW("websocket","protocol","/chat","sync")=0

 Set ^WWW("websocket","protocol","/superchat","routine")="Superchat^Routines(sockid,msg)"
 Set ^WWW("websocket","protocol","/superchat","sub")="chat, superchat"
 Set ^WWW("websocket","protocol","/superchat","sync")=1

 ;Error Pages
 Set ^WWW("http","state",404,"page")="/error/404.html"


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;Unchangable Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;MIME-Types
 Set ^WWW("http","files","mime","acad")="Content-Type: application/acad"
 Set ^WWW("http","files","mime","dwg")="Content-Type: application/acad"

 Set ^WWW("http","files","mime","applefile")="Content-Type: application/applefile"

 Set ^WWW("http","files","mime","astound")="Content-Type: application/astound"
 Set ^WWW("http","files","mime","asd")="Content-Type: application/astound"
 Set ^WWW("http","files","mime","asn")="Content-Type: application/astound"

 Set ^WWW("http","files","mime","dsptype")="Content-Type: application/dsptype"
 Set ^WWW("http","files","mime","tsp")="Content-Type: application/dsptype"

 Set ^WWW("http","files","mime","dxf")="Content-Type: application/dxf"

 Set ^WWW("http","files","mime","futuresplash")="Content-Type: application/futuresplash"
 Set ^WWW("http","files","mime","spl")="Content-Type: application/futuresplash"

 Set ^WWW("http","files","mime","gzip")="Content-Type: application/gzip"
 Set ^WWW("http","files","mime","gz")="Content-Type: application/gzip"

 Set ^WWW("http","files","mime","jpeg")="Content-Type: image/jpeg"
 Set ^WWW("http","files","mime","jpg")="Content-Type: image/jpeg"

 Set ^WWW("http","files","mime","png")="Content-Type: image/png"

 Set ^WWW("http","files","mime","plain")="Content-Type: text/plain"
 Set ^WWW("http","files","mime","txt")="Content-Type: text/plain"

 Set ^WWW("http","files","mime","json")="Content-Type: application/json"
 Set ^WWW("http","files","mime","html")="Content-Type: text/html; charset=utf-8"

 ;HTTP Errorstates 
 Set ^WWW("http","state",101)="HTTP/1.1 101 Switching Protocols"
 Set ^WWW("http","state",200)="HTTP/1.1 200 OK"
 Set ^WWW("http","state",201)="HTTP/1.1 201 Created"
 Set ^WWW("http","state",400)="HTTP/1.1 400 Bad Request"
 Set ^WWW("http","state",401)="HTTP/1.1 401 Unauthorized"
 Set ^WWW("http","state",401,"head")="WWW-Authenticate: Basic realm="""_^WWW("server")_""""
 Set ^WWW("http","state",404)="HTTP/1.1 404 Not Found"
 Set ^WWW("http","state",408)="HTTP/1.1 408 Request Time-out"
 Set ^WWW("http","state",409)="HTTP/1.1 409 Conflict"
 Set ^WWW("http","state",413)="HTTP/1.1 413 Request Entity Too Large"
 Set ^WWW("http","state",501)="HTTP/1.1 501 Not Implemented"
 Set ^WWW("http","state",503)="HTTP/1.1 503 Service Unavailable"

 ;HTTP Methoddistributor
 Set ^WWW("http","distributor","GET")="GET(sockid)"
 Set ^WWW("http","distributor","POST")="POST(sockid)"
 Set ^WWW("http","distributor","PUT")="PUT(sockid)"
 Set ^WWW("http","distributor","DELETE")="DELETE(sockid)"
 Set ^WWW("http","distributor","HEAD")="HEAD(sockid)" 

 ;Websocket Errorstates
 Set ^WWW("websocket","state",1000)=$Char(3,232)
 Set ^WWW("websocket","state",1001)=$Char(3,233)
 Set ^WWW("websocket","state",1002)=$Char(3,234)
 Set ^WWW("websocket","state",1003)=$Char(3,235)
 Set ^WWW("websocket","state",1007)=$Char(3,239)
 Set ^WWW("websocket","state",1008)=$Char(3,240)
 Set ^WWW("websocket","state",1009)=$Char(3,241)
 Set ^WWW("websocket","state",1011)=$Char(3,243)

 Set ^WWW("trigger")=0
 Set ^WWW("cmd")="START"
 Set ^WWW("socket")="server"
 Set ^WWW("maxsockets")=$View("MAX_SOCKETS")

 Set ^WWWSOCKETLIST=0

 ;Not automatically deleted Globals
 Set ^WWWUSER("admin")="Basic YWRtaW46MTIzNA=="

 Set ^WWWDATABASE("data","example")="{""Name"": ""Mustermann"",""Vorname"": ""Max""}"

 Set ^WWWHTTPDATA("/data/example","length")=41
 Set ^WWWHTTPDATA("/data/example","type")="json"
 Set ^WWWHTTPDATA("/data/example","date")="Mon, 21 Dez 2015 09:38:23"
 Set ^WWWHTTPDATA("/data/example","rev")=1
 Set ^WWWHTTPDATA("/data/example","auth")=0

 Quit
