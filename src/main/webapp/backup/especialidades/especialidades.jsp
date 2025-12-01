<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    Statement st = null;
    ResultSet rs = null;
    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("espe_nombre");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Operación no especificada");
        return;
    }

    if (tipo.equals("guardar")) {
        try {
            st = conn.createStatement();
            st.executeUpdate("INSERT INTO especialidades(espe_nombre) VALUES('" + nombre + "')");
            out.println("Especialidad registrada");
        } catch (SQLException e) {
            out.println("Error al registrar: " + e.getMessage());
        }
    } else if (tipo.equals("listar")) {
        try {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT * FROM especialidades ORDER BY id_especialidad ASC");
            while (rs.next()) { 
%>
<tr>
    <td><%= rs.getInt("id_especialidad") %></td>
    <td><%= rs.getString("espe_nombre") %></td>
    <td>
        <i class="fas fa-edit" style="color:green" 
           onclick="datosModif('<%= rs.getInt("id_especialidad") %>', 
                  '<%= rs.getString("espe_nombre") %>')" 
           data-toggle="modal" data-target="#exampleModal"></i>
        <i class="fas fa-trash" style="color:red" 
           onclick="dell(<%= rs.getInt("id_especialidad") %>)"></i>
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
            st.executeUpdate("UPDATE especialidades SET espe_nombre='" + nombre + "' WHERE id_especialidad=" + pk);
            out.println("Especialidad actualizada");
        } catch (SQLException e) {
            out.println("Error al actualizar: " + e.getMessage());
        }
    } else if (tipo.equals("eliminar")) {
        try {
            st = conn.createStatement();
            st.executeUpdate("DELETE FROM especialidades WHERE id_especialidad=" + pk);
            out.println("Especialidad eliminada");
        } catch (SQLException e) {
            out.println("Error al eliminar: " + e.getMessage());
        }
    }
%>