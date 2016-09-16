examples;

Chat(sockid,data)

 Set channel="chat"

 Do Send^WWWinterface(channel,data)

 Quit


Superchat(sockid,data)

 Set channel="chat"

 Do Send^WWWinterface(channel,data)

 Quit


Time(data)

 Set head=^WWW("http","states",200)_$Char(13,10)
 Set head=head_$Char(13,10)

 Set body=$Zdate($horolog,"24:60:SS DD.MM.YEAR")

 Do Response^WWWinterface(head,body)

 Quit
