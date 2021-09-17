output "vpc" {
    value = module.vpc
}
output "BastionSG" {
    value = aws_security_group.BastionSG
}
output "AppSG" {
    value = aws_security_group.AppSG
}
