sc stop "CLS Client Service"

taskkill /f /im CLSUserClient.exe

MsiExec /qn /X{4441A97E-8750-4A01-98FF-06BD12CF4443}