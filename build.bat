del ..\working.sfc
copy ..\alttp.sfc ..\working.sfc
asar.exe LTTP_RND_GeneralBugfixes.asm ..\working.sfc
@echo %cmdcmdline%|find /i """%~f0""">nul && cmd /k
