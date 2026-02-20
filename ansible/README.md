# infra

Install required ansible roles:
```bash
ansible-galaxy install -r requirements.yml
```

Update roles:
```bash
ansible-galaxy install -r requirements.yml --force
```

Apply playbook locally:
```bash
ansible-playbook -i inventory.yml local.yml
```
Apply to different host by changing target in a copy of local.yml and using that.

Largely sourced from and inspired by:
- https://github.com/notthebee/infra
- https://github.com/alf149/ansible-role-crowdsec
- https://github.com/bashirsouid/AnsibleKopia
