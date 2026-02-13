# bcrail
The BCRail environment for Flatcar Docker container runners. 🛤️

## Subcommands

### `bcrail setcontext [context] [flatcar_version]`

Initializes a context under `${BCRAIL_STATE_DIR}/contexts/<context>` and stores it as the active context in `~/.bcrail`.

- `context`: optional, defaults to `default`
- `flatcar_version`: optional image selector for `local:flatcar/<version>`, defaults to `current`

What it does:

1. Loads environment from `${BCRAIL_LOCOMOTIVE_ENV}` when present.
2. Creates context directories (`stacks`, `keys`, `config`) and SSH keys.
3. Generates context-specific Ignition config from `${BCRAIL_CONFIG_DIR}/ignition.json`.
4. Creates/starts the Incus VM `bcrail-<context>` from profile `bcrail`.
5. Ensures and attaches a block storage volume named `bcrail-<context>-state`.

Example:

```bash
bcrail setcontext default current
```

### `bcrail getcontext`

Prints the current context name from `~/.bcrail`.

- Returns `default` when no context has been set yet.

Example:

```bash
bcrail getcontext
```

### `bcrail resolve-incus-dns <instance>`

Resolves the current IPv4 address for an Incus instance name.

Example:

```bash
bcrail resolve-incus-dns bcrail-default
```

### `bcrail config`

Prints the resolved runtime configuration as `KEY=value` lines.

Output fields:

- `BCRAIL_STATE_DIR`
- `BCRAIL_CONFIG_DIR`
- `BCRAIL_LOCOMOTIVE_ENV`
- `BCRAIL_LOCOMOTIVE_ENV_LOADED` (`yes`/`no`)
- `BCRAIL_NETWORK_BRIDGE`
- `BCRAIL_STORAGE_POOL`

Example:

```bash
bcrail config
```

## Configuration

`bcrail` reads environment variables in this order:

1. Process environment.
2. `${BCRAIL_LOCOMOTIVE_ENV:-/etc/bcrail/locomotive.env}` if present.
3. Built-in defaults.

Relevant variables:

- `BCRAIL_NETWORK_BRIDGE` (default: `incusbr0`)
- `BCRAIL_STORAGE_POOL` (default: `default`)
- `BCRAIL_STATE_DIR` (default: `/var/lib/bcrail`)
- `BCRAIL_CONFIG_DIR` (default: `/etc/bcrail`)
- `BCRAIL_CONTEXT_FILE` (default: `~/.bcrail`)

Show the effective resolved values with:

```bash
bcrail config
```
