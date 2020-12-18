# `trombik.octoprint`

`ansible` role for `octoprint`.

# Requirements

- Python environment
- `virtualenv`

The role assumes `sudo` is used for `become_method` in `ansible`.

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `octoprint_user` | User name of `octoprint` | `{{ __octoprint_user }}` |
| `octoprint_group` | Group name of `octoprint` | `{{ __octoprint_group }}` |
| `octoprint_extra_groups` | List of extra groups that `octoprint` user belongs to | `{{ __octoprint_extra_groups }}` |
| `octoprint_package` | Package name of `octoprint` | `{{ __octoprint_package }}` |
| `octoprint_extra_packages` | List of extra packages to install | `{{ __octoprint_extra_packages }}` |
| `octoprint_home_dir` | Path to `$HOME` of `octoprint` user | `{{ __octoprint_home_dir }}` |
| `octoprint_dir` | Path to directory where `octoprint` is installed | `{{ octoprint_home_dir }}/octoprint` |
| `octoprint_service` | Service name of `octoprint` | `{{ __octoprint_service }}` |
| `octoprint_flags` | Additional flags for `octoprint` command (see below) | `""` |

## `octoprint_flags`

On FreeBSD, the content of `/etc/rc.conf.d/octoprint`.

On Ubuntu, the content of `/etc/default/octoprint`.

## Debian

| Variable | Default |
|----------|---------|
| `__octoprint_user` | `octoprint` |
| `__octoprint_group` | `octoprint` |
| `__octoprint_extra_groups` | `["dialout"]` |
| `__octoprint_package` | `octoprint` |
| `__octoprint_extra_packages` | `["python3-dev", "build-essential"]` |
| `__octoprint_home_dir` | `/home/octoprint` |
| `__octoprint_service` | `octoprint` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__octoprint_user` | `octoprint` |
| `__octoprint_group` | `octoprint` |
| `__octoprint_extra_groups` | `["dialer"]` |
| `__octoprint_package` | `octoprint` |
| `__octoprint_extra_packages` | `[]` |
| `__octoprint_home_dir` | `/usr/local/octoprint` |
| `__octoprint_service` | `octoprint` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - role: trombik.virtualenv
    - ansible-role-octoprint
  vars:
    os_octoprint_flags:
      FreeBSD: octoprint_extra_flags=-v
      Debian: EXTRA_FLAGS=-v
    octoprint_flags: "{{ os_octoprint_flags[ansible_os_family] }}"
```

# License

```
Copyright (c) 2020 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
