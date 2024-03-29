@Library('common-shared') _

pipeline {
    agent any

    environment {
        APP_NAME = 'cbi-sponsorships-api'
        NAMESPACE = 'foundation-internal-webdev-apps'
        IMAGE_NAME = 'eclipsefdn/cbi-sponsorships-api'
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

        stage('Build docker image') {
            agent {
                label 'docker-build'
            }
            steps {
                readTrusted 'Dockerfile'
                withCredentials([file(credentialsId: 'auth.json', variable: 'AUTH_JSON')]) {
                    sh '''
                        DOCKER_BUILDKIT=1 docker build \
                            --secret id=composer_auth,src="${AUTH_JSON}" \
                            -f Dockerfile \
                            --no-cache \
                            -t ${IMAGE_NAME}:${TAG_NAME} \
                            -t ${IMAGE_NAME}:latest . 2> docker_build.log
                    '''
                }
                archiveArtifacts artifacts: 'docker_build.log'
            }
        }

        stage('Push docker image') {
            agent {
                label 'docker-build'
            }
            when {
                environment name: 'GIT_BRANCH', value: 'main'
            }
            steps {
                withDockerRegistry([credentialsId: 'webdev-docker-bot', url: 'https://index.docker.io/v1/']) {
                    sh '''
                        docker tag "${IMAGE_NAME}:${TAG_NAME}" "${IMAGE_NAME}:latest"
                        docker push ${IMAGE_NAME}:${TAG_NAME}
                        docker push ${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Deploy to cluster') {
            agent {
                kubernetes {
                    label 'kubedeploy-agent'
                    yaml '''
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                            - name: kubectl
                              image: eclipsefdn/kubectl:okd-c1
                              command:
                                - cat
                              tty: true
                              resources:
                                limits:
                                  cpu: 1
                                  memory: 1Gi
                              volumeMounts:
                                - mountPath: /home/default/.kube
                                  name: dot-kube
                                  readOnly: false
                            - name: jnlp
                              resources:
                                limits:
                                  cpu: 1
                                  memory: 1Gi
                          volumes:
                            - name: dot-kube
                              emptyDir: {}
                    '''
                }
            }
            when {
                environment name: 'GIT_BRANCH', value: 'main'
            }
            steps {
                container('kubectl') {
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

