# Kubernetes cluster

aws eks update-kubeconfig --name eks-cluster --region us-east-1

# check current kubectl context
kubectl config get-contexts

# apply k8s sample app
kubectl apply -f ingressclass.yaml
kubectl create namespace game-2048 --save-config
kubectl apply -n game-2048 -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.8.0/docs/examples/2048/2048_full.yaml

# Reference to read
https://aws.amazon.com/blogs/networking-and-content-delivery/deploying-aws-load-balancer-controller-on-amazon-eks/

# Create IAM Role
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json