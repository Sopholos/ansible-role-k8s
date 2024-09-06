Role Name
=========
Установка k8s с помощью kubeadm по официальной документации на debian, ubuntu, astra linux, где используется apt.  
Внимание: с некоторых провайдеров недоступен ресурс https://pkgs.k8s.io/. Тогда надо использовать установку без пакетного менеджера с официального сайта.

TCP балансировщик (nginx)

Requirements
------------
Установка для Ubuntu/Debian.
!!! Заполните переменные в файле defaults/main.yml или укажите в запускаемом playbook:  
- k8s_endpoint
- k8s_control_planes
- k8s_workers

Role Variables
--------------


Dependencies
------------
wget

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------
BSD

Author Information
------------------
Алексей Шумов

PS
------------------
# install ingress controller
kubectl create namespace nginx-ingress && \
helm install nginx-ingress oci://ghcr.io/nginxinc/charts/nginx-ingress --version 1.1.3 -n nginx-ingress --set controller.kind=daemonset --set controller.hostNetwork=true;
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace --set controller.kind=daemonset --set controller.hostNetwork=true;
#################
## WORKER NODE ##
#################

#USE JOIN COMMAND FROM MASTER NODE KUBEADM OUTPUT

### K9s
k9s <-- start gui  
you MUST have ~/.kube/config file with current k8s config or KUDECONFIG environment variable  
use ":" to navigate trough cluster resources https://k9scli.io/topics/commands/  
EXAMPLE:  
PRESS ":" then TYPE "deploy" and PRESS "Enter" will open deployments list  
PRESS ":" then TYPE "q" and PRESS "Enter" will close k9s and return you to shell  
