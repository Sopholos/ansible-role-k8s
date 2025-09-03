Role Name
=========

Установка k8s с помощью kubeadm по официальной документации на debian, ubuntu, astra linux, где используется apt, с использованием containerd и cilium.  
> При выполнении задач используется первая нода в списке control_planes. Учитывайте это и всегда выставляйте в inventory первым рабочий control-plane.

В случае использования нескольких control-plane подготовьте внешний TCP балансировщик и укажите в переменной k8s_endpoint его адрес. В случае одного control-plane укажите его адрес.

Инструкция по развертыванию
------

1. Создайте машины, добавляемые в кластер, в том числе load-balancer.

2. Укажите в inventory сервера и переменные:

```bash
control_planes:
    hosts:
        kub-mn-01:
              
worker_nodes:
    hosts:
        kub-wn-01:

k8s:
    children:
        control_planes:
        worker_nodes:
    vars:
        k8s_endpoint: "kub-lb-01"
        k8s_controlplane_port: "6443"
        k8s_version: "1.31"

        backup_dir: "~/backup_k8s/"
        backup_ansible_dir: "/Users/macbook/backup"
        # backup_time: ""
        backup_db: "etcd-{{ backup_time }}.db"
        backup_members: "members-{{ backup_time }}.txt"
        backup_manifests: "all-resources-backup-{{ backup_time }}.yaml"
        etcd_dir_to_restore: "/var/lib/etcd-{{ backup_time }}"

        zabbix_server_host: "zabbix.local"
        zabbix_monitoring_version: "6.4"

        yandex_s3_bucket: "{{ yandex_s3_bucket_k8s }}"
        yandex_s3_key: "{{ yandex_s3_key_k8s }}"
        yandex_s3_secret: "{{ yandex_s3_secret_k8s }}"
```

3. Настройте load balancer, указав адреса control plane для TCP балансировки API порта.

``` bash
stream {
    upstream control_planes {
        server kub-mn-t-01.local:6443 fail_timeout=1s max_fails=2;
        server kub-mn-t-02.local:6443 fail_timeout=1s max_fails=2;
 
    }
    server {
        listen 6443;
        proxy_pass control_planes;
    }
 
}
```

4. Для развертывания кластера k8s запустите роль с тегом _-tags install_.  
Она установит на сервера containerd, runc, пакеты из install_packages, k8s (kubeadm), helm, ingress controller.
5. Для изменения состава worker node необходимо в inventory добавить/убрать узлы и запустить роль с тегом _-tags scale-worker-nodes_.
6. Для изменения состава control plane необходимо в inventory добавить/убрать узлы и запустить роль с тегом _-tags add_cp --extra-vars "cp=kub-wn-t-02"_ и _-tags del_cp --extra-vars "cp=kub-wn-t-02"_. Перед этим убрать control plane их haproxy!!!
7. Указав тег _-tags add-soft_, устанавливается через helm агент для zabbix, kubernetes dashboard, cronjob для резервного копирования etcd.
8. Для установки поддержки yandex s3 в качестве pvc запустите роль с тегом _-tags s3_.
9. Для обновления кластера в inventory укажите новую версию k8s (при необходимости containerd, runc) и запустите роль с тегом _-tags upgrade_.
10. Для резервного копирования etcd кластера запустите роль с тегом _-tags backup_.  
В заданной в переменной директории создадутся файлы:  
all-resources-backup-2024-10-17_14_13_08.yaml  
ca-2024-10-17_14_13_08.crt  
etcd-2024-10-17_14_13_08.db  
members-2024-10-17_14_13_08.txt
11. Для восстановления из резервной копии etcd запустите роль с тегом _-tags restore -extra-vars "backup_time=YYYY-MM-DD_HH_MM_SS"_.
12. Для полного удаления кластера с серверов, указанных в inventiry, запустите роль с тегом _-tags delete_.
13. Для сброса подключения к кластеру с серверов, указанных в inventiry, запустите роль с тегом _-tags reset_.

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
``` bash
- backup_dir // Директория для сохранения бэкапа на нодах кластера
- backup_ansible_dir // Директория для сохранения бэкапа на сервере Ansible
- backup_time // Время бэкапа для восстановления
- backup_db // Файл с бэкапом для восстановления кластера
- backup_members // Файл с бэкапом состава кластера etcd
- backup_manifests // Файл с бэкапом манифестов всех развернутых ресурсов
- etcd_dir_to_restore // Директория с восстановленными данными для etcd
- переменные для хелм чарта backup_etcd:
backup_etcd:
    cronJob:
        name: etcd-backup
        schedule: "0 3 ** *"
        image: "bitnami/etcd:latest"
        backupDir: "/tmp/backup"
    serviceAccount:
        name: etcd-backup-sa
    namespace: kube-system
    image:
        registry: gitlab.agroassist.ru:5050
        project: "devops/kubernetes/registry"
        name: "etcd"
        tag: "20241004-1455"
        pullPolicy: IfNotPresent
    credentials:
        username: "{{ username_registry }}"
        password: "{{ password_registry }}"
```

Dependencies
------------

wget

Example Playbook
----------------

Author Information
------------------

Алексей Шумов
 
