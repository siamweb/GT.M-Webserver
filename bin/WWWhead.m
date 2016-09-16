WWWhead;

HEAD(sockid)

 Set $Ztrap="Do ErrorTrap^WWWerror"

 If ($Data(^WWWDATA(path))) Do  Quit
 . Do Data(sockid,path)
 . Kill ^WWW("con",sockid)

 Set filepath=^WWW("localpath")_^WWW("con",sockid,"path")

 If ($Data(^WWW("http",path,"file")))'=0 Do 
 . Set filepath=^WWW("localpath")_^WWW("http",path,"file")

 Set size=$$FileSize^WWWutils(filepath)

 If (size=-1) Do ERROR^WWWerror(404) Quit

 Do File(filepath,size)

 Kill ^WWW("con",sockid)

 Quit


Data(sockid,path)

 Set head=^WWW("http","states",200)_$Char(13,10)

 Set head=head_"Server: "_^WWW("server")_$Char(13,10)
 Set head=head_"Last-Modified: "_^WWWDATA(path,"date")_$Char(13,10)
 Set head=head_"Content-Length: "_^WWWDATA(path,"length")_$Char(13,10)
 Set head=head_"X-Revision: "_^WWWDATA(path,"rev")_$Char(13,10)
 Set head=head_"X-Authenticate: "_^WWWDATA(path,"auth")_$Char(13,10)

 If $Data(^WWWDATA(path,"type"))'=0 Do
 . Set head=head_^WWW("http","files","mime",^WWWDATA(path,"type"))_$Char(13,10)

 Set head=head_$Char(13,10)

 Do Send^WWWutils($IO,head)

 Quit


File(filepath,size)

 Set head=^WWW("http","states",200)_$Char(13,10)

 Set head=head_"Server: "_^WWW("server")_$Char(13,10)
 Set head=head_"Content-Length: "_size_$Char(13,10)

 Set mime=$$GetMime^WWWutils(filepath)

 If ($Data(^WWW("mimes",mime))'=0) Do
 . Set head=head_^WWW("mimes",mime)_$Char(13,10)

 Set head=head_$Char(13,10)

 Do Send^WWWutils(io,head)

 Quit
