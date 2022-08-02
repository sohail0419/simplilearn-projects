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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDvGlmQjl4+h2L/ir58EuVNT2kzOjMiktkke6IOYypAdE2JlmBplBU0nKddWN4tWzoqsgT/H0O47238243XHRkA94q5QPpzXMTSFuvlV1jk7lNvdP7sEQL9FxRwpAhTtLPQei7uih6m4j6ZFF8PEUWu1v36Glx6vE/EMn0MEclAyqdRrOywdEGni6W73RyErP/3OWgZauU8nZRFLTp5+y9Zs1jGVO9+IfpuLO+riCaID4OYhfDFVBgKCWgQuK6QEH7i/i2HaQHepDXIeuv0B/StjH5Y+0GA36JnC2v5q5zeA1sXS10C1aoyUf5wFPAWnkKOIu341iJTy3slhfoh7tHGWul4x6BkbpMGGP3YBqUDu+sq/UwZmPAZ/ZoLP7lCLIphsePfACfzwCBvfzUbMcWPM4fSN5omtbfrusJM4CTSbzi8MjBR7GxNlf85aWQ+GVRzsCjlRgnY5wu+QqHL1lRbHMdMigvf6lCGXDFVS070KLggN5IqlMYAPR5hxyr8KA8= root@ip-172-31-22-94"
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
