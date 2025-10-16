pipeline {
    agent any

    environment {
        // Project configuratie
        DOTNET_CLI_HOME = '/tmp/dotnet'
        DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 'true'
        DOTNET_NOLOGO = 'true'

        // Repository URLs
        DEV_REPO = 'https://github.com/HOGENT-RISE/dotnet-2526-vc1.git'
        OPS_REPO = 'https://github.com/HOGENT-RISE/ops-2526-vc1-1.git'

        // Branches
        DEV_BRANCH = 'main'
        OPS_BRANCH = 'main'

        // Build configuratie
        BUILD_CONFIG = 'Release'

        // Paths
        SRC_PATH = 'app-code/src'
        OPS_PATH = 'ops-code'
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Clone Repositories') {
            parallel {
                stage('Clone Dev Repository') {
                    steps {
                        dir('app-code') {
                            git branch: "${DEV_BRANCH}",
                                url: "${DEV_REPO}",
                                credentialsId: 'jenkins-classic-workaround'
                        }
                    }
                }

                stage('Clone Ops Repository') {
                    steps {
                        dir('ops-code') {
                            git branch: "${OPS_BRANCH}",
                                url: "${OPS_REPO}",
                                credentialsId: 'jenkins-classic-workaround' 
                        }
                    }
                }
            }
        }

        stage('Environment Info') {
            steps {
                script {
                    sh '''
                        dotnet --version

                        echo "\n.NET SDKs Geïnstalleerd:"
                        dotnet --list-sdks

                        echo "\n.NET Runtimes Geïnstalleerd:"
                        dotnet --list-runtimes
                    '''
                }
            }
        }

        stage('Restore Dependencies') {
            steps {
                dir("${SRC_PATH}") {
                    sh '''
                        dotnet restore Rise.sln --verbosity minimal
                    '''
                }
            }
        }

        stage('Build Application') {
            steps {
                dir("${SRC_PATH}") {
                    sh '''
                        dotnet build Rise.sln \
                            --configuration ${BUILD_CONFIG} \
                            --no-restore \
                            --verbosity minimal \
                            /p:TreatWarningsAsErrors=false

                    '''
                }
            }
        }

        stage('Run Tests') {
            steps {

                dir("${SRC_PATH}") {
                    sh '''
                        dotnet test Rise.sln \
                            --configuration ${BUILD_CONFIG} \
                            --no-build \
                            --no-restore \
                            --verbosity normal \
                            --logger "trx;LogFileName=test-results.trx" \
                            --logger "console;verbosity=detailed" \
                            --collect:"XPlat Code Coverage" \
                            -- RunConfiguration.CollectSourceInformation=true
                    '''
                }
            }
        }

        stage('Publish Application') {
            steps {
                dir("${SRC_PATH}") {
                    sh '''
                        dotnet publish Rise.Server/Rise.Server.csproj \
                            --configuration ${BUILD_CONFIG} \
                            --no-build \
                            --output ${WORKSPACE}/publish
                    '''
                }
            }
        }

        stage('Package Artifacts') {
            steps {
                sh '''
                    cd ${WORKSPACE}/publish
                    tar -czf rise-app.tar.gz *
                    mv rise-app.tar.gz ${WORKSPACE}/
                '''
            }
        }

        stage('Deploy to Application Server') {
                steps {
                    script {
                        sh '''
                            echo "Deploying artifact to application server..."
                            scp -o StrictHostKeyChecking=no rise-app.tar.gz rise@192.168.1.10:/tmp/rise-app.tar.gz

                            echo "Installing artifact on application server..."
                            ssh -o StrictHostKeyChecking=no rise@192.168.1.10 << 'EOF'
                                sudo systemctl stop rise-app.service
                                sudo rm -rf /opt/rise-app/*
                                sudo tar -xzf /tmp/rise-app.tar.gz -C /opt/rise-app/
                                sudo systemctl start rise-app.service
                                echo "Deployment finished!"
                            'EOF'
                        '''
                    }
                }
            }

        stage('Health Check') {
            steps {
                script {
                    sh '''
                        sleep 10

                        if curl -f http://192.168.1.10/health 2>/dev/null || curl -f http://192.168.1.10/ 2>/dev/null; then
                            echo "Application is healthy!"
                        else
                            echo "Application health check failed!"
                            exit 1
                        fi
                    '''
                }
            }
        }
    }
}