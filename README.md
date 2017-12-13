## Otus DevOps Home Work 5 by Vladimir Drozdetskiy

### Стенд:
Хост Bastion: External 35.187.126.40 Internal 10.132.0.2  
Хост Someinternalhost: External None Internal 10.132.0.3

### Слайд 36 выполнение задания:

На своей "машине" редактируем и редактируем файл ~/.ssh/config  
Не забывал выставить права 600 на файл config  
Так же не забываем включить Forward agent  
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
ssh -t bastion ssh someinternalhost  #Вариант для студентов:)
```
```
ssh -L 2587:someinternalhost:22 bastion  
#Проброс локального порта на someinternalhost,
есть минус нужно подключаться через второй терминал:)
```
