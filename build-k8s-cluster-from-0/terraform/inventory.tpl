[master]
${master_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${key_name}.pem

[workers]
%{ for ip in worker_ips ~}
${ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${key_name}.pem
%{ endfor ~}

[all:vars]
ansible_python_interpreter=/usr/bin/python3
