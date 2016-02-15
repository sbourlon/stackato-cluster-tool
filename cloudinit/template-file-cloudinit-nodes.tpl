#cloud-config

# Does not work
# users:
#  - name: stackato
#    sudo: ['ALL=(ALL) NOPASSWD:ALL']

apt_proxy: http://${core_ip}:3142
packages:
 - sshpass

bootcmd:
 # Waiting for the APT Cacher
 - bash -c 'while ! nc -z ${core_ip} 3142; do echo Waiting for APT Cacher on ${core_ip}; sleep 5; done'
 # Passwordless sudo before the Stackato firstboot
 - echo "stackato ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# stackato:
#   nats:
#     ip: ${core_ip}
#   roles: ${roles}

runcmd:
- while ! sshpass -p${core_password} ssh -o StrictHostKeyChecking=no stackato@${core_ip} test -d ${stackato_automation_path}; do echo "Waiting for ${core_ip}:${stackato_automation_path}"; sleep 5; done
- sshpass -p${core_password} rsync -a stackato@${core_ip}:${stackato_automation_path}/ ${stackato_automation_path}
- chmod u+x ${stackato_automation_path}/configure-node.sh
- ${stackato_automation_path}/configure-node.sh "${core_ip}" "${core_password}" "${cluster_hostname}" "${stackato_automation_path}" "${roles}"