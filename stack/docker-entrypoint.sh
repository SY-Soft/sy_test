#!/bin/bash
set -e

BASE=/var/cache/laravel

mkdir -p "$BASE"

for project in /var/www/projects/*; do
    [ -d "$project" ] || continue
    [ -f "$project/artisan" ] || continue

    name=$(basename "$project")
    root="$BASE/$name"

    echo "Preparing Laravel project: $name"

    mkdir -p \
        "$root/storage/app/private" \
        "$root/storage/app/public" \
        "$root/storage/framework/cache/data" \
        "$root/storage/framework/sessions" \
        "$root/storage/framework/testing" \
        "$root/storage/framework/views" \
        "$root/storage/logs" \
        "$root/bootstrap-cache"

    # Preserve existing storage data when switching to the runtime volume.
    if [ -L "$project/storage" ]; then
        rm "$project/storage"
    elif [ -d "$project/storage" ]; then
        cp -a "$project/storage/." "$root/storage/"
        rm -rf "$project/storage"
    fi

    ln -s "$root/storage" "$project/storage"

    mkdir -p "$project/bootstrap"

    if [ -L "$project/bootstrap/cache" ]; then
        rm "$project/bootstrap/cache"
    elif [ -d "$project/bootstrap/cache" ]; then
        cp -a "$project/bootstrap/cache/." "$root/bootstrap-cache/"
        rm -rf "$project/bootstrap/cache"
    fi

    ln -s "$root/bootstrap-cache" "$project/bootstrap/cache"

    chown -R www-data:www-data "$root"

    echo "Laravel paths ready: $name"
done

exec php-fpm
