
:: del "C:\windows\System32\drivers\etc\hosts" /s /f /q

@echo off 

set `hostspath`=%windir%\System32\drivers\etc\hosts 

:: echo 62.116.159.4 message.mcafee.com >> `%hostspath%`   
:: echo 217.160.113.37 message123.mcafee.com >> `%hostpath%` 

exit 