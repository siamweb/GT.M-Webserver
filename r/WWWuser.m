WWWuser;


Create(name,password)

 Set ^WWWUSER(name)=$$Encoding(name,password)

 Write "User "_name_" crated",!

 Quit


Delete(name)

 Kill ^WWWUSER(name)

 Use $IO Write "User "_name_" deleted",!

 Quit


ChangePassword(name,old,new)

 Set dummy=$$Encoding(name,old)

 If dummy'=^WWWUSER(name) Do  Quit
 . Write "Wrong password",!

 Set ^WWWUSER(name)=$$Encoding(name,new)
 
 Quit


ShowUser

 Set x=""

 For  Do  Quit:x=""
 . Set x=$Order(^WWWUSER(x))
 . Quit:x=""
 . Write x,!

 Quit


Encoding(name,password)

 Set io=$IO

 Set pipe="base64"
 
 Set shellcmd="/bin/echo -n """_name_":"_password_""" | openssl base64 "
 
 Open pipe:(command=shellcmd:readonly)::"PIPE"
 
 Use pipe Read shellout Close pipe Use io

 Set hash="Basic "_shellout
 
 Quit hash
