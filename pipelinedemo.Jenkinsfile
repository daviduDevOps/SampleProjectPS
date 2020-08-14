agentLabel = "Dev"

pipeline {	
    agent { label agentLabel }
	
	stages {	
	    stage('Blue Env: Download Artifacts from Artifactory') {	        
			steps {	
			echo 'Downloading Artifacts from Artifactory'	
			git credentialsId: 'davidu-github-credentials', url: 'https://github.com/daviduDevOps/SampleProjectPS.git'			
			}
		}		
		stage('Blue Env: upload artifacts to S3') {	
			steps {	
			echo 'upload artifacts to S3'			
			}
		}
		stage('Blue Env: Deployment') {			
			steps {	
				echo 'Code Deployment inprogress..'	
				step([$class: 'AWSCodeDeployPublisher', applicationName: 'NgmDemoBlueGreenLB', awsAccessKey: 'AKIA2O67XNNTQOYA3EEH', awsSecretKey: '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', credentials: 'awsAccessKey', deploymentConfig: 'CodeDeployDefault.OneAtATime', deploymentGroupAppspec: false, deploymentGroupName: 'NgmDemoBlueGreenDeploymentGroup', deploymentMethod: 'deploy', excludes: '', iamRoleArn: '', includes: '**', pollingFreqSec: 15, pollingTimeoutSec: 3000, proxyHost: '', proxyPort: 0, region: 'us-east-1', s3bucket: 'bluegreencodedeploydemobucket', s3prefix: '', subdirectory: '', versionFileName: '', waitForCompletion: true])			
			}	
		}
		stage('Blue Env: Update Host file') {				
			steps {	
				echo 'Blue Env: Update Host file'		
				powershell label: '', returnStdout: true, script: '''$Username = \'Administrator\'
				$Password = \'ArSAgx67DeS-uOPkpo$9lyyo$-bBa=MX\'
				$pass = ConvertTo-SecureString -AsPlainText $Password -Force
				$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
				$instances = aws deploy  list-deployments --application-name NgmDemoBlueGreenLB --deployment-group-name NgmDemoBlueGreenDeploymentGroup    --region us-east-1
				$deployIdarray = $instances | ConvertFrom-Json
				$deploymentId = $deployIdarray.deployments[0]
				$instances = aws deploy list-deployment-instances --deployment-id  $deploymentId --region us-east-1
				$instancesarray = $instances | ConvertFrom-Json
				$instanceId = $instancesarray.instancesList[0]
				$privateiplist = aws ec2 describe-instances --region us-east-1 --instance-ids $instanceId --query 'Reservations[].Instances[].PrivateIpAddress'
				$privateipaddress = $privateiplist  | ConvertFrom-Json
				echo $privateipaddress
				Invoke-Command -ComputerName $privateipaddress -FilePath C:\\temp\\HelloWorldApp\\Scripts\\AddToHosts.ps1  -credential $Cred'''	
			}	
		}
		stage('Blue Env: Validate deployment') {		
			input {		
				message "Please approve to proceed ?"		
				ok "Yes, we should."		
				submitter "alice,bob"		
				parameters {		string(name: 'APPROVER', defaultValue: 'Mr Sridhar', description: 'We are going to deploy build no: ?')		
				}			
			}		
			steps {		
				echo 'CI Release Environment'		
				//build 'QA'		
			}
		}
		stage('Green Env: Update Host file') {		    
			steps {	
				echo 'Green Env: Update Host file'		
				powershell label: '', returnStdout: true, script: '''$Username = \'Administrator\'
				$Password = \'ArSAgx67DeS-uOPkpo$9lyyo$-bBa=MX\'
				$pass = ConvertTo-SecureString -AsPlainText $Password -Force
				$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
				$instances = aws deploy  list-deployments --application-name NgmDemoBlueGreenLB --deployment-group-name NgmDemoBlueGreenDeploymentGroup  --region us-east-1
				$deployIdarray = $instances | ConvertFrom-Json
				$deploymentId = $deployIdarray.deployments[0]
				$instances = aws deploy list-deployment-instances --deployment-id  $deploymentId --region us-east-1
				$instancesarray = $instances | ConvertFrom-Json
				$instanceId = $instancesarray.instancesList[0]
				$privateiplist = aws ec2 describe-instances --region us-east-1 --instance-ids $instanceId --query 'Reservations[].Instances[].PrivateIpAddress'
				$privateipaddress = $privateiplist  | ConvertFrom-Json
				echo $privateipaddress
				Invoke-Command -ComputerName $privateipaddress -FilePath C:\\temp\\HelloWorldApp\\Scripts\\RemoveFromHosts.ps1  -credential $Cred'''	
			}
		}
		stage('Green Env: Validate deployment') {		
			input {		
				message "Please approve to Route traffic to Green ?"		
				ok "Yes, we should."		
				submitter "alice,bob"		
				parameters {		string(name: 'APPROVER', defaultValue: 'Mr Sridhar', description: 'We are going to deploy build no: ?')		
				}			
			}		
			steps {		
				echo 'Green Env: Validate deployment'	
			}
		}
		stage("Reroute Traffic from Blue to Green"){
			steps{
				powershell label: 'RerouteLoadTraffic', script: '''$instances = aws deploy  list-deployments --application-name NgmDemoBlueGreenLB --deployment-group-name NgmDemoBlueGreenDeploymentGroup --region us-east-1
				$deployIdarray = $instances | ConvertFrom-Json
				$deploymentId = $deployIdarray.deployments[0]
				$instances = aws deploy list-deployment-instances --deployment-id  $deploymentId --region us-east-1
				$instancesarray = $instances | ConvertFrom-Json
				$instanceId = $instancesarray.instancesList[0]
				$deploymentdetails = aws deploy get-deployment --deployment-id $deploymentId --region us-east-1
				$deploymentdetailsJson = $deploymentdetails | ConvertFrom-Json
				$targetInstances = $deploymentdetailsJson.deploymentInfo.applicationName
				$autoscalename = $deploymentdetailsJson.deploymentInfo.targetInstances.autoScalingGroups[0]
				$bluetargetarn = \'arn:aws:elasticloadbalancing:us-east-1:719339350887:targetgroup/NgmDemoBlueTG/7badefd622347ea4\'
				$greentargetarn = \'arn:aws:elasticloadbalancing:us-east-1:719339350887:targetgroup/NgmDemoGreenTG/757373647b666d16\'
				echo $autoscalename
				aws autoscaling attach-load-balancer-target-groups --auto-scaling-group-name $autoscalename --target-group-arns $greentargetarn --region us-east-1
				sleep -Seconds (30)
				#aws autoscaling detach-load-balancer-target-groups --auto-scaling-group-name $autoscalename --target-group-arns $bluetargetarn --region us-east-1'''	
			}
		}	
	}
}
