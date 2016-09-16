WWWparse;


Start(filepath)

 new DEPTH,ROW

 Set DEPTH=0
 Set ROW=0

 Open filepath:(READONLY:EXCEPTION="Do ParseError^WWWerror(1,0)")

 Use filepath:EXCEPTION="goto EOF"

 For  Read line Do ProcessLine(line)

 Quit


EOF

 Close filepath

 Quit


ProcessLine(line)

 Set ROW=ROW+1

 If ($$Trim(line)="") Quit

 Set comment=$Find(line,"#")

 If (comment=2) Quit
 If (comment>2) Set line=$Extract(line,1,comment-2)

 If ($Find(line,":")=0) Do ParseError^WWWerror(2,ROW)

 Set key=$Piece(line,":",1)
 Set value=($Piece(line,":",2,999999))

 If ($$LeadingSpaces(value)=1) Do ParseError^WWWerror(2,ROW)

 Set spaces=$$LeadingSpaces(key)

 If (DEPTH>0) Do
 . For i=DEPTH:-1:1 Do
 . . If (spaces<=DEPTH(DEPTH-1,"spaces")) Set DEPTH=DEPTH-1

 Set DEPTH(DEPTH)=$$Trim(key)
 Set DEPTH(DEPTH,"spaces")=spaces

 If (value="") Do  Quit
 . Set DEPTH=DEPTH+1

 Set varparam="^WWW("""

 For i=0:1:DEPTH Do
 . Set varparam=varparam_DEPTH(i)
 . If (i'=DEPTH) Set varparam=varparam_""","""

 Set varparam=varparam_""")"

 Set @varparam=$$Trim(value)

 Quit


Trim(str)

 Set i=$$LeadingSpaces(str)
 For j=$$FollowingSpaces(str)

 Quit $Extract(str,i,j)


LeadingSpaces(str)

 new i

 If (str="") Quit 0
 For i=1:1:$Length(str) Set char=$Extract(str,i) Quit:(" "'=char)&($Char(9)'=char)

 Quit i


FollowingSpaces(str)

 new i

 If (str="") Quit 0
 For i=$Length(str):-1:1 Set char=$Extract(str,i) Quit:(" "'=char)&($Char(9)'=char)

 Quit i
