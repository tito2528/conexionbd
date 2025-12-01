<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*" %>
<%
    String accion = request.getParameter("accion");
    System.out.println("DEBUG_CITAS: Acción recibida - " + accion);

    if (accion == null) {
        out.print("{\"error\":\"Acción no especificada\"}");
        return;
    }

    try {
        if ("obtener_citas".equals(accion)) {
            StringBuilder json = new StringBuilder("{\"citas\":[");
            boolean primero = true;
            
            String sql = "SELECT a.id_agendamiento, a.age_fecha, h.hora_inicio, h.hora_fin, " +
                         "c.cli_nombre || ' ' || c.cli_apellido as cliente, " +
                         "p.prof_nombre || ' ' || p.prof_apellido as profesional, " +
                         "(SELECT string_agg(s.ser_nombre, ', ') FROM detalle_agendamiento da " +
                         " JOIN servicio s ON da.id_servicio = s.id_servicio " +
                         " WHERE da.id_agendamiento = a.id_agendamiento) as servicios, " +
                         "conf.con_descripcion as estado " +
                         "FROM agendamiento a " +
                         "JOIN cliente c ON a.id_cliente = c.id_cliente " +
                         "JOIN profesional p ON a.id_profesional = p.id_profesional " +
                         "JOIN horario h ON a.id_horario = h.id_horario " +
                         "JOIN confirmacion conf ON a.id_confirmacion = conf.id_confirmacion " +
                         "ORDER BY a.age_fecha DESC, h.hora_inicio DESC";
            
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (!primero) json.append(",");
                    json.append("{")
                        .append("\"id_agendamiento\":").append(rs.getInt("id_agendamiento")).append(",")
                        .append("\"fecha\":\"").append(rs.getDate("age_fecha")).append("\",")
                        .append("\"hora_inicio\":\"").append(rs.getString("hora_inicio").substring(0,5)).append("\",")
                        .append("\"hora_fin\":\"").append(rs.getString("hora_fin").substring(0,5)).append("\",")
                        .append("\"cliente\":\"").append(rs.getString("cliente")).append("\",")
                        .append("\"profesional\":\"").append(rs.getString("profesional")).append("\",")
                        .append("\"servicios\":\"").append(rs.getString("servicios") != null ? rs.getString("servicios") : "N/A").append("\",")
                        .append("\"estado\":\"").append(rs.getString("estado")).append("\"")
                        .append("}");
                    primero = false;
                }
            }
            json.append("]}");
            out.print(json.toString());
            
        } else if ("obtener_detalle_cita".equals(accion)) {
            String idAgendamiento = request.getParameter("id_agendamiento");
            if (idAgendamiento == null) {
                out.print("{\"error\":\"ID de agendamiento no especificado\"}");
                return;
            }
            
            StringBuilder json = new StringBuilder();
            // Obtener información básica de la cita
            String sqlCita = "SELECT a.id_agendamiento, a.age_fecha, h.hora_inicio, h.hora_fin, " +
                           "c.cli_nombre || ' ' || c.cli_apellido as cliente, " +
                           "p.prof_nombre || ' ' || p.prof_apellido as profesional, " +
                           "suc.suc_nombre as sucursal, " +
                           "conf.con_descripcion as estado, a.observaciones " +
                           "FROM agendamiento a " +
                           "JOIN cliente c ON a.id_cliente = c.id_cliente " +
                           "JOIN profesional p ON a.id_profesional = p.id_profesional " +
                           "JOIN sucursal suc ON a.id_sucursal = suc.id_sucursal " +
                           "JOIN horario h ON a.id_horario = h.id_horario " +
                           "JOIN confirmacion conf ON a.id_confirmacion = conf.id_confirmacion " +
                           "WHERE a.id_agendamiento = ?";
            
            try (PreparedStatement ps = conn.prepareStatement(sqlCita)) {
                ps.setInt(1, Integer.parseInt(idAgendamiento));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        json.append("{\"success\":true,\"cita\":{")
                            .append("\"id_agendamiento\":").append(rs.getInt("id_agendamiento")).append(",")
                            .append("\"fecha\":\"").append(rs.getDate("age_fecha")).append("\",")
                            .append("\"hora_inicio\":\"").append(rs.getString("hora_inicio").substring(0,5)).append("\",")
                            .append("\"hora_fin\":\"").append(rs.getString("hora_fin").substring(0,5)).append("\",")
                            .append("\"cliente\":\"").append(rs.getString("cliente")).append("\",")
                            .append("\"profesional\":\"").append(rs.getString("profesional")).append("\",")
                            .append("\"sucursal\":\"").append(rs.getString("sucursal")).append("\",")
                            .append("\"estado\":\"").append(rs.getString("estado")).append("\",")
                            .append("\"observaciones\":\"").append(rs.getString("observaciones") != null ? rs.getString("observaciones") : "").append("\"},");
                    } else {
                        out.print("{\"error\":\"Cita no encontrada\"}");
                        return;
                    }
                }
            }
            
            // Obtener servicios de la cita
            json.append("\"servicios\":[");
            boolean primero = true;
            String sqlServicios = "SELECT s.ser_nombre as nombre, da.cantidad, da.precio_unitario as precio, " +
                                "(da.cantidad * da.precio_unitario) as subtotal " +
                                "FROM detalle_agendamiento da " +
                                "JOIN servicio s ON da.id_servicio = s.id_servicio " +
                                "WHERE da.id_agendamiento = ?";
            
            try (PreparedStatement ps = conn.prepareStatement(sqlServicios)) {
                ps.setInt(1, Integer.parseInt(idAgendamiento));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        if (!primero) json.append(",");
                        json.append("{")
                            .append("\"nombre\":\"").append(rs.getString("nombre")).append("\",")
                            .append("\"cantidad\":").append(rs.getInt("cantidad")).append(",")
                            .append("\"precio\":").append(rs.getDouble("precio")).append(",")
                            .append("\"subtotal\":").append(rs.getDouble("subtotal")).append("}");
                        primero = false;
                    }
                }
            }
            json.append("],");
            
            // Calcular total
            String sqlTotal = "SELECT SUM(cantidad * precio_unitario) as total FROM detalle_agendamiento WHERE id_agendamiento = ?";
            double total = 0;
            try (PreparedStatement ps = conn.prepareStatement(sqlTotal)) {
                ps.setInt(1, Integer.parseInt(idAgendamiento));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        total = rs.getDouble("total");
                    }
                }
            }
            json.append("\"total\":").append(total).append("}");
            
            out.print(json.toString());
            
        } else if ("cancelar_cita".equals(accion)) {
            String idAgendamiento = request.getParameter("id_agendamiento");
            if (idAgendamiento == null) {
                out.print("{\"error\":\"ID de agendamiento no especificado\"}");
                return;
            }
            
            String sql = "UPDATE agendamiento SET id_confirmacion = 3 WHERE id_agendamiento = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, Integer.parseInt(idAgendamiento));
                int affectedRows = ps.executeUpdate();
                if (affectedRows > 0) {
                    out.print("{\"success\":true,\"mensaje\":\"Cita cancelada exitosamente\"}");
                } else {
                    out.print("{\"error\":\"No se pudo cancelar la cita\"}");
                }
            }
        } else {
            out.print("{\"error\":\"Acción no reconocida\"}");
        }
    } catch (Exception e) {
        System.out.println("DEBUG_CITAS: Error - " + e.getMessage());
        out.print("{\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
    }
%>