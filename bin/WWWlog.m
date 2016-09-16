WWWlog;

Create

 Open ^WWW("logfile"):newversion

 Use ^WWW("logfile")

 Write "####################",!
 Write "# Logfile "_$Zdate($horolog,"MON DD, YYYY 24:60:SS"),!
 Write "####################",!

 Close ^WWW("logfile")

 Quit


Log(str)

 Set previo=$IO

 Open ^WWW("logfile"):APPEND

 Use ^WWW("logfile")

 Write $Zdate($horolog,"MON DD, YYYY 24:60:SS")," ",str,!
 
 Close ^WWW("logfile")

 Use previo
 
 Quit
