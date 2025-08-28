pipeline {
  agent any
  options { timestamps() }
  parameters {
    string(name: 'AWS_REGION', defaultValue: 'us-east-1')
    string(name: 'ECR_ACCOUNT_ID', defaultValue: '')
    string(name: 'CLUSTER_NAME', defaultValue: 'micro-eks')
    string(name: 'ECR_URI_BASE', defaultValue: '')
  }
  environment {
    USERS_IMAGE = "${params.ECR_URI_BASE}/users"
    ORDERS_IMAGE = "${params.ECR_URI_BASE}/orders"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build Images') {
      steps {
        dir('services/users') {
          sh 'docker build -t users:ci .' 
        }
        dir('services/orders') {
          sh 'docker build -t orders:ci .' 
        }
      }
    }
    stage('Login ECR') {
      steps {
        sh 'aws ecr get-login-password --region ${params.AWS_REGION} | docker login --username AWS --password-stdin ${params.ECR_ACCOUNT_ID}.dkr.ecr.${params.AWS_REGION}.amazonaws.com'
      }
    }
    stage('Tag & Push') {
      steps {
        sh 'docker tag users:ci ${USERS_IMAGE}:latest'
        sh 'docker tag orders:ci ${ORDERS_IMAGE}:latest'
        sh 'docker push ${USERS_IMAGE}:latest'
        sh 'docker push ${ORDERS_IMAGE}:latest'
      }
    }
    stage('Deploy to EKS') {
      steps {
        sh 'aws eks update-kubeconfig --name ${params.CLUSTER_NAME} --region ${params.AWS_REGION}'
        sh 'kubectl apply -f k8s/namespace.yaml'
        sh "sed 's#REPLACE_ECR_URI#${params.ECR_URI_BASE}#g' k8s/users-deployment.yaml | kubectl apply -f -"
        sh 'kubectl apply -f k8s/users-service.yaml'
        sh "sed 's#REPLACE_ECR_URI#${params.ECR_URI_BASE}#g' k8s/orders-deployment.yaml | kubectl apply -f -"
        sh 'kubectl apply -f k8s/orders-service.yaml'
      }
    }
  }
  post {
    always { sh 'kubectl get pods -n microapps | cat || true' }
  }
}
