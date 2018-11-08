bastion_IP = 35.228.69.68
someinternalhost_IP = 10.166.0.3

testapp_IP = 35.228.161.64 
testapp_port = 9292 


# rainman17_infra
rainman17 Infra repository

[HW-3]

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


[cloud-testapp]

testapp_IP = 35.228.161.64
testapp_port = 9292

Создание инстанcа из консоли (стартап скритп из файла)
```sh
$ gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=startup-script.sh
```

Создание инстанта из консоли (стартап скритп из gs)
```sh
$ gcloud compute instances create reddit-app1\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata=startup-script-url='gs://rainman17/startup-script.sh'
```

Сздание правила **firewall** из консоли
```sh
gcloud compute firewall-rules create default-puma-server --allow tcp:9292 \
  --target-tags=puma-server --source-ranges="0.0.0.0/0" \
  --description="Allow incoming traffic on Puma server"
```
    


