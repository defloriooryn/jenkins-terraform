pipeline {
    agent any
    stages {

        stage("Checkout"){
            steps{
        		echo pwd()
                git branch: 'main', 
                  credentialsId: 'auth-jenkins-tf',
                  url: 'https://github.com/defloriooryn/jenkins-terraform.git'
            }
        }

        stage("TF Init"){
            steps{
                sh 'export AWS_PROFILE=jenkins'
                sh 'terraform init'
            }
        }

        stage("TF Validate"){
            steps{
                sh 'terraform validate'
            }
        }

        stage("TF Plan"){
            steps{
                sh 'terraform plan'
            }
        }

        stage("TF Apply"){
            steps{
                sh 'terraform apply -auto-approve'
            }
        }
    }
}