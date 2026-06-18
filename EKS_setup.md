Using eksctl (Recommended)
This is the fastest way to get started. Ensure you have eksctl installed and configured with AWS credentials.

Bash
eksctl create cluster \
  --name <your-cluster-name> \
  --region <your-region> \
  --enable-auto-mode

--------------------------------------------------------------------------------------------
(Note: You must first download the official IAM policy from AWS and create it in your account if you haven't already).
ALB setup:
eksctl utils associate-iam-oidc-provider --cluster <your-cluster-name> --approve

curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json


aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json

#This command will output an ARN like arn:aws:iam::472514435602:policy/AWSLoadBalancerControllerIAMPolicy. Copy that ARN. You will need it for the next step.
Bash

  eksctl create iamserviceaccount \
  --cluster=<your-cluster-name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

--------------------------------------------------------------------------------------------------
EBS DRIVER SA & Setup:

eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster <your-cluster-name> \
  --service-account-role-arn arn:aws:iam:::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole \
  --force

  eksctl create addon --name aws-ebs-csi-driver --cluster voting-app --force

Kubernetes needs a storage class to automatically provision the disk (EBS) for your database.
   eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster <YOUR_CLUSTER_NAME> \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --role-only \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve

  --------------------------------------------------------------------

 Install the Controller: The easiest way is using Helm:

Bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<your-cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

-----------------------------------------------------------------------------------------
note: genrally in EKS auto mode you dont need to create ALB controller
Just defining a ingress class will help you to provision the LB