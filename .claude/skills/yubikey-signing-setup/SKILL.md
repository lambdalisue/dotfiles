---
name: yubikey-signing-setup
description: Set up per-device GPG commit signing with the YubiKey on a fresh machine — import the card's public key, create a local sign-only subkey, verify, and publish the updated key. Explicit invocation only.
disable-model-invocation: true
---

# YubiKey per-device signing setup

Set up GPG commit signing on a NEW machine, following the key model in
https://zenn.dev/lambdalisue/articles/gpg-with-yubikey-2024

## Key model (why this is needed)

- The YubiKey holds the **primary key `[C]` (certify-only)** and the
  **encryption subkey `[E]`**. Primary fingerprint:
  `DF391438E6C2FA2A6398BDEEB11731DAB90A2400` (short id `B11731DAB90A2400`).
- **Signing is done by a per-device, on-disk sign-only subkey `[S]`.** Each
  machine has its own. A fresh machine has none, so `git commit` signing fails
  with `gpg: skipped "...": No secret key`.
- Git is configured (in this repo's git config) with
  `user.signingkey=B11731DAB90A2400` (the primary) and `commit.gpgsign=true`;
  gpg auto-selects the local `[S]` subkey.

## Do NOT run

The article's one-time provisioning steps are already done on the YubiKey.
NEVER run these here: `ykman openpgp reset`, `keytocard`, `passwd`, card
`generate`. They wipe or move key material.

## Procedure

1. Insert the YubiKey. Confirm the card is seen (initially
   `General key info: [none]`):

       gpg --card-status

2. Import the public key from the card's registered URL (equivalent to
   `gpg --card-edit` → `fetch`, but needs no tty):

       curl -fsSL "https://keys.openpgp.org/vks/v1/by-fingerprint/DF391438E6C2FA2A6398BDEEB11731DAB90A2400" | gpg --import

3. Re-read the card so gpg creates the on-card secret stubs (`[C]` primary,
   `[E]` encryption). Confirm `General key info: pub rsa4096/B11731DAB90A2400`:

       gpg --card-status

4. Create the per-device signing subkey: ECC sign-only, Curve 25519, never
   expires. A GUI pinentry asks for the **Admin PIN** and the YubiKey needs a
   **touch**. Interactive form:

       gpg --expert --edit-key B11731DAB90A2400
       # addkey → (10) ECC (sign only) → (1) Curve 25519 → 0 (never) → y → y → save

   Non-interactive contexts lack a tty; drive the menu and let pinentry pop
   the GUI dialog:

       printf '%s\n' addkey 10 1 0 y y save \
         | gpg --no-tty --expert --command-fd 0 --status-fd 2 --edit-key B11731DAB90A2400

5. Verify a new **local** subkey exists (`ssb` with no `#`/`>`) and test sign:

       gpg -K            # expect: ssb   ed25519 <today> [S]
       echo test | gpg --local-user B11731DAB90A2400 --sign --armor

6. Publish the updated public key so the new subkey verifies elsewhere:

       # keys.openpgp.org (no auth)
       gpg --keyserver hkps://keys.openpgp.org --send-keys B11731DAB90A2400

       # GitHub (needs `gh auth login`)
       gpg --armor --export B11731DAB90A2400 > /tmp/gpg-pub.asc
       gh gpg-key add /tmp/gpg-pub.asc
       # If GitHub already has this key (HTTP 422 "key_id already exists"),
       # delete then re-add so the new subkey is included:
       #   gh gpg-key list            # find the key id
       #   gh gpg-key delete <id>
       #   gh gpg-key add /tmp/gpg-pub.asc

## Notes

- The local `[S]` subkey never expires (per the article). If this machine is
  lost or decommissioned, revoke that subkey and re-publish.
- `gpg --edit-key` needs a controlling tty; in scripted/non-interactive
  contexts use the `--no-tty --command-fd 0` form above.
