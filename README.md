# NanoHost 🚀

> **Egyszerű, moduláris, Docker-alapú helyi webszerver környezet**  
> Több weboldal (WordPress/PHP) kiszolgálása egyetlen gépen, minimális konfigurációval

[![Docker](https://img.shields.io/badge/Docker-20.10+-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![PHP](https://img.shields.io/badge/PHP-8.4+-777BB4?logo=php&logoColor=white)](https://www.php.net/)
[![MariaDB](https://img.shields.io/badge/MariaDB-11.0+-003545?logo=mariadb&logoColor=white)](https://mariadb.org/)
[![Apache](https://img.shields.io/badge/Apache-2.4+-D22128?logo=apache&logoColor=white)](https://httpd.apache.org/)

---

## ✨ Főbb jellemzők

| Feature | Leírás |
|---------|--------|
| 🎯 **Maximális automatizmus** | Csak a domain listát kell megadnod az `.env` fájlban |
| ⚡ **Dinamikus VirtualHostok** | Nincs több kézi Apache konfigurálás |
| 🔒 **Automatikus SSL** | Önaláírt tanúsítványok generálása minden domainhez |
| 🏗️ **Izolált környezet** | Külön adatbázis és webroot minden projekthez |
| 🐘 **Modern PHP** | PHP 8.4+ alapértelmezetten |
| 🔄 **Auto-Provisioning** | Automatikus projekt létrehozás az `src/` mappában |

---

## 📋 Tech Stack

| Komponens | Verzió | Szerepkör |
|-----------|--------|-----------|
| 🐘 **PHP** | 8.4+ | Backend nyelv |
| 🗄️ **MariaDB** | 10.0+ | Adatbázis szerver |
| 🌐 **Apache** | 2.4+ | Web szerver |
| 🐳 **Docker** | 20.10+ | Konténerizáció |
| 🔧 **Docker Compose** | 2.0+ | Orchestration |

---

## 🚀 Gyors kezdés

### 📦 1. Repository klónozása

```bash
git clone https://github.com/SolutionMasterIT/NanoHost.git
cd nanohost
```

### ⚙️ 2. Konfiguráció létrehozása

```bash
cp .env.example .env
nano .env  # vagy vim, code, stb.
```

### 🏗️ 3. Környezet indítása

```bash
docker compose up -d --build
```

### 🎉 4. Készen vagy!

Nyisd meg böngészőben: `https://weboldal1.local`

---

## ⚠️ Fontos figyelmeztetések

### 🪟 Windows felhasználóknak - CRLF probléma!

> **KRITIKUS:** Ha Windows alatt szerkeszted a fájlokat, a **line-ending (sorvég) problémát okozhat**!

A bash scriptek Unix-stílusú sorvégeket (`LF`) várnak, de Windows alapértelmezetten `CRLF`-et használ.

#### ✅ Megoldás #1: Git beállítás (ajánlott)

```bash
# Globális beállítás (minden repo-ra)
git config --global core.autocrlf input

# Csak erre a repo-ra
git config core.autocrlf input

# Újra checkout a fájlokhoz
git checkout -- .
```

#### ✅ Megoldás #2: Manuális konverzió

```bash
# Egyetlen fájl
sed -i 's/\r$//' build.sh

# Összes shell script
find . -name "*.sh" -type f -exec sed -i 's/\r$//' {} \;
```

#### ✅ Megoldás #3: dos2unix használata

```bash
# Ubuntu/Debian
sudo apt-get install dos2unix

# Használat
dos2unix *.sh scripts/*.sh
```

#### 🔍 Hogyan ellenőrzöd?

```bash
# Ha "^M" karaktereket látsz a sorvégeken, CRLF-ed van
cat -A build.sh

# Megfelelő kimenet (csak $):
#!/bin/bash$
echo "Hello"$

# Rossz kimenet (^M$ látható):
#!/bin/bash^M$
echo "Hello"^M$
```

---

## 🛠️ Előfeltételek & Telepítés

### 📋 Minimális követelmények

- **Docker**: 20.10 vagy újabb
- **Docker Compose**: 2.0 vagy újabb  
- **Legalább 2GB RAM** a konténereknek
- **Legalább 5GB szabad hely** a storage-hez

### 1️⃣ Futtatási jogok megadása

```bash
# Scriptek futtathatóvá tétele
chmod +x *.sh
chmod +x scripts/*.sh
```

### 2️⃣ Build folyamat testreszabása (Opcionális)

#### Színes BuildKit kikapcsolása (SSH-nál hasznos)

```bash
# Egyszeri használat
BUILDKIT_PROGRESS=plain docker compose up -d --build

# Végleges beállítás
export BUILDKIT_PROGRESS=plain
echo 'export BUILDKIT_PROGRESS=plain' >> ~/.bashrc
```

#### Terminál javítása SSH-n keresztül

```bash
export TERM=xterm-256color
```

---

## ⚙️ Konfiguráció (.env)

A rendszer **egyetlen belépési pontja** az `.env` fájl.

### 📝 Példa konfiguráció

```env
# Domain lista (vesszővel elválasztva, space nélkül)
DOMAINS=weboldal1.local,weboldal2.test,projekt3.dev

# Adatbázis root jelszó
MYSQL_ROOT_PASSWORD=root

```

### 🔐 Biztonsági tippek

- ❌ **NE commitolj** éles jelszavakat a repo-ba!
- ✅ Használj `.env.example`-t sablonként
- ✅ Add hozzá az `.env`-t a `.gitignore`-hoz
- ✅ Használj erős jelszavakat production-ben

---

## 🚀 Használati útmutató

### ▶️ Környezet indítása

```bash
docker compose up -d --build
```

### 🔍 Státusz ellenőrzése

```bash
# Konténerek listázása
docker compose ps

# Logok megtekintése
docker compose logs -f

# Csak "dev-webserver" szerver logok
docker compose logs -f dev-webserver
```

### ➕ Új domain hozzáadása

**1. Szerkeszd az `.env` fájlt:**

```bash
nano .env
```

**2. Add hozzá az új domaint:**

```env
DOMAINS=weboldal1.local,weboldal2.test,projekt3.dev,uj-projekt.local
```

**3. Indítsd újra:**

```bash
docker compose up -d --build
```

**4. Automatikus létrehozás:**
- ✅ SSL tanúsítvány: `/ssl/uj-projekt.local.crt`
- ✅ Web könyvtár: `/src/uj-projekt.local/`
- ✅ Adatbázis: `uj_projekt_local`

### 🗑️ Domain eltávolítása

**1. Töröld az `.env`-ből:**

```bash
nano .env
```

**2. Opcionálisan töröld a fájlokat:**

```bash
# Web fájlok
rm -rf src/regi-domain.local

# SSL tanúsítvány
rm ssl/regi-domain.local.*

# Adatbázis (a konténerben)
docker compose exec dev-database mysql -u root -p
# DROP DATABASE regi_domain_local;
```

### 🛑 Környezet leállítása

```bash
# Leállítás (adat megőrzése)
docker compose down

# Teljes törlés (adatokkal együtt!)
docker compose down -v
```

### 🔄 Újraindítás

```bash
# Gyors újraindítás
docker compose restart

# Teljes rebuild
docker compose up -d --build --force-recreate
```

---

## 📂 Könyvtárszerkezet(példa)

```
nanohost/
├── 📁 config/              # PHP konfigurációk
│   └── php.ini
├── 📁 db/                  # Perzisztens MariaDB adatok
├── 📁 scripts/             # Automatizációs scriptek
│   ├── entrypoint.sh
│   ├── generate-ssl.sh
│   ├── generate-vhosts.sh
│   └── setup-databases.sh
├── 📁 src/                 # Weboldalak forráskódja
│   ├── weboldal1.local/
│   ├── weboldal2.test/
│   └── projekt3.dev/
├── 📁 ssl/                 # Generált SSL tanúsítványok
├── 📄 docker-compose.yml   # Docker orchestration
├── 📄 Dockerfile           # PHP+Apache image
├── 📄 .env                 # Konfiguráció (ne commitold!)
├── 📄 .env.example         # Konfiguráció sablon
└── 📄 README.md            # Ez a fájl
```

---

## 🐳 Docker parancsok gyűjteménye

### Konténer műveletek

```bash
# Belépés a web konténerbe
docker compose exec web bash

# Belépés a DB konténerbe
docker compose exec db bash

# MySQL shell elérése
docker compose exec db mysql -u root -p

# PHP verzió ellenőrzése
docker compose exec web php -v

# Apache konfiguráció tesztelése
docker compose exec web apache2ctl configtest
```

### Logok és hibakeresés

```bash
# Összes log realtime
docker compose logs -f

# Utolsó 50 sor
docker compose logs --tail=50

# Csak hibák
docker compose logs | grep -i error

# Egy adott szolgáltatás logjai
docker compose logs -f web
```

### Takarítás és karbantartás

```bash
# Leállított konténerek törlése
docker container prune

# Nem használt image-ek törlése
docker image prune -a

# Teljes rendszer takarítás (vigyázz!)
docker system prune -a --volumes

# Konténer resource használat
docker stats
```

---

## 🔧 Gyakori problémák és megoldások

### ❌ "Permission denied" hiba

**Probléma:** `bash: ./build.sh: Permission denied`

**Megoldás:**
```bash
chmod +x *.sh scripts/*.sh
```

---

### ❌ Port már használatban

**Probléma:** `Error: bind: address already in use`

**Megoldás:**
```bash
# Ellenőrizd, mi futtat a portokon
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Állítsd le a konkurens szolgáltatást
sudo systemctl stop apache2
sudo systemctl stop nginx
```

---

### ❌ CRLF hibák bash scriptekben

**Probléma:** `/bin/bash^M: bad interpreter`

**Megoldás:** Lásd a [Windows figyelmeztetés](#-windows-felhasználóknak---crlf-probléma) szekciót!

---

### ❌ Nem elérhető a domain

**Probléma:** A böngésző nem találja `weboldal1.local`-t

**Megoldás - `/etc/hosts` fájl szerkesztése:**

```bash
sudo nano /etc/hosts
```

Adj hozzá:
```
127.0.0.1  weboldal1.local
127.0.0.1  weboldal2.test
127.0.0.1  projekt3.dev
```

**Windows-on:** `C:\Windows\System32\drivers\etc\hosts`

---

### ❌ SSL figyelmeztetés böngészőben

**Probléma:** "Your connection is not private"

**Megoldás:** Ez **normális** önaláírt tanúsítványoknál!

- **Chrome/Edge:** Kattints "Advanced" → "Proceed to site"
- **Firefox:** "Advanced" → "Accept the Risk"

**Vagy** importáld a tanúsítványt a rendszerbe (haladó).

---

## 📚 További erőforrások

### Dokumentációk

- 📖 [Docker Documentation](https://docs.docker.com/)
- 📖 [PHP Manual](https://www.php.net/manual/)
- 📖 [Apache HTTP Server](https://httpd.apache.org/docs/)
- 📖 [MariaDB Knowledge Base](https://mariadb.com/kb/)

### Hasznos parancsok referencia

```bash
# Docker verzió
docker --version
docker compose version

# Rendszer információk
docker info

# Konténerek részletes listája
docker compose ps -a

# Image-ek listája
docker images

# Volume-ok listája
docker volume ls
```

---

## 🤝 Közreműködés

A pull request-eket szívesen fogadok! Nagyobb változtatásoknál előbb nyiss issue-t.

### Fejlesztési folyamat

1. Fork-old a repo-t
2. Hozz létre feature branch-et (`git checkout -b feature/AmazingFeature`)
3. Commit-old a változtatásokat (`git commit -m 'Add some AmazingFeature'`)
4. Push-old a branch-et (`git push origin feature/AmazingFeature`)
5. Nyiss egy Pull Request-et

---

## 📜 Licensz

GPL-3.0 License - lásd a `LICENSE` fájlt a részletekért.

---

## 👨‍💻 Készítő

**NanoHost Project**

- 🌐 Website: [solutionmaster.hu](https://solutionmaster.hu)
- 📧 Email: janos.fejleszto@gmail.com
- 🐙 GitHub: [@SolutionMasterIT](https://github.com/SolutionMasterIT)

---

## ⭐ Hasznos volt?

Ha tetszik a projekt, adj egy csillagot! ⭐

```bash
# Clone & Star
git clone https://github.com/SolutionMasterIT/NanoHost.git
# Don't forget to star the repo! 🌟
```

---

## 🗺️ Roadmap

- [ ] Multi-PHP verzió támogatás
- [ ] Nginx alternatíva
- [ ] PostgreSQL támogatás
- [ ] Automatikus Let's Encrypt SSL
- [ ] GUI admin panel
- [ ] CI/CD integráció
- [ ] Kubernetes deployment

---

<div align="center">

**Készítve ❤️-vel Docker és PHP segítségével**

[⬆ Vissza a tetejére](#nanohost-)

</div>
