Role Name
=========

Установка k8s с помощью kubeadm по официальной документации на debian, ubuntu, astra linux, где используется apt, с использованием containerd и cilium.  
> При выполнении задач используется первая нода в списке control_planes. Учитывайте это и всегда выставляйте в inventory первым рабочий control-plane.

В случае использования нескольких control-plane подготовьте внешний TCP балансировщик и укажите в переменной k8s_endpoint его адрес. В случае одного control-plane укажите его адрес.

### Инструкция по развертыванию
1. Создайте машины под кластер.
2. Укажите в inventory сервера и переменные:
```bash
control_planes:
    hosts:
        kub-mn-01:
        kub-mn-02:

worker_nodes:
    hosts:
        kub-wn-01:

k8s:
    children:
        control_planes:
        worker_nodes:
    vars:
        k8s_endpoint: "kub-lb.domain.local"
        k8s_controlplane_port: "6443"
        k8s_version: "1.31"

        backup_dir: "~/backup_k8s_remote/"
        backup_ansible_dir: "/backup_local"
        backup_time: ""
        backup_db: "etcd-{{ backup_time }}.db"
        backup_members: "members-{{ backup_time }}.txt"
        backup_manifests: "all-resources-backup-{{ backup_time }}.yaml"
        etcd_dir_to_restore: "/var/lib/etcd-{{ backup_time }}"

        zabbix_server_host: "zabbix.domain.local"
        zabbix_monitoring_version: "6.4"

        yandex_s3_bucket: "bucket"
        yandex_s3_key: "key"
        yandex_s3_secret: "secret"
```
3. Запустите роль с тегом -tags install.  
Она установит на сервера containerd, runc, пакеты из install_packages

Requirements
------------

Установка для Ubuntu/Debian.  
Список используемых переменных:  

- k8s_endpoint // Адрес балансировщика или control-plane в случае его отсутствия
- k8s_controlplane_port // Порт балансировщика или control-plane для подключения к API
- k8s_version // Версия кластера для установки или обновления

---

- containerd_distr_url
- runc_distr_url
- cni_plugins_distr_url
- install_packages
- ingress_definitions

---

- zabbix_server_host // Адрес zabbix сервера в случае установки агента в кластер
- zabbix_monitoring_version // Версия агента

---

- yandex_s3_bucket // Идентификатор бакета в S3 от Яндекс
- yandex_s3_key // Ключ доступа
- yandex_s3_secret // Секрет доступа

---

- backup_dir // Директория для сохранения бэкапа на нодах кластера
- backup_ansible_dir // Директория для сохранения бэкапа на сервере Ansible
- backup_time // Время бэкапа для восстановления
- backup_db // Файл с бэкапом для восстановления кластера
- backup_members // Файл с бэкапом состава кластера etcd
- backup_manifests // Файл с бэкапом манифестов всех развернутых ресурсов
- etcd_dir_to_restore // Директория с восстановленными данными для etcd

Dependencies
------------

wget

Example Playbook
----------------

1. Установка кластера.  
В переменной k8s_version указывается устанавливаемая версия.
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
1. Обновление кластера до заданной версии.  
В переменной k8s_version указывается устанавливаемая версия.
`pwsh ./Servers/Deployment/k8s/test/upgrade-k8s.ps1`
1. Вывод всех нод, заданных в inventory из кластера.
`pwsh ./Servers/Deployment/k8s/test/reset.ps1`
1. Удаление кластера со всех нод.
`pwsh ./Servers/Deployment/k8s/test/delete-k8s.ps1`
1. Резервное копирование кластера.
`pwsh ./Servers/Deployment/k8s/test/backup-k8s.ps1`
1. Восстановление кластера из резервной копии.
`pwsh ./Servers/Deployment/k8s/test/restore-k8s.ps1`

Author Information
------------------

Алексей Шумов

PS
------------------

На control-plane ноды устанавливается k9s для возможности удобного просмотра информации о кластере из командной строки.  
Команды:

- k9s - start gui  
- use ":" to navigate trough cluster resources <https://k9scli.io/topics/>
- PRESS ":" then TYPE "deploy" and PRESS "Enter" will open deployments list  
- PRESS ":" then TYPE "q" and PRESS "Enter" will close k9s and return you to shell  
