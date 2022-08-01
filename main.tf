# # Creation of VM in AWS 
#  - Security group 

resource "aws_security_group" "allow_SSH" {
  name        = "allow_SSH1"
  description = "Allow SSH inbound traffic"

  #  - INBOUND

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  #  - OUTBOUND RULES

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#  - key pair

resource "aws_key_pair" "deployer1" {
  key_name   = "deployer-key11"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqqtyRPayg7jmneSc6ZbNSsuVpDKjrVVINKi88mRvzd/Nh0YCkLTPjUU2r5jCGu3Suh7ZD2Xn6fdWsS97ZBiqB0HTTXp4PYLznSQceZYVLska3C0hO9IvvoKZwK3SlX+DgxQGZvb1d3SmFj0zRsABh393qbDGAuUITChtc5JOoQGzi0wmLLmXB22iofHY1qHMgyGLnVMwTe4R8VZGCrhgSOcQn/yRbnRdbF4AREFHT8v1NrOUa3Mczd6NdkS3eDvaR1Fmy6V6OIOIgWPrMl+7oTadvaNtfDwmHMHUlY+MRdJBcnwZfzMYQEFGxMLSvktRLZiqfvd9Almpd9q8o0vRsj3X1pQQroZcTEaph1bmCcOSj9/VQL9k4Rfq1NSb6WRk30/xTL4TiIZSe0Ape3LPb8uYsAI51GikCGNnn8B7nQGR1zVsI7duov55tUbcPfLERox7hYEEC/+J6O8Eor1uC2gmJK7NgwpFXYGC0f/2ZGOlAM8KReNCj0HCE2kK7DRs= sohailsonu498gm@ip-172-31-22-94"
}

resource "aws_instance" "amzn-linux" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer1.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  tags = {
    "Name" = "Linux-Node"
    "ENV"  = "Dev"
  }

  depends_on = [aws_key_pair.deployer1]

}


####### Ubuntu VM #####


resource "aws_instance" "ubuntu" {
  ami                    = "ami-04505e74c0741db8d"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer1.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  tags = {
    "Name" = "UBUNTU-Node"
    "ENV"  = "Dev"
  }


  # Type of connection to be established
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./deployer")
    host        = self.public_ip
  }

  # Remotely execute commands to install Java, Python, Jenkins
  provisioner "remote-exec" {
    inline = [
      "sudo apt update && upgrade",
      "sudo apt install -y python3.8",
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ >  /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-8-jre",
      "sudo apt-get install -y jenkins",
      "sudo apt-get install -y docker docker.io",
      "sudo chmod 777 /var/run/docker.sock",
      "sudo cat  /var/lib/jenkins/secrets/initialAdminPassword",
    ]
  }

  depends_on = [aws_key_pair.deployer1]

}
