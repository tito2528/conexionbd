<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    Statement st = null;
    ResultSet rs = null;
    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("suc_nombre");
    String direccion = request.getParameter("suc_direccion");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Operación no especificada");
        return;
    }

    if (tipo.equals("guardar")) {
        try {
            st = conn.createStatement();
            String sql = "INSERT INTO sucursal(suc_nombre, suc_direccion) " +
                         "VALUES('" + nombre + "', '" + direccion + "')";
            st.executeUpdate(sql);
            out.println("Sucursal registrada");
        } catch (SQLException e) {
            out.println("Error al registrar: " + e.getMessage());
        }
    } else if (tipo.equals("listar")) {
        try {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT * FROM sucursal ORDER BY id_sucursal ASC");
            while (rs.next()) { 
%>
<tr>
    <td><%= rs.getInt("id_sucursal") %></td>
    <td><%= rs.getString("suc_nombre") %></td>
    <td><%= rs.getString("suc_direccion") %></td>
    <td>
        <i class="fas fa-edit" style="color:green" 
           onclick="datosModif('<%= rs.getInt("id_sucursal") %>', 
                  '<%= rs.getString("suc_nombre") %>',
                  '<%= rs.getString("suc_direccion") %>')" 
           data-toggle="modal" data-target="#exampleModal"></i>
        <i class="fas fa-trash" style="color:red" 
           onclick="dell(<%= rs.getInt("id_sucursal") %>)"></i>
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
            String sql = "UPDATE sucursal SET " +
                         "suc_nombre='" + nombre + "', " +
                         "suc_direccion='" + direccion + "' " +
                         "WHERE id_sucursal=" + pk;
            st.executeUpdate(sql);
            out.println("Sucursal actualizada");
        } catch (SQLException e) {
            out.println("Error al actualizar: " + e.getMessage());
        }
    } else if (tipo.equals("eliminar")) {
        try {
            st = conn.createStatement();
            st.executeUpdate("DELETE FROM sucursal WHERE id_sucursal=" + pk);
            out.println("Sucursal eliminada");
        } catch (SQLException e) {
            out.println("Error al eliminar: " + e.getMessage());
        }
    }
%>