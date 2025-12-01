<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    Statement st = null;
    ResultSet rs = null;
    String tipo = request.getParameter("campo");
    String descripcion = request.getParameter("mp_descripcion");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Operación no especificada");
        return;
    }

    if (tipo.equals("guardar")) {
        try {
            st = conn.createStatement();
            String sql = "INSERT INTO metodo_pago(mp_descripcion) VALUES('" + descripcion + "')";
            st.executeUpdate(sql);
            out.println("Método de pago registrado correctamente");
        } catch (SQLException e) {
            out.println("Error al registrar método de pago: " + e.getMessage());
        }
    } else if (tipo.equals("listar")) {
        try {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT * FROM metodo_pago ORDER BY id_metodo_pago ASC");
            while (rs.next()) { 
%>
<tr>
    <td><%= rs.getInt("id_metodo_pago") %></td>
    <td><%= rs.getString("mp_descripcion") %></td>
    <td>
        <i class="fas fa-edit text-primary mr-2" 
           onclick="cargarParaEditar(<%= rs.getInt("id_metodo_pago") %>, '<%= rs.getString("mp_descripcion") %>')"
           data-toggle="modal" data-target="#exampleModal"></i>
        <i class="fas fa-trash text-danger" 
           onclick="confirmarEliminacion(<%= rs.getInt("id_metodo_pago") %>, '<%= rs.getString("mp_descripcion") %>')"></i>
    </td>
</tr>
<%
            }
        } catch (Exception e) {
            out.println("<tr><td colspan='3' class='text-danger'>Error al listar métodos de pago: " + e.getMessage() + "</td></tr>");
        }
    } else if (tipo.equals("modificar")) {
        try {
            st = conn.createStatement();
            String sql = "UPDATE metodo_pago SET mp_descripcion = '" + descripcion + "' WHERE id_metodo_pago = " + pk;
            st.executeUpdate(sql);
            out.println("Método de pago actualizado correctamente");
        } catch (SQLException e) {
            out.println("Error al actualizar método de pago: " + e.getMessage());
        }
    } else if (tipo.equals("eliminar")) {
        try {
            st = conn.createStatement();
            st.executeUpdate("DELETE FROM metodo_pago WHERE id_metodo_pago = " + pk);
            out.println("Método de pago eliminado correctamente");
        } catch (SQLException e) {
            out.println("Error al eliminar método de pago: " + e.getMessage());
        }
    }
%>
