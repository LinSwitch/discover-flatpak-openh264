# Обход блокировки OpenH264 для Flatpak через Tor + Docker

---

## 🌍 English Version

➡️ **Read this guide in English:**  
**[Bypassing the OpenH264 Block for Flatpak Using Tor + Docker](./README.en.md)**

---

В некоторых регионах сервер Cisco, с которого Flatpak скачивает OpenH264, **заблокирован**.
Из-за этого при попытке установить любое Flatpak-приложение через Discover появляется ошибка:

```
403 Forbidden
```
Это не проблема Linux или KDE — это результат **сетевой блокировки**.
В этом репозитории находится минимальный комплект файлов, повторяющий команды из видео, для обхода ограничений с помощью локального Tor-прокси в Docker.

---

## 📦 Что здесь находится

* **Dockerfile** — минимальный образ Tor на Alpine
* **torrc** — конфигурация Tor с поддержкой мостов

---

## 🛠 Требования

* Docker
* Linux (Arch, KDE, Steam Deck Desktop Mode или любой другой дистрибутив с Flatpak + Discover)
* Python 3 (для локального веб-сервера)

---

# 🚀 Установка и запуск

## 1. Устанавливаем Docker

Arch / SteamOS / Manjaro:

```bash
sudo pacman -S docker
sudo systemctl enable --now docker
```

## 2. Добавляем пользователя в группу docker

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 3. Клонируем репозиторий

```bash
git clone https://github.com/LinSwitch/discover-flatpak-openh264
cd discover-flatpak-openh264
```

*(Если видео вы смотрели — это те же два файла, которые мы скачивали вручную.)*

---

## 4. Получаем свежие Tor-мосты

Мосты быстро устаревают — берите новые здесь:

📡 **Telegram-бот:** `@GetBridgesBot`

Вставьте полученные строки в `torrc`:

```
UseBridges 1
ClientTransportPlugin obfs4 exec /usr/bin/lyrebird
Bridge obfs4 ...  # ваша строка
```

---

## 5. Собираем Tor-образ

```bash
docker build -t tor-proxy .
```

---

## 6. Запускаем Tor-прокси на порту 9050

```bash
docker run -d --name tor-proxy -p 127.0.0.1:9050:9050 tor-proxy
```

Проверка:

```bash
curl --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip
```

Должно показать {"IsTor":true,"IP":"адрес"}.

---

# 🔑 Подготовка OpenH264

## 7. Скачиваем контрольную сумму Cisco (через Tor). 
Актуальная версия OpenH264 — **2.5.1**.  
Если в будущем Flatpak начнёт запрашивать другую версию — **замените её в URL** на актуальную.

Список всех версий:  
https://github.com/cisco/openh264/releases

```bash
curl -x socks5h://127.0.0.1:9050 -O http://ciscobinary.openh264.org/libopenh264-2.5.1-linux64.7.so.signed.md5.txt
```

Проверяем, что файл не заглушка:

```bash
cat libopenh264-2.5.1-linux64.7.so.signed.md5.txt
```

Если там MD5-хэш, а не HTML-страница — всё ок.

---

## 8. Скачиваем сам архив

```bash
curl -x socks5h://127.0.0.1:9050 -O http://ciscobinary.openh264.org/libopenh264-2.5.1-linux64.7.so.bz2
```

---

## 9. Запускаем локальный HTTP-сервер

Flatpak качает OpenH264 **только по HTTP**, поэтому поднимаем локальный сервер:

```bash
sudo python3 -m http.server 80 -b 127.0.0.1
```

---

## 10. Подмена домена через /etc/hosts

Открываем файл:

```bash
sudo nano /etc/hosts
```

Добавляем строку:

```
127.0.0.1  ciscobinary.openh264.org
```

Теперь Flatpak будет думать, что скачивает файл с оригинального сервера.

---

## 🎉 11. Ставим любое Flatpak-приложение

Теперь можно устанавливать всё, что угодно:

```bash
flatpak install org.videolan.VLC
```

Discover тоже перестанет выдавать ошибку 403.

## 12. После установки:
   - остановите сервер (`Ctrl+C`),
   - уберите строку из `/etc/hosts`.

## 🔄 Обновление мостов (без пересборки)
```bash
docker cp tor-proxy:/etc/tor/torrc torrc
# отредактируйте torrc
docker cp torrc tor-proxy:/etc/tor/torrc
docker restart tor-proxy
```

## 📺 Видео-инструкция
[Ошибка 403 в Discover? Как обойти блокировку OpenH264 через Tor в Docker](https://youtu.be/wB9s7lQ5Uz8)

