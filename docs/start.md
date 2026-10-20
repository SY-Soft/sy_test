## Быстрый старт + ремонт

После запуска проверьте сайты:

- Laravel: http://laravel.localhost
- Drupal: http://drupal.localhost
- phpMyAdmin: http://localhost:8080

### Если сайт не открывается

Посмотрите состояние контейнеров:

```powershell
docker compose ps
```

Посмотрите последние сообщения PHP, Nginx и MySQL:

```powershell
docker compose logs --tail=100 php nginx mysql
```

Если контейнеры работают, но после изменения конфигурации сайт не открывается, перезапустите PHP и Nginx:

```powershell
docker compose restart php nginx
```

Если менялся `Dockerfile` или конфигурация сборки PHP, пересоберите образ и запустите контейнеры:

```powershell
docker compose up -d --build
```

### Если отсутствуют зависимости Composer

Выполните команды установки для нужного проекта:

```powershell
docker compose exec -w /var/www/projects/laravel php composer install
docker compose exec -w /var/www/projects/drupal php composer install
```

Если проблема только в одном проекте, достаточно выполнить команду для него.

### Если не запускается MySQL

Сначала проверьте состояние контейнера и журнал:

```powershell
docker compose ps mysql
docker compose logs --tail=200 mysql
```

**Не запускайте `.\start.ps1` автоматически при любой ошибке MySQL.** Скрипт предназначен для инициализации пустого или неполного каталога данных и в таком случае удаляет его содержимое перед созданием новой базы. Это может уничтожить существующие данные.

Перед переинициализацией убедитесь, что данные не нужны либо у вас есть их резервная копия.

