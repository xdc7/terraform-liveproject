provider "aws" {
    region = "us-east-1"
}
resource "aws_instance" "helloworld" {
    ami = "ami-0ee02acd56a52998e"
    instance_type = "t2.micro"
    tags = {
        Name = "HelloWorld"
    }
}
