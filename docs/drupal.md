## Установка Drupal

Далее предполагается, что репозиторий sy_lamp находится в D:\sy_lamp, а новый проект будет называться drupal_my. Если у Вас другой путь или имя проекта, замените их в командах на свои.

Запустите контейнеры и соберите PHP-образ (если еще не запускали):

```powershell
cd D:\sy_lamp\stack
docker compose up -d --build
```
**Примечание:** при первом запуске команда может выполняться несколько минут: Docker скачивает необходимые образы и собирает PHP-образ. Дождитесь завершения команды, прежде чем переходить к следующему шагу.


**1. Запускаем bash и создать проект:**

```powershell
docker compose -f docker-compose.yml exec php bash
cd /var/www/projects
composer create-project drupal/recommended-project drupal_my
# Копируем BAT-обёртку для работы с проектом через Docker
cp bin/composer.bat drupal_my
```

**2. Файловая система:**

Подготавливаем файловую систему и файл настроек для установки Drupal

_(если копи-паст - в баше можно всю пачку сразу)_

```bash
cd /var/www/projects/drupal_my
mkdir -p ./web/sites/default/files/translations
chown -R www-data:www-data ./web/sites/default/files
cp ./web/sites/default/default.settings.php ./web/sites/default/settings.php
chmod -R 777 ./web/sites/default/files
chmod 777 ./web/sites/default/settings.php
```

**3. Создать базу данных**

В [phpMyAdmin](http://localhost:8080) (http://localhost:8080 Логин: `root`, пароль: `root`) создать базу данных `drupal_my` с кодировкой `utf8mb4` и сопоставлением `utf8mb4_general_ci`.


**4. Установка**


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


**5. Снять права на запись**

Снять права на запись (после установки):
```bash
chmod 755 /var/www/projects/drupal_my/web/sites/default
chmod 644 /var/www/projects/drupal_my/web/sites/default/settings.php
```
**[Drupal](http://drupal_my.localhost)** установлен! 