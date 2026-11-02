import re
import urllib.request

url = "https://cloud-images.ubuntu.com/releases/26.04/release/"
html = urllib.request.urlopen(url, timeout=60).read().decode("utf-8", "replace")
names = sorted(set(re.findall(r'href="([^"]+)"', html)))
for name in names:
    if "amd64" in name and name.endswith((".img", ".img.manifest", ".vmdk")):
        print(name)
