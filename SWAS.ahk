#SingleInstance Force
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
start:
Run, rsrc\task.bat, %A_ScriptDir%
sleep 1000
ScriptQuotes := A_ScriptFullPath
ScriptQuotes = \"%ScriptQuotes%\"
SplitPath, A_ScriptFullPath, , , , ScriptNameNoExt
IfExist, notask
	{
	nostart=1
	Run *RunAs schtasks.exe /Create /SC onlogon /TN SWAS /TR "%ScriptQuotes%"
	FIleDelete, notask
	}
IfNotExist, %A_ScriptDir%\starters
	{
			filecreatedir, %A_ScriptDir%\starters
	}
IfNotExist, %ScriptNameNoExt%.ini
	{
	IniWrite, 3, %ScriptNameNoExt%.ini, Config, DefaultPreDelay
	IniWrite, 3, %ScriptNameNoExt%.ini, Config, DefaultPostDelay
	IniWrite, 0, %ScriptNameNoExt%.ini, Config, DefaultAdminElevate
	}
IniRead, DefPre, %ScriptNameNoExt%.ini, Config, DefaultPreDelay
IniRead, DefPost, %ScriptNameNoExt%.ini, Config, DefaultPostDelay
IniRead, DefElevate, %ScriptNameNoExt%.ini, Config, DefaultAdminElevate
loop, files, starters\*.lnk
	{
	FileGetShortcut, %A_LoopFilePath% , OutTarget, OutDir, OutArgs, OutDescription, OutIcon, OutIconNum, OutRunState
	SplitPath, A_LoopFilePath,,,,FNameNoExt
	LinkINI = %A_LoopFileDir%\%FNameNoExt%.ini
	IfNotExist, %LinkINI%
		{
		nostart=1
		IniWrite, %OutTarget%, starters\%FNameNoExt%.ini, Action , Target
		IniWrite, %OutArgs%, starters\%FNameNoExt%.ini, Action , Arguments
		IniWrite, %OutDir%, starters\%FNameNoExt%.ini, Action , StartIn
		IniWrite, %DefElevate%, starters\%FNameNoExt%.ini, Admin , RunElevated
		IniWrite, %DefPre%, starters\%FNameNoExt%.ini, Delay , Pre
		IniWrite, %DefPost%, starters\%FNameNoExt%.ini, Delay , Post
		}
	filecreatedir, %A_LoopFileDir%\lnk\
	filemove, %A_LoopFilePath%, %A_LoopFileDir%\lnk\
	}
If (nostart = 1)
		{
		 exitapp
		}
loop, files, starters\*.ini
	{
	IniRead, RunTarget, %A_LoopFilePath%, Action , Target
	IniRead, RunArgs, %A_LoopFilePath%, Action , Arguments
	IniRead, RunWorkingDir, %A_LoopFilePath%, Action , StartIn
	IniRead, RunItAdmin, %A_LoopFilePath%, Admin , RunElevated
	IniRead, PreDelay, %A_LoopFilePath%, Delay , Pre
	IniRead, PostDelay, %A_LoopFilePath%, Delay , Post
	PreDelay := PreDelay * 1000
	PostDelay := PostDelay * 1000
	IfNotExist, %RunTarget%
		{
		SplashTextOn,,,"Autostart Couldnt find %RunWorkingDir%\%RunTarget% ... `n skipping..."
		haderror = 1
		continue
		}
	sleep %PreDelay%
	If (RunItAdmin = 0)
		{
		Run, %RunTarget% %RunArgs%, %RunWorkingDir%
		}
	If (RunItAdmin = 1)
		{
		TheReturnDir = %A_ScriptDir%
		SetWorkingDir %RunWorkingDir%
		Run *RunAs %RunTarget% %RunArgs%
		SetWorkingDir %TheReturnDir%
		}
	sleep %PostDelay%
	}
if (haderror = 1)
	{
	msgbox Errors Occured in Autostart
	SplashTextOff
	}

