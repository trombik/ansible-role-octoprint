# `trombik.octoprint`

`ansible` role for `octoprint`.

This role is only useful when installing `octoprint` for the first time
because `octoprint` modifies `config.yaml`.

The role installs `octoprint` with `virtualenv`, not package system (probably
never will).

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
| `octoprint_config_dir` | Path to configuration directory | `{{ octoprint_home_dir }}/.octoprint` |
| `octoprint_service` | Service name of `octoprint` | `{{ __octoprint_service }}` |
| `octoprint_flags` | Additional flags for `octoprint` command (see below) | `""` |
| `octoprint_yaml_files` | List of configuration files in `YAML` format (see below) | `[]` |

## `octoprint_flags`

On FreeBSD, the content of `/etc/rc.conf.d/octoprint`.

On Ubuntu, the content of `/etc/default/octoprint`.

On OpenBSD, this variable does nothing.

## `octoprint_yaml_files`

A list of configuration files in `YAML` format.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `path` | Relative path from `octoprint_home_dir/.octoprint` | Yes |
| `mode` | Permission of the file | No |
| `content` | The content of the file | No |
| `state` | Either `present` or `absent` | No |

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

## OpenBSD

| Variable | Default |
|----------|---------|
| `__octoprint_user` | `_octoprint` |
| `__octoprint_group` | `_octoprint` |
| `__octoprint_extra_groups` | `["dialer"]` |
| `__octoprint_package` | `octoprint` |
| `__octoprint_extra_packages` | `[]` |
| `__octoprint_home_dir` | `/usr/local/octoprint` |
| `__octoprint_service` | `octoprint` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - role: trombik.virtualenv
    - ansible-role-octoprint
  vars:
    os_octoprint_flags:
      FreeBSD: octoprint_extra_flags=-v
      Debian: EXTRA_FLAGS=-v
      # XXX octoprint_extra_flags does not work on OpenBSD. see
      # tasks/install-OpenBSD.yml
      OpenBSD: ""
    octoprint_flags: "{{ os_octoprint_flags[ansible_os_family] }}"
    octoprint_yaml_files:
      - path: data/appkeys/keys.yaml
        mode: "0640"
        content:
          - api_key: B9B058659A154060833F317BD947A030
            app_id: cura
      - path: users.yaml
        content:
          root:
            active: true
            apikey: null
            groups:
              - admins
              - users
            # root
            password: accdeb2c4cf9536eba1bbc07d4128762d3391dc67a55b020c008fde5d0a6fb12605e090cd19da33a60d5ec850bb36c0328069834cb0013666ba9ccf2add83b4f
            permissions: []
            roles:
              - user
              - admin
            settings:
              interface:
                language: en
      - path: config.yaml
        mode: "0640"
        content:
          api:
            key: 5636381594984F8887F63F8E0CBD4F9D
          plugins:
            _disabled:
              - tracking
            announcements:
              _config_version: 1
            discovery:
              upnpUuid: a42d1309-7f45-4f59-ba85-777f511b3b3e
            errortracking:
              unique_id: 47891e2e-0233-4f81-8b27-a5c73b6d5786
            gcodeviewer:
              _config_version: 1
            softwareupdate:
              _config_version: 9
            virtual_printer:
              _config_version: 1
          printerProfiles:
            default: _default
          # XXX do not bind on [::]. otherwise, octoprint fails with the following
          # exception on OpenBSD.
          #
          # vagrantup octoprint:   File "/usr/local/octoprint/octoprint/lib/python3.7/site-packages/octoprint/server/__init__.py", line 2327, in __init__
          # vagrantup octoprint:     octoprint.util.net.IPPROTO_IPV6, octoprint.util.net.IPV6_V6ONLY, 0
          # vagrantup octoprint: OSError: [Errno 22] Invalid argument
          server:
            host: 0.0.0.0
            secretKey: XNOSFH7XP0cPrKNx5AQF8MysEfVjtGSQ
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
