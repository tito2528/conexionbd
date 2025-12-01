<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    Statement st = null;
    ResultSet rs = null;
    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("cli_nombre");
    String apellido = request.getParameter("cli_apellido");
    String ci = request.getParameter("cli_ci");
    String telefono = request.getParameter("cli_telefono");
    String direccion = request.getParameter("cli_direccion");
    String email = request.getParameter("cli_email");
    String idSucursal = request.getParameter("id_sucursal");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Operación no especificada");
        return;
    }

    if (tipo.equals("guardar")) {
        try {
            st = conn.createStatement();
            String sql = "INSERT INTO cliente(cli_nombre, cli_apellido, cli_ci, cli_telefono, " +
                        "cli_direccion, cli_email, id_sucursal) VALUES('" + 
                        nombre + "', '" + apellido + "', '" + ci + "', '" + telefono + "', '" + 
                        direccion + "', '" + email + "', " + 
                        (idSucursal.isEmpty() ? "NULL" : idSucursal) + ")";
            st.executeUpdate(sql);
            out.println("Cliente registrado correctamente");
        } catch (SQLException e) {
            out.println("Error al registrar: " + e.getMessage());
        }
    } else if (tipo.equals("listar")) {
        try {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT c.id_cliente, c.cli_nombre, c.cli_apellido, c.cli_ci, " +
                               "c.cli_telefono, c.cli_direccion, c.cli_email, " +
                               "s.suc_nombre as sucursal, c.id_sucursal " +
                               "FROM cliente c " +
                               "LEFT JOIN sucursal s ON c.id_sucursal = s.id_sucursal " +
                               "ORDER BY c.id_cliente ASC");
            while (rs.next()) { 
%>
<tr>
    <td><%= rs.getInt("id_cliente") %></td>
    <td><%= rs.getString("cli_nombre") %></td>
    <td><%= rs.getString("cli_apellido") %></td>
    <td><%= rs.getString("cli_ci") %></td>
    <td><%= rs.getString("cli_telefono") %></td>
    <td><%= rs.getString("cli_email") %></td>
    <td><%= rs.getString("cli_direccion") %></td>
    <td><%= rs.getString("sucursal") %></td>
    <td>
        <i class="fas fa-edit" style="color:green" 
           onclick="datosModif('<%= rs.getInt("id_cliente") %>', 
                  '<%= rs.getString("cli_nombre") %>',
                  '<%= rs.getString("cli_apellido") %>',
                  '<%= rs.getString("cli_ci") %>',
                  '<%= rs.getString("cli_telefono") %>',
                  '<%= rs.getString("cli_direccion") %>',
                  '<%= rs.getString("cli_email") %>',
                  '<%= rs.getObject("id_sucursal") != null ? rs.getInt("id_sucursal") : "" %>')" 
           data-toggle="tooltip" title="Editar"></i>
        <i class="fas fa-trash" style="color:red" 
           onclick="dell(<%= rs.getInt("id_cliente") %>)"
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
            String sql = "UPDATE cliente SET " +
                        "cli_nombre='" + nombre + "', " +
                        "cli_apellido='" + apellido + "', " +
                        "cli_ci='" + ci + "', " +
                        "cli_telefono='" + telefono + "', " +
                        "cli_direccion='" + direccion + "', " +
                        "cli_email='" + email + "', " +
                        "id_sucursal=" + (idSucursal.isEmpty() ? "NULL" : idSucursal) + " " +
                        "WHERE id_cliente=" + pk;
            st.executeUpdate(sql);
            out.println("Cliente actualizado correctamente");
        } catch (SQLException e) {
            out.println("Error al actualizar: " + e.getMessage());
        }
    } else if (tipo.equals("eliminar")) {
        try {
            st = conn.createStatement();
            st.executeUpdate("DELETE FROM cliente WHERE id_cliente=" + pk);
            out.println("Cliente eliminado correctamente");
        } catch (SQLException e) {
            out.println("Error al eliminar: " + e.getMessage());
        }
    } else if (tipo.equals("cargarSucursales")) {
        try {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT id_sucursal, suc_nombre FROM sucursal ORDER BY suc_nombre");
            while (rs.next()) {
                out.println("<option value='" + rs.getInt("id_sucursal") + "'>" + rs.getString("suc_nombre") + "</option>");
            }
        } catch (SQLException e) {
            out.println("Error al cargar sucursales: " + e.getMessage());
        }
    }
%>