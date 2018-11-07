# rainman17_infra
rainman17 Infra repository

[HW-3]
bastion_IP = 35.228.69.68 someinternalhost_IP = 10.166.0.3
>Исследовать способ подключения к someinternalhost в одну
>команду из вашего рабочего устройства, проверить
>работоспособность найденного решения и внести его в
>README.md в вашем репозитории

```
ssh -i ~/.ssh/root -A -t root@<внешний IP бастиона> ssh <someinternalhost>
```

Дополнительное задание:
>Предложить вариант решения для подключения из консоли при
>помощи команды вида ssh someinternalhost из локальной
>консоли рабочего устройства, чтобы подключение
>выполнялось по алиасу someinternalhost и внести его в
>README.md в вашем репозитории


отредактировать ~/.ssh/config
```
Host bastion            # имя бастиона
Hostname 35.228.69.68   # внешний ip бастиона
User root               # пользователь под которым подключаться
Host someinternalhost   # нужная машина
ProxyCommand ssh -q bastion nc -q0 10.166.0.3 22 # здесь меняем только ip адрес машины
```
Подключение командой
```
ssh someinternalhost
```

