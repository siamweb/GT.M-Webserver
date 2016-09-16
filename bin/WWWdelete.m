WWWdelete;

DELETE(sockid)

 Set $Ztrap="Do ErrorTrap^WWWerror"

 Set path=^WWW("con",sockid,"path")

 If ($Data(^WWWDATA(path))) Do  Quit
 . Do Data(sockid)
 . Kill ^WWW("con",sockid)

 Do ERROR^WWWerror(409)
 Kill ^WWW("con",sockid)

 Quit


Data(sockid)

 Set path=^WWW("con",sockid,"path")

 Set varparam=^WWWDATA(path)

 Kill @varparam
 Kill ^WWWDATA(path)

 Do Response(sockid,200)

 Quit


Response(sockid,state)

 Set head=^WWW("http","states",state)_$Char(13,10)
 Set head=head_"Server: "_^WWW("server")_$Char(13,10)

 Set head=head_$Char(13,10)

 Set body="Deleted! URL: """_path_""""

 Do Send^WWWutils($IO,head)
 Do Send^WWWutils($IO,body)

 Quit
