# DMP
Модуль ядра ОС linux, который создает виртуальные блочные устройства поверх существующего на базе device mapper и следит за статистикой выполняемых операций на устройстве. Статистика доступна через sysfs модуля.

Поддерживаемые статистические данные:
- Количество запросов на запись
- Количество запросов на чтение
- Средний размер блока на запись
- Средний размер блока на чтение
- Общее кол-во запросов
- Средний размер блока

## Использование

- Сборка:
```shell
git clone https://github.com/Sarapulov-Vas/DMP.git
cd DMP
make
```

- Установка:

```shell
sudo insmod dmo.ko
```

- Создание тестого блочного устройсва:
```shell
sudo dmsetup create zero1 --table "0 $size zero"
```

- Создание DMP устройства:
```shell
sudo dmsetup create dmpl --table "0 $size dmp /dev/mapper/zero1"
```

- Вывод статистики:
```shell
cat /sys/module/dmp/stat/volumes
```
## Разработка

Модуль тестируется в виртуальной машине QEMU.
Настройка окружения:

```shell
./scripts/setup_env.sh
```
Запуск QEMU:
```shell
./scripts/run_qemu.sh
```

## Статус

На данный момент только реализован данный пример: https://gauravmmh1.medium.com/writing-your-own-device-mapper-target-539689d19a89

Для запуска в виртуальной машине используйте скрипт:

```shell
./scripts/run_example.sh
```
