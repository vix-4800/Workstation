"""Validate the shared WireGuard vault values before writing a keyfile."""

import base64
import binascii
import ipaddress
import re

from ansible.errors import AnsibleFilterError


def _invalid(name, expectation):
    return AnsibleFilterError(f"{name} {expectation}")


def _key(values, name, optional=False):
    value = values.get(name, "")
    if optional and value == "":
        return ""
    if isinstance(value, str):
        try:
            decoded = base64.b64decode(value, validate=True)
            if len(decoded) == 32 and base64.b64encode(decoded).decode() == value:
                return value
        except (binascii.Error, ValueError):
            pass
    raise _invalid(name, "must be a base64-encoded WireGuard key")


def _entries(values, name):
    value = values.get(name)
    if not isinstance(value, str) or not value.strip():
        raise _invalid(name, "must be a nonempty comma-separated string")
    return [entry.strip() for entry in value.split(",")]


def _hostname(value):
    return (
        len(value.rstrip(".")) <= 253
        and all(
            re.fullmatch(r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?", label)
            for label in value.removesuffix(".").split(".")
        )
    )


def _endpoint(value):
    if isinstance(value, str):
        match = re.fullmatch(r"(?:\[([A-Fa-f0-9:.]+(?:%[A-Za-z0-9_.-]+)?)\]|([A-Za-z0-9.-]+)):([0-9]{1,5})", value)
        if match and 1 <= int(match[3]) <= 65535:
            if match[2] and _hostname(match[2]):
                return value
            if match[1]:
                try:
                    ipaddress.IPv6Address(match[1])
                    return value
                except ValueError:
                    pass
    raise _invalid("vault_wg_endpoint", "must contain a host and a port from 1 to 65535")


def _keepalive(value):
    if value == "off":
        return 0
    if re.fullmatch(r"[0-9]{1,5}", str(value)) and int(value) <= 65535:
        return int(value)
    raise _invalid("vault_wg_persistent_keepalive", "must be off or an integer from 0 to 65535")


def debian_wireguard_profile(values):
    families = {
        "ipv4": {"addresses": [], "dns": []},
        "ipv6": {"addresses": [], "dns": []},
    }
    for value in _entries(values, "vault_wg_address"):
        try:
            address = ipaddress.ip_interface(value)
            if "%" in value:
                raise ValueError
        except ValueError:
            raise _invalid("vault_wg_address", "must contain only IP addresses or CIDRs") from None
        families[f"ipv{address.version}"]["addresses"].append(str(address))

    dns_search = ["~."]
    for value in _entries(values, "vault_wg_dns"):
        try:
            address = ipaddress.ip_address(value)
        except ValueError:
            if not _hostname(value.removeprefix("~")) and value != "~.":
                raise _invalid("vault_wg_dns", "must contain IP addresses or DNS domains") from None
            if value not in dns_search:
                dns_search.append(value)
        else:
            if "%" in value:
                raise _invalid("vault_wg_dns", "must contain unscoped IP addresses or DNS domains")
            families[f"ipv{address.version}"]["dns"].append(str(address))

    if not any(config["addresses"] and config["dns"] for config in families.values()):
        raise _invalid("vault_wg_dns", "must have a DNS server matching a configured IP address family")

    return {
        "families": families,
        "dns_search": dns_search,
        "private_key": _key(values, "vault_wg_private_key"),
        "peer_public_key": _key(values, "vault_wg_peer_public_key"),
        "preshared_key": _key(values, "vault_wg_preshared_key", optional=True),
        "endpoint": _endpoint(values.get("vault_wg_endpoint")),
        "keepalive": _keepalive(values.get("vault_wg_persistent_keepalive", 0)),
    }


def debian_wireguard_keyfile_owned(contents, uuid, markers):
    lines = contents.splitlines()
    return bool(lines and lines[0] in markers and f"uuid={uuid}" in lines)


class FilterModule:
    def filters(self):
        return {
            "debian_wireguard_profile": debian_wireguard_profile,
            "debian_wireguard_keyfile_owned": debian_wireguard_keyfile_owned,
        }
