Role Name
=========

Установка k8s с помощью kubeadm по официальной документации на debian, ubuntu, astra linux, где используется apt, с использованием containerd и cilium.  
> При выполнении задач используется первая нода в списке control_planes. Учитывайте это и всегда выставляйте в inventory первым рабочий control-plane.

В случае использования нескольких control-plane подготовьте внешний TCP балансировщик и укажите в переменной k8s_endpoint его адрес. В случае одного control-plane укажите его адрес.

Requirements
------------

Установка для Ubuntu/Debian.  
Список используемых переменных:  

- k8s_version
- k8s_controlplane_port
- k8s_endpoint
- k8s_control_planes
- k8s_workers
- zabbix_server_host
- zabbix_monitoring_version
- containerd_distr_url
- runc_distr_url
- cni_plugins_distr_url
- install_packages
- ingress_definitions
- yandex_s3_bucket
- yandex_s3_key
- yandex_s3_secret

Dependencies
------------

wget

Example Playbook
----------------

1. Установка кластера.
`pwsh ./Servers/Deployment/k8s/test/install-k8s.yml`
1. Инициализация кластера.
`pwsh ./Servers/Deployment/k8s/test/init-k8s.yml`
1. Добавление или удаление worker nodes в соответствии с файлом inventory.
`pwsh ./Servers/Deployment/k8s/test/scale-workers-k8s.ps1`
1. Добавление control plane с etcd.
`pwsh ./Servers/Deployment/k8s/test/add-cp-k8s.ps1 -cp kub-wn-t-01`
1. Удаление control plane с etcd.
`pwsh ./Servers/Deployment/k8s/test/del-cp-k8s.ps1 -cp kub-wn-t-01`
1. Установка дополнительного ПО (zabbix, kubernetes dashboard).
`pwsh ./Servers/Deployment/k8s/test/install_additional_soft.ps1`
1. Добавление/удаление ingress в соответствии с заданной переменной ingress_definitions.  
`pwsh ./Servers/Deployment/k8s/test/ingress.ps1`
Ингрессы, которые отсутствуют в переменной, а в кластере существуют - __удаляются!!!__
1. Добавление CSI для подключения к Yandex S3.
`pwsh ./Servers/Deployment/k8s/test/yandex-s3.ps1`
1. Вывод всех нод, заданных в inventory из кластера.
`pwsh ./Servers/Deployment/k8s/test/reset.ps1`

Author Information
------------------

Алексей Шумов

PS
------------------
На control-plane ноды устанавливается k9s для возможности удобного просмотра информации о кластере из командной строки.  
Команды:
- k9s - start gui  
- use ":" to navigate trough cluster resources https://k9scli.io/topics/  
- PRESS ":" then TYPE "deploy" and PRESS "Enter" will open deployments list  
- PRESS ":" then TYPE "q" and PRESS "Enter" will close k9s and return you to shell  
