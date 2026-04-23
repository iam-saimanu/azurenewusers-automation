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
