WWWutils;


Send(io,msg)

 Set previo=$IO

 Use io:NOWRAP
 Write msg

 Use previo

 Quit


SendFile(io,filepath)

 Set previo=$IO

 Open filepath:(READONLY:FIXED:WRAP:CHSET="M")

 For  Use filepath Read line#^WWW("stringmax") Quit:$ZEOF  Do Send(io,line)

 Close filepath

 Use previo

 Quit


Login(user)

 Set permission=1
 Set x=""

 For  Do  Quit:x=""
 . Set x=$Order(^WWWUSER(x))
 . Quit:x=""
 . If user=^WWWUSER(x) Do
 . . Set permission=0
 . . Do Log^WWWlog("User """_x_""" logged in")
 . . Set x=""

 Quit permission


FileSize(filename)

 Set pipe="size"
 Set shellcmd="[ -f """_filename_""" ] && wc -c """_filename_""" || echo -1"

 Open pipe:(command=shellcmd:readonly)::"PIPE"

 Use pipe Read shellout

 Close pipe

 Set size=$Piece(shellout," ")

 Quit size


GetMime(filepath)

 Set count=$Length(filepath,".")
 Set mime=$Piece(filepath,".",count)

 Quit mime


IntToNum(int)

 New len,num

 Set int=$Char(0)_int

 Set len=$Zbitlen(int)
 Set num=0
 For i=1:1:len Do
 . If $Zbitget(int,(len+1)-i) Set num=num+(2**(i-1))
 
 Quit num


LengthToBit(length)

 New bit,bitlen,tmpbit

 If length<126 Set bit=$Zbitstr(8,0) Set bitlen=8
 Else  If length<65535 Set bit=$Zbitstr(16,0) Set bitlen=16
 Else  Set bit=$Zbitstr(64,0) Set bitlen=64

 For i=0:1 Do  Quit:length=0
 . Set tmpbit(i)=0
 . If length#2=1 Set length=length-1 Set tmpbit(i)=1
 . Set length=length/2

 For j=0:1:i Do
 . Set bit=$Zbitset(bit,bitlen-j,tmpbit(j))

 Set bit=$Zextract(bit,2,99)
 
 Quit bit


EncodingUser(name,password)

 Set io=$IO

 Set pipe="base64"
 
 Set shellcmd="/bin/echo -n """_name_":"_password_""" | openssl base64 "
 
 Open pipe:(command=shellcmd:readonly)::"PIPE"
 
 Use pipe Read shellout Close pipe Use io

 Set hash="Basic "_shellout
 
 Quit hash
