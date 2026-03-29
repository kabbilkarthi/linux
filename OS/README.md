# Remote Admin Tool

**Author:** KABBIL GI

A Bash-based interactive menu-driven tool for performing common sysadmin tasks across multiple remote hosts via SSH. Supports parallel and sequential execution, LSF farm management, and structured logging.

---

## Features

- Multi-host SSH execution (parallel or sequential)
- Hostfile support for bulk operations
- LSF farm integration (via `bjobs`, `blimits`)
- Disk usage and filesystem checks
- Citrix session management
- Process and D-State inspection
- Login restriction auditing
- Health check execution (LS and SS)
- Automatic per-host logging with date-stamped log files

---

## Requirements

- Bash 4.0+
- SSH access to target hosts (key-based auth recommended)
- `getopt` (GNU extended version)
- LSF tools (`bjobs`, `blimits`) — only for Farm menu
- Citrix tools (`ctxqsession`, `ctxreset`) — only for Citrix menu
- Health check scripts — only for Health Check menu

---

## Usage

```bash
./script.sh [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `-m, --machine <value>` | Single host, comma-separated hosts, or path to a hostfile |
| `-f, --farm <value>` | LSF farm name |
| `-h, --help` | Show help message |

### Examples

```bash
# Single host
./script.sh -m server01

# Multiple hosts (comma-separated)
./script.sh -m server01,server02,server03

# Hosts from a file
./script.sh -m /path/to/hostfile.txt

# LSF farm only
./script.sh -f prod_farm

# Combined
./script.sh -m server01,server02 -f prod_farm
```

### Hostfile Format

One hostname per line. Lines starting with `#` and blank lines are ignored.

```
# Production servers
server01
server02
server03
```

---

## Main Menu

```
-----------------------------------------------
| Main MENU                                   |
-----------------------------------------------
| 1. Disk             | 2. Citrix             |
| 3. Process          | 4. Exit               |
| 5. Farm             | 6. Login Restriction  |
| 7. Health Check     |                       |
-----------------------------------------------
```

---

## Menu Reference

### 1. Disk

Requires `-m` hosts.

| Option | Description |
|--------|-------------|
| FS Size | Runs `df -h <path>` on each host |
| Disk Usage Sort | Runs `du` with top consumers sorted by size |

You will be prompted to enter a disk path before entering this menu.

### 2. Citrix

Requires `-m` hosts.

| Option | Description |
|--------|-------------|
| ctxqsession | Lists active Citrix user sessions |
| ctxreset | Resets a specific session (prompts for session ID per host) |
| Reboot | Issues `sudo shutdown -r now` after confirmation |

> **Note:** `ctxreset` runs sequentially, one host at a time, to avoid session ID collisions.

### 3. Process

Requires `-m` hosts.

| Option | Description |
|--------|-------------|
| Uptime/Cores | Shows `uptime` and `nproc` output |
| D-State Process | Lists any processes in uninterruptible sleep (D-state) |

### 5. Farm

Requires `-f` farm (or will prompt if not passed).

| Option | Description |
|--------|-------------|
| Pending reason | Lists a user's jobs via `bjobs` and optionally shows `bjobs -l <jobid>` |
| User Limit | Shows user limits via `blimits -u <user>` |

Farm profile is sourced from `/global/lsf/cells/<farm>/conf/profile.lsf`.

### 6. Login Restriction

Requires `-m` hosts.

| Option | Description |
|--------|-------------|
| Show Restrictions | Displays the last 4 lines of `/etc/security/access.conf` |
| Search User | Greps for a specific username in `access.conf` |

### 7. Health Check

Requires `-m` hosts.

| Option | Description |
|--------|-------------|
| Health Check - LS | Runs `/etc/synopsys/local_health_check/bin/local_health_check.sh -v` |
| Health Check - SS | Runs `ckhealth.ksh -v` |

---

## Logging

All output is automatically logged to date-stamped files in the current directory:

- **Host operations:** `<hostname>_DD-MM-YY.log`
- **Farm operations:** `<farmname>_DD-MM-YY.log`

Logs are appended (not overwritten) on repeated runs within the same day.

---

## Execution Modes

| Mode | Used For |
|------|----------|
| **Parallel** (up to 3 concurrent jobs) | General host commands via `run_parallel` |
| **Sequential** | Interactive operations, session resets, reboots, and anything requiring per-host input |

The `MAX_PARALLEL` variable (default: `3`) controls how many SSH connections run concurrently in parallel mode.

---

## Exit & Cleanup

- Press **Ctrl+C** at any time to exit. The `trap cleanup` handler will terminate all background jobs cleanly.
- Selecting **Exit (option 4)** from any sub-menu exits the script immediately.

---

## Notes

- SSH connections use `-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o LogLevel=ERROR` to suppress host key prompts and noise.
- SSH exit code `255` is treated as a connection failure and logged with a `[WARN]` message.
- The script validates that at least one of `-m` or `-f` is provided before displaying the main menu.
