WWWget;


GET(sockid)

 Set $Ztrap="Do ErrorTrap^WWWerror"

 Set path=^WWW("con",sockid,"path")

 If (path="/") Do  Quit
 . Do Index
 . Kill ^WWW("con",sockid)

 If ($Data(^WWW("http","routines",path,"routine"))) Do  Quit
 . Set data=^WWW("con",sockid,"query")
 . Do Routine(path,data)
 . Kill ^WWW("con",sockid)

 If ($Data(^WWWDATA(path))) Do  Quit
 . Do Data(path)
 . Kill ^WWW("con",sockid)

 Set filepath=^WWW("filepath")_^WWW("con",sockid,"path")

 If ($Data(^WWW("http","files",path,"path"))'=0) Do 
 . Set filepath=^WWW("filepath")_^WWW("http","files",path,"path")

 Set size=$$FileSize^WWWutils(filepath)

 If (size=-1) Do ERROR^WWWerror(404) Quit

 Do File(filepath,size)

 Kill ^WWW("con",sockid)

 Quit


Index

 Do Log^WWWlog("Sending index")

 Set body=$$Create^WWWindex

 Set head=^WWW("http","states",200)_$Char(13,10)

 Set head=head_"Server: "_^WWW("server")_$Char(13,10)
 Set head=head_"Content-Length: "_$Length(body)_$Char(13,10)
 Set head=head_^WWW("mimes","html")_$Char(13,10)

 Set head=head_$Char(13,10)

 Do Send^WWWutils($IO,head)
 Do Send^WWWutils($IO,body)

 Quit


Routine(path,data)

 Do Log^WWWlog("Running routine: "_path)

 Do @^WWW("http","routines",path,"routine")

 Quit


Data(path)

 Do Log^WWWlog("Sending data: "_path)

 Set head=^WWW("http","states",200)_$Char(13,10)

 Set head=head_"Server: "_^WWW("server")_$Char(13,10)
 Set head=head_"Last-Modified: "_^WWWDATA(path,"date")_$Char(13,10)
 Set head=head_"Content-Length: "_^WWWDATA(path,"length")_$Char(13,10)
 Set head=head_"X-Revision: "_^WWWDATA(path,"rev")_$Char(13,10)
 Set head=head_"X-Authenticate: "_^WWWDATA(path,"auth")_$Char(13,10)

 If $Data(^WWWDATA(path,"type"))'=0 Do
 . Set head=head_^WWW("mimes",^WWWDATA(path,"type"))_$Char(13,10)

 Set head=head_$Char(13,10)

 Do Send^WWWutils($IO,head)

 Set varparam=^WWWDATA(path)_"(""data"",x)"

 Set x=""

 For  Do  Quit:x=""
 . Set x=$Order(@varparam)
 . Quit:x=""
 . Do Send^WWWutils($IO,@varparam)

 Quit


File(filepath,size)

 Do Log^WWWlog("Sending file: "_filepath)

 Set io=$IO

 Set head=^WWW("http","states",200)_$Char(13,10)

 Set head=head_"Server: "_^WWW("server")_$Char(13,10)
 Set head=head_"Content-Length: "_size_$Char(13,10)

 Set mime=$$GetMime^WWWutils(filepath)

 If ($Data(^WWW("mimes",mime))'=0) Do
 . Set head=head_^WWW("mimes",mime)_$Char(13,10)

 Set head=head_$Char(13,10)

 Do Send^WWWutils(io,head)

 Do SendFile^WWWutils(io,filepath)

 Quit
