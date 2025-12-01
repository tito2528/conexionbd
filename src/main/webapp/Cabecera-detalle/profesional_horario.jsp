<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*, java.util.*, java.text.*"%>
<%
// DEBUG EXTENDIDO
System.out.println("=== DEBUG PROFESIONAL_HORARIO ===");
System.out.println("Accion: " + request.getParameter("accion"));
System.out.println("id_profesional: " + request.getParameter("id_profesional"));
System.out.println("id_horario: " + request.getParameter("id_horario"));
System.out.println("dia_semana: " + request.getParameter("dia_semana"));

if (conn == null) {
    System.out.println("❌ CONEXION NULL");
    out.print("Error: No hay conexión a la base de datos.");
    return;
} else {
    System.out.println("✅ Conexión establecida");
}

PreparedStatement ps = null;
ResultSet rs = null;

String accion = request.getParameter("accion");
String id_profesional = request.getParameter("id_profesional");
String id_servicio = request.getParameter("id_servicio");
String fecha = request.getParameter("fecha");
String id_horario = request.getParameter("id_horario");
String dia_semana = request.getParameter("dia_semana");
String id = request.getParameter("id");

try {
    if (conn == null) {
        out.print("No hay conexión a la base de datos.");
        return;
    }

    if ("listarProfesionales".equals(accion)) {
        System.out.println("📋 Listando profesionales...");
        String sql = "SELECT id_profesional, prof_nombre, prof_apellido FROM profesional WHERE estado = 'ACTIVO' ORDER BY prof_nombre, prof_apellido";
        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();
        
        out.print("<option value=''>Seleccione...</option>");
        while (rs.next()) {
            out.print("<option value='" + rs.getInt("id_profesional") + "'>");
            out.print(rs.getString("prof_nombre") + " " + rs.getString("prof_apellido"));
            out.print("</option>");
        }
        System.out.println("✅ Profesionales listados");

    } else if ("listarHorarios".equals(accion)) {
        System.out.println("📋 Listando horarios...");
        String sql = "SELECT id_horario, hora_inicio, hora_fin FROM horario ORDER BY hora_inicio";
        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();
        
        out.print("<option value=''>Seleccione...</option>");
        while (rs.next()) {
            out.print("<option value='" + rs.getInt("id_horario") + "'>");
            out.print(rs.getString("hora_inicio").substring(0, 5) + " - " + rs.getString("hora_fin").substring(0, 5));
            out.print("</option>");
        }
        System.out.println("✅ Horarios listados");

    } else if ("listarHorariosProfesional".equals(accion)) {
        System.out.println("📋 Listando horarios de profesionales...");
        String sql = "SELECT ph.id_profesional_horario, p.prof_nombre, p.prof_apellido, " +
                    "h.hora_inicio, h.hora_fin, ph.dia_semana " +
                    "FROM profesional_horario ph " +
                    "JOIN profesional p ON ph.id_profesional = p.id_profesional " +
                    "JOIN horario h ON ph.id_horario = h.id_horario " +
                    "ORDER BY p.prof_nombre, ph.dia_semana, h.hora_inicio";
        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();
        
        String[] dias = {"", "Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"};
        
        boolean hayDatos = false;
        while (rs.next()) {
            hayDatos = true;
            out.print("<tr>");
            out.print("<td>" + rs.getString("prof_nombre") + " " + rs.getString("prof_apellido") + "</td>");
            out.print("<td>" + dias[rs.getInt("dia_semana")] + "</td>");
            out.print("<td>" + rs.getString("hora_inicio").substring(0, 5) + " - " + rs.getString("hora_fin").substring(0, 5) + "</td>");
            out.print("<td>");
            out.print("<button class='btn btn-danger btn-sm' onclick='eliminarHorarioProfesional(" + 
                     rs.getInt("id_profesional_horario") + ")'>Eliminar</button>");
            out.print("</td>");
            out.print("</tr>");
        }
        
        if (!hayDatos) {
            out.print("<tr><td colspan='4' class='text-center text-muted'>No hay horarios asignados</td></tr>");
        }
        System.out.println("✅ Horarios de profesionales listados");

    } else if ("guardarHorario".equals(accion)) {
        System.out.println("💾 Guardando horario...");
        
        if (id_profesional != null && !id_profesional.isEmpty() && 
            id_horario != null && !id_horario.isEmpty() && 
            dia_semana != null && !dia_semana.isEmpty()) {
            
            // Verificar si ya existe
            String sqlCheck = "SELECT COUNT(*) FROM profesional_horario WHERE id_profesional = ? AND id_horario = ? AND dia_semana = ?";
            ps = conn.prepareStatement(sqlCheck);
            ps.setInt(1, Integer.parseInt(id_profesional));
            ps.setInt(2, Integer.parseInt(id_horario));
            ps.setInt(3, Integer.parseInt(dia_semana));
            rs = ps.executeQuery();
            rs.next();
            int existe = rs.getInt(1);
            
            if (existe > 0) {
                out.print("Este horario ya está asignado al profesional para ese día.");
                System.out.println("❌ Horario duplicado");
            } else {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                
                String sqlInsert = "INSERT INTO profesional_horario (id_profesional, id_horario, dia_semana) VALUES (?, ?, ?)";
                ps = conn.prepareStatement(sqlInsert);
                ps.setInt(1, Integer.parseInt(id_profesional));
                ps.setInt(2, Integer.parseInt(id_horario));
                ps.setInt(3, Integer.parseInt(dia_semana));
                int filas = ps.executeUpdate();
                
                if (filas > 0) {
                    out.print("Horario asignado correctamente al profesional.");
                    System.out.println("✅ Horario guardado correctamente");
                } else {
                    out.print("Error al asignar el horario.");
                    System.out.println("❌ No se insertaron filas");
                }
            }
        } else {
            out.print("Datos incompletos para guardar el horario.");
            System.out.println("❌ Datos incompletos");
        }

    } else if ("eliminarHorario".equals(accion)) {
        System.out.println("🗑️ Eliminando horario...");
        if (id != null && !id.isEmpty()) {
            String sqlDelete = "DELETE FROM profesional_horario WHERE id_profesional_horario = ?";
            ps = conn.prepareStatement(sqlDelete);
            ps.setInt(1, Integer.parseInt(id));
            int filas = ps.executeUpdate();
            
            if (filas > 0) {
                out.print("Horario eliminado correctamente.");
                System.out.println("✅ Horario eliminado");
            } else {
                out.print("Error al eliminar el horario.");
                System.out.println("❌ No se eliminaron filas");
            }
        } else {
            out.print("ID no válido para eliminar.");
            System.out.println("❌ ID inválido");
        }

    } else if ("validarDisponibilidad".equals(accion)) {
        System.out.println("🔍 Validando disponibilidad del profesional...");
        
        if (id_profesional != null && id_horario != null && fecha != null) {
            // Obtener día de la semana
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date date = sdf.parse(fecha);
            Calendar cal = Calendar.getInstance();
            cal.setTime(date);
            int diaSemana = cal.get(Calendar.DAY_OF_WEEK);
            
            System.out.println("Profesional: " + id_profesional);
            System.out.println("Horario seleccionado ID: " + id_horario);
            System.out.println("Fecha: " + fecha);
            System.out.println("Día semana: " + diaSemana);
            
            // PASO 1: Obtener el horario seleccionado por el cliente (30 min)
            String sqlHorarioCliente = "SELECT hora_inicio, hora_fin FROM horario WHERE id_horario = ?";
            ps = conn.prepareStatement(sqlHorarioCliente);
            ps.setInt(1, Integer.parseInt(id_horario));
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                out.print("Error: No se encontró el horario seleccionado.");
                return;
            }
            
            String horaInicioCliente = rs.getString("hora_inicio");
            String horaFinCliente = rs.getString("hora_fin");
            System.out.println("Horario cliente: " + horaInicioCliente + " - " + horaFinCliente);
            
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            
            // PASO 2: Obtener TODOS los horarios del profesional para ese día
            String sqlHorariosProfesional = "SELECT h.hora_inicio, h.hora_fin " +
                                           "FROM profesional_horario ph " +
                                           "JOIN horario h ON ph.id_horario = h.id_horario " +
                                           "WHERE ph.id_profesional = ? AND ph.dia_semana = ?";
            ps = conn.prepareStatement(sqlHorariosProfesional);
            ps.setInt(1, Integer.parseInt(id_profesional));
            ps.setInt(2, diaSemana);
            rs = ps.executeQuery();
            
            boolean trabajaEnEseHorario = false;
            
            // VALIDAR si el horario del cliente CAE DENTRO de algún rango de trabajo del profesional
            while (rs.next()) {
                String horaInicioProfesional = rs.getString("hora_inicio");
                String horaFinProfesional = rs.getString("hora_fin");
                
                System.out.println("Comparando con horario profesional: " + horaInicioProfesional + " - " + horaFinProfesional);
                
                // Verificar si el horario del cliente está DENTRO del rango del profesional
                if (horaInicioCliente.compareTo(horaInicioProfesional) >= 0 && 
                    horaFinCliente.compareTo(horaFinProfesional) <= 0) {
                    trabajaEnEseHorario = true;
                    System.out.println("✅ El horario del cliente CAE DENTRO del horario del profesional");
                    break;
                }
            }
            
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            
            // VALIDACIÓN 1: ¿El profesional trabaja en ese horario?
            if (!trabajaEnEseHorario) {
                String sqlNombreProf = "SELECT prof_nombre, prof_apellido FROM profesional WHERE id_profesional = ?";
                ps = conn.prepareStatement(sqlNombreProf);
                ps.setInt(1, Integer.parseInt(id_profesional));
                rs = ps.executeQuery();
                String nombreProf = "";
                if (rs.next()) {
                    nombreProf = rs.getString("prof_nombre") + " " + rs.getString("prof_apellido");
                }
                
                out.print("El profesional " + nombreProf + " no trabaja en el horario . Por favor seleccione otro profesional u otro horario.");
                System.out.println("❌ Profesional no trabaja en ese horario");
                return;
            }
            
            // VALIDACIÓN 2: ¿El profesional ya tiene una cita en ese horario?
            String sqlVerificarCita = "SELECT COUNT(*) FROM agendamiento " +
                                     "WHERE id_profesional = ? AND id_horario = ? AND age_fecha = ? " +
                                     "AND (estado = 'pendiente' OR estado = 'confirmado')";
            ps = conn.prepareStatement(sqlVerificarCita);
            ps.setInt(1, Integer.parseInt(id_profesional));
            ps.setInt(2, Integer.parseInt(id_horario));
            ps.setDate(3, java.sql.Date.valueOf(fecha));
            rs = ps.executeQuery();
            rs.next();
            int tieneCita = rs.getInt(1);
            
            if (tieneCita > 0) {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                
                String sqlNombreProf = "SELECT prof_nombre, prof_apellido FROM profesional WHERE id_profesional = ?";
                ps = conn.prepareStatement(sqlNombreProf);
                ps.setInt(1, Integer.parseInt(id_profesional));
                rs = ps.executeQuery();
                String nombreProf = "";
                if (rs.next()) {
                    nombreProf = rs.getString("prof_nombre") + " " + rs.getString("prof_apellido");
                }
                
                out.print("El profesional " + nombreProf + " ya tiene una cita agendada en el horario " + horaInicioCliente.substring(0,5) + " - " + horaFinCliente.substring(0,5) + ". Por favor seleccione otro profesional.");
                System.out.println("❌ Profesional ya tiene cita en ese horario");
                return;
            }
            
            // TODO BIEN - PROFESIONAL DISPONIBLE
            out.print("DISPONIBLE");
            System.out.println("✅ Profesional disponible en ese horario");
            
        } else {
            out.print("Datos incompletos para validar disponibilidad.");
            System.out.println("❌ Datos incompletos");
        }

    } else {
        out.print("Acción no reconocida: " + accion);
        System.out.println("❌ Acción no reconocida: " + accion);
    }
} catch (Exception e) {
    out.print("Error: " + e.getMessage());
    System.out.println("❌ EXCEPCIÓN: " + e.getMessage());
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
}
%>