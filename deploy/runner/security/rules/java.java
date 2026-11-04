import java.security.MessageDigest;
import java.sql.Statement;

class Rules {
    void sqli(Statement st, String name) throws Exception {
        // ruleid: agnts.java.sqli.concat-statement
        st.executeQuery("SELECT * FROM users WHERE name = '" + name + "'");
        // ok: agnts.java.sqli.concat-statement
        st.executeQuery("SELECT * FROM users");
    }

    private static final String COLS = "id, name";
    private java.sql.Connection conn;
    private org.springframework.jdbc.core.JdbcTemplate jdbc;
    private javax.persistence.EntityManager em;

    // Built in a variable first, run inside a try block; Spring and JPA.
    void repository(String q, String sort) throws Exception {
        // ruleid: agnts.java.sqli.concat-statement
        String sql = "SELECT * FROM products ORDER BY " + sort;
        try (Statement st = conn.createStatement()) {
            // ruleid: agnts.java.sqli.concat-statement
            st.executeQuery(sql);
        }
        // ruleid: agnts.java.sqli.concat-statement
        jdbc.queryForList("SELECT * FROM products WHERE name = '" + q + "'");
        // ruleid: agnts.java.sqli.concat-statement
        em.createQuery("FROM Product p WHERE p.name = '" + q + "'");
        // ruleid: agnts.java.sqli.concat-statement
        conn.prepareStatement("SELECT * FROM products WHERE name = '" + q + "'");
        // ruleid: agnts.java.sqli.concat-statement
        conn.createStatement().execute("SET SCHEMA \"" + q + "\"");
    }

    // Built here, run by a helper: reported where it is built.
    Object byOwner(String owner) throws Exception {
        // ruleid: agnts.java.sqli.concat-statement
        String query = "SELECT * FROM orders WHERE owner = '" + owner + "'";
        return run(query);
    }

    void safe(String q, Runnable job, java.util.concurrent.Executor ex) throws Exception {
        // ok: agnts.java.sqli.concat-statement
        java.sql.PreparedStatement ps = conn.prepareStatement("SELECT * FROM products WHERE name = ?");
        ps.setString(1, q);
        // ok: agnts.java.sqli.concat-statement
        conn.createStatement().executeQuery("SELECT " + COLS + " FROM products");
        // ok: agnts.java.sqli.concat-statement
        ex.execute(() -> log("deleted from cart: " + q));
    }

    Object run(String q) { return null; }
    void log(String s) {}

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
