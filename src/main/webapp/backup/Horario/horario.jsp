<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    Statement st = null;
    ResultSet rs = null;
    String tipo = request.getParameter("campo");
    String horaInicio = request.getParameter("hora_inicio");
    String horaFin = request.getParameter("hora_fin");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Operación no especificada");
        return;
    }

    if (tipo.equals("guardar")) {
        try {
            st = conn.createStatement();
            String sql = "INSERT INTO horario(hora_inicio, hora_fin) " +
                         "VALUES('" + horaInicio + "', '" + horaFin + "')";
            st.executeUpdate(sql);
            out.println("Horario registrado correctamente");
        } catch (SQLException e) {
            out.println("Error al registrar: " + e.getMessage());
        }
    } else if (tipo.equals("listar")) {
        try {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT id_horario, hora_inicio, hora_fin FROM horario ORDER BY hora_inicio ASC");
            while (rs.next()) { 
%>
<tr>
    <td><%= rs.getInt("id_horario") %></td>
    <td><%= rs.getString("hora_inicio") %></td>
    <td><%= rs.getString("hora_fin") %></td>
    <td>
        <i class="fas fa-edit" style="color:green" 
           onclick="datosModif('<%= rs.getInt("id_horario") %>', 
                  '<%= rs.getString("hora_inicio") %>',
                  '<%= rs.getString("hora_fin") %>')" 
           data-toggle="tooltip" title="Editar"></i>
        <i class="fas fa-trash" style="color:red" 
           onclick="eliminarHorario(<%= rs.getInt("id_horario") %>)"
           data-toggle="tooltip" title="Eliminar"></i>
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
            String sql = "UPDATE horario SET " +
                         "hora_inicio='" + horaInicio + "', " +
                         "hora_fin='" + horaFin + "' " +
                         "WHERE id_horario=" + pk;
            st.executeUpdate(sql);
            out.println("Horario actualizado correctamente");
        } catch (SQLException e) {
            out.println("Error al actualizar: " + e.getMessage());
        }
    } else if (tipo.equals("eliminar")) {
        try {
            st = conn.createStatement();
            st.executeUpdate("DELETE FROM horario WHERE id_horario=" + pk);
            out.println("Horario eliminado correctamente");
        } catch (SQLException e) {
            out.println("Error al eliminar: " + e.getMessage());
        }
    }
%>