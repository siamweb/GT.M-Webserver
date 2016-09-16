WWWindex;

Create()

 Set body=""

 For i=1:1 Do  Quit:line=""
 . Set line=$Piece($Text(@("HTML")+i),";",2,255)
 . Quit:line=""
 . If ($Find(line,"$$$")'=0) Set line=$$Links()
 . Set body=body_line_$Char(13,10)

 Quit body


Links()

 Set x=""

 Set links="<h1>Websites</h1>"_$Char(13,10)

 For  Do  Quit:x=""
 . Set x=$Order(^WWW("http","files",x))
 . Quit:x=""
 . Set links=links_"<a href="""_^WWW("http","files",x,"path")_""">"_x_"</a>"_$Char(13,10)

 Set links=links_"<h1>Data</h1>"_$Char(13,10)

 For  Do  Quit:x=""
 . Set x=$Order(^WWWDATA(x))
 . Quit:x=""
 . Set links=links_"<a href="""_x_""">"_x_"</a>"_$Char(13,10)

 Set links=links_"<h1>Routines</h1>"_$Char(13,10)

 For  Do  Quit:x=""
 . Set x=$Order(^WWW("http","routines",x))
 . Quit:x=""
 . Set links=links_"<a href="""_x_""">"_x_"</a>"_$Char(13,10)

 Quit links


HTML;
 ;<!doctype html>
 ;<html>
 ;  <head>
 ;      <meta charset="utf-8" />
 ;      <title>Index</title>
 ;  </head>
 ;  <body>
 ;      $$$
 ;  </body>
 ;</html>
 ;
