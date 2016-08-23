WWWdata;


Get(uri)

 Set uri=$$CheckURI(uri)

 Set varparam=$$Pathtovar^WWWhttp(uri)
 Set data=""

 If $Data(@varparam)'=0 Set data=@varparam

 Quit data


Put(uri,type,data,auth)

 Set uri=$$CheckURI(uri)

 If $Data(^WWW("http","path",uri))'=0 Do  Quit
 . Write "Error URI as Website already existing!"

 If $Data(^WWW("http","protocol",uri,"routine"))'=0 Do  Quit
 . Write "Error URI as Routine already existing!"

 Set varparam=$$Pathtovar^WWWhttp(uri)

 If $Data(^WWWHTTPDATA(uri)) Do  Quit
 . Write "Error Data already existing!"

 Set @varparam=data

 Set ^WWWHTTPDATA(uri,"length")=$Length(data)
 Set ^WWWHTTPDATA(uri,"date")=$Zdate($HOROLOG,"DAY, DD MON YEAR 24:60:SS")
 Set ^WWWHTTPDATA(uri,"rev")=1
 Set ^WWWHTTPDATA(uri,"auth")=auth
 
 If $Data(^WWW("http","files","mime",type))=0 Set type="plain"
 Set ^WWWHTTPDATA(uri,"type")=type

 write "Data created: "_uri

 Quit


Update(uri,type,data,auth,rev)

 Set uri=$$CheckURI(uri) 

 Set varparam=$$Pathtovar^WWWhttp(uri)

 If $Data(@varparam)=0 Do  Quit
 . Write "Error URI not found!"

 If rev'=^WWWHTTPDATA(uri,"rev") Do  Quit
 . Write "Error Revision is not equal!"

 Set @varparam=data
 
 Set ^WWWHTTPDATA(uri,"auth")=auth
 Set ^WWWHTTPDATA(uri,"length")=$Length(data)
 Set ^WWWHTTPDATA(uri,"date")=$Zdate($HOROLOG,"DAY, DD MON YEAR 24:60:SS")
 
 If $Data(^WWW("http","files","mime",type))=0 Set type="plain"
 Set ^WWWHTTPDATA(uri,"type")=type

 Set ^WWWHTTPDATA(uri,"rev")=^WWWHTTPDATA(uri,"rev")+1

 Write "Data updated: "_uri

 Quit


Post(uri,type,data,auth)

 Set uri=$$CheckURI(uri) 

 Set varparam=$$Pathtovar^WWWhttp(uri)

 If $Data(@varparam)=0 Do  Quit
 . Write "Error URI not found!"

 For  Do  Quit:$Data(@varparam)=0
 . Set ident="doc"_$Random(999999)
 . Set newpath=uri_"/"_ident
 . Set varparam=$$Pathtovar^WWWhttp(newpath)

 Set @varparam=data

 Set ^WWWHTTPDATA(newpath,"length")=$Length(data)
 Set ^WWWHTTPDATA(newpath,"date")=$Zdate($HOROLOG,"DAY, DD MON YEAR 24:60:SS")
 Set ^WWWHTTPDATA(newpath,"rev")=1
 Set ^WWWHTTPDATA(newpath,"auth")=auth
 
 If $Data(^WWW("http","files","mime",type))=0 Set type="plain"
 Set ^WWWHTTPDATA(newpath,"type")=type

 Write "Data created: "_newpath

 Quit


Delete(uri)

 Set uri=$$CheckURI(uri)

 Set varparam=$$Pathtovar^WWWhttp(uri)

 If $Data(@varparam)=0 Do  Quit
 . Write "Error URI not found!"

 Kill @varparam
 Kill ^WWWHTTPDATA(uri)

 Write "Data deleted!"

 Quit


Show(uri)

 Set uri=$$CheckURI(uri)

 Set varparam=$$Pathtovar^WWWhttp(uri)

 If $Data(@varparam)=0 Do  Quit
 . Write "Error URI not found!"

 Set data=@varparam

 Write "Length: "_^WWWHTTPDATA(uri,"length")_$Char(13,10)
 Write "Type: "_^WWWHTTPDATA(uri,"type")_$Char(13,10)
 Write "Last Modified: "_^WWWHTTPDATA(uri,"date")_$Char(13,10)
 Write "Revision: "_^WWWHTTPDATA(uri,"rev")_$Char(13,10)

 Write "Data: "_data

 Quit


CheckURI(uri)

 Set length=$Length(uri)

 If (length>1)&($Extract(uri,length,length)="/") Do
 . Set uri=$Extract(uri,1,length-1)
 
 If $Extract(uri,1,1)'="/" Do
 . Set uri="/"_uri
 
 Quit uri