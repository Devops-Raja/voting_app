1. Using eksctl (Recommended)
This is the fastest way to get started. Ensure you have eksctl installed and configured with AWS credentials.

Bash
eksctl create cluster \
  --name <your-cluster-name> \
  --region <your-region> \
  --enable-auto-mode

--------------------------------------------------------------------------------------------
2. (Note: You must first download the official IAM policy from AWS and create it in your account if you haven't already).

curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json


aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json

#This command will output an ARN like arn:aws:iam::472514435602:policy/AWSLoadBalancerControllerIAMPolicy. Copy that ARN. You will need it for the next step.

aws iam attach-role-policy \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --policy-arn YOUR_POLICY_ARN
-----------------------------------------------------------------------------------------------
3. Set Up the AWS Load Balancer Controller
Your cluster needs permission to create and manage AWS Load Balancers.

Associate IAM OIDC Provider: Ensure your cluster has an OIDC provider.

Bash:
eksctl utils associate-iam-oidc-provider --cluster <your-cluster-name> --approve
Create IAM Policy & Service Account: The controller needs specific permissions to talk to AWS. You can create the IAM role and service account using eksctl:

Bash
eksctl create iamserviceaccount \
  --cluster=<your-cluster-name> \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<your-account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

aws iam attach-role-policy \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --policy-arn arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy
--------------------------------------------------------------------------------------------------

eksctl create iamserviceaccount \
  --cluster voting-app \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-name AmazonEKS_EBS_CSI_DriverRole

eksctl create addon --name aws-ebs-csi-driver --cluster voting-app --service-account-role-arn arn:aws:iam::<YOUR_ACCOUNT_ID>:role/AmazonEKS_EBS_CSI_DriverRole --force
  --------------------------------------------------------------------

4. Install the Controller: The easiest way is using Helm:

Bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<your-cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
5. Review and Apply Your YAMLs
Before applying, ensure your manifests are configured for the ALB:  

Service Type: Your Service should typically be ClusterIP.  

Ingress Annotations: Your Ingress YAML must include the specific annotations so the controller knows to pick it up:

YAML
annotations:
  kubernetes.io/ingress.class: alb
  alb.ingress.kubernetes.io/scheme: internet-facing
  alb.ingress.kubernetes.io/target-type: ip

-----------------------------------------------------------------------------------------
Kubernetes needs a storage class to automatically provision the disk (EBS) for your database.
6. eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster <YOUR_CLUSTER_NAME> \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --role-only \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve

eksctl utils associate-iam-oidc-provider --cluster <YOUR_CLUSTER_NAME> --approve

eksctl create addon --name aws-ebs-csi-driver --cluster <YOUR_CLUSTER_NAME> \
  --service-account-role-arn arn:aws:iam::<YOUR_ACCOUNT_ID>:role/AmazonEKS_EBS_CSI_DriverRole --force




6. kubectl apply -f ./k8/namespace.yaml
7. kubectl apply -f ./k8/ --recursive
