## Установка Laravel

Далее предполагается, что репозиторий sy_lamp находится в D:\sy_lamp, а новый проект будет называться laravel_my. Если у Вас другой путь или имя проекта, замените их в командах на свои.

Запустите контейнеры и соберите PHP-образ (если еще не запускали):

```powershell
cd D:\sy_lamp\stack
docker compose up -d --build
```
**Примечание:** при первом запуске команда может выполняться несколько минут: Docker скачивает необходимые образы и собирает PHP-образ. Дождитесь завершения команды, прежде чем переходить к следующему шагу.

**1. Создать проект без автоматического выполнения Composer-скриптов:**

```powershell
cd ..\projects\bin
.\composer create-project laravel/laravel ../laravel_my --no-scripts
# Копируем BAT-обёртки для работы с проектом через Docker
Copy-Item .\composer.bat, .\artisan.bat ..\laravel_my\
```


**2. Создать `.env`:**

```powershell
cd ../laravel_my
cp .env.example .env
```

**3. Создать базу данных** 

В [phpMyAdmin](http://localhost:8080) (http://localhost:8080 Логин: `root`, пароль: `root`) создать базу данных `laravel_my` с кодировкой `utf8mb4` и сопоставлением `utf8mb4_general_ci`.


**4. Настроить `.env`:**

```dotenv
APP_URL=http://laravel_my.localhost

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel_my
DB_USERNAME=root
DB_PASSWORD=root

SESSION_DRIVER=file
```

**5. Перезапустить PHP-контейнер**, чтобы entrypoint подготовил каталоги нового Laravel-проекта:

```powershell
docker compose -f ..\..\stack\docker-compose.yml restart php
```

**6. Сгенерировать ключ и выполнить миграции:**

```powershell
.\artisan key:generate
.\artisan config:clear
.\artisan migrate
```

**[Laravel](http://laravel_my.localhost)** установлен!

**7. Если нужен bash:**

```powershell
docker compose -f ..\..\stack\docker-compose.yml exec php bash
cd /var/www/projects/laravel_my
```

## Хранение сессий Laravel

Параметр `SESSION_DRIVER` в `.env` определяет, где Laravel хранит пользовательские сессии.

- `file` — файлы в `storage/framework/sessions`.
- `database` — записи в таблице `sessions` базы данных.
- `redis` — хранение в Redis при соответствующей настройке Laravel.

**Для первоначальной установки используется `file`.** Так сессии не зависят от наличия таблицы `sessions` и не мешают первому запуску миграций.

Когда проект настроен и база данных готова, при необходимости можно переключиться на MySQL.

В `.env`:

```dotenv
SESSION_DRIVER=database
```

Затем проверьте каталог `database/migrations`: если миграция таблицы `sessions` уже есть, повторно создавать её не нужно. Если миграции нет, выполните:

```powershell
.\artisan make:session-table
.\artisan migrate
.\artisan config:clear
```

После смены драйвера Laravel начнёт использовать таблицу `sessions`. Для обычного учебного проекта можно оставить `file`; переход на `database` нужен, если вы хотите хранить сессии в БД.

## Примечания

- Каталоги `storage` и `bootstrap/cache` Laravel выносятся в Docker volume `laravel_cache`.
