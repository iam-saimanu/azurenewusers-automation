param (
    [string]$tenantId,
    [string]$clientId,
    [string]$clientSecret
)

# ==============================
# Get Access Token
# ==============================
$body = @{
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
    client_id     = $clientId
    client_secret = $clientSecret
}

$tokenResponse = Invoke-RestMethod -Method Post `
    -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
    -Body $body

$accessToken = $tokenResponse.access_token

# ==============================
# Read CSV
# ==============================
$csvPath = "$PSScriptRoot/users.csv"
$users = Import-Csv -Path $csvPath

# ==============================
# Loop Users
# ==============================
foreach ($u in $users) {

    # Check if user exists
    $existingUser = Invoke-RestMethod -Method Get `
        -Uri "https://graph.microsoft.com/v1.0/users/$($u.UserPrincipalName)" `
        -Headers @{Authorization = "Bearer $accessToken"} `
        -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Host "⚠️ Already exists: $($u.UserPrincipalName)"
        continue
    }

    $user = @{
        accountEnabled = $true
        displayName    = $u.DisplayName
        mailNickname   = $u.MailNickname
        userPrincipalName = $u.UserPrincipalName
        passwordProfile = @{
            forceChangePasswordNextSignIn = $true
            password = $u.Password
        }
    }

    try {
        Invoke-RestMethod -Method Post `
            -Uri "https://graph.microsoft.com/v1.0/users" `
            -Headers @{Authorization = "Bearer $accessToken"} `
            -Body ($user | ConvertTo-Json -Depth 10) `
            -ContentType "application/json"

        Write-Host "✅ Created: $($u.UserPrincipalName)"
    }
    catch {
    Write-Host "❌ Failed: $($u.UserPrincipalName)"
    Write-Host $_.Exception.Message

    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd()
        Write-Host "Full Error:"
        Write-Host $responseBody
    }
}
}
