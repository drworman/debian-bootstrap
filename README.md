# Debian Bootstrap

A starter kit for a fresh Debian install: a curated package list, a
seed of `$HOME` dotfiles, an i3wm desktop, and a folder of utility
scripts. Drop the repo onto a brand-new machine, edit a handful of
values, run `ndi.sh`, and you have a working environment.

This README is also the orientation document for someone new to
Linux — it covers what each file does, what gets sourced when you
log in, and where to look up keybindings for the tools the desktop
expects you to use.

---

## Quick start

1. Boot Debian, install the base system, log in as `root` (or via
   `sudo -i`).
2. Clone this repo, `cd` into it.
3. Edit `ndi.sh` and set `newUser` to the username you want.
4. Edit `packages_install.txt` and `packages_remove.txt` if you want
   to add or skip anything.
5. Edit the dotfiles in `home/` — see [Edit before first use](#edit-before-first-use).
6. `bash ndi.sh`
7. After it finishes: `passwd <newUser>`, then log out and back in
   as that user.

---

## Cheatsheets — bookmark these

The desktop in this repo is i3wm with vim and nano as default editors.
If you've never used any of them, keep these open:

- **i3wm reference card** — <https://i3wm.org/docs/refcard.html>
- **vim cheatsheet**      — <https://vim.rtorr.com/>
- **nano cheatsheet**     — <https://www.nano-editor.org/dist/latest/cheatsheet.html>

For i3wm in particular: `Mod+Enter` opens a terminal, `Mod+d` opens
the launcher, `Mod+Shift+q` closes a window, `Mod+Shift+e` exits the
session. `Mod` is the Super (Windows) key by default.

---

## Contents

### Top-level files

| Path                            | Purpose                                                                                 |
| ------------------------------- | --------------------------------------------------------------------------------------- |
| `README.md`                     | This file.                                                                              |
| `description`                   | One-line repo summary used by gitweb / cgit.                                            |
| `.gitignore`                    | Universal ignore rules (caches, editor swap files, build outputs, etc).                 |
| `ndi.sh`                        | "New Debian Install" — the main bootstrap script. Run as root.                          |
| `packages_install.txt`          | List of apt packages installed by `ndi.sh`. One package per line.                       |
| `packages_remove.txt`           | List of apt packages purged by `ndi.sh` (replaces `exim`/`mailutils` etc).              |
| `thinkpad_packages_install.txt` | Extra packages for ThinkPad laptops (TLP, thinkfan, etc). Enable in `ndi.sh` if needed. |

### `docs/`

| Path                        | Purpose                                                             |
| --------------------------- | ------------------------------------------------------------------- |
| `docs/keychain.md`          | How to make `keychain` auto-load your SSH keys at login.            |
| `docs/ssh-auto-nopasswd.md` | Setting up passwordless SSH between a client and server.            |
| `docs/linux_commands.md`    | Crib sheet of useful Linux one-liners (find/sed/awk/gs/ffmpeg/etc). |

### `home/` — dotfiles

| Path                 | Purpose                                                                                   |
| -------------------- | ----------------------------------------------------------------------------------------- |
| `home/.bash_profile` | Login-shell setup: env vars, `PATH`, host-specific overrides, keychain, gnome-keyring.    |
| `home/.bashrc`       | Interactive-shell setup: history, prompt, aliases, completion, auto-startx on tty1.       |
| `home/.bash_aliases` | Aliases (`ll`, `g`, `t`, …) and small functions (`mcd`, `mnt`, `randpass`, git wrappers). |
| `home/.bash_logout`  | Clears the console on logout for privacy.                                                 |
| `home/.xinitrc`      | What `startx` runs — sources `/etc/X11/xinit/xinitrc.d/*.sh`, then `exec i3`.             |
| `home/.conkyrc`      | Conky desktop monitor configuration.                                                      |
| `home/.ssh/config`   | Per-host SSH client configuration.                                                        |

### `home/.i3/` — i3 window manager

| Path                     | Purpose                                                                                       |
| ------------------------ | --------------------------------------------------------------------------------------------- |
| `home/.i3/config`        | i3 keybindings, workspace setup, and program launches.                                        |
| `home/.i3/i3session.sh`  | Session start: loads `.Xresources`, sets root background, daemons, etc.                       |
| `home/.i3/i3bar.sh`      | Spawns the bottom bar (i3blocks) on every monitor.                                            |
| `home/.i3/i3blocks.conf` | Layout of the status bar — which blocks appear, in what order, refresh intervals.             |
| `home/.i3/i3status.conf` | Optional `i3status` config (alternative to i3blocks).                                         |
| `home/.i3/blocks/*`      | Individual block scripts (network, battery, audio, weather, mail, etc) — one per status item. |
| `home/.i3/w1.json`       | Saved i3 layout for workspace 1.                                                              |

### `home/.local/bin/` — user scripts

These are on `$PATH` after `.bash_profile` runs. Reformatted with a
standard header — open any one of them and the user-editable variables
are clearly fenced off at the top.

| Script          | Purpose                                                                                                  |
| --------------- | -------------------------------------------------------------------------------------------------------- |
| `avery-address` | Generate PostScript for Avery 5160/5260 address-label sheets.                                            |
| `chrome`        | Wrapper that launches Google Chrome with the GNOME keyring as the password store.                        |
| `duc`           | Print total `$HOME` size and file count.                                                                 |
| `fd`            | Find duplicate files in `./` and replace duplicates with hardlinks (`fdupes -drSN`).                     |
| `getipkgs`      | Generate per-host installed-package lists (Debian/Arch/Gentoo aware).                                    |
| `gfupd`         | Download/update the Google Fonts collection into `~/.fonts`.                                             |
| `git-collect`   | Archive a repo's tracked + untracked-but-not-ignored files (excluding images) to a `tar.gz`.             |
| `git-init`      | Bootstrap a new repo: `priv` + `ghub` remotes, GitHub repo via `gh`, template seed, main + dev branches. |
| `git-mirror`    | Force `git push --mirror` to every configured remote (destructive, exact replication).                   |
| `git-publish`   | Run `git-sync` then `git-mirror` — end-of-day "everything aligned" command.                              |
| `git-sync`      | Per-branch ahead/behind/diverged check; pushes ahead branches, ff-pulls behind branches.                 |
| `hsb`           | Host-aware Sync Batch — runs the right Unison profile based on FQDN + LAN-vs-roaming.                    |
| `mail.pers`     | Print unread-message count for personal mailbox over IMAPS (i3blocks/conky source).                      |
| `mail.work`     | Same as `mail.pers` for the work mailbox — kept separate so credentials are independent.                 |
| `matrixlock.py` | i3lock with a Matrix-rain animation (`neo`) on every visible workspace.                                  |
| `mkdebarchive`  | Re-download every installed `.deb` into `~/debarchive/` for offline reinstalls.                          |
| `netudev.sh`    | Generate `/etc/udev/rules.d/10-network.rules` to pin interface names to `eth0` / `wlan0`.                |
| `rsau`          | Restart the user audio stack (pipewire / wireplumber / pipewire-pulse).                                  |
| `screenlock`    | Like `matrixlock.py` but with the "SYSTEM FAILURE" banner on the rain.                                   |
| `sgnl`          | Wrapper that launches Signal Desktop with the GNOME keyring as the password store.                       |
| `sshperms`      | Apply `600`/`700` recursively to `$PWD` — what `~/.ssh` needs.                                           |
| `sysclean`      | Cross-distro cleanup: remove orphans, optionally purge named packages, repeat orphan pass.               |
| `sysupd`        | Cross-distro full upgrade with silent first pass + interactive recovery pass + `$HOME` cleanup.          |
| `webperms`      | Apply `644`/`755` recursively to `$PWD` — Apache/nginx document-root standard.                           |

### `home/.unison/`

Unison profile templates for bidirectional sync.

| Path                             | Purpose                                                            |
| -------------------------------- | ------------------------------------------------------------------ |
| `home/.unison/unison_prefs`      | Shared preferences pulled in by `include unison_prefs` in others.  |
| `home/.unison/<host>.prf`        | Per-host LAN profile (sync runs without confirmation).             |
| `home/.unison/<host>_remote.prf` | Per-host roaming profile (used when the laptop is off-LAN).        |
| `home/.unison/ask-<host>.prf`    | Same as the matching profile, but Unison prompts before each diff. |

Rename these to your own `hostname.domain.tld` before first use. The
`hsb` script picks one automatically based on the local FQDN and IP.

### `.github/workflows/` and `.scripts/`

| Path                              | Purpose                                                                               |
| --------------------------------- | ------------------------------------------------------------------------------------- |
| `.github/workflows/release.yml`   | On GitHub Release publish: build a source tarball, sign with SSH, upload.             |
| `.github/workflows/sync-wiki.yml` | On push to `main`: copy `README.md` / `INSTALL.md` / `docs/**` into the repo's wiki.  |
| `.scripts/sync_wiki.sh`           | Helper script invoked by `sync-wiki.yml` — handles renaming, link rewriting, sidebar. |

---

## Edit before first use

Open these files and change the placeholders to match your environment.

### Identity / network

- `home/.bash_profile`
  - `EMAIL_ADDR` — your email address
  - `GITHUB_TOKEN` — personal access token if you want one in the env
  - `LTOP` / `DTOP` — FQDN of your laptop and desktop (used for
    host-specific overrides)
  - `LTOPEDP1` / `LTOPHDMI` / `DTOPDP` / `DTOPHDMI` — the X11 output
    names for built-in vs external displays (find them with `xrandr`)
  - `BROWSER`, `EDITOR`, `VISUAL`, `GTK_THEME`

### Shell preferences

- `home/.bashrc` — uncomment the `PS1` style you prefer (4 examples
  near the top); tweak history options, completions
- `home/.bash_aliases` — add or remove aliases as you like

### Window manager and bar

- `home/.i3/config` — keybindings, autostart programs, workspace defaults
- `home/.i3/i3blocks.conf` — pick which status blocks are shown
- `home/.i3/blocks/*` — for each enabled block, fill in the block's
  variables: zip code in `weather`, interface name in `network`,
  API keys, etc.
- `home/.conkyrc` — fonts, position, what stats to display
- `home/.xinitrc` — leave alone unless you want a different WM

### Mail and credentials

- `home/.local/bin/mail.pers`, `home/.local/bin/mail.work`
  - `USERNAME`, `PASSWORD`, `SERVER`, `PORT`
  - **Use an app password, not your real account password.**

### Sync (Unison)

- `home/.local/bin/hsb` — set `LAPTOP_HOSTNAME`, `HOME_SUBNET`,
  `REMOTE_PROFILE`
- `home/.unison/*.prf` — rename to `<your-fqdn>.prf`. Inside each,
  the `root =` line is the **remote** machine; the file *name*
  refers to the **local** machine. Profiles use SSH, so set up
  passwordless SSH first (see `docs/ssh-auto-nopasswd.md`) or expect
  to type your password at every sync.
  - `ask-*` profiles prompt before applying each diff.
  - Plain profiles run unattended.
  - Run sync with `unison-gtk` (manual GUI) or `hsb` (automatic).

### Git workflow

- `home/.local/bin/git-init` — set `GHUB_URL` and `PRIV_URL` to your
  GitHub and self-hosted git remotes.
- Set up a `~/.local/share/git-template/` directory containing
  whatever skeleton files you want every new repo to start with
  (license, `.gitignore`, signing key, `.github/`, etc).

### Bootstrap script

- `ndi.sh` — set `newUser` to your target username. Uncomment the
  `dpkg-add-architecture i386` line if you need 32-bit support.
  Uncomment the thinkpad-packages line if you're on a ThinkPad.

---

## Interactive login flow

This is what happens, in order, when you log in on tty1 and end up in
i3 with a working terminal:

```
agetty (tty1)
  └─ login(1)
       └─ exec bash --login                       # login shell
            ├─ /etc/profile                       # system-wide login init
            │     └─ /etc/profile.d/*.sh
            ├─ ~/.bash_profile                    # ← per-user login init
            │     ├─ source ~/.profile (if it exists)
            │     ├─ export NUMLOCK / SYSBELL / TOUCHPAD / LANG / EDITOR / …
            │     ├─ host-specific overrides (FQDN == $LTOP / $DTOP)
            │     ├─ build PATH via path_add / path_add_if_execs
            │     ├─ apply numlock + system-bell settings
            │     ├─ start gnome-keyring-daemon (pkcs11 + secrets + gpg)
            │     ├─ start keychain → load all ~/.ssh/* private keys
            │     ├─ source ~/.keychain/$HOSTNAME-sh   # exports SSH_AUTH_SOCK
            │     └─ source ~/.bashrc              ← ★ (interactive login)
            │
            └─ ~/.bashrc                          # interactive setup
                  ├─ early-return if non-interactive
                  ├─ history options + checkwinsize
                  ├─ prompt (PS1)
                  ├─ source ~/.bash_aliases       ← aliases + small functions
                  ├─ define _service_fn, register completions
                  ├─ source /etc/bash_completion (if non-posix)
                  └─ if tty == /dev/tty1 and no DISPLAY:
                        startx                    ← launches X
                          └─ ~/.xinitrc
                               ├─ source /etc/X11/xinit/xinitrc.d/*.sh
                               └─ exec /usr/bin/i3
                                    └─ ~/.i3/config
                                         ├─ ~/.i3/i3session.sh    (autostart)
                                         └─ ~/.i3/i3bar.sh        (status bar)
                                              └─ i3blocks (~/.i3/i3blocks.conf)
                                                   └─ ~/.i3/blocks/*
                        # when X exits, control returns here…
                        logout                    ← cleanly ends the session
```

On logout, `~/.bash_logout` runs and clears the console
(`/usr/bin/clear_console -q`) for privacy.

### Why some files appear to be sourced twice

You'll notice `~/.bash_profile` ends with:

```sh
if [ -n "$BASH_VERSION" ] && [[ $- == *i* ]]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
```

Bash's split between *login* shells (read `.bash_profile`) and
*interactive non-login* shells (read `.bashrc`) means env vars and
aliases live in different files — but you usually want both in both
shells. The pattern above is the standard fix: have the login shell
explicitly source `.bashrc` after the env is set up. So the order on
a tty1 login is **`.bash_profile` first, `.bashrc` second** — but
opening a new terminal under i3 only runs `.bashrc` (it's an
interactive non-login shell), and the env vars are already inherited
from the parent process.

### `.profile` vs `.bash_profile`

`~/.bash_profile` checks for `~/.profile` and sources it first.
`~/.profile` is the POSIX-portable file (read by `dash`, `sh`,
display managers, etc); `~/.bash_profile` is bash-specific. Putting
truly portable env vars in `~/.profile` and bash-only ones in
`~/.bash_profile` keeps everything happy. This repo doesn't ship a
`~/.profile`; the source line is there as a hook in case you add one
later.

---

## Dependencies

Everything here is in `packages_install.txt` and will be installed by
`ndi.sh`, except where flagged as a manual install.

### What each script needs

| Script          | External programs (Debian package)                                                                                          |
| --------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `avery-address` | perl (`perl`)                                                                                                               |
| `chrome`        | google-chrome-stable *(manual)*, libsecret-1-0 (`gnome-keyring`)                                                            |
| `duc`           | du, wc (`coreutils`); find (`findutils`)                                                                                    |
| `fd`            | fdupes (`fdupes`)                                                                                                           |
| `getipkgs`      | apt-mark (`apt`); hostname (`hostname`); coreutils (sort)                                                                   |
| `gfupd`         | wget (`wget`); unzip (`unzip`); fc-cache (`fontconfig`)                                                                     |
| `git-collect`   | git (`git`); tar (`tar`); grep (`grep`); coreutils (realpath, du, cut)                                                      |
| `git-init`      | git (`git`); gh *(manual — github-cli)*; rsync (`rsync`); sed (`sed`); grep (`grep`)                                        |
| `git-mirror`    | git (`git`); sed (`sed`)                                                                                                    |
| `git-publish`   | git (`git`)                                                                                                                 |
| `git-sync`      | git (`git`); awk (`mawk`); grep (`grep`); sed (`sed`)                                                                       |
| `hsb`           | python3 (`python3`); unison (`unison`); hostname (`hostname`)                                                               |
| `mail.pers`     | python3 (`python3`) — `imaplib` is in the standard library                                                                  |
| `mail.work`     | python3 (`python3`) — `imaplib` is in the standard library                                                                  |
| `matrixlock.py` | python3 (`python3`); i3-msg + i3lock (`i3-wm`, `i3lock`); xterm (`xterm`); curl (`curl`); neo *(manual)*; procps (`procps`) |
| `mkdebarchive`  | apt, dpkg (`apt`, `dpkg`); localepurge (`localepurge`); sudo (`sudo`); awk (`mawk`)                                         |
| `netudev.sh`    | udevadm (`udev`); coreutils; sudo (`sudo`)                                                                                  |
| `rsau`          | systemctl (`systemd`); pipewire + wireplumber (`pipewire-audio`)                                                            |
| `screenlock`    | same as `matrixlock.py`                                                                                                     |
| `sgnl`          | signal-desktop (`signal-desktop`); libsecret-1-0 (`gnome-keyring`)                                                          |
| `sshperms`      | findutils, coreutils, sudo                                                                                                  |
| `sysclean`      | sudo, coreutils — package-manager varies by distro                                                                          |
| `sysupd`        | sudo, coreutils — package-manager varies by distro                                                                          |
| `webperms`      | findutils, coreutils, sudo                                                                                                  |

`.bash_profile` itself depends on `xdotool` (`xdotool`) for
`xdotool getactivewindow`, `setleds` (`kbd`) for the numlock toggle,
`setterm` (`util-linux`) for the system bell, `keychain` (`keychain`),
and `gnome-keyring-daemon` (`gnome-keyring`) — all in the package list.
