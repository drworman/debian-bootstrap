# SSH agent automation with `keychain`

`keychain` (the shell tool, not macOS Keychain) starts your `ssh-agent`
and loads your private keys when your login shell starts, then reuses
the same agent across subshells. It will prompt once per session for
any encrypted key passphrases and remember them until you log out.

This is what makes `git push`, `ssh server`, `unison`, etc. work
without typing a passphrase every time.

---

## 1. Install

```sh
sudo apt install keychain
```

---

## 2. Add it to your shell startup

The `keychain` invocation belongs in a *login* shell file:

- bash: `~/.bash_profile` or `~/.profile`
- zsh:  `~/.zshrc` (zsh treats it as a login file)

This repo's `home/.bash_profile` already includes the recommended block:

```sh
# SSH keychain
KEYS=$(find ~/.ssh -maxdepth 1 -type f \
    ! -name "authorized_keys*" \
    ! -name "*.pub" \
    ! -name "known_hosts" \
    ! -name "allowed_signers" \
    ! -name "config" \
    -printf "%f ")

if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(keychain --eval --quiet $KEYS)"
fi

source ~/.keychain/$HOSTNAME-sh
```

The `find` command auto-discovers every private key in `~/.ssh/`,
excluding the public-key, config, and bookkeeping files. The
`if [ -z "$SSH_AUTH_SOCK" ]` guard means keychain only starts the
agent if one isn't already running, so subshells reuse the existing
one. The final `source` line picks up the `SSH_AUTH_SOCK` /
`SSH_AGENT_PID` environment variables that keychain wrote out.

---

## 3. Pair with `~/.ssh/config`

For consistent behaviour, point each host at the specific key it
should use. Auto-loading every key into the agent and letting OpenSSH
pick is fragile — many servers reject the connection if too many keys
are tried before the right one.

Example `~/.ssh/config`:

```
Host host.domain.tld
    User username
    Hostname host.domain.tld
    IdentityFile ~/.ssh/id_rsa
    AddKeysToAgent yes
    IdentitiesOnly yes
```

`IdentitiesOnly yes` is the important line — it tells OpenSSH to use
*only* the listed `IdentityFile` for that host, instead of trying
every key in the agent.

---

## 4. Common problems

**"Too many authentication failures"** — too many keys are being
tried against a server. Fix: `IdentitiesOnly yes` in
`~/.ssh/config` for that Host.

**Wrong file** — putting the keychain block in `~/.bashrc` instead of
`~/.bash_profile` means it re-runs in every subshell. Login files
fire once at login; rc files fire on every interactive shell.

**Permission errors** — keys must be private:

```sh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
chmod 700 ~/.ssh
```

The `sshperms` script in `home/.local/bin/` does this in one go when
run from inside `~/.ssh/`.

---

## 5. The short version

```sh
eval "$(keychain --quiet --eval --agents ssh)"
```

…with `~/.ssh/config` doing the per-host key selection. This is what
`home/.bash_profile` is set up to do.
