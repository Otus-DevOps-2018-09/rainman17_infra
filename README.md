# rainman17_infra
rainman17 Infra repository

[HW-3]
Исследовать способ подключения к someinternalhost в одну
команду из вашего рабочего устройства, проверить
работоспособность найденного решения и внести его в
README.md в вашем репозитории



Дополнительное задание:
>Предложить вариант решения для подключения из консоли при
>помощи команды вида ssh someinternalhost из локальной
>консоли рабочего устройства, чтобы подключение
>выполнялось по алиасу someinternalhost и внести его в
>README.md в вашем репозитории
отредактировать ~/.ssh/config
Host bastion            # имя бастиона
Hostname 35.228.69.68   # внешний ip бастиона
User root               # пользователь под которым подключаться
Host instance-1         # нужная машина
ProxyCommand ssh -q bastion nc -q0 10.166.0.3 22 # здесь меняем только ip адрес машины
