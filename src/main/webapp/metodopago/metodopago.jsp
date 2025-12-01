<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String tipo = request.getParameter("campo");
    String descripcion = request.getParameter("mp_descripcion");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Operación no especificada");
        return;
    }

    try {
        con = conn; // Assumes 'conn' is the Connection object from the included file.

        if ("guardar".equals(tipo)) {
            // Validar campos obligatorios
            if (descripcion == null || descripcion.trim().isEmpty()) {
                out.println("⚠️ Error: La descripción del método de pago es obligatoria");
                return;
            }

            // ===== VALIDACIÓN DE DUPLICADOS =====
            // Verificar si el método de pago ya existe
            String checkDescripcionSql = "SELECT COUNT(*) FROM metodo_pago WHERE LOWER(TRIM(mp_descripcion)) = LOWER(TRIM(?))";
            ps = con.prepareStatement(checkDescripcionSql);
            ps.setString(1, descripcion);
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("⚠️ Error: Ya existe un método de pago con esa descripción: " + descripcion);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====

            // Using PreparedStatement to prevent SQL injection
            ps = con.prepareStatement("INSERT INTO metodo_pago(mp_descripcion) VALUES(?)");
            ps.setString(1, descripcion);
            ps.executeUpdate();
            out.println("✅ Método de pago registrado exitosamente");
        } else if ("listar".equals(tipo)) {
            // Using PreparedStatement for better resource management and safety
            ps = con.prepareStatement("SELECT id_metodo_pago, mp_descripcion FROM metodo_pago ORDER BY id_metodo_pago ASC");
            rs = ps.executeQuery();
            while (rs.next()) {
%>
<tr>
    <td><%= rs.getInt("id_metodo_pago") %></td>
    <td><%= rs.getString("mp_descripcion") %></td>
    <td>
    <i class="fas fa-edit text-primary mr-2" style="cursor:pointer"
       onclick="cargarParaEditar(<%= rs.getInt("id_metodo_pago") %>, '<%= rs.getString("mp_descripcion").replace("'", "\\'") %>')"></i>
    <i class="fas fa-trash text-danger" style="cursor:pointer"
       onclick="confirmarEliminacion(<%= rs.getInt("id_metodo_pago") %>, '<%= rs.getString("mp_descripcion").replace("'", "\\'") %>')"></i>
    <!-- BOTÓN PARA REPORTE INDIVIDUAL DE MÉTODO DE PAGO -->
    <i class="fas fa-print" style="color:#007bff; cursor:pointer; margin-left:5px;"
       onclick="imprimirMetodoPagoIndividual(<%= rs.getInt("id_metodo_pago") %>, '<%= rs.getString("mp_descripcion") %>')"
       title="Generar Reporte del Método de Pago"></i>
</td>
</tr>
<%
            }
        } else if ("modificar".equals(tipo)) {
            // ===== VALIDACIÓN DE DUPLICADOS AL MODIFICAR =====
            String checkDescripcionSql = "SELECT COUNT(*) FROM metodo_pago WHERE LOWER(TRIM(mp_descripcion)) = LOWER(TRIM(?)) AND id_metodo_pago != ?";
            ps = con.prepareStatement(checkDescripcionSql);
            ps.setString(1, descripcion);
            ps.setInt(2, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("⚠️ Error: Ya existe otro método de pago con esa descripción: " + descripcion);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====

            // Using PreparedStatement to prevent SQL injection
            ps = con.prepareStatement("UPDATE metodo_pago SET mp_descripcion = ? WHERE id_metodo_pago = ?");
            ps.setString(1, descripcion);
            ps.setInt(2, Integer.parseInt(pk));
            ps.executeUpdate();
            out.println("✅ Método de pago actualizado exitosamente");
        } else if ("eliminar".equals(tipo)) {
            // ===== VALIDAR RELACIONES ANTES DE ELIMINAR =====
            // Verificar si tiene facturas asociadas
            String checkFacturasSql = "SELECT COUNT(*) FROM facturacion WHERE id_metodo_pago = ?";
            ps = con.prepareStatement(checkFacturasSql);
            ps.setInt(1, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                int cantidad = rs.getInt(1);
                String mensaje = (cantidad == 1) ? "factura asociada" : "facturas asociadas";
                out.println("⚠️ No se puede eliminar: El método de pago tiene " + cantidad + " " + mensaje);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====

            // Using PreparedStatement to prevent SQL injection
            ps = con.prepareStatement("DELETE FROM metodo_pago WHERE id_metodo_pago = ?");
            ps.setInt(1, Integer.parseInt(pk));
            ps.executeUpdate();
            out.println("✅ Método de pago eliminado exitosamente");
        }
    } catch (SQLException e) {
        String mensaje = e.getMessage().toLowerCase();
        if (mensaje.contains("duplicate") || mensaje.contains("unique")) {
            out.println("⚠️ Error: Ya existe un registro con esos datos");
        } else if (mensaje.contains("foreign key") || mensaje.contains("constraint")) {
            out.println("⚠️ Error: No se puede eliminar porque está relacionado con otros registros");
        } else {
            out.println("❌ Error en la base de datos: " + e.getMessage());
        }
        e.printStackTrace();
    } catch (Exception e) {
        out.println("❌ Error general: " + e.getMessage());
        e.printStackTrace();
    } finally {
        // Ensure all resources are closed in the correct order
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null && !con.isClosed()) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>