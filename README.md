# Vulner – Local Vulnerability Scanner & Privilege Escalation Tester 🔎🛠

**Vulner.sh** is a Bash-based automation script that performs local security auditing on Linux systems. Designed for use in CTFs, pentesting labs, and privilege escalation practice, it scans system components for misconfigurations and local vulnerabilities.

---

## 📚 Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Tested On](#tested-on)
5. [Usage](#usage)
6. [Function Breakdown](#function-breakdown)

---

## 🧭 Overview

**Vulner.sh** collects and inspects security-relevant system data to help identify local privilege escalation paths and weak points. It consolidates enumeration techniques in one script, saving results in a structured output format.

---

## ✨ Features

- 🔍 Kernel info, system version, architecture
- 📁 World-writable and SUID file enumeration
- 🔑 Cron job checks and PATH hijack detection
- 🐚 User, password, shadow, and sudo analysis
- 📦 Package listings and vulnerable versions
- 🛠 Local exploit suggestion (optional manual input or tool linking)

---

## 🔧 Requirements

No external dependencies needed  
(but optionally pairs well with tools like `linpeas.sh`, `pspy`, or `exploit-db`)

> Root not required, but additional findings if run as root

---

## 🖥️ Tested On

- ✅ Kali Linux
- ✅ Ubuntu 20.04–22.04
- ✅ Debian 11

---

## 🚀 Usage

```bash
chmod +x Vulner.sh
./Vulner.sh
```

> Output will be saved in the current directory or as specified

---

## 🔎 Function Breakdown

- `system_info`: Basic system details (uname, lsb_release, hostname)
- `user_enum`: Lists users, UIDs, login shells, and current privileges
- `file_check`: SUID/SGID files, world-writable files, sensitive file perms
- `cron_check`: Looks for user cron jobs and suspicious PATH configs
- `network_enum`: Shows open ports, processes, and local connections
- `exploit_suggestion`: (optional) links or outputs known local exploits

---

## ⚠️ Disclaimer

This script is for **educational and legal auditing use only**. Do not deploy on production systems or networks without permission.

---

**Author**: Hadroxx  
**Script**: `Vulner.sh`
