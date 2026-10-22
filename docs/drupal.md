## Установка Drupal

Далее предполагается, что репозиторий sy_lamp находится в D:\sy_lamp, а новый проект будет называться drupal_my. Если у Вас другой путь или имя проекта, замените их в командах на свои.

**1. Создать проект:**

```powershell
D:
cd /sy_lamp/projects/bin
./composer create-project drupal/recommended-project ../drupal_my
Copy-Item .\composer.bat  ..\drupal_my\
```


**2. Запускаем контейнеры и bash:**

```powershell
cd ..\..\stack
docker compose up -d --build
docker compose -f docker-compose.yml exec php bash
cd /var/www/projects/drupal_my
```

**3. Файловая система:**

Подготавливаем файловую систему и файл настроек для установки Drupal

```bash
mkdir -p ./web/sites/default/files/translations
chown -R www-data:www-data ./web/sites/default/files
cp ./web/sites/default/default.settings.php ./web/sites/default/settings.php
chmod -R 775 ./web/sites/default/files
chmod 775 ./web/sites/default/settings.php
```

**4. Создать базу данных**

В [phpMyAdmin](http://localhost:8080) (http://localhost:8080 Логин: `root`, пароль: `root`) создать базу данных `drupal_my` с кодировкой `utf8mb4` и сопоставлением `utf8mb4_general_ci`.


**5. Установка**


Переходим по адресу [http://drupal_my.localhost](http://drupal_my.localhost) и устанавливаем Drupal

На шаге "Конфигурация базы данных" заполните следующим образом:

Тип базы данных: MySQL, MariaDB или аналог

**Название базы данных:** drupal_my

**Имя пользователя базы данных:** root

**Пароль к базе данных:** root

"Дополнительные настройки"


**Хост:** mysql

**Номер порта:** 3306

**Уровень изоляции транзакций:**
Рекомендуемый уровень транзакций базы данных для Drupal - "READ COMMITTED".

**Префикс имени таблицы:**
Если эта база данных будет использоваться более чем одним приложением, уникальный префикс таблиц, например drupal_, поможет предотвратить конфликты.


**6. Снять права на запись**

Снять права на запись (после установки):
```bash
chmod 755 /var/www/projects/drupal_my/web/sites/default
chmod 644 /var/www/projects/drupal_my/web/sites/default/settings.php
```
**Drupal** установлен!