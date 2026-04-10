# 🚀 Exchange Online User Provisioning Automation using Jenkins Pipeline

## 📌 Project Overview

## This project automates user mailbox creation in Exchange Online using a CI/CD pipeline built with Jenkins and GitHub.

Whenever code is pushed to the GitHub repository, Jenkins triggers a pipeline that executes a PowerShell script to create user mailboxes automatically.

---

## 🧠 Architecture

GitHub → Jenkins Pipeline → PowerShell Script → Exchange Online

---

## 🎯 Objectives

* Automate Exchange Online user provisioning
* Implement CI/CD pipeline using Jenkins (Groovy)
* Integrate GitHub with Jenkins using webhook
* Use secure credential handling
* Enable real-time build monitoring

---

## 🛠️ Tools & Technologies

* GitHub (Version Control)
* Jenkins (CI/CD Tool)
* PowerShell (Automation Scripting)
* Exchange Online (Target System)

---

## 📂 Project Structure

```
exchange-automation/
│── create-user.ps1
│── Jenkinsfile
│── README.md
```

---

## ⚙️ Prerequisites

* Microsoft 365 Developer Account (Exchange Online access)
* Jenkins installed and running
* GitHub account
* Basic knowledge of PowerShell

---

## 🔐 Credentials Setup (Jenkins)

1. Go to: Manage Jenkins → Credentials
2. Add:

   * Username (Exchange Admin Email)
   * Password
3. Set IDs:

   * exchange-username
   * exchange-password

---

## 🧾 PowerShell Script (create-user.ps1)

```powershell
Connect-ExchangeOnline -UserPrincipalName $env:ADMIN_USERNAME

New-Mailbox -Name "Test User Jenkins" `
-DisplayName "Test User Jenkins" `
-UserPrincipalName "jenkinsuser@yourdomain.onmicrosoft.com" `
-Password (ConvertTo-SecureString "Password123!" -AsPlainText -Force)

Write-Output "User created successfully"
```

---

## 🔁 Jenkins Pipeline (Jenkinsfile)

```groovy
pipeline {
    agent any

    environment {
        ADMIN_USERNAME = credentials('exchange-username')
        ADMIN_PASSWORD = credentials('exchange-password')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/your-username/exchange-automation.git'
            }
        }

        stage('Install Module') {
            steps {
                powershell '''
                Install-Module ExchangeOnlineManagement -Force
                '''
            }
        }

        stage('Run Script') {
            steps {
                powershell '''
                $env:ADMIN_USERNAME = "${env.ADMIN_USERNAME}"
                $env:ADMIN_PASSWORD = "${env.ADMIN_PASSWORD}"
                ./create-user.ps1
                '''
            }
        }
    }
}
```

---

## 🔄 Pipeline Trigger

### Option 1: Poll SCM

```
H/5 * * * *
```

### Option 2: GitHub Webhook (Recommended)

Add webhook in GitHub:

```
http://<jenkins-url>/github-webhook/
```

---

## ▶️ How It Works

1. Developer pushes code to GitHub
2. Jenkins pipeline is triggered
3. Jenkins pulls latest code
4. PowerShell script runs
5. User mailbox is created in Exchange Online

---

## 📊 Output

* Jenkins build logs
* Pipeline stage view
* Exchange user created successfully

---

## 🚀 Future Enhancements

* Add CSV input for bulk user creation
* Implement error handling
* Add logging mechanism
* Send email notifications on failure

---

---

## 🧑‍💻 Author
Sai Manogna TL 

