pipeline {
    agent any
    environment {
        TERRAFORM_VERSION = '1.0.0'
    }
    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }
        stage('Clone Repository') {
            steps {
                git 'https://github.com/UnitedA/tool.git'
            }
        }
        stage('List Files') {
            steps {
                script {
                    sh '''
                    cd ${WORKSPACE}
                    ls -R
                    '''
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    dir('elasticsearch-infra') {
                        sh '''
                        terraform init
                        '''
                    }
                }
            }
        }
        stage('Terraform Plan') {
            when {
                expression { return fileExists('elasticsearch-infra/main.tf') }
            }
            steps {
                script {
                    dir('elasticsearch-infra') {
                        sh 'terraform plan'
                    }
                }
            }
        }
        stage('Approval for Apply') {
            input {
                message 'Do you want to apply the changes?'
            }
            when {
                expression { return fileExists('elasticsearch-infra/main.tf') }
            }
            steps {
                script {
                    dir('elasticsearch-infra') {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
        stage('Tool Deploy') {
            steps {
                echo 'Deploying the tool...'
                // Add your deploy steps here
            }
        }
        stage('Approval for Destroy') {
            input {
                message 'Do you want to destroy the infrastructure?'
            }
            steps {
                script {
                    dir('elasticsearch-infra') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Cleaning up temporary files and states...'
            cleanWs()
        }
        failure {
            echo 'Failed!'
        }
    }
}
