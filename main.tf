pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = 'azure-credentials' // The ID of your Azure credentials in Jenkins
        TF_VERSION            = '1.7.0'          // Specify your desired Terraform version
        TF_VAR_resource_group_name = 'rg-storage-linux-cicd'
        TF_VAR_location            = 'eastus'
        TF_VAR_storage_account_prefix = 'stolinuxcicd'
        // Add other Terraform variables here if needed
    }

    stages {
        stage('Checkout Repo') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                tool name: 'Terraform', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
                sh "terraform init -backend=false"
            }
        }

        stage('Terraform Plan') {
            steps {
                tool name: 'Terraform', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
                withCredentials([azureServicePrincipal(credentialsId: "${AZURE_CREDENTIALS_ID}")]) {
                    // Authenticate with Azure using the credentials stored in Jenkins
                    sh '"C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\wbin\\az.cmd" login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%'
                    sh '"C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\wbin\\az.cmd" account set --subscription %AZURE_SUBSCRIPTION_ID%'
                    sh "terraform plan -out=plan.out"
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    def proceed = input message: 'Approve Deployment', ok: 'Proceed'
                    if (proceed) {
                        tool name: 'Terraform', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
                        withCredentials([azureServicePrincipal(credentialsId: "${AZURE_CREDENTIALS_ID}")]) {
                            // Ensure the correct subscription is selected (might not be strictly necessary here)
                            sh '"C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\wbin\\az.cmd" account set --subscription %AZURE_SUBSCRIPTION_ID%'
                            sh "terraform apply plan.out"
                        }
                    } else {
                        echo 'Deployment was not approved.'
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
