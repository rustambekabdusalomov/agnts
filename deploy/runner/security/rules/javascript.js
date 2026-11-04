const cp = require("child_process");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");

async function sqli(db, id) {
  // ruleid: agnts.js.sqli.template-query
  await db.query(`SELECT * FROM users WHERE id = ${id}`);
  // ok: agnts.js.sqli.template-query
  await db.query("SELECT * FROM users WHERE id = $1", [id]);
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
