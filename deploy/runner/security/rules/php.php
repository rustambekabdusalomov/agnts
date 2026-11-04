<?php
function sqli($conn) {
    $id = $_GET['id'];
    // ruleid: agnts.php.sqli.request-into-query
    mysqli_query($conn, "SELECT * FROM users WHERE id = " . $id);
    // ok: agnts.php.sqli.request-into-query
    mysqli_query($conn, "SELECT * FROM users WHERE id = " . intval($_GET['id']));
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
