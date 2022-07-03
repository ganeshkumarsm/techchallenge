# techchallenge

#Challenge 1 - 3 Tier Architecture
===================================
a. All the components are deployed through Terraform 
b. VPC, Internet Gateway, Public and Private Subnets,Public and Private Routing tables, Routes, Load Balancer, EC2 instances (with K3s boot strap), Security Groups, AWS RDS instance, TG,Listeners are deployed through Terraform.
c. The code is modular in nature. All the required parameters for the Compute, Networking, Load Balancing and RDS are passed from the Root module to the Child modules.
d. The sensive data such as access_keys are not hardcoded. 
e. Terraform.tfvars contains variables (which are maintained locally) and not commite to the Github repo.

Deployment:
=============
a. Deploys Application Load Balancer
b. Deploys the EC2 Instances in Public Subnets
  i) Bootstraps Kubernetes(K3s) cluster on the EC2 Instances
  ii) EC2 instances connect to the RDS instance to write the cluster config data.
c. Deploys Amazon RDS instance into private subnet used for the Kubernetes cluster.
d. After the cluster is ready,
   i) Login to one of the EC2 instances, Verify the node status using kubectl get nodes
e. Deploy a sample NGINX application (dep.yml file is uploaded here), make sure the ports are set correctly (if you are customizing it) or else it uses port 8080 on the node and TG listens on port 8080 and LB does the health check on port 8080.

Accessing the env:
a.Launch browser and connect to the Load Balancer URL. 
b.You should see NGINX page coming up.

How to Further Improve/Scale It:
===========================
   I am working on (1), (2), (3) below and solution is 80% complete.
1.  We can look into another kind of implementation where the EC2 instances(Kube nodes) are placed in private subnet and only ALB can communicate with these nodes. This improves the security posture of the solution.
2. We can deploy the NAT Gateway for the external connectivity to our EC2 instances. 
3. We can deploy the Bastian host in the public subnet and allow only the required ports through security group.
4. The solution can be further scaled with Autoscaling group based on the scaling rules we plan to define.
5. For deployment to multiple environments, as of now, we have to change the AWS account creds, region(if required) in the code. 
6. In future, we can implement workspaces (eg: Terraform Workspaces) and deploy the environment to respective workspaces.
