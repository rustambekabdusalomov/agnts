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


COLS = "id, name"


# Built in a variable first, as a repository layer does: reported where it
# runs (one finding with where it is built), also inside a with block.
async def create(conn, name):
    # ruleid: agnts.py.sqli.formatted-execute
    q = ("INSERT INTO students (name) "
         "VALUES ('%(name)s')" % {"name": name})
    async with conn.cursor() as cur:
        # ruleid: agnts.py.sqli.formatted-execute
        await cur.execute(q)


def search(cur, session, Product, q, sort):
    # ruleid: agnts.py.sqli.formatted-execute
    sql = "SELECT * FROM products ORDER BY " + sort
    # ruleid: agnts.py.sqli.formatted-execute
    cur.execute(sql)
    # ruleid: agnts.py.sqli.formatted-execute
    by_name = "SELECT * FROM products WHERE name = '{}'".format(q)
    # ruleid: agnts.py.sqli.formatted-execute
    cur.execute(by_name)
    # ruleid: agnts.py.sqli.formatted-execute
    cur.execute("SELECT * FROM products WHERE name = '" + q + "'")
    # ruleid: agnts.py.sqli.formatted-execute
    session.execute(text(f"SELECT * FROM products WHERE name = '{q}'"))
    # ruleid: agnts.py.sqli.formatted-execute
    Product.objects.raw("SELECT * FROM shop_product WHERE name = '" + q + "'")


def safe_queries(cur, q, id):
    # ok: agnts.py.sqli.formatted-execute
    cur.execute("SELECT * FROM products WHERE name LIKE %s", (f"%{q}%",))
    # ok: agnts.py.sqli.formatted-execute
    cur.execute("SELECT " + COLS + " FROM products WHERE id = %s", (id,))
    # ok: agnts.py.sqli.formatted-execute
    cur.execute(f"SELECT {COLS} FROM products WHERE id = %s", (id,))


# Built here, run by a helper: reported where it is built.
def by_owner(owner):
    # ruleid: agnts.py.sqli.formatted-execute
    sql = f"SELECT * FROM orders WHERE owner = '{owner}'"
    return run(sql)
