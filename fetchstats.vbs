' OpenDNS Stats Fetch for Windows
' Based on original fetchstats script from Richard Crowley
' Brian Hartvigsen <brian.hartvigsen@opendns.com>
'
' Changes by Leandro Camilo, 2020-03-19
'
' Usage: cscript /NoLogo fetchstats.vbs <username> <network-id> <YYYY-MM-DD> [<YYYY-MM-DD>]

' Instantiate object here so that cookies will be tracked.
Set objHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")

Function GetUrlData(strUrl, strMethod, strData)
	objHTTP.Open strMethod, strUrl
	If strMethod = "POST" Then
		objHTTP.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
	End If
	objHTTP.Option(6) = False
	objHTTP.Send(strData)

	If Err.Number <> 0 Then
		GetUrlData = "ERROR: " & Err.Description & vbCrLf & Err.Source & " (" & Err.Nmber & ")"
	Else
		GetUrlData = objHTTP.ResponseText
	End If
End Function

LOGINURL="https://login.opendns.com/?source=dashboard"
CSVURL="https://dashboard.opendns.com"

Sub Usage()
	Wscript.StdErr.Write "Usage: <username> <network_id> <YYYY-MM-DD> [<YYYY-MM-DD>]" & vbCrLf
	WScript.Quit 1
End Sub

If Wscript.Arguments.Count < 3 Or Wscript.Arguments.Count > 4 Then
	Usage
End If

Username = Wscript.Arguments.Item(0)
If Len(Username) = 0 Then: Usage
Network = Wscript.Arguments.Item(1)
If Len(Network) = 0 Then: Usage

Set regDate = new RegExp
regDate.Pattern = "^\d{4}-\d{2}-\d{2}$"

DateRange = Wscript.Arguments.Item(2)
If Not regDate.Test(DateRange) Then: Usage

If Wscript.Arguments.Count = 4 Then
	ToDate = Wscript.Arguments.Item(3)
	If Not regDate.Test(toDate) Then: Usage
	DateRange = DateRange & "to" & ToDate
End If

WScript.StdErr.Write "Starting stats download" & vbCrLf
WScript.StdErr.Write "OpenDNS Password for " & Username & ": "

' Are they running Vista or 7?
On Error Resume Next
Set objPassword = CreateObject("ScriptPW.Password") 
If objPassword <> Null Then
    Password = objPassword.GetPassword()
Else
    Password = WScript.StdIn.ReadLine
End If
Wscript.StdErr.Write vbCrLf
On Error GoTo 0

Set regEx = New RegExp
regEx.IgnoreCase = true
regEx.Pattern = ".*name=""formtoken"" value=""([0-9a-f]*)"".*"

Wscript.StdErr.Write "Login in..."

data = GetUrlData(LOGINURL, "GET", "")

Set Matches = regEx.Execute(data)
token = Matches(0).SubMatches(0)

data = GetUrlData(LOGINURL, "POST", "formtoken=" & token & "&username=" & replace(escape(Username),"+","%2B")  & "&password=" & replace(escape(Password),"+","%2B"))

regEx.Pattern = ".*Login failed. Check your username and/or password.*"
Set loginMatches = regEx.Execute(data)

If loginMatches.Count > 0 Then
	Wscript.StdErr.Write "[ERROR]" & vbCrLf
	Wscript.StdErr.Write "Login Failed. Check username and password" & vbCrLf
	WScript.Quit 1
End If

Wscript.StdErr.Write "[OK]" & vbCrLf

Set objFSO=CreateObject("Scripting.FileSystemObject")
outFile="domainstats_full.csv"
Set objFile = objFSO.CreateTextFile(outFile,True)

page=1
Do While True
	Wscript.StdErr.Write "Downloading page " & page & "..."
	data = GetUrlData(CSVURL & "/stats/" & Network & "/topdomains/" & DateRange & "/page" & page & ".csv", "GET", "")
	waiting = False
	If page = 1 Then
		If LenB(data) = 0 Then
			WScript.StdErr.Write "You can not access " & Network & vbCrLf
			WScript.Quit 2
		ElseIf InStr(data, "<!DOCTYPE") Or InStr(data, "<html") Then
		    Wscript.StdErr.Write "[ERROR]"  & vbCrLf
		    Wscript.StdErr.Write "Error retrieving data.  Date range may be outside of available data or too many stats request inthe latest 2 minutes."
		    Wscript.Quit 2
		End If
	Else
		If InStr(data, "Please view fewer than 20 reports in 2 minutes.") Then
			Wscript.StdErr.Write "[INFO]" & vbCrLf
			waiting = True
			secondsToWait = 120
			Wscript.StdErr.Write "Hits in latest 2 minutes reached. Let's wait 2 minutes before proceed." & vbCrLf
			while secondsToWait >= 0
				Wscript.StdErr.Write vbCr
				Wscript.StdErr.Write "Waiting " & ConvertTime(secondsToWait) & "..."
				Delay(1)
				secondsToWait = secondsToWait - 1
			wend 
			Wscript.StdErr.Write "[OK]" & vbCrLf
		Else
			' First line is always header
			data=Mid(data,InStr(data,vbLf)+1)
		End If
	End If
	If Not waiting Then
		If LenB(Trim(data)) = 0 Or InStr(data, "<html") Then
			Wscript.StdErr.Write data & vbCrLf
			Wscript.StdErr.Write "[Stats finished in the previous page]" & vbCrLf
			Exit Do
		End If
		Wscript.StdErr.Write "[OK]" & vbCrLf
		objFile.Write data
		page = page + 1
	Else	
		waiting = False
	End If
Loop
objFile.Close

Wscript.StdErr.Write "Stats saved to file " & outFile & vbCrLf

Sub Delay( seconds )
	Dim wshShell, strCmd
	Set wshShell = CreateObject( "WScript.Shell" )
	strCmd = wshShell.ExpandEnvironmentStrings( "%COMSPEC% /C (TIMEOUT.EXE /T " & seconds & " /NOBREAK)" )
	wshShell.Run strCmd, 0, 1
	Set wshShell = Nothing
End Sub

'************************************************************
Function ConvertTime(intTotalSecs)
	Dim intHours,intMinutes,intSeconds,Time
	intHours = intTotalSecs \ 3600
	intMinutes = (intTotalSecs Mod 3600) \ 60
	intSeconds = intTotalSecs Mod 60
	ConvertTime = LPad(intHours) & "h" & LPad(intMinutes) & "m" & LPad(intSeconds) & "s"
End Function
'************************************************************
Function LPad(v) 
 	LPad = Right("0" & v, 2) 
End Function
'************************************************************