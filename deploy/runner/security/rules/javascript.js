const cp = require("child_process");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");

const COLS = "id, name";

async function sqli(db, id) {
  // ruleid: agnts.js.sqli.template-query
  await db.query(`SELECT * FROM users WHERE id = ${id}`);
  // ok: agnts.js.sqli.template-query
  await db.query("SELECT * FROM users WHERE id = $1", [id]);
}

// Built in a variable first, as a repository layer does: reported where
// it is built and where it runs (one finding), also inside a try block.
async function search(pool, q, sort) {
  // ruleid: agnts.js.sqli.template-query
  const sql = `SELECT ${COLS} FROM products WHERE name ILIKE '%${q}%' ORDER BY id`;
  // ruleid: agnts.js.sqli.template-query
  await pool.query(sql);
  // ruleid: agnts.js.sqli.template-query
  let byName = "SELECT * FROM products ORDER BY " + sort;
  try {
    // ruleid: agnts.js.sqli.template-query
    await pool.query(byName);
  } catch (e) {
    throw e;
  }
  // ruleid: agnts.js.sqli.template-query
  await pool.query("SELECT * FROM products WHERE name = '" + q + "'");
}

async function safeQueries(db, q, id) {
  // ok: agnts.js.sqli.template-query
  await db.query("SELECT " + COLS + " FROM products WHERE id = $1", [id]);
  // ok: agnts.js.sqli.template-query
  await db.query("SELECT * FROM products WHERE name ILIKE $1", [`%${q}%`]);
  // ok: agnts.js.sqli.template-query
  const sql = `SELECT ${COLS} FROM products WHERE id = $1`;
  await db.query(sql, [id]);
}

// The query inside a handler is reported once, on the query; the handler
// passed to router.get is not a query.
function routes(router, db) {
  // ruleid: agnts.js.sqli.template-query
  router.get("/", async (req, res) => res.json(await db.query("SELECT * FROM t WHERE a = '" + req.query.a + "'")));
}

function cmd(name) {
  // ruleid: agnts.js.cmdi.exec-with-input
  cp.exec("ls " + name);
  // ok: agnts.js.cmdi.exec-with-input
  cp.exec("ls -la");
}

function code(s) {
  // ruleid: agnts.js.code.eval
  eval(s);
  // ok: agnts.js.code.eval
  eval("1 + 1");
}

function handler(req, res) {
  // ruleid: agnts.js.xss.request-into-response
  res.send("<h1>Hello " + req.query.name + "</h1>");
  // ok: agnts.js.xss.request-into-response
  res.send(JSON.stringify(req.query));
}

function auth(token) {
  // ruleid: agnts.js.jwt.verify-without-algorithms
  return jwt.decode(token);
}

function hash(s) {
  // ruleid: agnts.js.crypto.weak-hash
  return crypto.createHash("md5").update(s).digest("hex");
}

// Built here, run by a helper: reported where it is built.
function byOwner(owner) {
  // ruleid: agnts.js.sqli.template-query
  const sql = "SELECT * FROM orders WHERE owner = '" + owner + "'";
  return run(sql);
}
