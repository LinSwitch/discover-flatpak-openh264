# Bypassing the OpenH264 Block for Flatpak via Tor + Docker

In some regions, the Cisco server that Flatpak uses to download OpenH264 is **blocked**.
Because of this, when installing any Flatpak application through Discover, you may see an error:

```
403 Forbidden
```

This is not a Linux or KDE problem — it's a **network-level block**.
This repository contains a minimal set of files reproducing the steps from the video, allowing you to bypass the restriction using a local Tor proxy inside Docker.

---

## 📦 What’s Included

* **Dockerfile** — minimal Tor image based on Alpine
* **torrc** — Tor configuration with bridge support

---

## 🛠 Requirements

* Docker
* Linux (Arch, KDE, Steam Deck Desktop Mode, or any distro with Flatpak + Discover)
* Python 3 (for the local web server)

---

# 🚀 Setup and Usage

## 1. Install Docker

Arch / SteamOS / Manjaro:

```bash
sudo pacman -S docker
sudo systemctl enable --now docker
```

## 2. Add your user to the docker group

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 3. Clone the repository

```bash
git clone https://github.com/LinSwitc/discover-flatpak-openh264
cd discover-flatpak-openh264
```

*(If you watched the video — these are the same two files we downloaded manually.)*

---

## 4. Get fresh Tor bridges

Bridges become outdated quickly — fetch new ones here:

📡 **Telegram bot:** `@GetBridgesBot`

Insert the received lines into `torrc`:

```
UseBridges 1
ClientTransportPlugin obfs4 exec /usr/bin/lyrebird
Bridge obfs4 ...  # your bridge line
```

---

## 5. Build the Tor image

```bash
docker build -t tor-proxy .
```

---

## 6. Start the Tor proxy on port 9050

```bash
docker run -d --name tor-proxy -p 127.0.0.1:9050:9050 tor-proxy
```

Test it:

```bash
curl --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip
```

You should see: `{"IsTor":true,"IP":"your_ip"}`.

---

# 🔑 Fetching OpenH264

## 7. Download the Cisco checksum (via Tor).
The current OpenH264 version is **2.5.1**.
If Flatpak starts requesting a different version in the future — replace it in the URL with the correct one.

List of all releases:
https://github.com/cisco/openh264/releases

```bash
curl -x socks5h://127.0.0.1:9050 -O http://ciscobinary.openh264.org/libopenh264-2.5.1-linux64.7.so.signed.md5.txt
```

Check that the file is not an HTML placeholder:

```bash
cat libopenh264-2.5.1-linux64.7.so.signed.md5.txt
```

If it contains an MD5 hash — you're good.

---

## 8. Download the actual binary

```bash
curl -x socks5h://127.0.0.1:9050 -O http://ciscobinary.openh264.org/libopenh264-2.5.1-linux64.7.so.bz2
```

---

## 9. Start a local HTTP server

Flatpak downloads OpenH264 **only via HTTP**, so we start a local server:

```bash
sudo python3 -m http.server 80 -b 127.0.0.1
```

---

## 10. Add a hosts override

Open:

```bash
sudo nano /etc/hosts
```

Add:

```
127.0.0.1  ciscobinary.openh264.org
```

Now Flatpak will think it’s downloading from the original Cisco server.

---

## 🎉 11. Install any Flatpak application

You can now install anything:

```bash
flatpak install org.videolan.VLC
```

Discover will stop showing the 403 error.

---

## 12. After installation:

* stop the server (`Ctrl+C`)
* remove the line from `/etc/hosts`

---

## 🔄 Updating bridges (without rebuilding)

```bash
docker cp tor-proxy:/etc/tor/torrc torrc
# edit torrc
docker cp torrc tor-proxy:/etc/tor/torrc
docker restart tor-proxy
```

---

## 📺 Video Guide

**[Error 403 in Discover? How to bypass the OpenH264 block with Tor in Docker](https://youtu.be/wB9s7lQ5Uz8)**
