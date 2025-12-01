<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    PreparedStatement ps = null;
    ResultSet rs = null;

    String tipo = request.getParameter("campo");
    String horaInicio = request.getParameter("hora_inicio");
    String horaFin = request.getParameter("hora_fin");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Error: Operación no especificada.");
        return;
    }

    try {
        if (conn == null) {
            out.println("Error: No hay conexión a la base de datos.");
            return;
        }

        if ("guardar".equals(tipo)) {
            if (horaInicio == null || horaInicio.trim().isEmpty() || horaFin == null || horaFin.trim().isEmpty()) {
                out.println("⚠️ Error: Las horas de inicio y fin son obligatorias");
                return;
            }
            
            // ===== VALIDACIÓN DE DUPLICADOS =====
            // Verificar si ya existe un horario con las mismas horas
            String checkHorarioSql = "SELECT COUNT(*) FROM horario WHERE hora_inicio = CAST(? AS TIME) AND hora_fin = CAST(? AS TIME)";
            ps = conn.prepareStatement(checkHorarioSql);
            ps.setString(1, horaInicio.trim());
            ps.setString(2, horaFin.trim());
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("⚠️ Error: Ya existe un horario de " + horaInicio + " a " + horaFin);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====
            
            // La corrección está aquí: usar CAST(? AS TIME)
            String sql = "INSERT INTO horario(hora_inicio, hora_fin) VALUES(CAST(? AS TIME), CAST(? AS TIME))";
            ps = conn.prepareStatement(sql);
            ps.setString(1, horaInicio.trim());
            ps.setString(2, horaFin.trim());
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.println("✅ Horario registrado exitosamente");
            } else {
                out.println("❌ Error: No se pudo registrar el horario");
            }
        } else if ("listar".equals(tipo)) {
            String sql = "SELECT id_horario, hora_inicio, hora_fin FROM horario ORDER BY hora_inicio ASC";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
%>
<tr>
    <td><%= rs.getInt("id_horario") %></td>
    <td><%= rs.getString("hora_inicio") %></td>
    <td><%= rs.getString("hora_fin") %></td>
    <td>
    <i class="fas fa-edit" style="color:green; cursor:pointer"
       onclick="datosModif('<%= rs.getInt("id_horario") %>', '<%= rs.getString("hora_inicio") %>', '<%= rs.getString("hora_fin") %>')"
       data-toggle="tooltip" title="Editar"></i>
    <i class="fas fa-trash" style="color:red; cursor:pointer"
       onclick="eliminarHorario(<%= rs.getInt("id_horario") %>)"
       data-toggle="tooltip" title="Eliminar"></i>
    <!-- BOTÓN PARA REPORTE INDIVIDUAL DE HORARIO -->
    <i class="fas fa-print" style="color:#007bff; cursor:pointer; margin-left:5px;"
       onclick="imprimirHorarioIndividual(<%= rs.getInt("id_horario") %>, '<%= rs.getString("hora_inicio") %> - <%= rs.getString("hora_fin") %>')"
       title="Generar Reporte del Horario"></i>
</td>
</tr>
<%
            }
        } else if ("modificar".equals(tipo)) {
            if (horaInicio == null || horaInicio.trim().isEmpty() || horaFin == null || horaFin.trim().isEmpty() || pk == null || pk.trim().isEmpty()) {
                out.println("⚠️ Error: Las horas de inicio y fin son obligatorias");
                return;
            }
            
            // ===== VALIDACIÓN DE DUPLICADOS AL MODIFICAR =====
            String checkHorarioSql = "SELECT COUNT(*) FROM horario WHERE hora_inicio = CAST(? AS TIME) AND hora_fin = CAST(? AS TIME) AND id_horario != ?";
            ps = conn.prepareStatement(checkHorarioSql);
            ps.setString(1, horaInicio.trim());
            ps.setString(2, horaFin.trim());
            ps.setInt(3, Integer.parseInt(pk.trim()));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("⚠️ Error: Ya existe otro horario de " + horaInicio + " a " + horaFin);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====
            
            // La corrección también está aquí: usar CAST(? AS TIME)
            String sql = "UPDATE horario SET hora_inicio=CAST(? AS TIME), hora_fin=CAST(? AS TIME) WHERE id_horario=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, horaInicio.trim());
            ps.setString(2, horaFin.trim());
            ps.setInt(3, Integer.parseInt(pk.trim()));
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.println("✅ Horario actualizado exitosamente");
            } else {
                out.println("❌ Error: No se pudo actualizar el horario");
            }
        } else if ("eliminar".equals(tipo)) {
            if (pk == null || pk.trim().isEmpty()) {
                out.println("⚠️ Error: Se requiere un ID para eliminar el horario");
                return;
            }
            
            // ===== VALIDAR RELACIONES ANTES DE ELIMINAR =====
            // Verificar si tiene profesionales asociados
            String checkProfesionalesSql = "SELECT COUNT(*) FROM profesional WHERE id_horario = ?";
            ps = conn.prepareStatement(checkProfesionalesSql);
            ps.setInt(1, Integer.parseInt(pk.trim()));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                int cantidad = rs.getInt(1);
                String mensaje = (cantidad == 1) ? "profesional asociado" : "profesionales asociados";
                out.println("⚠️ No se puede eliminar: El horario tiene " + cantidad + " " + mensaje);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====
            
            String sql = "DELETE FROM horario WHERE id_horario=?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(pk.trim()));
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.println("✅ Horario eliminado exitosamente");
            } else {
                out.println("❌ Error: No se pudo eliminar el horario");
            }
        } else {
            out.println("Operación no reconocida.");
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
        e.printStackTrace();
    } catch (Exception e) {
        out.println("❌ Error general: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) { /* ignore */ }
        if (ps != null) try { ps.close(); } catch (SQLException ignore) { /* ignore */ }
        if (conn != null) try { conn.close(); } catch (SQLException ignore) { /* ignore */ }
    }
%>