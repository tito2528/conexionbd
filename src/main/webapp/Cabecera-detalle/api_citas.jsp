<%@page contentType="application/json" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%><%@page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date"%><%
// IMPORTANTE: No dejar espacios ni saltos de línea antes del JSON
out.clearBuffer();
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
%><%@ include file="../conexion.jsp" %><%
PreparedStatement ps = null;
ResultSet rs = null;

try {
    if (conn == null) {
        out.print("{\"error\":\"No hay conexión a la base de datos\"}");
        return;
    }
    
    String accion = request.getParameter("accion");
    
    if ("listarCitasModerno".equals(accion)) {
        String desde = request.getParameter("desde");
        String hasta = request.getParameter("hasta");
        String estadoFiltro = request.getParameter("estado");

        if (desde == null || desde.isEmpty()) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            desde = sdf.format(new Date());
        }
        if (hasta == null || hasta.isEmpty()) {
            hasta = desde;
        }

        String sql = "SELECT a.id_agendamiento, " +
                    "c.id_cliente, c.cli_nombre, c.cli_apellido, c.cli_telefono, " +
                    "p.id_profesional, p.prof_nombre, p.prof_apellido, " +
                    "su.id_sucursal, su.suc_nombre, " +
                    "h.hora_inicio, h.hora_fin, a.estado, a.age_fecha, a.observaciones, " +
                    "(SELECT STRING_AGG(s.ser_nombre, ', ') FROM detalle_servicio ds " +
                    " JOIN servicio s ON ds.id_servicio = s.id_servicio " +
                    " WHERE ds.id_agendamiento = a.id_agendamiento) as servicios " +
                    "FROM agendamiento a " +
                    "JOIN cliente c ON a.id_cliente = c.id_cliente " +
                    "JOIN profesional p ON a.id_profesional = p.id_profesional " +
                    "JOIN sucursal su ON a.id_sucursal = su.id_sucursal " +
                    "JOIN horario h ON a.id_horario = h.id_horario " +
                    "WHERE a.age_fecha BETWEEN ? AND ? ";
        
        if (estadoFiltro != null && !estadoFiltro.isEmpty()) {
            sql += "AND a.estado = ? ";
        }
        
        sql += "ORDER BY a.age_fecha, h.hora_inicio";

        ps = conn.prepareStatement(sql);
        ps.setDate(1, java.sql.Date.valueOf(desde));
        ps.setDate(2, java.sql.Date.valueOf(hasta));
        
        if (estadoFiltro != null && !estadoFiltro.isEmpty()) {
            ps.setString(3, estadoFiltro);
        }
        
        rs = ps.executeQuery();

        // Construir JSON limpio
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        
        while (rs.next()) {
            if (!first) json.append(",");
            first = false;
            
            String horaInicio = rs.getString("hora_inicio");
            String horaFin = rs.getString("hora_fin");
            String telefono = rs.getString("cli_telefono");
            String observaciones = rs.getString("observaciones");
            String servicios = rs.getString("servicios");
            
            json.append("{");
            json.append("\"id_agendamiento\":").append(rs.getInt("id_agendamiento")).append(",");
            json.append("\"id_cliente\":").append(rs.getInt("id_cliente")).append(",");
            json.append("\"cliente\":\"").append(rs.getString("cli_nombre")).append(" ").append(rs.getString("cli_apellido")).append("\",");
            json.append("\"telefono\":\"").append(telefono != null ? telefono : "").append("\",");
            json.append("\"id_profesional\":").append(rs.getInt("id_profesional")).append(",");
            json.append("\"profesional\":\"").append(rs.getString("prof_nombre")).append(" ").append(rs.getString("prof_apellido")).append("\",");
            json.append("\"id_sucursal\":").append(rs.getInt("id_sucursal")).append(",");
            json.append("\"sucursal\":\"").append(rs.getString("suc_nombre")).append("\",");
            json.append("\"hora_inicio\":\"").append(horaInicio != null ? horaInicio.substring(0, 5) : "").append("\",");
            json.append("\"hora_fin\":\"").append(horaFin != null ? horaFin.substring(0, 5) : "").append("\",");
            json.append("\"estado\":\"").append(rs.getString("estado")).append("\",");
            json.append("\"fecha\":\"").append(rs.getString("age_fecha")).append("\",");
            json.append("\"observaciones\":\"").append(observaciones != null ? observaciones.replace("\"", "\\\"") : "").append("\",");
            json.append("\"servicios\":\"").append(servicios != null ? servicios.replace("\"", "\\\"") : "Sin servicios").append("\"");
            json.append("}");
        }
        
        json.append("]");
        out.print(json.toString());
        
    } else {
        out.print("{\"error\":\"Acción no válida\"}");
    }
    
} catch (Exception e) {
    out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
}
%>
