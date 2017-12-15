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
