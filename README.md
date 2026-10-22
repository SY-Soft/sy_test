# SY-LAMP

Docker-окружение для локальной разработки на Laravel и Drupal под Windows.

Проект создавался для личного использования: чтобы глубже разобраться с Docker и собрать удобное окружение, которое достаточно настроить один раз, а затем использовать для разных проектов.

## Состав

- **Docker Compose**
- **Nginx**
- **PHP 8.3-FPM**
- **Composer 2**
- **Xdebug**
- **MySQL 8.0**
- **phpMyAdmin**
- **Redis 7**

 <details>
<summary><strong>⚙️ Автодомены, базы данных и перенос окружения между компьютерами ⬇</strong></summary>

**Главное:** проекты подключаются по доменам `ИМЯ_ПРОЕКТА.localhost`, а базы MySQL хранятся на физическом диске, а не внутри контейнера.

### 🌐 Автоматические домены — Nginx

- `projects/laravel` → `http://laravel.localhost`
- `projects/drupal` → `http://drupal.localhost`

### 💾 Базы данных на физическом диске

Данные MySQL хранятся в каталоге `mysql` на хосте. Это позволяет переносить окружение между компьютерами вместе с базами данных.

### 🔄 Переносимость окружения

Проекты, конфигурация Docker и базы данных находятся в каталогах репозитория или рядом с ним.

</details>

В репозитории находятся готовые проекты Laravel и Drupal, а также подготовленные данные MySQL. После запуска окружения проекты доступны по локальным доменам.

Поддерживаются Laravel и Drupal 8/9/10/11.

## Запуск

Из каталога `stack` запустите контейнеры и соберите PHP-образ:

```powershell
docker compose up -d --build
```

При первом запуске после клонирования репозитория или после изменения зависимостей установите Composer-пакеты для проектов:

```powershell
docker compose exec -w /var/www/projects/laravel php composer install
docker compose exec -w /var/www/projects/drupal php composer install
```

Команды `composer install` достаточно выполнить один раз после клонирования репозитория. Повторный запуск нужен, если зависимости проекта изменились.

## Быстрый запуск и восстановление окружения

Из каталога `stack` выполните:

```powershell
.\start.ps1
```

Если каталог данных MySQL отсутствует или содержит неполный набор файлов инициализации, скрипт **очистит его содержимое и инициализирует MySQL заново**.

**Внимание:** при переинициализации существующие базы данных могут быть потеряны. Скрипт не восстанавливает ранее сохранённые данные.


Если возникли проблемы с запуском, смотрите [инструкцию по запуску и восстановлению](docs/start.md).

## Доступ к проектам

Проекты находятся в `projects/`. Имя каталога определяет локальный домен:

| Каталог | URL |
|---|---|
| `projects/laravel` | [http://laravel.localhost](http://laravel.localhost) |
| `projects/drupal` | [http://drupal.localhost](http://drupal.localhost) |

phpMyAdmin: [http://localhost:8080](http://localhost:8080)

Логин: `root`  
Пароль: `root`

## Шаблоны и готовые проекты

- `laravel` — чистый Laravel 13, [http://laravel.localhost](http://laravel.localhost). Локальные команды Composer и Artisan.
- `drupal` — чистый Drupal 11, [http://drupal.localhost](http://drupal.localhost). Локальный Composer. Логин: `admin`, пароль: `admin`.

## Composer и Artisan

Находясь в каталоге проекта:

```powershell
.\composer --version
.\composer install
.\composer require vendor/package

.\artisan about
.\artisan migrate
```

Команды выполняются через локальные BAT-файлы, которые запускают Composer и Artisan внутри PHP-контейнера. Это избавляет от необходимости каждый раз писать полную команду Docker Compose.

Например, для проекта `laravel_my` команда Artisan без пакетного файла (`.bat`) выглядит так:

```powershell
docker compose -f ..\..\stack\docker-compose.yml exec -w /var/www/projects/laravel_my php php artisan about
```

С пакетным файлом команда короче:

```powershell
.\artisan about
```



## [Установка Laravel](docs/laravel.md)

## [Установка Drupal](docs/drupal.md)

## Xdebug

Xdebug настроен для запуска отладки по триггеру:

```ini
xdebug.mode=debug
xdebug.start_with_request=trigger
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
```

В PhpStorm настройте сервер и сопоставление локального каталога проекта с `/var/www/projects/ИМЯ_ПРОЕКТА`. Для запуска отладки используйте триггер `XDEBUG_TRIGGER=1`.

## Примечания

- После добавления проекта перезапустите PHP-контейнер: entrypoint подготавливает каталоги при запуске.
- Данные MySQL хранятся отдельно от контейнера.
- Окружение предназначено для локальной разработки, не для production.