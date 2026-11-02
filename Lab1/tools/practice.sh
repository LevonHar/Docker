set -e
echo "===== whoami / id ====="
whoami
id
echo "===== hostname / date / uptime ====="
hostname
date
uptime
echo "===== uname ====="
uname -a
echo "===== os-release ====="
cat /etc/os-release
echo "===== pwd / ls ====="
pwd
ls -la
echo "===== filesystem navigation ====="
mkdir -p ~/lab/notes
echo "Hello from Ubuntu Server" > ~/lab/notes/hello.txt
cp ~/lab/notes/hello.txt ~/lab/notes/hello-copy.txt
mv ~/lab/notes/hello-copy.txt ~/lab/notes/renamed.txt
echo "-- hello.txt --"
cat ~/lab/notes/hello.txt
ls -la ~/lab/notes
rm ~/lab/notes/renamed.txt
echo "-- after rm --"
ls -la ~/lab/notes
echo "===== disk / memory ====="
df -h
free -h
echo "===== network ====="
ip -br addr
echo "===== processes ====="
ps -ef | head -n 12
echo "===== practice done ====="
