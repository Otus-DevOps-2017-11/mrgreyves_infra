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
public_key_path = "Path to public key"
disk_image = "reddit-base"
private_key_path = "Path to private key"
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
