Our web application runs on a Windows Virtual Machine (VM).  I want to execute `Python` within a `Windows` `BAT` file so that I can easily run a generic script with a few clicks.  

I can run a multiline `Python` string like -

```cmd
0<0# : ^
'''
:: my bat file setup
python %~f0 %* 
exit /b 0
'''

# my python script

exit()

```

> https://stackoverflow.com/questions/71373956/execute-multi-line-python-code-inside-windows-batch-script/71376176#71376176

#python
#windows