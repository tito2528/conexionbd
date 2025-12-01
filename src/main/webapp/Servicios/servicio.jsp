<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("ser_nombre");
    String precio = request.getParameter("ser_precio");
    String duracion = request.getParameter("duracion_minutos");
    String pk = request.getParameter("pk");
    String estado = request.getParameter("estado");

    try {
        if (conn == null) {
            out.println("Error: No hay conexión a la base de datos.");
            return;
        }

        if ("guardar".equals(tipo)) {
            if (nombre == null || nombre.trim().isEmpty() || precio == null || precio.isEmpty()) {
                out.println("⚠️ Error: Nombre y Precio son obligatorios");
                return;
            }
            
            // ===== VALIDACIÓN DE DUPLICADOS =====
            // Verificar si el nombre del servicio ya existe
            String checkNombreSql = "SELECT COUNT(*) FROM servicio WHERE LOWER(TRIM(ser_nombre)) = LOWER(TRIM(?))";
            ps = conn.prepareStatement(checkNombreSql);
            ps.setString(1, nombre);
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("⚠️ Error: Ya existe un servicio con el nombre: " + nombre);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====
            
            estado = (estado != null && !estado.isEmpty()) ? estado : "ACTIVO";
            int duracionMinutos = (duracion != null && !duracion.isEmpty()) ? Integer.parseInt(duracion) : 60;
            
            String sql = "INSERT INTO servicio(ser_nombre, ser_precio, duracion_minutos, estado) VALUES(?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setBigDecimal(2, new java.math.BigDecimal(precio));
            ps.setInt(3, duracionMinutos);
            ps.setString(4, estado);
            
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.println("✅ Servicio registrado exitosamente");
            } else {
                out.println("❌ Error: No se pudo registrar el servicio");
            }
        } else if ("listar".equals(tipo)) {
            String sql = "SELECT * FROM servicio ORDER BY id_servicio ASC";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
%>
<tr>
    <td><%= rs.getInt("id_servicio") %></td>
    <td><%= rs.getString("ser_nombre") %></td>
    <td>₲<%= rs.getBigDecimal("ser_precio") %></td>
    <td><%= rs.getInt("duracion_minutos") %> min</td>
    <td>
        <span class="badge <%= "ACTIVO".equals(rs.getString("estado")) ? "badge-success" : "badge-danger" %>">
            <%= rs.getString("estado") %>
        </span>
    </td>
    <td>
    <i class="fas fa-edit" style="color:green; cursor:pointer"
       onclick="datosModif('<%= rs.getInt("id_servicio") %>', 
                        '<%= rs.getString("ser_nombre") %>',
                        '<%= rs.getBigDecimal("ser_precio") %>',
                        '<%= rs.getInt("duracion_minutos") %>',
                        '<%= rs.getString("estado") %>')"></i>
    <i class="fas fa-trash" style="color:red; cursor:pointer"
       onclick="dell(<%= rs.getInt("id_servicio") %>)"></i>
    <!-- BOTÓN PARA REPORTE INDIVIDUAL DE SERVICIO -->
    <i class="fas fa-print" style="color:#007bff; cursor:pointer; margin-left:5px;"
       onclick="imprimirServicioIndividual(<%= rs.getInt("id_servicio") %>, '<%= rs.getString("ser_nombre") %>')"
       title="Generar Reporte del Servicio"></i>
</td>
</tr>
<%
            }
        } else if ("modificar".equals(tipo)) {
            if (nombre == null || nombre.trim().isEmpty() || precio == null || precio.isEmpty()) {
                out.println("⚠️ Error: Nombre y Precio son obligatorios");
                return;
            }
            
            // ===== VALIDACIÓN DE DUPLICADOS AL MODIFICAR =====
            String checkNombreSql = "SELECT COUNT(*) FROM servicio WHERE LOWER(TRIM(ser_nombre)) = LOWER(TRIM(?)) AND id_servicio != ?";
            ps = conn.prepareStatement(checkNombreSql);
            ps.setString(1, nombre);
            ps.setInt(2, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("⚠️ Error: Ya existe otro servicio con el nombre: " + nombre);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====
            
            estado = (estado != null && !estado.isEmpty()) ? estado : "ACTIVO";
            int duracionMinutos = (duracion != null && !duracion.isEmpty()) ? Integer.parseInt(duracion) : 60;
            
            String sql = "UPDATE servicio SET ser_nombre=?, ser_precio=?, duracion_minutos=?, estado=? WHERE id_servicio=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setBigDecimal(2, new java.math.BigDecimal(precio));
            ps.setInt(3, duracionMinutos);
            ps.setString(4, estado);
            ps.setInt(5, Integer.parseInt(pk));
            
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.println("✅ Servicio actualizado exitosamente");
            } else {
                out.println("❌ Error: No se pudo actualizar el servicio");
            }
        } else if ("eliminar".equals(tipo)) {
            String checkSql = "SELECT COUNT(*) FROM detalle_servicio WHERE id_servicio = ?";
            ps = conn.prepareStatement(checkSql);
            ps.setInt(1, Integer.parseInt(pk));
            rs = ps.executeQuery();
            rs.next();
            int numCitas = rs.getInt(1);
            if(numCitas > 0) {
                String mensaje = (numCitas == 1) ? "cita asociada" : "citas asociadas";
                out.println("⚠️ No se puede eliminar: El servicio tiene " + numCitas + " " + mensaje);
                return;
            }

            String deleteSql = "DELETE FROM servicio WHERE id_servicio=?";
            ps = conn.prepareStatement(deleteSql);
            ps.setInt(1, Integer.parseInt(pk));
            
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.println("✅ Servicio eliminado exitosamente");
            } else {
                out.println("❌ Error: No se pudo eliminar el servicio");
            }
        } else if ("cambiar_estado".equals(tipo)) {
            String sql = "UPDATE servicio SET estado=? WHERE id_servicio=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, estado);
            ps.setInt(2, Integer.parseInt(pk));
            
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.println("Estado actualizado exitosamente");
            } else {
                out.println("Error: No se pudo actualizar el estado.");
            }
        } else {
            out.println("Operación no especificada.");
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
    } catch (NumberFormatException e) {
        out.println("⚠️ Error: Formato de número inválido");
    } catch (Exception e) {
        out.println("❌ Error general: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException ignore) {}
        }
        if (ps != null) {
            try { ps.close(); } catch (SQLException ignore) {}
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>