import pathlib
import pycdlib

root = pathlib.Path(r"D:\Docker\Lab1")
pub = (root / "keys" / "lab_ed25519.pub").read_text(encoding="utf-8").strip()
vm = root / "vm"

user_data = f"""#cloud-config
hostname: ubuntu-server
fqdn: ubuntu-server.lab
manage_etc_hosts: true
ssh_authorized_keys:
  - {pub}
disable_root: true
ssh_pwauth: false
package_update: false
package_upgrade: false
growpart:
  mode: auto
  devices: ['/']
  ignore_growroot_disabled: false
resize_rootfs: true
runcmd:
  - [ sh, -c, "echo cloud-init-done > /var/tmp/cloud-init-done" ]
"""

meta_data = """instance-id: lab1-ubuntu-01
local-hostname: ubuntu-server
"""

network_config = """version: 2
ethernets:
  nic0:
    match:
      driver: virtio*
    dhcp4: true
    dhcp6: false
"""

files = {
    "user-data": user_data,
    "meta-data": meta_data,
    "network-config": network_config,
}
for name, text in files.items():
    (vm / name).write_bytes(text.encode("utf-8"))

iso = pycdlib.PyCdlib()
iso.new(interchange_level=3, joliet=3, rock_ridge="1.09", vol_ident="cidata")
iso.add_file(
    str(vm / "user-data"),
    iso_path="/USER_DAT.;1",
    rr_name="user-data",
    joliet_path="/user-data",
)
iso.add_file(
    str(vm / "meta-data"),
    iso_path="/META_DAT.;1",
    rr_name="meta-data",
    joliet_path="/meta-data",
)
iso.add_file(
    str(vm / "network-config"),
    iso_path="/NETWORK.;1",
    rr_name="network-config",
    joliet_path="/network-config",
)
seed = vm / "seed.iso"
if seed.exists():
    seed.unlink()
iso.write(str(seed))
iso.close()
print(f"wrote {seed} ({seed.stat().st_size} bytes)")
