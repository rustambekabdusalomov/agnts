import os
import pickle
import subprocess

import requests
import yaml


def sqli(cur, name):
    # ruleid: agnts.py.sqli.formatted-execute
    cur.execute(f"SELECT * FROM users WHERE name = '{name}'")
    # ok: agnts.py.sqli.formatted-execute
    cur.execute("SELECT * FROM users WHERE name = %s", (name,))


def cmd(name):
    # ruleid: agnts.py.cmdi.shell-true
    subprocess.run("ls " + name, shell=True)
    # ok: agnts.py.cmdi.shell-true
    subprocess.run(["ls", name])
    # ruleid: agnts.py.cmdi.shell-true
    os.system("rm " + name)


def load(data):
    # ruleid: agnts.py.deser.unsafe-load
    pickle.loads(data)
    # ruleid: agnts.py.deser.unsafe-load
    yaml.load(data)
    # ok: agnts.py.deser.unsafe-load
    yaml.load(data, Loader=yaml.SafeLoader)


def code(s):
    # ruleid: agnts.py.code.eval
    eval(s)


def fetch(url):
    # ruleid: agnts.py.tls.verify-false
    requests.get(url, verify=False)
    # ok: agnts.py.tls.verify-false
    requests.get(url)


def serve(app):
    # ruleid: agnts.py.config.flask-debug
    app.run(host="0.0.0.0", debug=True)
