pipeline {
    agent any
    environment {
        TERRAFORM_WORKSPACE = "/var/lib/jenkins/workspace/tool-pipeline/elasticsearch-infra/"
        INSTALL_WORKSPACE = "/var/lib/jenkins/workspace/tool-pipeline/elasticsearch/"
        PATH = "/usr/local/bin:${env.PATH}" // Ensure terraform path is added
    }
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Select action: apply or destroy')
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'master', url: 'https://github.com/UnitedA/tool.git'
            }
        } 
        // stage('List Files') {
        //     steps {
        //         script {
        //             sh "cd ${env.WORKSPACE} && ls -R"
        //         }
        //     }
        // }
        stage('Terraform Init') {
            steps {
                script {
                    try {
                        // Initialize Terraform in the workspace directory
                        sh "cd ${env.TERRAFORM_WORKSPACE} && terraform init"
                    } catch (Exception e) {
                        error "Terraform Init failed: ${e}"
                    }
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
            }
            steps {
                script {
                    try {
                        // Run Terraform Plan
                        sh "cd ${env.TERRAFORM_WORKSPACE} && terraform plan"
                    } catch (Exception e) {
                        error "Terraform Plan failed: ${e}"
                    }
                }
            }
        }
        stage('Approval For Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    input message: "Do you want to apply Terraform changes?", ok: "Apply"
                }
           }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' && currentBuild.result == null || currentBuild.result == 'SUCCESS' }
            }
            steps {
                script {
                    try {
                        // Apply the Terraform changes
                        sh """
                            cd ${env.TERRAFORM_WORKSPACE}
                            terraform apply -auto-approve

                            // Copy SSH key to install workspace for tool deployment
                            sudo cp ${env.TERRAFORM_WORKSPACE}/infra_key.pem ${env.INSTALL_WORKSPACE}
                            sudo chown jenkins:jenkins ${env.INSTALL_WORKSPACE}/infra_key.pem
                            sudo chmod 400 ${env.INSTALL_WORKSPACE}/infra_key.pem
                        """
                    } catch (Exception e) {
                        error "Terraform Apply failed: ${e}"
                    }
                }
            }
        }
        stage('List Files') {
            steps {
                sh 'ls -R'
            }
        }
        
        
        
        
       stage('Tool Deploy') {
            when {
                expression { params.ACTION == 'apply' && currentBuild.result == null || currentBuild.result == 'SUCCESS' }
            }
            steps {
                script {
                    sh "cd ${env.INSTALL_WORKSPACE} && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbook.yml"
                 }
            }
        }

        stage('Approval for Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                input "Do you want to destroy the Terraform infrastructure?"
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' && currentBuild.result == 'SUCCESS' }
            }
            steps {
                script {
                    try {
                        // Destroy the Terraform infrastructure
                        sh "cd ${env.TERRAFORM_WORKSPACE} && terraform destroy -auto-approve"
                    } catch (Exception e) {
                        error "Terraform Destroy failed: ${e}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up temporary files and states...'
            cleanWs() // Clean up workspace
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline execution failed.'
        }
    }
}
