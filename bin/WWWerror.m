WWWerror;


ERROR(code)

 Set $Ztrap="Do ErrorTrap^WWWerror"

 Do Log^WWWlog("Error http: "_code)

 Set head=^WWW("http","states",code)_$Char(13,10)
 Set head=head_^WWW("mimes","html")_$Char(13,10)

 If (code=401) Do
 . Set head=head_"WWW-Authenticate: Basic realm="_^WWW("realm")_$Char(13,10)

 Do Log^WWWlog("Error head: "_head)

 If ($Data(^WWW("http","error",code))) Do  Quit
 . Set path=^WWW("localpath")_^WWW("http","error",code)
 . Do File(path,head)

 Set head=head_$Char(13,10)

 Do Send^WWWutils($IO,head)

 Quit


File(filepath,head)

 Set io=$IO
 Set max=1024*1024

 Set size=$$FileSize^WWWutils(path)
  
 If (size=-1) Do  Quit
 . Set head=head_$Char(13,10) 
 . Do Send^WWWutils(io,head)

 Set head=head_"Content-Length: "_size_$Char(13,10,13,10)

 Do Send^WWWutils(io,head)
 Do SendFile^WWWutils(io,filepath)

 Quit


ErrorTrap

 Set $Ztrap=""
 Set ^WWW("state")="Error: Server stopped! Please view logfile for more information."
 Do Log^WWWlog($Zstatus)

 halt


ParseError(code,row)

 Set str="Error!"

 If (code=1) Set str="Error: Can't open configfile: "_$Zstatus
 If (code=2) Set str="Error: Parse Error in Line "_row

 Set ^WWW("state")=str

 Halt
