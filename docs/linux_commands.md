# Linux command crib sheet

A grab-bag of one-liners and recipes that are easier to look up than
to remember. Organised by topic.

---

## Python alternatives (update-alternatives)

When you have several Python interpreters installed, `update-alternatives`
manages which one `/usr/bin/python` points at:

```sh
# See what's currently registered
update-alternatives --list python

# Pick interactively
update-alternatives --config python

# Register a new interpreter (priority 10)
update-alternatives --install /usr/bin/python python /usr/bin/python3.8 10

# Drop one
update-alternatives --remove python /usr/bin/python3.8
```

---

## Optical media

```sh
# Erase a DVD+RW (fast = blank table only)
cdrecord dev=/dev/sr0 blank=fast

# Format a fresh DVD+RW
dvd+rw-format -force /dev/sr0
```

### Build an ISO from a directory

```sh
# Joliet + Rock Ridge, suitable for almost anything
xorrisofs -r -J -o ./image.iso ./directory/

# Burn an ISO to disc
cdrecord dev=/dev/sr0 image.iso

# All in one — pipe straight to the burner
xorrisofs -fRrlJ -A DISC_LABEL -o - directory \
    | sudo cdrecord dev=/dev/sr0 -

# Burn with verbose progress and eject when done
wodim -eject -tao speed=2 dev=/dev/sr0 -v -data image.iso
```

---

## Use a video file as the desktop background

```sh
mpv -vo x11 -wid "$(xwininfo -name Desktop | awk '/id:/ {print $4}')" video.mp4
```

`xwininfo -name Desktop` finds the X window that the WM treats as the
root/desktop; mpv renders into that window's ID, so the video plays
behind everything else.

---

## Iterate over `ls` output safely

```sh
# Install every APK in a directory onto an attached Android device
(IFS=$'\n'
 for f in $(ls /path/to/apps/); do
     /path/to/adb install "/path/to/apps/$f"
 done)
```

The `IFS=$'\n'` keeps filenames with spaces from being split on every
whitespace character. Even better: use `find -exec` or `find -print0 |
xargs -0` for filenames with newlines.

---

## Encrypted password file editor

A bash function that decrypts a GPG-encrypted file into a temp file,
opens it in `vim`, re-encrypts on save, and securely wipes the temp
files. Drop into `~/.bashrc`:

```sh
OpenEncrypted() {
    local ENCRYPTEDFILE="$1"
    local TEMPFILE1 TEMPFILE2
    TEMPFILE1=$(mktemp)
    TEMPFILE2=$(mktemp)

    if [ ! -f "$ENCRYPTEDFILE" ]; then
        echo "No password file."
        return
    fi

    gpg -o - "$ENCRYPTEDFILE" > "$TEMPFILE1" || return
    cp "$TEMPFILE1" "$TEMPFILE2"

    vim "$TEMPFILE1"

    if ! diff -q "$TEMPFILE1" "$TEMPFILE2" >/dev/null 2>&1; then
        local CODE=1
        while [ "$CODE" != "0" ]; do
            gpg -o - --symmetric "$TEMPFILE1" > "$ENCRYPTEDFILE"
            CODE=$?
        done
    fi

    wipe -fs "$TEMPFILE1" "$TEMPFILE2"
}

VimPasswords() {
    OpenEncrypted "/media/disk/Docs/passwords.txt.gpg"
}
```

Requires `gnupg` and `wipe`. On Debian: `sudo apt install gnupg wipe`.

> The original used `tempfile`, which is deprecated; `mktemp` is the
> modern replacement.

---

## Find + act recipes

### Find and move

```sh
# Move every .ttf under $HOME into ~/.fonts/
find ~/ -iname '*.ttf' -exec mv -n -t ~/.fonts/ {} +
```

### Find and remove

```sh
# Remove every Syncthing conflict file in the current tree
find ./ -iname '*sync-conflict*' -delete
```

### Find and rename (mass)

```sh
# Debian rename (perl-style)
find ./ -iname '*old.example.com*' -exec rename 's/old\.example\.com/new.example.com/' {} +

# util-linux rename (bare from→to)
find ./ -iname '*old.example.com*' -exec rename 'old.example.com' 'new.example.com' {} +
```

> Debian ships *both* `rename` implementations. `dpkg -L rename` will
> tell you which is on your `PATH`. The perl version takes a regex,
> the util-linux version takes a literal `from to` pair.

### Find by extension with regex

```sh
find ./ -iname '*.jpg'
find -regex '.*\.\(jpg\|png\)'
```

### Find text inside files

```sh
# Search every .html in cwd for a string (NUL-delimited, safe with spaces)
find ./ -name '*.html' -type f -print0 | xargs -0 grep -i "needle"
```

### Mass find and replace

```sh
# Replace literal text in every regular file under cwd
find ./ -type f -print0 | xargs -0 sed -i 's/old.example.com/new.example.com/Ig'

# Same idea with perl-pi (handles regex more cleanly)
find ./ -type f -print0 | xargs -0 perl -pi -e 's/oldhost/newhost/g'
```

```sh
# Replace 'testing' with 'unstable' in every apt source list (sudo)
sudo find /etc/apt/ -type f -iname '*.list' -print0 \
    | xargs -0 sed -i 's/testing/unstable/Ig'
```

---

## Compress a PDF

```sh
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/screen -dNOPAUSE -dBATCH -dQUIET \
   -sOutputFile=output.pdf input.pdf
```

`-dPDFSETTINGS` profiles, smallest to largest:
`/screen`, `/ebook`, `/printer`, `/prepress`, `/default`.

---

## Convert audio (.m4a → .mp3, recursive)

```sh
find ./ -name '*.m4a' -exec sh -c '
    ffmpeg -i "$1" -acodec mp3 -ac 2 -ab 320k "${1%.m4a}.mp3"
' _ {} \;
```

---

## awk: replace a specific column at a specific row

```sh
# In rows 2..5, set columns 7 and 9 to 60; print everything else as-is
awk 'FNR==2,FNR==5 { $7=$9=60 } 1' input.dat > tmp

# Same idea, single row
awk 'FNR==1 { $1=60 } 1' input.dat > tmp
```

The trailing `1` is awk shorthand for "print the current line". The
range pattern `FNR==2,FNR==5` selects rows 2 through 5 inclusive.

---

## Replace spaces with `#` on the first line of /etc/hosts

```sh
# Show what the new line would look like
head -n1 /etc/hosts | awk '{ gsub(" ", "#", $0); print }'

# Apply it in place to a copy
sed -i "1s/^.*$/$(head -n1 /etc/hosts | awk '{ gsub(\" \", \"#\", $0); print }')/" ./hosts
```
