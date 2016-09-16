WWWpost;

POST(sockid)

 Set $Ztrap="Do ErrorTrap^WWWerror"

 Set path=^WWW("con",sockid,"path")

 If ($Data(^WWW("http","protocol",path,"routine"))) Do  Quit
 . Set data=^WWW("con",sockid,"body")
 . Do Routine(path,data)
 . Kill ^WWW("con",sockid)

 If ($Data(^WWWDATA(path))) Do  Quit
 . Do Data(sockid,path)
 . Kill ^WWW("con",sockid)

 Do ERROR^WWWerror(sockid,409)
 Kill ^WWW("con",sockid)

 Quit


Routine(path,data)

 Set msg=$$@^WWW("http","protocol",path,"routine")

 Do Send^WWWutils($IO,msg)

 Quit


Data(sockid)

 Set path=^WWW("con",sockid,"path")

 For  Do  Quit:$Data(@varparam)=0
 . Set ident="doc"_$Random(999999)
 . Set newpath=path_"/"_ident

 For  Do  Quit:$Data(@varparam)=0
 . Set varparam="^ID"_$Random(999999)

 Do Save(sockid,newpath,varparam)

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
