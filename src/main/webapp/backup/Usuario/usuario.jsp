<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    Statement st = null;
    ResultSet rs = null;
    String tipo = request.getParameter("campo");
    String usuario = request.getParameter("usu_usuario");
    String password = request.getParameter("password");
    String nombre = request.getParameter("usu_nombre");
    String apellido = request.getParameter("usu_apellido");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Operación no especificada");
        return;
    }

    if (tipo.equals("guardar")) {
        try {
            st = conn.createStatement();
            String sql = "INSERT INTO usuario(usu_usuario, password, usu_nombre, usu_apellido) " +
                         "VALUES('" + usuario + "', '" + password + "', '" + nombre + "', '" + apellido + "')";
            st.executeUpdate(sql);
            out.println("Usuario registrado");
        } catch (SQLException e) {
            out.println("Error al registrar: " + e.getMessage());
        }
    } else if (tipo.equals("listar")) {
        try {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT id_usuario, usu_usuario, usu_nombre, usu_apellido FROM usuario ORDER BY id_usuario ASC");
            while (rs.next()) { 
%>
<tr>
    <td><%= rs.getInt("id_usuario") %></td>
    <td><%= rs.getString("usu_usuario") %></td>
    <td><%= rs.getString("usu_nombre") %></td>
    <td><%= rs.getString("usu_apellido") %></td>
    <td>
        <i class="fas fa-edit" style="color:green" 
           onclick="datosModif('<%= rs.getInt("id_usuario") %>', 
                  '<%= rs.getString("usu_usuario") %>',
                  '<%= rs.getString("usu_nombre") %>',
                  '<%= rs.getString("usu_apellido") %>')" 
           data-toggle="modal" data-target="#exampleModal"></i>
        <i class="fas fa-trash" style="color:red" 
           onclick="dell(<%= rs.getInt("id_usuario") %>)"></i>
    </td>
</tr>
<%
            }
        } catch (Exception e) {
            out.println("Error al listar: " + e.getMessage());
        }
    } else if (tipo.equals("modificar")) {
        try {
            st = conn.createStatement();
            String sql = "UPDATE usuario SET " +
                         "usu_usuario='" + usuario + "', " +
                         (password.isEmpty() ? "" : "password='" + password + "', ") +
                         "usu_nombre='" + nombre + "', " +
                         "usu_apellido='" + apellido + "' " +
                         "WHERE id_usuario=" + pk;
            st.executeUpdate(sql);
            out.println("Usuario actualizado");
        } catch (SQLException e) {
            out.println("Error al actualizar: " + e.getMessage());
        }
    } else if (tipo.equals("eliminar")) {
        try {
            st = conn.createStatement();
            st.executeUpdate("DELETE FROM usuario WHERE id_usuario=" + pk);
            out.println("Usuario eliminado");
        } catch (SQLException e) {
            out.println("Error al eliminar: " + e.getMessage());
        }
    }
%>