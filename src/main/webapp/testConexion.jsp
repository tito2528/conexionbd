<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Test Conexión PostgreSQL</title>
</head>
<body>
    <h2>Resultado de conexión:</h2>
    <%
    Connection testConn = null;
    try {
        Class.forName("org.postgresql.Driver");
        testConn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_2025", 
            "postgres", 
            "admin");
        
        out.print("<p style='color:green'>¡Conexión exitosa!</p>");
        out.print("<p>Versión PostgreSQL: " + testConn.getMetaData().getDatabaseProductVersion() + "</p>");
        
    } catch (Exception e) {
        out.print("<p style='color:red'>Error: " + e.getMessage() + "</p>");
    } finally {
        if (testConn != null) try { testConn.close(); } catch (SQLException ignore) {}
    }
    %>
</body>
</html>