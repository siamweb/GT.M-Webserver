Chat;


Chat(sockid,data)

 Set type="text"
 Set protocol="/chat"
 Set unfragmented=1

 Do Send^WWWwsi(type,data,protocol,unfragmented)

 Quit

Superchat(sockid,data)

 Set type="text"
 Set protocol="/superchat"
 Set unfragmented=1

 Do Send^WWWwsi(type,data,protocol,unfragmented)

 Quit
