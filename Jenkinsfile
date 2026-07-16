@Library('common-shared') _

pipeline {
    agent {
        kubernetes {
            label 'docker-kubectl'
            yaml '''
                 apiVersion: v1
                 kind: Pod
                 spec:
                   containers:
                     - name: docker-kubectl
                       image: fr3d/docker-kubectl:0.0.0
                       command:
                         - cat
                       tty: true
                       resources:
                         limits:
                           cpu: 1
                           memory: 1Gi
                       volumeMounts:
                         - mountPath: /home/jenkins/agent/.docker
                           name: dot-docker
                           readOnly: false
                         - mountPath: /home/default/.kube
                           name: dot-kube
                           readOnly: false
                     - name: jnlp
                       resources:
                         limits:
                           cpu: 1
                           memory: 1Gi
                   volumes:
                     - name: dot-docker
                       emptyDir: {}
                     - name: dot-kube
                       emptyDir: {}
            '''
        }
    }

    environment {
        APP_NAME = 'cbi-sponsorships-api'
        NAMESPACE = 'foundation-internal-webdev-apps'
        IMAGE_NAME = 'eclipsefdn/cbi-sponsorships-api'
        HOME = "/home/jenkins/agent/"
        CONTAINER_NAME = 'app'
        ENVIRONMENT = 'production'
        TAG_NAME = sh(
            script: """
                GIT_COMMIT_SHORT=\$(git rev-parse --short ${env.GIT_COMMIT})
                GIT_BRANCH=${env.GIT_BRANCH}
                printf \${GIT_BRANCH//\\//_}-\${GIT_COMMIT_SHORT}-${env.BUILD_NUMBER}
            """,
        returnStdout: true
        )
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    stages {

        stage('Build and push docker image remotely') {
            when {
                environment name: 'GIT_BRANCH', value: 'main'
            }
            steps {
                container('docker-kubectl')  {
                    readTrusted 'Dockerfile'
                    withCredentials([file(credentialsId: 'auth.json', variable: 'AUTH_JSON')]) {
                        withDockerRegistry([credentialsId: 'webdev-docker-bot', url: 'https://index.docker.io/v1/']) {
                            sh '''
                                docker buildx create --name remote-okd --driver remote tcp://buildkitd.foundation-internal-infra-buildkitd:1234
                                DOCKER_BUILDKIT=1 docker buildx build \
                                    --builder remote-okd \
                                    --secret id=composer_auth,src="${AUTH_JSON}" \
                                    -f Dockerfile \
                                    --no-cache \
                                    -t ${IMAGE_NAME}:${TAG_NAME} \
                                    -t ${IMAGE_NAME}:latest --push .
                                '''
                        }
                    }
                    //archiveArtifacts artifacts: 'docker_remote_build.log'
                }
            }
        }

        stage('Deploy to cluster') {
            when {
                environment name: 'GIT_BRANCH', value: 'main'
            }
            steps {
                container('docker-kubectl') {
                    sh '''
                      echo "newImageRef: ${IMAGE_NAME}:${TAG_NAME}"
                    '''
                    updateContainerImage([
                        namespace: "${env.NAMESPACE}",
                        selector: "app=${env.APP_NAME},environment=${env.ENVIRONMENT}",
                        containerName: "${env.CONTAINER_NAME}",
                        newImageRef: "${env.IMAGE_NAME}:${env.TAG_NAME}"
                    ])
                }
            }
        }
    }
    post {
        always {
            deleteDir()
        }
    }
}