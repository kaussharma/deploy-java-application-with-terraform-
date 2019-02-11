output "lb_address" {
  value = "${aws_alb.alb.dns_name}"
}

output "instance_ips" {
  value = ["${aws_instance.primary.*.public_ip}"]
}