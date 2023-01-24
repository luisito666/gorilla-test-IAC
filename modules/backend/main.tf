
data "tls_certificate" "k8s_certificate" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.k8s_certificate.certificates[*].sha1_fingerprint
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy_document" "eks_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = ["${aws_iam_openid_connect_provider.oidc.arn}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_service_account_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
  name               = "eks-oidc-service-account-role"
}


resource "aws_iam_role_policy" "eks_oidc_role_policy" {
  name   = "eks-alb-service-account-policy"
  role   = aws_iam_role.eks_service_account_role.id
  policy = file("${path.module}/ALBIngressControllerIAMPolicy.json")
}
