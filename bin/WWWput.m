WWWput;

PUT(sockid)

 Set $Ztrap="Do ErrorTrap^WWWerror"

 Set path=^WWW("con",sockid,"path")

 If ($Data(^WWW("http","routines",path,"routine"))'=0) Do  Quit
 . Do ERROR^WWWerro(sockid,409)

 If ($Data(^WWW("http","file",path,"path"))'=0) Do  Quit
 . Do ERROR^WWWerror(sockid,409)

 If ($Data(^WWWDATA(path))'=0) Do  Quit
 . Do Update(sockid)
 . Kill  ^WWW("con",sockid)

 Do Create(sockid)

 Kill ^WWW("con",sockid)

 Quit


Update(sockid)

 If ($Data(^WWW("con",sockid,"head","X-Revision"))=0) Do  Quit
 . Do ERROR^WWWerror(sockid,400)

 Set path=^WWW("con",sockid,"path")

 If (^WWW("con",sockid,"head","X-Revision")'=^WWWDATA(path,"rev")) Do  Quit
 . Do ERROR^WWWerror(sockid,409)

 Set ^WWWDATA(path,"rev")=^WWWDATA(path,"rev")+1

 Kill @^WWWDATA(path)

 Do Save(sockid,path,^WWWDATA(path))

 Do Response(sockid,200)

 Quit


Create(sockid)

 Set path=^WWW("con",sockid,"path")

 For  Do  Quit:$Data(@varparam)=0
 . Set varparam="^ID"_$Random(999999)

 Do Save(sockid,path,varparam)

 Set ^WWWDATA(path)=varparam
 Set ^WWWDATA(path,"rev")=1

 Set varparam=varparam_"("""path""")"
 Set @varparam=path

 Do Response(sockid,201)

 Quit


Save(sockid,path,varparam)

 Set varparam=varparam_"(""data"",x)"

 If (^WWW("con",sockid,"body","split")=0) Do  Quit
 . Set x=0
 . Set @varparam=^WWW("con",sockid,"body")

 For  Do  Quit:x=""
 . Set x=$Order(^WWW("con",sockid,"body",x))
 . Quit:x=""
 . Set @varparam=^WWW("con",sockid,"body",x)

 Set ^WWWDATA(path,"length")=^WWW("con",sockid,"body","length")
 Set ^WWWDATA(path,"date")=$Zdate($HOROLOG,"DAY, DD MON YEAR 24:60:SS")
 Set ^WWWDATA(path,"auth")=0
 Set ^WWWDATA(path,"type")="text/plain"
 
 If $Data(^WWW("con",sockid,"head","Content-Type"))'=0 Do
 . Set ^WWWDATA(path,"type")=^WWW("con",sockid,"head","Content-Type")

 If $Data(^WWW("con",sockid,"head","X-Authenticate"))'=0 Do
 . Set ^WWWDATA(path,"auth")=^WWW("con",sockid,"head","X-Authenticate")

 Quit


Response(sockid,state)

 Set path=^WWW("con",sockid,"path")

 Set head=^WWW("http","states",state)_$Char(13,10)
 Set head=head_"Server: "_^WWW("server")_$Char(13,10)
 Set head=head_"Last-Modified: "_^WWWDATA(path,"date")_$Char(13,10)
 Set head=head_"X-Revision: "_^WWWDATA(path,"rev")_$Char(13,10)
 Set head=head_"X-Authenticate: "_^WWWDATA(path,"auth")_$Char(13,10)
 Set head=head_"Content-Type: "_^WWWDATA(path,"type")_$Char(13,10)

 Set body="Created! URL: """_path_""""

 If (state=200) Set body="Updated! URL: """_path_""""

 Set head=head_"Content-Length: "_$Length(body)_$Char(13,10)
 Set head=head_$Char(13,10)

 Do Send^WWWutils($IO,head)
 Do Send^WWWutils($IO,body)

 Quit
