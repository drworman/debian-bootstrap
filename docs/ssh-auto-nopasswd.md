# Passwordless SSH from client to server

Set up SSH key-based login so you can `ssh user@host` without typing a
password. The key lives on the client; the public half lives in the
server's `~/.ssh/authorized_keys`.

> **Heads-up:** the recipe below pulls the *private* key off the
> server. That's an unusual layout — it works, but the more common
> approach is to generate the keypair on the **client** and push only
> the public key to the server. Both are documented here.

---

## Recommended (client-generated key)

On the **client** (the machine you'll be sshing *from*):

```sh
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_<server>
ssh-copy-id -i ~/.ssh/id_<server>.pub user@server.example.com
```

Then add a stanza to `~/.ssh/config` so the right key is offered for
that host:

```
Host server.example.com
    User user
    Hostname server.example.com
    IdentityFile ~/.ssh/id_<server>
    IdentitiesOnly yes
```

---

## Original recipe (server-generated key)

This is the workflow the original document described. Use it if you
want every machine that needs access to share one key that lives on
the server.

### On the server

```sh
cd \
    && rm -rf .ssh \
    && ssh-keygen -b 4096 -t rsa \
    && cd ~/.ssh \
    && cat id_rsa.pub >> authorized_keys \
    && chmod 600 authorized_keys \
    && rm id_rsa.pub
```

This creates a fresh `~/.ssh`, generates a 4096-bit RSA keypair,
authorises that public key for incoming connections, and cleans up the
public-key file.

### On the client

```sh
cd ~/.ssh \
    && scp user@server.example.com:.ssh/id_rsa server.example.com.rsa \
    && chmod 600 server.example.com.rsa \
    && printf "\nHost server.example.com\nUser user\nHostname server.example.com\nIdentityFile ~/.ssh/server.example.com.rsa\n" \
        >> config
```

This copies the private key from the server to the client (over the
existing password-authenticated SSH session), tightens its permissions,
and appends a matching `~/.ssh/config` entry.

After this, `ssh server.example.com` will succeed without a password.

---

## Verifying

```sh
ssh -v user@server.example.com 'echo OK'
```

Look for `Authenticated to ... using "publickey"` in the verbose
output. If you see `Permission denied (publickey)`, the most common
causes are:

- Wrong permissions on `~/.ssh` (must be `700`) or
  `authorized_keys` (must be `600`) on the **server**.
- Server-side `sshd_config` has `PubkeyAuthentication no` or the key
  type is disabled.
- Client offered a different key first; force one with
  `ssh -i ~/.ssh/server.example.com.rsa ...` or set
  `IdentitiesOnly yes` in `~/.ssh/config`.
