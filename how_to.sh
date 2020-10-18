ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts 01_enviroment.yaml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts 02_network.yaml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts 03_installer.yaml
vncviewer 10.2.1.30:20000&

ssh-keygen -f ~/.ssh/known_hosts -R "10.5.0.2"
ssh-copy-id -o StrictHostKeyChecking=no root@10.5.0.2
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts 04_prepare.yaml
#ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts 05_install_nodes.yaml

#Follow:
for i in `seq 20001 20006`; do vncviewer 10.2.1.31:${i}& done




ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts 06_wait_installation.yaml
