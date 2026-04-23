pipeline {
    agent any

    environment {
        TENANT_ID = credentials('tenant-id')
        CLIENT_ID = credentials('client-id')
        CLIENT_SECRET = credentials('entra-secret')
    }

    stages {

        stage('Run Script') {
            steps {
                powershell '''
                ./create-users.ps1 `
                -tenantId $env:TENANT_ID `
                -clientId $env:CLIENT_ID `
                -clientSecret $env:CLIENT_SECRET
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
