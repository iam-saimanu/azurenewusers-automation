# 🚀 Azure Entra ID Bulk User Automation using PowerShell & Jenkins

## 📌 Project Overview

This project automates **bulk user creation** in Microsoft Entra ID using:

* PowerShell script
* CSV file (user data)
* GitHub (code repository)
* Jenkins (CI/CD pipeline)

👉 Goal: Automatically create users in Entra ID whenever the pipeline is triggered.

---

## 🏗️ Architecture Diagram

```
        +-------------------+
        |   GitHub Repo     |
        | (Code + CSV File) |
        +--------+----------+
                 |
                 | (Webhook / Manual Trigger)
                 ↓
        +-------------------+
        |     Jenkins       |
        |  CI/CD Pipeline   |
        +--------+----------+
                 |
                 | Runs PowerShell Script
                 ↓
        +-------------------+
        | PowerShell Script |
        | (create-users.ps1)|
        +--------+----------+
                 |
                 | Calls Microsoft Graph API
                 ↓
        +-----------------------------+
        | Microsoft Entra ID (Azure) |
        |     Users Created         |
        +-----------------------------+
```

---

## 📁 Project Structure

```
entra-user-automation/
│
├── create-users.ps1   # PowerShell script to create users
├── users.csv          # Input file with user details
├── Jenkinsfile        # CI/CD pipeline definition
└── README.md          # Project documentation
```

---

## ⚙️ Prerequisites

* Azure Account
* Entra ID Tenant
* App Registration with:

  * `User.ReadWrite.All` permission
  * Admin Consent granted
* Jenkins installed
* GitHub repository

---

## 🔐 Secure Credentials Setup

In Jenkins → Manage Credentials, add:

| Credential ID  | Description     |
| -------------- | --------------- |
| `tenant-id`    | Azure Tenant ID |
| `client-id`    | App (Client) ID |
| `entra-secret` | Client Secret   |

---

## 📄 users.csv Format

```csv
DisplayName,UserPrincipalName,MailNickname,Password
John Doe,john@yourtenant.onmicrosoft.com,john,Password@123
Jane Smith,jane@yourtenant.onmicrosoft.com,jane,Password@123
```

---

## 🧠 PowerShell Script (create-users.ps1)

```powershell
param (
    [string]$tenantId,
    [string]$clientId,
    [string]$clientSecret
)

# Get Access Token
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

# Read CSV
$users = Import-Csv -Path "$PSScriptRoot/users.csv"

foreach ($u in $users) {

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

        Write-Host "Created: $($u.UserPrincipalName)"
    }
    catch {
        Write-Host "Failed: $($u.UserPrincipalName)"
        Write-Host $_
    }
}
```

---

## ⚙️ Jenkins Pipeline (Jenkinsfile)

```groovy
pipeline {
    agent any

    environment {
        TENANT_ID = credentials('tenant-id')
        CLIENT_ID = credentials('client-id')
        CLIENT_SECRET = credentials('entra-secret')
    }

    stages {

        stage('Check Files') {
            steps {
                bat 'dir'
            }
        }

        stage('Run Script') {
            steps {
                bat '''
                powershell -ExecutionPolicy Bypass -File create-users.ps1 ^
                -tenantId %TENANT_ID% ^
                -clientId %CLIENT_ID% ^
                -clientSecret %CLIENT_SECRET%
                '''
            }
        }
    }

    post {
        success {
            echo 'Users created successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
```

---

## 🔄 Workflow (Step-by-Step)

1. Developer updates `users.csv` in GitHub
2. Pipeline is triggered (manual or webhook)
3. Jenkins pulls latest code
4. Jenkins runs PowerShell script
5. Script calls Microsoft Graph API
6. Users are created in Entra ID

---

## ✅ Key Features

* Automated bulk user provisioning
* Secure credential management using Jenkins
* CI/CD pipeline integration
* Scalable and reusable automation

---

## 🚀 Future Enhancements

* Add logging and reports
* Email notifications on success/failure
* Validate CSV before execution
* Integrate with Azure Key Vault
* Add rollback mechanism

---

## 📌 Conclusion

This project demonstrates a real-world DevOps use case by combining:

* Cloud identity management
* Automation scripting
* CI/CD pipeline integration

## 👤 Author

Sai Manogna TL

- GitHub: https://github.com/iam-saimanu/azurenewusers-automation 
- Project: Azure Entra ID Bulk User Automation
