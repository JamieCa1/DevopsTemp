# Start both VMs

vagrant up

# SSH to control node

vagrant ssh control

# Inside control node, run Ansible

cd /vagrant/ansible
ansible-playbook -i inventory.yml site.yml

# Test app

curl http://172.16.128.10:5000

# Or from host: http://localhost:5000
