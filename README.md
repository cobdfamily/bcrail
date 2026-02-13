# bcrail
The BCRail environment for Flatcar Docker container runners. 🛤️

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

Show the effective resolved values with:

```bash
bcrail config
```
