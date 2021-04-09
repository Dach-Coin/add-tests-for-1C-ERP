@Echo off

rem Отключение сеансов пользователей при длительном отсутствии активности 
oscript ./uni_script.os /Terminate /S Server1C\DbName /N Админ /P 123456

Timeout /T 3