<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    Statement st = null;
    ResultSet rs = null;
    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("ser_nombre");
    String precio = request.getParameter("ser_precio");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Operación no especificada");
        return;
    }

    if (tipo.equals("guardar")) {
        try {
            st = conn.createStatement();
            String sql = "INSERT INTO servicio(ser_nombre, ser_precio) VALUES('" + nombre + "', " + precio + ")";
            st.executeUpdate(sql);
            out.println("Servicio registrado");
        } catch (SQLException e) {
            out.println("Error al registrar: " + e.getMessage());
        }
    } else if (tipo.equals("listar")) {
        try {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT * FROM servicio ORDER BY id_servicio ASC");
            while (rs.next()) { 
%>
<tr>
    <td><%= rs.getInt("id_servicio") %></td>
    <td><%= rs.getString("ser_nombre") %></td>
    <td>$<%= rs.getBigDecimal("ser_precio") %></td>
    <td>
        <i class="fas fa-edit" style="color:green" 
           onclick="datosModif('<%= rs.getInt("id_servicio") %>', 
                  '<%= rs.getString("ser_nombre") %>',
                  '<%= rs.getBigDecimal("ser_precio") %>')" 
           data-toggle="modal" data-target="#exampleModal"></i>
        <i class="fas fa-trash" style="color:red" 
           onclick="dell(<%= rs.getInt("id_servicio") %>)"></i>
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
            String sql = "UPDATE servicio SET " +
                         "ser_nombre='" + nombre + "', " +
                         "ser_precio=" + precio + " " +
                         "WHERE id_servicio=" + pk;
            st.executeUpdate(sql);
            out.println("Servicio actualizado");
        } catch (SQLException e) {
            out.println("Error al actualizar: " + e.getMessage());
        }
    } else if (tipo.equals("eliminar")) {
        try {
            st = conn.createStatement();
            st.executeUpdate("DELETE FROM servicio WHERE id_servicio=" + pk);
            out.println("Servicio eliminado");
        } catch (SQLException e) {
            out.println("Error al eliminar: " + e.getMessage());
        }
    }
%>