<?php
function sqli($conn) {
    $id = $_GET['id'];
    // ruleid: agnts.php.sqli.request-into-query, agnts.php.sqli.concat-query
    mysqli_query($conn, "SELECT * FROM users WHERE id = " . $id);
    // ok: agnts.php.sqli.request-into-query, agnts.php.sqli.concat-query
    mysqli_query($conn, "SELECT * FROM users WHERE id = " . intval($_GET['id']));
}

const COLS = "id, name";

// A repository method builds the query from its parameters.
class ProductRepo {
    public function search($q) {
        // ruleid: agnts.php.sqli.concat-query
        return $this->db->query("SELECT * FROM products WHERE name = '" . $q . "'");
    }
    public function sorted($sort) {
        // ruleid: agnts.php.sqli.concat-query
        $sql = "SELECT * FROM products ORDER BY " . $sort;
        // ruleid: agnts.php.sqli.concat-query
        return $this->pdo->query($sql);
    }
    public function byName($name) {
        // ruleid: agnts.php.sqli.concat-query
        $sql = "SELECT * FROM products WHERE name = '$name'";
        // ruleid: agnts.php.sqli.concat-query
        return mysqli_query($this->conn, $sql);
    }
    public function laravel($q) {
        // ruleid: agnts.php.sqli.concat-query
        DB::select("SELECT * FROM products WHERE name = '" . $q . "'");
        // ruleid: agnts.php.sqli.concat-query
        return Product::query()->whereRaw("name = '" . $q . "'")->get();
    }
    public function prepared($q) {
        // ruleid: agnts.php.sqli.concat-query
        return $this->pdo->prepare("SELECT * FROM products WHERE name = '" . $q . "'");
    }
    public function safe($q, $id) {
        // ok: agnts.php.sqli.concat-query
        $st = $this->pdo->prepare("SELECT * FROM products WHERE name = ?");
        $st->execute([$q]);
        // ok: agnts.php.sqli.concat-query
        $this->pdo->query("SELECT " . COLS . " FROM products");
        // ok: agnts.php.sqli.concat-query
        return $this->pdo->query("SELECT * FROM products WHERE id = " . (int) $id);
    }
}

function code($s) {
    // ruleid: agnts.php.code.eval
    eval($s);
}

function cmd() {
    // ruleid: agnts.php.cmdi.shell-with-input
    system("ls " . $_GET['dir']);
    // ok: agnts.php.cmdi.shell-with-input
    system("ls " . escapeshellarg($_GET['dir']));
}
