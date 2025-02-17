resource "aws_instance" "ec2bkn" {
  instance_type = "t4g.nano"
  tags = {
    Name = "test-spot"
  }
  ami = "ami-0c518311db5640eff"
}