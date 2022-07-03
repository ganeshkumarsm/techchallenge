# techchallenge

#Challenge 1 - 3 Tier Architecture
===================================
1. All the components are deployed through Terraform 
2. VPC, Internet Gateway, Public and Private Subnets,Public and Private Routing tables, Routes, Load Balancer, EC2 instances (with K3s boot strap), Security Groups, AWS RDS instance, TG,Listeners are deployed through Terraform.
3. The code is modular in nature. All the required parameters for the Compute, Networking, Load Balancing and RDS are passed from the Root module to the Child modules.
4. The sensive data such as access_keys are not hardcoded. 
5. Terraform.tfvars contains variables (which are maintained locally) and not commite to the Github repo.

Deployment:
=============
1. Deploys Application Load Balancer
2. Deploys the EC2 Instances in Public Subnets
  i) Bootstraps Kubernetes(K3s) cluster on the EC2 Instances
  ii) EC2 instances connect to the RDS instance to write the cluster config data.
3. Deploys Amazon RDS instance into private subnet used for the Kubernetes cluster.
4. After the cluster is ready,
   i) Login to one of the EC2 instances, Verify the node status using kubectl get nodes
5. Deploy a sample NGINX application (dep.yml file is uploaded here), make sure the ports are set correctly (if you are customizing it) or else it uses port 8080 on the node and TG listens on port 8080 and LB does the health check on port 8080.

Accessing the env:
===================
1.Launch browser and connect to the Load Balancer URL. 
2.You should see NGINX page coming up.

How to Further Improve/Scale It:
===========================
   I am working on (1), (2), (3) below and solution is 80% complete.
1.  We can look into another kind of implementation where the EC2 instances(Kube nodes) are placed in private subnet and only ALB can communicate with these nodes. This improves the security posture of the solution.
2. We can deploy the NAT Gateway for the external connectivity to our EC2 instances. 
3. We can deploy the Bastian host in the public subnet and allow only the required ports through security group.
4. The solution can be further scaled with Autoscaling group based on the scaling rules we plan to define.
5. For deployment to multiple environments, as of now, we have to change the AWS account creds, region(if required) in the code. 
6. In future, we can implement workspaces (eg: Terraform Workspaces) and deploy the environment to respective workspaces.
