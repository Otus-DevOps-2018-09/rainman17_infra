bastion_IP = 35.228.69.68
someinternalhost_IP = 10.166.0.3

testapp_IP = 35.228.161.64 
testapp_port = 9292 


# rainman17_infra
rainman17 Infra repository

[terraform-1]
>Добавьте в веб интерфейсе ssh ключ пользователю appuser_web в метаданные проекта. Выполните
>terraform apply и проверьте результат;
если ресурс добавить через web-интерфейс GCP, то при apply терраформ удалит ресурс и приветет в соответствие описанное в конфигах 

>Добавьте в код еще один terraform ресурс для нового инстанса приложения, например reddit-app2,
>добавьте его в балансировщик и проверьте, что при остановке на одном из инстансов приложения
>(например systemctl stop puma), приложение продолжает быть доступным по адресу балансировщика;
>Добавьте в output переменные адрес второго инстанса; Какие проблемы вы видите в такой
>конфигурации приложения? Добавьте описание в README.md.
- код дублируется. неудобно читать.
- неудобно масштабировать. каждый раз копировать код затратно.
- неудобно поддерживать. нужно больше ресурсов

Установка Terraform:
```
$ wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip 
$ unzip terraform_0.11.10_linux_amd64.zip
$ mv terraform /usr/local/bin/ 
$ terraform -v 
```
Определим провайдера в файл main.tf и скачаем бинарные файлы выбранного провайдера: 
```
$ terraform init
```
Тестирование плана
```
$ terraform plan
```
Применение плана
```
$ terraform apply
```
Просмотр terraform.tfstate
```
$ terraform show | grep assigned_nat_ip
$ terraform refresh
```
Output переменные. Описываем в outputs.tf
```
output "app_external_ip" {
  value = "${google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip}"
}

## Просмотр output переменных
$ terraform output
$ terraform output app_external_ip 
```

Пересоздать ресурс при следующем изменении
```
$ terraform taint google_compute_instance.app
```
Input переменные. Определяем в файле variables.tf, тамже задаем значения по умолчанию
```
## Пример использования input переменных
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}
...
  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
```

Удалить все ресурсы
```
$ terraform destroy
```
###Сделано:
Обычное задание:
1. Определите input переменную для приватного ключа,
использующегося в определении подключения для
провижинеров (connection);
done
2. Определите input переменную для задания зоны в ресурсе
"google_compute_instance" "app". У нее должно быть
значение по умолчанию;
done
3. Отформатируйте все конфигурационные файлы используя
команду terraform fmt;
done
4. Так как в репозиторий не попадет ваш terraform.tfvars, то
нужно сделать рядом файл terraform.tfvars.example, в котором
будут указаны переменные для образца. Пример в gist.
done


Задание со *:
•Опишите в коде терраформа добавление ssh ключа пользователя appuser1 в метаданные проекта.
Выполните terraform apply и проверьте результат (публичный ключ можно брать пользователя appuser);
done

• Опишите в коде терраформа добавление ssh ключей нескольких пользователей в метаданные
проекта (можно просто один и тот же публичный ключ, но с разными именами пользователей, например
appuser1, appuser2 и т.д.). Выполните terraform apply и проверьте результат;
done

• Добавьте в веб интерфейсе ssh ключ пользователю appuser_web в метаданные проекта. Выполните
terraform apply и проверьте результат;
done

• Какие проблемы вы обнаружили? Добавьте описание в README.md ***(добавлено выше)***
done

• Не забудьте закоммитить добавленный код в репозиторий и добавить описание в README.md;
done


Задание с * *:
• Создайте файл lb.tf и опишите в нем в коде terraform создание HTTP балансировщика, направляющего
трафик на наше развернутое приложение на инстансе reddit-app. Проверьте доступность приложения
по адресу балансировщика. Добавьте в output переменные адрес балансировщика.
done

• Добавьте в код еще один terraform ресурс для нового инстанса приложения, например reddit-app2,
добавьте его в балансировщик и проверьте, что при остановке на одном из инстансов приложения
(например systemctl stop puma), приложение продолжает быть доступным по адресу балансировщика;
Добавьте в output переменные адрес второго инстанса; Какие проблемы вы видите в такой
конфигурации приложения? Добавьте описание в README.md.
done ***(добавлено выше)***

• Как мы видим, подход с созданием доп. инстанса копированием кода выглядит нерационально, т.к.
копируется много кода. Удалите описание reddit-app2 и попробуйте подход с заданием количества
инстансов через параметр ресурса count. Переменная count должна задаваться в параметрах и по
умолчанию равна 1.
done

• Не забудьте закоммитить добавленный код в репозиторий и добавить описание в README.md;
done


[packer-base]

Установка Packer:
```
$ wget https://releases.hashicorp.com/packer/1.3.1/packer_1.3.1_linux_amd64.zip 
$ unzip packer_1.3.1_linux_amd64.zip
$ sudo mv packer /usr/local/bin/
$ packer -v 
```
Создание Application Default Credentials: 
```
$ gcloud auth application-default login

```

Создаем шаблон для packer: ubuntu16.json
```
{
    "builders": [
        {
            "type": "googlecompute",
            "project_id": "infra-219820",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "source_image_family": "ubuntu-1604-lts",
            "zone": "europe-west1-b",
            "ssh_username": "eav",
            "machine_type": "f1-micro"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}

```

Проверка валидности шаблона packer:
```
$ packer validate ubuntu16.json 
```

Сборка образа
```
$ packer build ubuntu16.json
```

Создаем виртуалку из образа и запускаем приложение
```
$ git clone -b monolith https://github.com/express42/reddit.git
$ cd reddit && bundle install  
$ puma -d 

```

Запуск сборки с файлом переменных
```
$ packer build -var-file=variables.json ubuntu16.json

```

Запуск виртуальной машины из консоли
```
gcloud compute instances create reddit-app\
  --boot-disk-size=12GB \
  --image-family=reddit-full \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure

```



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
    


