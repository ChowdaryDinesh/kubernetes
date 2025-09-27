# kubernetes

## Ways to deploy:

### Option 1:
1. Have IntanceProfile attaached to the EC2 instance which are necessary to deploy the EKS cluster.
2. git clone https://github.com/ChowdaryDinesh/kubernetes.git
3. cd eks/terraform
5. Install the terraform, follow the hashicorp document for different OS: https://developer.hashicorp.com/terraform/install
4. Run `terraform init`
5. Run `terraform validate` (Optional)
6. Run `terraform plan` (Optional)
7. Run `terraform apply` 

### Option 2: ( From anywhere with internet access)
Pre-requisites:
1. AWS-Cli should be installed, follow the link for different OS: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
2. Run following steps:
    a. aws configure ( follow the prompts)
        Keep the accessKey, secretKey.
3. Perform same steps 4 to 7 as in `Option 1`


Note: Backend S3 is not implemented as part of this code, modify as required.

## Wait till the Cluster is up.

## To access the cluster:

### update the kubeconfig with aws cli:
    aws eks update-kubeconfig --name <cluster-name> --region <region>

Your cluster should be accessible.


