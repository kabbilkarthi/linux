# NFS Mount Automation Script

**Owner:** KABBIL GI
**Version:** v1
**Date:** 12-12-2022

A Bash script that automates NFS share discovery and mounting across multiple remote hosts. It auto-detects the correct SSH port, lists existing NFS mounts, and optionally creates and persists new NFS mounts — with email notification on success.

---

## Features

- Reads hosts from a centralized host file (`/var/host`)
- Auto-detects SSH port (`2022` vs default `22`) per host
- Lists existing NFS mounts on each host
- Interactively creates new NFS mounts on demand
- Backs up `/etc/fstab` before making changes
- Persists the new mount in `/etc/fstab`
- Sends an email notification upon successful mount

---

## Requirements

- Bash
- SSH key-based authentication (BatchMode — no password prompts)
- `mail` command configured on the local machine
- Root or sudo privileges on remote hosts (for `mount`, `mkdir`, `fstab` edits)
- Host list file at `/var/host`

---

## Host File Format

The script reads hostnames/IPs from `/var/host`, one per line.

```
server01
server02
192.168.1.50
```

---

## Usage

```bash
chmod +x nfs_mount.sh
./nfs_mount.sh
```

No arguments are required. The script is fully interactive — it will prompt for input at each step.

---

## How It Works

### Step 1 — SSH Port Detection

For each host, the script first attempts to connect on **port 2022** with a 60-second timeout.

- If successful → uses port 2022 for all subsequent commands
- If it fails → falls back to the **default SSH port (22)**

### Step 2 — Connectivity Check

Runs `uptime` on the host to confirm the selected SSH login works.

- Success → prints a host banner and proceeds
- Failure → prints `Login Not Success` and skips to the next host

### Step 3 — Show Existing NFS Mounts

Runs `df -T | grep nfs` on the remote host to display all currently mounted NFS shares.

### Step 4 — Prompt to Create NFS Mount

```
Need to create NFS? [ 'yes/y' or 'no/n' ]:
```

If **no** → skips and moves to the next host.

If **yes** → proceeds to mount creation:

| Prompt | Description |
|--------|-------------|
| `Storage IP` | NFS server IP (default: `172.20.5.150`) |
| `Share_name` | The exported share path on the NFS server |
| `Mount_name` | The local directory name to mount under `/` |

### Step 5 — Mount & Persist

1. Creates the local mount directory: `mkdir /<Mount_name>`
2. Backs up fstab: `cp /etc/fstab /etc/fstab_DD_MM_YYYY`
3. Mounts the share: `mount -t nfs <Storage_IP>:/<Share_name> /<Mount_name>`
4. If mount succeeds → appends entry to `/etc/fstab` for persistence across reboots:
   ```
   <Storage_IP>:/<Share_name>  /<Mount_name>  nfs  defaults  0  0
   ```
5. Confirms the mount with `df -T | grep /<Mount_name>`

### Step 6 — Email Notification

On a successful mount, an email is sent to the configured recipient:

```
Subject: NFS Testing

Hello kabbil,

Mounted the share <Share_name> in the server <host>.

Regards,
Kabbil
```

> **Note:** Update the `<TO MAIL ADDRESS>` placeholder in the script with the actual recipient email before use.

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| SSH on port 2022 fails | Falls back to default port 22 |
| SSH login check fails | Prints `Login Not Success`, skips host |
| `Share_name` left empty | Aborts with `Please Enter Share_name field` |
| `Mount_name` left empty | Aborts with `Please Enter Mount_name field` |
| `mount` command fails | Prints `Share not Exported`, skips fstab update |

---

## Important Notes

- The script runs **non-interactively** via `BatchMode=yes` — SSH key-based auth must be set up on all target hosts beforehand.
- `StrictHostKeyChecking=no` is used, meaning host key verification is disabled. Use with caution in untrusted networks.
- The `mail` command must be configured and working on the machine running this script for email notifications to function.
- Before running in production, replace `<TO MAIL ADDRESS>` in the script with a valid email address.
- fstab backups are created with the format `fstab_DD_MM_YYYY` on the **remote host**.
