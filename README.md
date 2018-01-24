[![Build Status](https://travis-ci.org/Otus-DevOps-2017-11/mrgreyves_infra.svg?branch=ansible-3)](https://travis-ci.org/Otus-DevOps-2017-11/mrgreyves_infra)
## Otus DevOps Home Work 5 by Vladimir Drozdetskiy

### Стенд:
Хост Bastion: External 35.187.126.40 Internal 10.132.0.2  
Хост Someinternalhost: External None Internal 10.132.0.3

### Слайд 36 выполнение задания:

На своей "машине" редактируем и редактируем файл ~/.ssh/config  
Не забывал выставить права 600 на файл config  
Так же не забываем включить Forward agent  
Начиная с OpenSSH_7.3p1 можно использовать ProxyJymp вместо ProxyCommand
```
Host bastion
Hostname 35.187.126.40
User root
Port 22

Host someinternalhost
Hostname 10.132.0.3
User root
Port 22
ProxyCommand ssh bastion -W %h:%p
```
Теперь к someinternalhost мы можем подключиться командой:  

ssh someinternalhost  

### Дополнительное задание:
```
ssh -o ProxyCommand='ssh -W %h:%p bastion' someinternalhost
#Используем ProxyCommand
```

```
ssh -t bastion ssh someinternalhost  #Вариант для студентов:)
```
```
ssh -L 2587:someinternalhost:22 bastion  
#Проброс локального порта на someinternalhost,
есть минус нужно подключаться через второй терминал:)
```
## Otus DevOps Home Work 6 by Vladimir Drozdetskiy  
```
Самостоятельная работа
Команды по настройке системы и деплоя приложения нужно завернуть
в баш скрипты, чтобы не вбивать эти команды вручную:
• скрипт install_ruby.sh - должен содержать команды по установке руби.
• скрипт install_mongodb.sh - должен содержать команды по установке
MongoDB
• скрипт deploy.sh должен содержать команды скачивания кода,
установки зависимостей через bundler и запуск приложения.
Для ознакомления с базовыми принципами написания баш скриптов
можно ознакомится с переводом хорошей серии туториалов.
Как минимум, нужно чтобы итоговые баш скрипты:
• Содержали shebang в начале
• Выполняли необходимые действия
• В репозиторий были закомиченными исполняемыми файлами (+x )
```
```
Дополнительное задание
В качестве доп задания используйте созданные ранее
скрипты для создания Startup script, который будет
запускаться при создании инстанса. Передавать Startup
скрипт необходимо как доп опцию уже использованной
ранее команде gcloud. В результате применения данной
команды gcloud мы должны получать инстанс с уже
запущенным приложением. Startup скрипт необходимо
закомитить, а используемую команду gcloud вставить в
описание репозитория (README.md)  
```
Вариант 1:  
```
gcloud compute instances create reddit-app\
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--zone=europe-west1-b \
--metadata-from-file "startup-script=./Extra.sh"
```
Здесь мы используем в качестве startup-script скрипт который лежит локально  

Вариант 2:
```
gcloud compute instances create reddit-app\
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--zone=europe-west1-b \
--metadata "startup-script-url=https://raw.githubusercontent.com/Otus-DevOps-2017-11/mrgreyves_infra/Infra-2/Extra.sh"
```
В качестве startup-script используем скрипт который лежит в удаленном репозитории

Вариант 3:
```
 gcloud compute instances create reddit-app\
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--zone=europe-west1-b \
--metadata "startup-script-url=gs://hw6/Extra.sh"
```
В качестве startup-script используем скрипт который лежит в Storage в бакете hw6


## Otus DevOps Home Work 7 by Vladimir Drozdetskiy  

1. Был создан файл для packer с описание образа ubuntu16.json  
В нем так же были указаны переменные в блоке variables  

```
"proj_id":"aerial-yeti-188613",
"source_image_family":"ubuntu-1604-lts",
"machine_type":"f1-micro"

```

2. В файле ubuntu16.json были использованы параметры обозначающие жесткий диск,  
теги, название сети, описание образа.  

```
"disk_size": "10",
"disk_type":"pd-standard",
"network":"default",
"tags":["puma-server"],
"image_description":"Otus DevOps HW_07 by VD"
```

PS: теги присваиваются образу в момент создания, потом они удаляются.  

3. Задание со * 1
Был создан файл для packer immutables.json. Образ собирается на основе ранее  
созданного образа reddit-base. Для автозапуска приложению был создан сервис.  
Так же была произведена первоначальная настройка.  
Секция с описанием и установкой сервиса:  

```
{
      "type":"file",
      "source":"files/reddit_app.service",
      "destination":"/tmp/"
    },
    {
      "inline":[
        "cd /tmp",
        "sudo mv reddit_app.service /etc/systemd/system/reddit_app.service",
        "systemctl enable reddit_app.service"

```

Сервис reddit_app.service  

```
[Unit]
Description=Reddit_app Otus DevOps
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/reddit/
ExecStart=/usr/local/bin/puma
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

4. Был создан простой скрипт который создает инстанс из ранее "запеченого" образа  

```
#!/bin/bash
gcloud compute instances create "reddit-app" \
--project "aerial-yeti-188613" \
--zone "europe-west1-b" \
--machine-type "f1-micro" \
--subnet "default" --maintenance-policy "MIGRATE" \
--tags "puma-server" --image-family reddit-full \
--boot-disk-size "10" --boot-disk-type "pd-standard"
```

## Otus DevOps Home Work 8 by Vladimir Drozdetskiy

1. Была опредлена input переменная для приватного ключа для подключения провиженеров  
 в файле variables.tf

```
variable private_key_path {
  description = "~/.ssh/appuser"
}

```

2. Была опредлена переменная для задания зоны в ресурсе "google_compute_instance" "app"  
в файле terraform.tfvars. В данном файле используются переменные заданные по умолчанию.  

```
zone = "europe-west1-b"
```
3. Было произведено форматирование конфигурационных файлов командой terraform fmt  
Команда выравнила файлы.  
Было:

```
provider "google" {
version = "1.4.0"
project = "${var.project}"
region  = "${var.region}"
}

```

Стало:

```
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

```

4. Был создан файл terraform.tfvars.example в качестве примера.

```
project = "You project ID"
public_key_path = "~/.ssh/appuser.pub"
disk_image = "reddit-base"
private_key_path = "~/.ssh/appuser"
```

5. Задание со звездочкой 1
Для добавления нескольких ключей можно использовать конструкцию

```
sshKeys = "user:${file(var.public_key_path)}*\n*user1:${file(var.public_key_path)}"
```
При этом будут добавлены 2 ключа. Поле metadata на сервере имеет ограничение по объему.  
Для ssh-keys это 256KB.
При ручном добавлении ключа через консоль gcp terraform его затрет.
Символ \n означает перенос строки. (в редакторе не влезает в строку)  
Для добавления ключей я бы лучшу использовал Ansible и т.д.

6. Задание со звездочкой 2

Согласно документации были определены параметры нашего балансировщика.  
Количество хостов для балансировки трафика в моем случае 2.  
Необходимо указать ряд ресурсов:  
* resource "google_compute_instance_group" "app" - указываем наши инстансы, (благодаря использованию
  count настройка стала проще:)), уменованные порты (9292 в нашем случае), зону
  где располагаются наши инстансы;
* resource "google_compute_global_forwarding_rule" "forward-rule" - указываем с какого порта
перенапрявлять трафик.  
* resource "google_compute_target_http_proxy" "proxy-rule" - указываем наш proxy  
* resource "google_compute_url_map" "app-url-map" - указываем url-map для нашего backend  
* resource "google_compute_backend_service" "app-backend" - указываем на backend.  
Так же указываем порт на котором живет наш сервис,протокол, health-check.  
* resource "google_compute_http_health_check" "app-health-check" - указываем параметры  
health-check (проверка доступности). В моем случаем это интервал проверки 15с, таймаут 5с.  
Так же указываем порт который проверяем.

PS: Использование count значительно облегчило создание нескольких инстансов.  
Если по каким либо причинам мы не собирамся\не можем использовать count,  
мы можем создать аналогичный main.tf с описанием еще одного\нескольких инстансов.  
Помимо всего была добавлена output переменная которая выдает адрес балансировщика  
```
output "lb_ip" {
  value = "${google_compute_global_forwarding_rule.reddit-forward.ip_address}"
}
```


## Otus DevOps Home Work 9 by Vladimir Drozdetskiy

В данном ДЗ были переделаны образы при помощи packer.  
Был создан файл конфигурации app.json в котором описывается создание образа  
с приложением.  

```
{
   "variables":{
         "proj_id":null,
         "source_image_family":null,
         "machine_type":"f1-micro"
   },
   "builders":[
      {
         "type":"googlecompute",
         "project_id":"{{user `proj_id`}}",
         "image_name":"reddit-app-base-{{timestamp}}",
         "image_family":"reddit-app-base",
         "source_image_family":"{{user `source_image_family`}}",
         "zone":"europe-west1-b",
         "ssh_username":"appuser",
         "machine_type":"{{user `machine_type`}}",
         "disk_size": "10",
         "disk_type":"pd-standard",
         "network":"default",
         "tags":["puma-server"],
         "image_description":"Otus DevOps HW_09 App by VD"
      }
   ],
   "provisioners":[
      {
         "type":"shell",
         "script":"scripts/install_ruby.sh",
         "execute_command":"sudo {{.Path}}"
      }
   ]
}

```
Создаем образ  
```
packer build -var-file=variables.json app.json
```

Так же создан файл конфигурации db.json. В нем описывается создание образа с DB.  

```
{
   "variables":{
         "proj_id":null,
         "source_image_family":null,
         "machine_type":"f1-micro"
   },
   "builders":[
      {
         "type":"googlecompute",
         "project_id":"{{user `proj_id`}}",
         "image_name":"reddit-db-base-{{timestamp}}",
         "image_family":"reddit-db-base",
         "source_image_family":"{{user `source_image_family`}}",
         "zone":"europe-west1-b",
         "ssh_username":"appuser",
         "machine_type":"{{user `machine_type`}}",
         "disk_size": "10",
         "disk_type":"pd-standard",
         "network":"default",
         "tags":["puma-server"],
         "image_description":"Otus DevOps HW_09 DB by VD"
      }
   ],
   "provisioners":[
      {
         "type":"shell",
         "script":"scripts/install_mongodb.sh",
         "execute_command":"sudo {{.Path}}"
      }
   ]
}

```
Создаем образ  
```
packer build -var-file=variables.json db.json
```
Самостоятельные задания:  
1. Были перенесены файлы main.tf, outputs.tf, terraform.tfvars, variables.tf  
в директории с описание окружений prod и stage;    
2. Была произведена параметризация окружений;  
3. Произведено форматирование при помощи команды

```
terraform fmt  
```

Задание со звездочкой 1  
Был создан remote backend на Google Cloud Storage по данному [мануалу](https://www.terraform.io/docs/backends/types/gcs.html)  
для окружения prod.
```
terraform {
  backend "gcs" {
    bucket = "hw9"
  }
}
```  
Где bucket = "hw9" это созданный бакет в GCS. При одновременном запуске применения  
изменений возникает блокировка.

Задание со здвездочкой 2  

Были добавлены необходимые провиженеры в модули app и db.  
Для app:

```
provisioner "file" {
    content     = "${data.template_file.pumaservice.rendered}"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }

```

Для db:

```
provisioner "file" {
    content     = "${data.template_file.mongod-config.rendered}"
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/mongod.conf /etc/mongod.conf",
      "sudo systemctl restart mongod",
    ]
  }

```

Не забываем указывать connection для провиженеров. Они одинаковые для app и db.  

```
connection {
    type        = "ssh"
    user        = "appuser"
    private_key = "${file(var.private_key_path)}"
  }
```

Все необходимые файлы были добавлены в каталоги files для каждого модуля.  
Так же была определены output переменные для модуля db.  
Нужна для передачи IP инстанса с бд в конфиг сервиса на инстансе с приложением.  

```
output "db_internal_ip" {
  value = "${google_compute_instance.db.network_interface.0.network_ip}"
}

output "db_external_ip" {
  value = "${google_compute_instance.db.network_interface.0.access_config.0.assigned_nat_ip}"
}
```

PS: было проверена работа с реестром модулей. Был создан storage bucket c   
содержимым:

```
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"
  name    = ["otus-hw-dv-001", "otus-hw-dv-002"]
}

output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}

```

Так же был создан файл с переменными variables.tf:

```
variable project {
  description = "PROJECT ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

```

При использовании команды  

```
terraform apply
```
создается 2 storage bucket с именами otus-hw-dv-001", "otus-hw-dv-002.  
При использовании

```
terraform destroy
```

Storage bucket удаляются


### PS: не забываем в prod окружении сменить ip в source ranges на свой:)   
### PSS: есть не очень очевидная особенность. Когда мы создаем 2 инстанса app и db, необходимо передавать в app внутренний ip адрес (internal) инстанса db для подключения к mongo, иначе firewall будет нас блокировать  


## Otus DevOps Home Work 10 by Vladimir Drozdetskiy

Была произведена инсталяция ansible согласно данным в ДЗ. Создан файл requirements.txt.  
Были сформированы файлы inventory(json,yml) с описанием инстансов. Произведена проверка ping.  

```
username:~/devops/hw/10/mrgreyves_infra/ansible# ansible appserver -i ./inventory -m ping
appserver | SUCCESS => {
    "changed": false,
    "ping": "pong"

```

```
username:~/devops/hw/10/mrgreyves_infra/ansible# ansible dbserver -i ./inventory -m ping
dbserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
Проверка ping для всех инстансов сразу (используется файл с расширением yaml):  

```
username:~/devops/hw/10/mrgreyves_infra/ansible# ansible all -m ping -i inventory.yml
dbserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
appserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

```

### Задание со звездочкой *

Была найдена статья в интернете с описанием создания файла inventory в формате   
json [тут](https://www.jeffgeerling.com/blog/creating-custom-dynamic-inventories-ansible).  
Просле ее прочтения и офф официальной документации узнал что ansible принимает  
данные в формате json если "что-то" отправляет в stdout. В качетве образца был  
использован скрипт [от сюда](https://gist.github.com/sivel/3c0745243787b9899486).  
Произведены небольшие правки. Добавлена переменная на файл inventory на основе которого формируется  
json.

```
inventory_file = "./inventory"
```
Произведено тестирование

```
username:~/devops/hw/10/mrgreyves_infra/ansible# ansible all -i ansible-to-json.py -m ping
dbserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
appserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
## Otus DevOps Home Work 11 by Vladimir Drozdetskiy

Был создан файл inventory в котором указаны ip адреса наших инстансов

```
[app]
appserver ansible_host=app ip

[db]
dbserver ansible_host=db ip

```
Так же был создан файл inventory.yml, инаформация описанная в нем аналогична.

Были созданы плейбуки в которых описывается диплой и настройка приложения,  
настройка инстанса БД mongodb

reddit_app_one_play.yml и reddit_app_multiple_play.yml - внутри созданы такс с тегами  
для применения определенных плеев. При указании тегов во время выполнения  
можно тем самым указать какой плей выполнить.
Так же были созданы плейбуки в которых описывается настройка бд (db.yml), настройка приложения (app.yml),  
установка приложения (deploy.yml)
Все отдельные плейбуки (app.yml, db.yml, deploy.yml) были испортированы в плейбук site.yml


```

---
- import_playbook: db.yml
- import_playbook: app.yml
- import_playbook: deploy.yml

```

Все плейбуки прошли проверку и применились на нужных инстансах.

### Задание со звездочкой *


При чтении [официальной документации](http://docs.ansible.com/ansible/latest/guide_gce.html)  
выяснил что Ansible у меня создавать динамический inventory. Из [официального репозитория](https://github.com/ansible/ansible/)  
были взяты файлы gce.ini и gce.py. Gce.py создает динамический inventory и выводит его в stdoud в формате json  
который понятен ansible. Был создан сервис аккаунт в gcp и получены данные для подключения. Файл gce.ini описывает  
подключение к gcp

```
gce_service_account_email_address =service account email
gce_service_account_pem_file_path =key.json
gce_project_id =project-id

```

Так же для работы скрипта необходимо было установить apache-libcloud

```
pip install apache-libcloud

```

#### При использовании gce.py необходимо использовать gce.ini

```
username:ansible vladimirdrozdeckij$ ansible all -i ./gce.py -m ping
reddit-app | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
reddit-db | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

```

Были изменен провижин в packer путем добавление в него плейбуко ansible.  
Образы пересоздались корректно. Произведена проверка установки/настройки приложения  
и бд. Все корректно, посты создаются.

PS: во время проверки не забываем проверить файлы пакера app.json, db.json и в случае необходимости  
переопределить пути до плейбуков ansible. 

## Otus DevOps Home Work 12 by Vladimir Drozdetskiy

В данном ДЗ мы создали наши роли (app, db) и пересни их в одноименные папки.  
Так же в terraform было добавлено правило для открытия 80 порта для проверки нашего приложения.  

```

resource "google_compute_firewall" "firewall_nginx_proxy_80" {
  name    = "allow-nginx-proxi"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

```

Был добавлен вызов публичной роли jdauphant.nginx в плейбук app.yml

```

---
- name: Configure app
  hosts: app
  become: true
  vars:
   db_host: ip address
  roles:
    - app
    - jdauphant.nginx

```

Был применен плейбук site.yml и проверена доступность нашего приложения по 80 порту

```

ansible-playbook -i environments/stage/inventory  playbooks/site.yml --check

```

```

appserver                  : ok=20   changed=0    unreachable=0    failed=0
dbserver                   : ok=3    changed=0    unreachable=0    failed=0

```

Проверка доступности нашего приложения по 80 порту

```

curl -Is http://35.205.70.81

```

```

HTTP/1.1 200 OK
Server: nginx
Date: Sun, 21 Jan 2018 17:47:29 GMT
Content-Type: text/html;charset=utf-8
Content-Length: 1861
Connection: keep-alive
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Set-Cookie: rack.session=BAh7CEkiD3Nlc3Npb25faWQGOgZFVEkiRWNmYTdjNTM3OTQ0OTVlMDY1ZjVi%0ANGYxYmNiNmI0MGZmNmU2YTdmYTFjZGY4Nzg1MTYyZjhjMGUxNGE2MTdlYzIG%0AOwBGSSIJY3NyZgY7AEZJIjExR0swTWRRWWRvcTdZelB5b2dwSTFlUzRQQ1ZS%0AVTY2QUN4ajU3c1I0eHJZPQY7AEZJIg10cmFja2luZwY7AEZ7B0kiFEhUVFBf%0AVVNFUl9BR0VOVAY7AFRJIi01NmMxYTdkOWI2YjdjZjUyMTdkNTk1YjM4MjVm%0AZDc4MjI5MmIyNGNjBjsARkkiGUhUVFBfQUNDRVBUX0xBTkdVQUdFBjsAVEki%0ALWRhMzlhM2VlNWU2YjRiMGQzMjU1YmZlZjk1NjAxODkwYWZkODA3MDkGOwBG%0A--d7d6f460bb67353cc571d5e2929948ea605101e2; path=/; HttpOnly

```


### Задание со звездочкой *

При выполнении этого задания было решено использовать terraform-inventory.  
Был найден [репозиторий](https://github.com/adammck/terraform-inventory) с описанием установки и использования.  
Есть маленькая особенноть, получить список инстансов terraform-inventory может если в папке находится файл  
terraform.tfstate. После это бы написан скрипт.

```

#!/usr/bin/env bash
env="stage"
TF_STATE=../terraform/${env}/terraform.tfstate terraform-inventory $1

```

Скрипт был проверен для всех окружений, отработал корректно.  

```

ansible-playbook -i environments/stage/terraform_inventory.sh playbooks/site.yml --check

```

```

35.189.241.104             : ok=3    changed=0    unreachable=0    failed=0
35.205.70.81               : ok=20   changed=0    unreachable=0    failed=0

```


### Задание со звездочкой **

Был создан файл .travis.yml в котором описано тестирование. Не забываем указывать с какой веткой работаем.  
Есть особенность если какая то комманда отправлет на выходе exit code  отличный от 0 билд получется с ошибкой.  
Не забываем так же указывать переменные для терраформа, инача terraform validate не пройдет.  
Так же необходимо следить за путями приложений и файлов.  
Наткнулся на один момент, так как у меня в terraform для окружения prod используется backend gce,  
travis не мог получить к нему доступ и вывалился с ошибкой, пришлось за комментировать строки в нем.  
После этого билд прошел корректно.

Код бейджа для репозитория:

```

[![Build Status](https://travis-ci.org/Otus-DevOps-2017-11/mrgreyves_infra.svg?branch=ansible-3)](https://travis-ci.org/Otus-DevOps-2017-11/mrgreyves_infra)

```