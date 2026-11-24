import base64
import configparser
import importlib.util
import unittest
from pathlib import Path

from ansible.errors import AnsibleFilterError
from jinja2 import Environment, FileSystemLoader, StrictUndefined


ROOT = Path(__file__).resolve().parents[1]
ROLE = ROOT / "roles" / "debian"
PROFILE_UUID = "dae0afd7-18d5-56b1-a523-42f48c25c628"
MARKER = "# Managed by the Workstation Debian role"
LEGACY_MARKER = "# Managed by the Workstation Ubuntu role"


def key(byte):
    return base64.b64encode(bytes([byte]) * 32).decode()


def vault_values():
    return {
        "vault_wg_private_key": key(1),
        "vault_wg_peer_public_key": key(2),
        "vault_wg_preshared_key": key(3),
        "vault_wg_address": "192.0.2.20/32, 192.0.2.21/32, 2001:db8::20/128",
        "vault_wg_dns": "192.0.2.53, 2001:db8::53, lab.example",
        "vault_wg_endpoint": "[2001:db8::1]:51820",
        "vault_wg_persistent_keepalive": "25",
    }


class DebianWireGuardTest(unittest.TestCase):
    def filters(self):
        plugin_path = ROLE / "filter_plugins" / "debian_wireguard.py"
        self.assertTrue(plugin_path.is_file(), "The Debian WireGuard filter is missing")
        spec = importlib.util.spec_from_file_location("debian_wireguard", plugin_path)
        plugin = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(plugin)
        return plugin.FilterModule().filters()

    def profile(self, values):
        return self.filters()["debian_wireguard_profile"](values)

    def render(self, values):
        profile = self.profile(values)
        env = Environment(
            loader=FileSystemLoader(ROLE / "templates"),
            undefined=StrictUndefined,
            trim_blocks=True,
        )
        return env.get_template("wg0.nmconnection.j2").render(
            debian_wg_profile=profile,
            debian_wg_uuid=PROFILE_UUID,
            debian_wg_marker=MARKER,
        )

    def test_migration_recognizes_the_legacy_profile_without_claiming_other_files(self):
        filters = self.filters()
        self.assertIn("debian_wireguard_keyfile_owned", filters)
        owns_keyfile = filters["debian_wireguard_keyfile_owned"]
        current_profile = self.render(vault_values())
        self.assertTrue(owns_keyfile(current_profile, PROFILE_UUID, [MARKER, LEGACY_MARKER]))
        old_profile = current_profile.replace(MARKER, LEGACY_MARKER, 1)
        self.assertTrue(owns_keyfile(old_profile, PROFILE_UUID, [MARKER, LEGACY_MARKER]))
        other_owner = current_profile.replace(MARKER, MARKER + " copy", 1)
        self.assertFalse(owns_keyfile(other_owner, PROFILE_UUID, [MARKER, LEGACY_MARKER]))
        other_uuid = current_profile.replace(PROFILE_UUID, "24b4d385-4510-42b2-9eed-989e193d50cc", 1)
        self.assertFalse(owns_keyfile(other_uuid, PROFILE_UUID, [MARKER, LEGACY_MARKER]))

    def test_dual_stack_full_tunnel_is_manually_activated(self):
        profile = configparser.ConfigParser(interpolation=None)
        profile.read_string(self.render(vault_values()))
        self.assertEqual(profile["connection"]["interface-name"], "wg0")
        self.assertEqual(profile["connection"]["type"], "wireguard")
        self.assertFalse(profile["connection"].getboolean("autoconnect"))
        self.assertTrue(profile["wireguard"].getboolean("peer-routes"))
        self.assertEqual(profile["wireguard"]["private-key"], key(1))
        peer = profile[f"wireguard-peer.{key(2)}"]
        self.assertEqual(peer["allowed-ips"], "0.0.0.0/0;::/0;")
        self.assertEqual(peer["preshared-key"], key(3))
        self.assertEqual(peer["preshared-key-flags"], "0")
        self.assertEqual(peer["endpoint"], "[2001:db8::1]:51820")
        self.assertEqual(peer["persistent-keepalive"], "25")
        self.assertEqual(profile["ipv4"]["address1"], "192.0.2.20/32")
        self.assertEqual(profile["ipv4"]["address2"], "192.0.2.21/32")
        self.assertEqual(profile["ipv4"]["dns"], "192.0.2.53;")
        self.assertEqual(profile["ipv6"]["address1"], "2001:db8::20/128")
        self.assertEqual(profile["ipv6"]["dns"], "2001:db8::53;")
        self.assertEqual(profile["ipv4"]["dns-search"], "~.;lab.example;")

    def test_single_stack_and_optional_fields(self):
        values = vault_values()
        values.update(vault_wg_address="192.0.2.20", vault_wg_dns="192.0.2.53")
        del values["vault_wg_preshared_key"]
        del values["vault_wg_persistent_keepalive"]
        profile = configparser.ConfigParser(interpolation=None)
        profile.read_string(self.render(values))
        self.assertEqual(profile["ipv4"]["address1"], "192.0.2.20/32")
        self.assertEqual(dict(profile["ipv6"]), {"method": "disabled"})
        peer = profile[f"wireguard-peer.{key(2)}"]
        self.assertNotIn("preshared-key", peer)
        self.assertNotIn("persistent-keepalive", peer)

    def test_invalid_fields_are_rejected_without_echoing_values(self):
        invalid_values = {
            "vault_wg_private_key": "invalid-secret",
            "vault_wg_peer_public_key": "CHANGEME",
            "vault_wg_preshared_key": "CHANGEME",
            "vault_wg_address": "192.0.2.20/33",
            "vault_wg_dns": "192.0.2.53;bad=1",
            "vault_wg_endpoint": "example.org:70000",
            "vault_wg_persistent_keepalive": "65536",
        }
        for variable, value in invalid_values.items():
            with self.subTest(variable=variable):
                with self.assertRaises(AnsibleFilterError) as raised:
                    self.profile(vault_values() | {variable: value})
                self.assertIn(variable, str(raised.exception))
                self.assertNotIn(value, str(raised.exception))

    def test_networkmanager_can_parse_the_generated_keyfile(self):
        try:
            import gi

            gi.require_version("NM", "1.0")
            from gi.repository import GLib, NM
        except (ImportError, ValueError):
            self.skipTest("NetworkManager introspection bindings are unavailable")

        keyfile = GLib.KeyFile()
        content = self.render(vault_values())
        keyfile.load_from_data(content, len(content.encode()), GLib.KeyFileFlags.NONE)
        connection = NM.keyfile_read(keyfile, "/etc/NetworkManager/system-connections", 0)
        self.assertTrue(connection.verify())
        wireguard = connection.get_setting_by_name("wireguard")
        peer = wireguard.get_peer(0)
        self.assertEqual(peer.get_preshared_key(), key(3))
        self.assertEqual(wireguard.get_private_key(), key(1))


if __name__ == "__main__":
    unittest.main()
