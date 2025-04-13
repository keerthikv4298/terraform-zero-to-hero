output "public_ip"{
    description = " here you can see the elastic ip"
    value = aws_instance.instance1.public_ip
}
output "instance_id_details"{
    description = "here you can see the instance id"
    value = aws_instance.instance1.id
}