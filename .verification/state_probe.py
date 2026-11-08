import json, os, subprocess, sys, time, urllib.request

root = r'd:\YASIN_WORKSHOP'
port = 5090
pid_file = os.path.join(root, '.verification', 'runtime', 'api.pid.txt')

print('PIDFILE=')
if os.path.exists(pid_file):
    print(open(pid_file, 'r', encoding='utf-8').read().strip())
else:
    print('MISSING')

print('---')
cmd = ['powershell', '-NoProfile', '-Command', 'Get-NetTCPConnection -LocalPort 5090 -ErrorAction SilentlyContinue | Format-Table -AutoSize']
res = subprocess.run(cmd, capture_output=True, text=True)
print(res.stdout or res.stderr or 'NO_OUTPUT')
print('---')

url = 'http://127.0.0.1:5090/health'
try:
    req = urllib.request.Request(url, method='GET')
    with urllib.request.urlopen(req, timeout=10) as resp:
        body = resp.read().decode('utf-8', errors='replace')
        print('STATUS=' + str(resp.status))
        print('BODY=' + body)
except Exception as ex:
    print('HEALTH_FAILED=' + str(ex))
