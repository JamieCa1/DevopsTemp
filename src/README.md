# Source code

This directory contains all source code for setting up the infrastructure necessary for running the application. Provide a clear directory structure with an overview in the main [README](../README.md) file.

# test:

run:

```bash
vagrant ssh controlnode -c "cd /vagrant && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ansible/site.yml -i ansible/inventory_dev.yml"
```

or

```bash

$ vagrant destroy -f && vagrant up && vagrant ssh controlnode -c "cd /vagrant && ANSIBLE_HOST_KEY_CHECKING=False ALLOW_BROKEN_CONDITIONALS=true ansible-playbook ansible/site.yml -i ansible/inventory_dev.yml"
```
