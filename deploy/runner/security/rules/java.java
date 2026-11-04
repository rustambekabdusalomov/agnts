import java.security.MessageDigest;
import java.sql.Statement;

class Rules {
    void sqli(Statement st, String name) throws Exception {
        // ruleid: agnts.java.sqli.concat-statement
        st.executeQuery("SELECT * FROM users WHERE name = '" + name + "'");
        // ok: agnts.java.sqli.concat-statement
        st.executeQuery("SELECT * FROM users");
    }

    void cmd(String name) throws Exception {
        // ruleid: agnts.java.cmdi.runtime-exec
        Runtime.getRuntime().exec("ls " + name);
        // ok: agnts.java.cmdi.runtime-exec
        Runtime.getRuntime().exec("ls");
    }

    void hash() throws Exception {
        // ruleid: agnts.java.crypto.weak-hash
        MessageDigest.getInstance("MD5");
        // ok: agnts.java.crypto.weak-hash
        MessageDigest.getInstance("SHA-256");
    }
}
