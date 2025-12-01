<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    Statement st = null;
    ResultSet rs = null;
    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("prof_nombre");
    String apellido = request.getParameter("prof_apellido");
    String telefono = request.getParameter("prof_telefono");
    String email = request.getParameter("prof_email");
    String idEspecialidad = request.getParameter("id_especialidad");
    String idSucursal = request.getParameter("id_sucursal");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Operación no especificada");
        return;
    }

    if (tipo.equals("guardar")) {
        try {
            st = conn.createStatement();
            String sql = "INSERT INTO profesional(prof_nombre, prof_apellido, prof_telefono, " +
                        "prof_email, id_especialidad, id_sucursal) VALUES('" + 
                        nombre + "', '" + apellido + "', '" + telefono + "', '" + 
                        email + "', " + 
                        (idEspecialidad.isEmpty() ? "NULL" : idEspecialidad) + ", " + 
                        (idSucursal.isEmpty() ? "NULL" : idSucursal) + ")";
            st.executeUpdate(sql);
            out.println("Profesional registrado");
        } catch (SQLException e) {
            out.println("Error al registrar: " + e.getMessage());
        }
    } else if (tipo.equals("listar")) {
        try {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT p.id_profesional, p.prof_nombre, p.prof_apellido, " +
                               "p.prof_telefono, p.prof_email, e.espe_nombre as especialidad, " +
                               "s.suc_nombre as sucursal, p.id_especialidad, p.id_sucursal " +
                               "FROM profesional p " +
                               "LEFT JOIN especialidades e ON p.id_especialidad = e.id_especialidad " +
                               "LEFT JOIN sucursal s ON p.id_sucursal = s.id_sucursal " +
                               "ORDER BY p.id_profesional ASC");
            while (rs.next()) { 
%>
<tr>
    <td><%= rs.getInt("id_profesional") %></td>
    <td><%= rs.getString("prof_nombre") %></td>
    <td><%= rs.getString("prof_apellido") %></td>
    <td><%= rs.getString("prof_telefono") %></td>
    <td><%= rs.getString("prof_email") %></td>
    <td><%= rs.getString("especialidad) %></td>
    <td><%= rs.getString("sucursal") %></td>
    <td>
        <i class="fas fa-edit" style="color:green" 
           onclick="datosModif('<%= rs.getInt("id_profesional") %>', 
                  '<%= rs.getString("prof_nombre") %>',
                  '<%= rs.getString("prof_apellido") %>',
                  '<%= rs.getString("prof_telefono") %>',
                  '<%= rs.getString("prof_email") %>',
                  '<%= rs.getObject("id_especialidad") != null ? rs.getInt("id_especialidad") : "" %>',
                  '<%= rs.getObject("id_sucursal") != null ? rs.getInt("id_sucursal") : "" %>')" 
           data-toggle="modal" data-target="#exampleModal"></i>
        <i class="fas fa-trash" style="color:red" 
           onclick="dell(<%= rs.getInt("id_profesional") %>)"></i>
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
            String sql = "UPDATE profesional SET " +
                        "prof_nombre='" + nombre + "', " +
                        "prof_apellido='" + apellido + "', " +
                        "prof_telefono='" + telefono + "', " +
                        "prof_email='" + email + "', " +
                        "id_especialidad=" + (idEspecialidad.isEmpty() ? "NULL" : idEspecialidad) + ", " +
                        "id_sucursal=" + (idSucursal.isEmpty() ? "NULL" : idSucursal) + " " +
                        "WHERE id_profesional=" + pk;
            st.executeUpdate(sql);
            out.println("Profesional actualizado");
        } catch (SQLException e) {
            out.println("Error al actualizar: " + e.getMessage());
        }
    } else if (tipo.equals("eliminar")) {
        try {
            st = conn.createStatement();
            st.executeUpdate("DELETE FROM profesional WHERE id_profesional=" + pk);
            out.println("Profesional eliminado");
        } catch (SQLException e) {
            out.println("Error al eliminar: " + e.getMessage());
        }
    }
%>