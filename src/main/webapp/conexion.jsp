<%-- 
    Document   : conexion
    Created on : 1 abr. 2025, 17:50:03
    Author     : Tito Pane
--%>

<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>

<%
    Connection conn = null;

    try {
        // Cargar el controlador JDBC de PostgreSQL
        Class.forName("org.postgresql.Driver");

        // Establecer la conexión con la base de datos
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin");

        if (conn != null) {
            //out.print("Conexión exitosa a PostgreSQL 12.5");
        }
    } catch (ClassNotFoundException e) {
        out.print("Error: No se encontró el driver de PostgreSQL. " + e.getMessage());
    } catch (SQLException e) {
        out.print("Error de conexión: " + e.getMessage());
    } /*finally {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                out.print("Error al cerrar la conexión: " + e.getMessage());
            }
        }
    }*/
%>