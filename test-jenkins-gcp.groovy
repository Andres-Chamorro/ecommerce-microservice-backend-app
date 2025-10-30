// Pipeline de prueba para verificar conexión con GCP
pipeline {
    agent any
    
    environment {
        GCP_PROJECT_ID = credentials('gcp-project-id')
    }
    
    stages {
        stage('Test GCP Connection') {
            steps {
                script {
                    echo "Testing GCP connection..."
                    echo "Project ID: ${GCP_PROJECT_ID}"
                    
                    withCredentials([file(credentialsId: 'gcp-service-account', variable: 'GCP_KEY')]) {
                        sh '''
                            gcloud auth activate-service-account --key-file=${GCP_KEY}
                            gcloud config set project ${GCP_PROJECT_ID}
                            gcloud container clusters list --zone=us-central1-a
                            kubectl get nodes
                        '''
                    }
                    
                    echo "GCP connection successful!"
                }
            }
        }
    }
}
