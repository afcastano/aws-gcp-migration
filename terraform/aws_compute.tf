#Deploy Wordpress instances
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.aws_disk_image}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "datafile" {
  template = "${file("${path.cwd}/aws_cloudconfig/vm_config.sh")}"
}

resource "tls_private_key" "demo_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "demo_keys" {
  key_name   = "wp_key"
  public_key = "${tls_private_key.demo_private_key.public_key_openssh}"
}

# bastion server
resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.ubuntu.id}"
  vpc_security_group_ids = [
    "${aws_security_group.pub.id}"
  ]
  instance_type = "${var.aws_instance_type}"
  subnet_id = "${aws_subnet.pub_subnet_1.id}"

  key_name = "${aws_key_pair.demo_keys.key_name}"
  tags {
    Name = "WordPress Bastion"
    SELECTOR = "bastion"
  }
}

# bastion server
resource "aws_instance" "db" {
  ami = "${data.aws_ami.ubuntu.id}"
  vpc_security_group_ids = [
    "${aws_security_group.pub.id}"
  ]
  instance_type = "${var.aws_instance_type}"
  subnet_id = "${aws_subnet.pub_subnet_1.id}"

  key_name = "${aws_key_pair.demo_keys.key_name}"
  tags {
    Name = "WordPress DB"
    SELECTOR = "db"
  }
}

resource "aws_eip" "db_eip" {
  depends_on = ["aws_internet_gateway.app_igw"]
}

resource "aws_eip_association" "db_eip_assoc" {
  instance_id = "${aws_instance.db.id}"
  allocation_id = "${aws_eip.db_eip.id}"
    provisioner "remote-exec" {
    inline = [
      "echo '############################## Installing velostrata...'",
      "wget -O 'velostrata-prep_4.2.0.deb' 'https://storage.googleapis.com/velostrata-release/V4.2.0/Latest/velostrata-prep_4.2.0.deb'",
      "sudo dpkg -i velostrata-prep_4.2.0.deb",
      "sudo apt-get install -f -y",
      "sudo dpkg -i velostrata-prep_4.2.0.deb",
      "echo '############################## Installing mysql...'",
      "sudo apt-get update",
      "echo 'mysql-server mysql-server/root_password password passw' | sudo debconf-set-selections",
      "echo 'mysql-server mysql-server/root_password_again password passw' | sudo debconf-set-selections",
      "sudo apt-get -y install mysql-server",
      "echo '############################## Creating mysql user...'",
      "mysql -uroot -ppassw -e 'GRANT ALL ON *.* TO \"wpdemo\"@\"%\" IDENTIFIED BY \"wpdemo\";'",
      "echo '############################## Allow remote connections...'",
      "sudo sh -c \"echo '[mysqld]' >> /etc/mysql/my.cnf\"",
      "sudo sh -c \"echo 'bind-address = 0.0.0.0' >> /etc/mysql/my.cnf\"",
      "sudo sh -c \"echo '[client]' >> /etc/mysql/my.cnf\"",
      "sudo sh -c \"echo 'port = 3306' >> /etc/mysql/my.cnf\"",
      "sudo cat /etc/mysql/my.cnf",
      "echo '############################## Restarting service'",
      "sudo service mysql restart",
      "echo '############################## Done'",
      "sleep 20"
    ]
  }

  connection {
    type        = "ssh"
    private_key = "${tls_private_key.demo_private_key.private_key_pem}"
    host        = "${self.public_ip}"
    user        = "ubuntu"
    timeout     = "30s"
  }

}

resource "aws_eip" "bastion_eip" {
  depends_on = ["aws_internet_gateway.app_igw"]
}

resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion_eip.id}"
  provisioner "remote-exec" {
    inline = [
      "echo '############################## installing velostrata...'",
      "wget -O 'velostrata-prep_4.2.0.deb' 'https://storage.googleapis.com/velostrata-release/V4.2.0/Latest/velostrata-prep_4.2.0.deb'",
      "sudo dpkg -i velostrata-prep_4.2.0.deb",
      "sudo apt-get install -f -y",
      "sudo dpkg -i velostrata-prep_4.2.0.deb",
      "echo '############################## installing docker...'",
      "sudo apt-get update",
      "sudo apt-get -y install docker.io",
      "echo '############################## installing wp...'",
      "sudo docker pull wordpress",
      "echo '############################## running wp...'",
      "sudo docker run --restart always --name wpsite -e WORDPRESS_DB_HOST=${aws_instance.db.private_ip}:3306 -e WORDPRESS_DB_USER=wpdemo -e WORDPRESS_DB_PASSWORD=wpdemo -p 8080:80 -d wordpress",
      "echo '############################## Done'",
      "sleep 20"
    ]
  }

  connection {
    type        = "ssh"
    private_key = "${tls_private_key.demo_private_key.private_key_pem}"
    host        = "${aws_eip.bastion_eip.public_ip}"
    user        = "ubuntu"
    timeout     = "30s"
  }
  depends_on = ["aws_eip_association.db_eip_assoc"]
}

#public access sg 
resource "aws_security_group" "pub" {
  name = "pub-secgroup"
  vpc_id = "${aws_vpc.app_vpc.id}"

  # ssh access from anywhere
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}