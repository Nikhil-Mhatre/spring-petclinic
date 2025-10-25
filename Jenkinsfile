pipeline {
    agent any

    tools {
        maven 'Maven-3.9.6'
        jdk 'JDK-25'
    }

    stages {
        stage('Build, Test & Package') {
            steps {
                echo "BUILDING THE NEW FEATURE BRANCH!"
                echo "Testing the new github-user-pat credential!"
                // We run 'package' which builds and tests
                sh 'mvn clean package'
            }
        }

        stage('Archive & Publish Reports') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                junit 'target/surefire-reports/*.xml'
            }
        }
        
        stage('Deploy to Staging') {
            // This stage will be skipped on our feature branch
            when {
                branch 'main'
            }
            steps {
                echo "DEPLOYING TO STAGING... (because this is the main branch)"
            }
        }

        // --- ADD THIS NEW STAGE ---
        stage('Build & Push Docker Image') {
            steps {
                script {
                    // 1. Define your ECR variables
                    // !! REPLACE THESE WITH YOUR VALUES FROM ECR !!
                    def ecrRegistry = "123456789012.dkr.ecr.us-east-1.amazonaws.com"
                    def ecrRepo = "spring-petclinic"
                    def ecrRegion = "us-east-1"
                    
                    // Create an image name with the build number, e.g., "spring-petclinic:5"
                    def imageName = "${ecrRepo}:${env.BUILD_NUMBER}"

                    // 2. Log into ECR and build/push
                    // This 'withRegistry' block uses the Amazon ECR plugin
                    // It finds AWS credentials from the EC2 instance's IAM Role
                    docker.withRegistry("https://${ecrRegistry}", "ecr:${ecrRegion}") {
                        
                        // 3. Build the image from our Dockerfile
                        // The '.' means "use the Dockerfile in the current directory"
                        def img = docker.build(imageName, ".")

                        // 4. Push the image to ECR
                        img.push()
                        echo "Successfully pushed ${imageName} to ECR"
                    }
                }
            }
        }
    } // --- End of stages ---

    post {
        success {
            echo 'Build Succeeded! Ready to deploy.'
        }
        
        failure {
            echo 'Build Failed. Please review the logs.'
        }
        
        always {
            echo 'Pipeline run finished.'
        }
    }
}
