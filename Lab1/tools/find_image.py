import re
import urllib.request

html = urllib.request.urlopen(
    "https://cloud-images.ubuntu.com/releases/", timeout=60
).read().decode("utf-8", "replace")
for match in re.finditer(
    r'href="(\d+\.\d+)/">[^<]*</a>\s+([0-9-]+ [0-9:]+)\s+-\s+([^<\n]+)',
    html,
):
    version, modified, desc = match.group(1), match.group(2), match.group(3).strip()
    if version.startswith(("22.04", "24.04", "25.", "26.")):
        print(f"{version} | {modified} | {desc}")
