data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_subnet_ids" "application_subnet" {
  vpc_id = "${aws_vpc.demo.id}"
  depends_on = ["aws_subnet.demo"]  
}

data "aws_subnet" "demo" {
  count = 2
  id = "${data.aws_subnet_ids.application_subnet.ids[count.index]}"
  depends_on = ["aws_vpc.demo"]
}


data "aws_instances" "instances" {
  depends_on = ["aws_instance.primary"]
  instance_tags {
    Role = "frontend"
  }
} 
