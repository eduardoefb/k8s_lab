# Deploy k8s using ansible over libvirt hypervisor

1 - Define your enviroment in config.yml
2 - Allow your machine to access (for now, using root user) allowing public key in hypervisor's authorized_keys

3 - Execute the playbook:

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts 00_run_without_installer.yaml 
```