resource "aws_iam_role" "lb_controller_iam_policy" {
  name               = "${var.cluster_name}-lb-controller-policy"
  assume_role_policy = file("${path.module}/lb-controller-iam-policy.json")
}

# resource "aws_iam_role_policy_attachment" "LBControllerIAMPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
#   role       = aws_iam_role.lb_controller.name
# }


resource "aws_iam_role" "lb_controller_role" {
  name               = "${var.cluster_name}-lb-controller-role"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${var.openid_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${var.openid_url}:aud": "sts.amazonaws.com",
                    "${var.openid_url}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "AWSLoadBalancerControllerIAMPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.lb_controller_role.name
}
