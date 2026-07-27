# Himalaya v1.2 provider setup

Use this reference only for account setup, authentication repair, or folder
mapping. Preserve existing configuration and add or repair one account at a
time.

Configuration keys in this reference target the
[Himalaya v1.2 sample configuration](https://github.com/pimalaya/himalaya/blob/v1.2.0/config.sample.toml).

## Security

- Store passwords and OAuth tokens in the system keyring.
- Never put secrets in TOML `*.raw` fields, shell arguments, chat, or logs.
- Let the user answer password and browser authorization prompts directly in
  their terminal.
- Use command-based secret retrieval only when the user already has a trusted
  secret manager and explicitly prefers it.

The default configuration is
`~/.config/himalaya/config.toml`. Start the interactive wizard with:

```bash
himalaya account configure <account>
```

After configuration, prompt for missing keyring values and verify both IMAP and
SMTP:

```bash
himalaya account doctor <account> --fix
himalaya folder list -a <account> -o json
```

## Password account shape

Use this Himalaya v1.2 shape for an app-password account. Replace placeholders
with public account settings only; enter the app password through
`account configure` or `account doctor --fix`.

```toml
[accounts.<account>]
email = "<email-address>"
display-name = "<display-name>"
default = false

backend.type = "imap"
backend.host = "<imap-host>"
backend.port = 993
backend.encryption.type = "tls"
backend.login = "<email-address>"
backend.auth.type = "password"
backend.auth.keyring = "<account>-imap"

message.send.backend.type = "smtp"
message.send.backend.host = "<smtp-host>"
message.send.backend.port = <smtp-port>
message.send.backend.encryption.type = "<tls-or-start-tls>"
message.send.backend.login = "<email-address>"
message.send.backend.auth.type = "password"
message.send.backend.auth.keyring = "<account>-smtp"
message.send.save-copy = true
```

Make only one account `default = true`.

## Provider settings

| Provider | IMAP | SMTP | Authentication |
| --- | --- | --- | --- |
| Gmail or Google Workspace | `imap.gmail.com:993`, `tls` | `smtp.gmail.com:465`, `tls` | App password when permitted; otherwise OAuth2 |
| Fastmail | `imap.fastmail.com:993`, `tls` | `smtp.fastmail.com:465`, `tls` | Fastmail app password |
| iCloud Mail | `imap.mail.me.com:993`, `tls` | `smtp.mail.me.com:587`, `start-tls` | Apple app-specific password; use the complete iCloud address as the login |

Provider guidance:

- Google app passwords require 2-Step Verification and may be unavailable under
  organization policy. For Workspace accounts where app passwords are blocked,
  use OAuth2. See
  [Google's app-password guidance](https://support.google.com/accounts/answer/185833).
- Fastmail requires an app password for third-party mail clients. See
  [Fastmail's IMAP and SMTP guidance](https://www.fastmail.help/hc/en-us/articles/1500000279921-IMAP-POP-and-SMTP).
- iCloud requires an app-specific password and two-factor authentication. See
  [Apple's mail-server guidance](https://support.apple.com/102525).

## Google OAuth2

Use a Google Cloud OAuth client suitable for a local application. Configure both
the IMAP backend and SMTP send backend with:

```toml
backend.auth.type = "oauth2"
backend.auth.client-id = "<client-id>"
backend.auth.method = "xoauth2"
backend.auth.auth-url = "https://accounts.google.com/o/oauth2/v2/auth"
backend.auth.token-url = "https://www.googleapis.com/oauth2/v3/token"
backend.auth.scopes = ["https://mail.google.com/"]

message.send.backend.auth.type = "oauth2"
message.send.backend.auth.client-id = "<client-id>"
message.send.backend.auth.method = "xoauth2"
message.send.backend.auth.auth-url = "https://accounts.google.com/o/oauth2/v2/auth"
message.send.backend.auth.token-url = "https://www.googleapis.com/oauth2/v3/token"
message.send.backend.auth.scopes = ["https://mail.google.com/"]
```

Store the client secret and generated access and refresh tokens in the keyring.
Use `account configure` or `account doctor --fix` to complete the browser flow
and keyring entries; do not collect those values in chat.

## Folder aliases

Always run `folder list` because folders can be localized or renamed. Then add
aliases to the account block using actual server names:

```toml
folder.aliases.inbox = "INBOX"
folder.aliases.sent = "<sent-folder>"
folder.aliases.drafts = "<drafts-folder>"
folder.aliases.trash = "<trash-folder>"
folder.aliases.archive = "<archive-folder>"
```

Common defaults are:

| Provider | Sent | Drafts | Trash | Archive |
| --- | --- | --- | --- | --- |
| Gmail | `[Gmail]/Sent Mail` | `[Gmail]/Drafts` | `[Gmail]/Trash` | `[Gmail]/All Mail` |
| Fastmail | `Sent` | `Drafts` | `Trash` | `Archive` |
| iCloud | `Sent Messages` | `Drafts` | `Deleted Messages` | `Archive` |

Treat these as suggestions, not authority over `folder list`.
