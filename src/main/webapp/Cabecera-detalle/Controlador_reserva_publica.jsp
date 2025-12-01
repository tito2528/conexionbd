<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*, java.text.*, java.util.*"%>
<%
PreparedStatement ps = null;
ResultSet rs = null;

String accion = request.getParameter("accion");
System.out.println("=== RESERVA PÚBLICA ===");
System.out.println("Acción: " + accion);

try {
    if (conn == null) {
        out.print("Error: No hay conexión a la base de datos.");
        return;
    }

    if ("listarServicios".equals(accion)) {
        // Cargar servicios para mostrar en la landing page con diseño DARK
        String sql = "SELECT id_servicio, ser_nombre, ser_precio FROM servicio WHERE estado IS NULL OR estado <> 'inactivo' ORDER BY ser_nombre";
        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();
        
        StringBuilder gridHtml = new StringBuilder();
        
        while (rs.next()) {
            int id = rs.getInt("id_servicio");
            String nombre = rs.getString("ser_nombre");
            int precio = rs.getInt("ser_precio");
            
            // 🎨 ASIGNAR IMAGEN SEGÚN EL SERVICIO (Personaliza aquí)
            String imagen = "default.jpg";
            
            // Asignar imagen según el nombre del servicio
            if (nombre.toLowerCase().contains("alisado")) {
                imagen = "alisadopermanente.jpg";
            } else if (nombre.toLowerCase().contains("brushing")) {
                imagen = "brushing.jpg";
            } else if (nombre.toLowerCase().contains("corte") && nombre.toLowerCase().contains("adulto")) {
                imagen = "corte-adulto.jpg";
            } else if (nombre.toLowerCase().contains("corte") && nombre.toLowerCase().contains("niño")) {
                imagen = "corte-nino.jpg";
            } else if (nombre.toLowerCase().contains("lavado")) {
                imagen = "lavado.jpg";
            } else if (nombre.toLowerCase().contains("rulos")) {
                imagen = "rulos.jpg";
            } else if (nombre.toLowerCase().contains("mechas")) {
                imagen = "mechas.jpg";
            } else if (nombre.toLowerCase().contains("tratamiento")) {
                imagen = "tratamiento.jpg";
            } else if (nombre.toLowerCase().contains("novia")) {
                imagen = "peinado.jpg";
            } else if (nombre.toLowerCase().contains("peinado")) {
                imagen = "peinadosocial.jpg";  // Para cualquier otro peinado
            } else if (nombre.toLowerCase().contains("nutricion") || nombre.toLowerCase().contains("nutrición")) {
                imagen = "nutricion.jpg";
            }
            // 👆 AGREGA MÁS SERVICIOS AQUÍ
            
            // Para la landing page (grid) - DISEÑO DARK CON IMAGEN
            gridHtml.append("<div class='col-md-4 mb-4'>");
            gridHtml.append("<div class='service-card' onclick='abrirModalConServicioDirecto(").append(id).append(", \"").append(nombre.replace("\"", "\\\"")).append("\", ").append(precio).append(")'>");
            
            // Imagen del servicio
            gridHtml.append("<img src='img/servicios/").append(imagen).append("' class='card-img-top' alt='").append(nombre).append("' onerror=\"this.src='img/servicios/default.jpg'\">");
            
            gridHtml.append("<div class='card-body'>");
            gridHtml.append("<h5 class='card-title'>").append(nombre).append("</h5>");
            gridHtml.append("<p class='card-text'><strong>Incluye:</strong><br>Servicio profesional de alta calidad</p>");
            gridHtml.append("<div class='price-tag mb-3'>");
            gridHtml.append("<span class='price'>Gs. ").append(String.format("%,d", precio)).append("</span>");
            gridHtml.append("</div>");
            gridHtml.append("<button class='btn-reservar-card'>");
            gridHtml.append("<i class='fas fa-calendar-check'></i> Reservar");
            gridHtml.append("</button>");
            gridHtml.append("</div>");
            gridHtml.append("</div>");
            gridHtml.append("</div>");
        }
        
        // Devolver JSON SIMPLE (sin librería)
        out.print("{");
        out.print("\"grid\":\"" + gridHtml.toString().replace("\"", "\\\"").replace("\n", "").replace("\r", "") + "\"");
        out.print("}");
        
    } else if ("listarProfesionalesPorServicio".equals(accion)) {
        String id_servicio = request.getParameter("id_servicio");
        
        String sql = "SELECT DISTINCT p.id_profesional, p.prof_nombre, p.prof_apellido, p.id_sucursal, s.suc_nombre " +
                    "FROM profesional p " +
                    "JOIN profesional_servicio ps ON p.id_profesional = ps.id_profesional " +
                    "LEFT JOIN sucursal s ON p.id_sucursal = s.id_sucursal " +
                    "WHERE ps.id_servicio = ? AND (p.estado IS NULL OR p.estado <> 'inactivo') " +
                    "ORDER BY p.prof_nombre";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(id_servicio));
        rs = ps.executeQuery();
        
        StringBuilder html = new StringBuilder();
        
        while (rs.next()) {
            int id = rs.getInt("id_profesional");
            String nombre = rs.getString("prof_nombre") + " " + rs.getString("prof_apellido");
            int idSucursal = rs.getInt("id_sucursal");
            String sucursal = rs.getString("suc_nombre");
            
            html.append("<div class='col-md-6 mb-3'>");
            html.append("<div class='servicio-card-modal' id='profesional-").append(id).append("' onclick='seleccionarProfesional(").append(id).append(", \"").append(nombre.replace("\"", "\\\"")).append("\", ").append(idSucursal).append(", \"").append(sucursal != null ? sucursal.replace("\"", "\\\"") : "").append("\")'>");
            html.append("<i class='fas fa-user-tie fa-3x mb-3' style='color: #3498db;'></i>");
            html.append("<h6 class='mb-2'>").append(nombre).append("</h6>");
            if (sucursal != null) {
                html.append("<p class='mb-0 text-muted'><i class='fas fa-map-marker-alt'></i> ").append(sucursal).append("</p>");
            }
            html.append("</div></div>");
        }
        
        if (html.length() == 0) {
            html.append("<div class='col-12'><p class='text-center text-muted'>No hay profesionales disponibles</p></div>");
        }
        
        out.print(html.toString());
        
    } else if ("obtenerHorariosDisponibles".equals(accion)) {
        String id_profesional_param = request.getParameter("id_profesional");
        String id_servicio = request.getParameter("id_servicio");
        String fecha = request.getParameter("fecha");
        
        int id_profesional = Integer.parseInt(id_profesional_param);
        
        System.out.println("🔍 Buscando horarios:");
        System.out.println("  - Profesional: " + id_profesional);
        System.out.println("  - Servicio: " + id_servicio);
        System.out.println("  - Fecha: " + fecha);
        
        // Obtener día de la semana
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        java.util.Date date = sdf.parse(fecha);
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        int diaSemana = cal.get(Calendar.DAY_OF_WEEK);
        
        StringBuilder html = new StringBuilder();
        boolean hayDisponibles = false;
        
        if (id_profesional == 0) {
            // OPCIÓN "CUALQUIERA" - Buscar cualquier profesional disponible
            System.out.println("🔍 Buscando CUALQUIER profesional disponible...");
            
            String sqlProfesionales = "SELECT DISTINCT p.id_profesional, p.id_sucursal " +
                                     "FROM profesional p " +
                                     "JOIN profesional_servicio ps ON p.id_profesional = ps.id_profesional " +
                                     "WHERE ps.id_servicio = ? AND (p.estado IS NULL OR p.estado <> 'inactivo')";
            PreparedStatement psProfesionales = conn.prepareStatement(sqlProfesionales);
            psProfesionales.setInt(1, Integer.parseInt(id_servicio));
            ResultSet rsProfesionales = psProfesionales.executeQuery();
            
            Map<Integer, Map<String, Object>> horariosUnicos = new HashMap<>();
            
            while (rsProfesionales.next()) {
                int idProf = rsProfesionales.getInt("id_profesional");
                int idSucursal = rsProfesionales.getInt("id_sucursal");
                
                System.out.println("  ✓ Revisando profesional ID: " + idProf + ", Sucursal ID: " + idSucursal);
                
                String sql = "SELECT h.id_horario, h.hora_inicio, h.hora_fin " +
                            "FROM horario h " +
                            "WHERE h.id_horario IN (" +
                            "  SELECT DISTINCT h2.id_horario " +
                            "  FROM profesional_horario ph " +
                            "  JOIN horario h_prof ON ph.id_horario = h_prof.id_horario " +
                            "  JOIN horario h2 ON h2.hora_inicio >= h_prof.hora_inicio AND h2.hora_fin <= h_prof.hora_fin " +
                            "  WHERE ph.id_profesional = ? AND ph.dia_semana = ? " +
                            "  AND EXTRACT(HOUR FROM (h2.hora_fin - h2.hora_inicio)) < 1 " +
                            ") " +
                            "ORDER BY h.hora_inicio";
                PreparedStatement psHorarios = conn.prepareStatement(sql);
                psHorarios.setInt(1, idProf);
                psHorarios.setInt(2, diaSemana);
                ResultSet rsHorarios = psHorarios.executeQuery();
                
                String sqlOcupados = "SELECT id_horario FROM agendamiento WHERE id_profesional = ? AND age_fecha = ? AND (estado = 'pendiente' OR estado = 'confirmado')";
                PreparedStatement psOcupados = conn.prepareStatement(sqlOcupados);
                psOcupados.setInt(1, idProf);
                psOcupados.setDate(2, java.sql.Date.valueOf(fecha));
                ResultSet rsOcupados = psOcupados.executeQuery();
                
                Set<Integer> ocupados = new HashSet<>();
                while (rsOcupados.next()) {
                    ocupados.add(rsOcupados.getInt("id_horario"));
                }
                rsOcupados.close();
                psOcupados.close();
                
                while (rsHorarios.next()) {
                    int idHorario = rsHorarios.getInt("id_horario");
                    if (!ocupados.contains(idHorario)) {
                        if (!horariosUnicos.containsKey(idHorario)) {
                            Map<String, Object> horarioData = new HashMap<>();
                            horarioData.put("hora_inicio", rsHorarios.getString("hora_inicio"));
                            horarioData.put("hora_fin", rsHorarios.getString("hora_fin"));
                            horarioData.put("id_profesional", idProf);
                            horarioData.put("id_sucursal", idSucursal);
                            horariosUnicos.put(idHorario, horarioData);
                        }
                    }
                }
                
                rsHorarios.close();
                psHorarios.close();
            }
            
            rsProfesionales.close();
            psProfesionales.close();
            
            List<Integer> horariosOrdenados = new ArrayList<>(horariosUnicos.keySet());
            Collections.sort(horariosOrdenados);
            
            for (Integer idHorario : horariosOrdenados) {
                Map<String, Object> horarioData = horariosUnicos.get(idHorario);
                String horaInicio = ((String) horarioData.get("hora_inicio")).substring(0, 5);
                String horaFin = ((String) horarioData.get("hora_fin")).substring(0, 5);
                int idProfAsignado = (Integer) horarioData.get("id_profesional");
                int idSucursalAsignada = (Integer) horarioData.get("id_sucursal");
                
                hayDisponibles = true;
                html.append("<button class='horario-btn' id='horario-").append(idHorario).append("' ");
                html.append("onclick='seleccionarHorario(").append(idHorario).append(", \"");
                html.append(horarioData.get("hora_inicio")).append("\", \"");
                html.append(horarioData.get("hora_fin")).append("\", ");
                html.append(idProfAsignado).append(", ");
                html.append(idSucursalAsignada).append(")'>");
                html.append(horaInicio).append(" - ").append(horaFin);
                html.append("</button>");
            }
            
        } else {
            // PROFESIONAL ESPECÍFICO
            System.out.println("🔍 Buscando horarios para profesional específico: " + id_profesional);
            
            String sqlSucursal = "SELECT id_sucursal FROM profesional WHERE id_profesional = ?";
            PreparedStatement psSucursal = conn.prepareStatement(sqlSucursal);
            psSucursal.setInt(1, id_profesional);
            ResultSet rsSucursal = psSucursal.executeQuery();
            int idSucursal = 0;
            if (rsSucursal.next()) {
                idSucursal = rsSucursal.getInt("id_sucursal");
                System.out.println("  ✓ Sucursal ID: " + idSucursal);
            }
            rsSucursal.close();
            psSucursal.close();
            
            String sql = "SELECT h.id_horario, h.hora_inicio, h.hora_fin " +
                        "FROM horario h " +
                        "WHERE h.id_horario IN (" +
                        "  SELECT DISTINCT h2.id_horario " +
                        "  FROM profesional_horario ph " +
                        "  JOIN horario h_prof ON ph.id_horario = h_prof.id_horario " +
                        "  JOIN horario h2 ON h2.hora_inicio >= h_prof.hora_inicio AND h2.hora_fin <= h_prof.hora_fin " +
                        "  WHERE ph.id_profesional = ? AND ph.dia_semana = ? " +
                        "  AND EXTRACT(HOUR FROM (h2.hora_fin - h2.hora_inicio)) < 1 " +
                        ") " +
                        "ORDER BY h.hora_inicio";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id_profesional);
            ps.setInt(2, diaSemana);
            rs = ps.executeQuery();
            
            String sqlOcupados = "SELECT id_horario FROM agendamiento WHERE id_profesional = ? AND age_fecha = ? AND (estado = 'pendiente' OR estado = 'confirmado')";
            PreparedStatement psOcupados = conn.prepareStatement(sqlOcupados);
            psOcupados.setInt(1, id_profesional);
            psOcupados.setDate(2, java.sql.Date.valueOf(fecha));
            ResultSet rsOcupados = psOcupados.executeQuery();
            
            Set<Integer> ocupados = new HashSet<>();
            while (rsOcupados.next()) {
                ocupados.add(rsOcupados.getInt("id_horario"));
            }
            rsOcupados.close();
            psOcupados.close();
            
            while (rs.next()) {
                int id = rs.getInt("id_horario");
                String horaInicio = rs.getString("hora_inicio").substring(0, 5);
                String horaFin = rs.getString("hora_fin").substring(0, 5);
                
                if (!ocupados.contains(id)) {
                    hayDisponibles = true;
                    html.append("<button class='horario-btn' id='horario-").append(id).append("' ");
                    html.append("onclick='seleccionarHorario(").append(id).append(", \"");
                    html.append(rs.getString("hora_inicio")).append("\", \"");
                    html.append(rs.getString("hora_fin")).append("\", ");
                    html.append(id_profesional).append(", ");
                    html.append(idSucursal).append(")'>");
                    html.append(horaInicio).append(" - ").append(horaFin);
                    html.append("</button>");
                }
            }
        }
        
        if (!hayDisponibles) {
            html.append("<p class='text-muted'><i class='fas fa-info-circle'></i> No hay horarios disponibles para esta fecha</p>");
        }
        
        out.print(html.toString());
        
    } else if ("listarServiciosCompleto".equals(accion)) {
        // Listar TODOS los servicios de forma completa para el index
        try {
            System.out.println("=== Cargando servicios completo ===");
            
            String sql = "SELECT id_servicio, ser_nombre, ser_precio, ser_descripcion, ser_imagen FROM servicio WHERE estado IS NULL OR estado <> 'inactivo' ORDER BY ser_nombre";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            StringBuilder jsonBuilder = new StringBuilder();
            jsonBuilder.append("{\"servicios\":[");
            
            boolean first = true;
            int contador = 0;
            while (rs.next()) {
                if (!first) jsonBuilder.append(",");
                first = false;
                contador++;
                
                int id = rs.getInt("id_servicio");
                String nombre = rs.getString("ser_nombre");
                int precio = rs.getInt("ser_precio");
                String descripcion = rs.getString("ser_descripcion");
                String imagen = rs.getString("ser_imagen");
                
                System.out.println("Servicio " + contador + ": " + nombre);
                
                // Si no tiene imagen, usar una por defecto
                if (imagen == null || imagen.trim().isEmpty()) {
                    imagen = "default.jpg";
                }
                
                jsonBuilder.append("{");
                jsonBuilder.append("\"id\":").append(id).append(",");
                jsonBuilder.append("\"nombre\":\"").append(nombre.replace("\"", "\\\"")).append("\",");
                jsonBuilder.append("\"precio\":").append(precio).append(",");
                jsonBuilder.append("\"descripcion\":\"").append(descripcion != null ? descripcion.replace("\"", "\\\"") : "").append("\",");
                jsonBuilder.append("\"imagen\":\"").append(imagen.replace("\"", "\\\"")).append("\"");
                jsonBuilder.append("}");
            }
            
            jsonBuilder.append("]}");
            System.out.println("Total servicios cargados: " + contador);
            System.out.println("JSON generado: " + jsonBuilder.toString());
            
            out.print(jsonBuilder.toString());
            
        } catch (Exception e) {
            System.out.println("ERROR en listarServiciosCompleto: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
        
    } else if ("registrarReserva".equals(accion)) {
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String telefono = request.getParameter("telefono");
        String email = request.getParameter("email");
        String ci = request.getParameter("ci");
        
        String id_servicio = request.getParameter("id_servicio");
        String id_profesional = request.getParameter("id_profesional");
        String id_sucursal = request.getParameter("id_sucursal");
        String fecha = request.getParameter("fecha");
        String id_horario = request.getParameter("id_horario");
        
        System.out.println("📝 Datos recibidos para reserva:");
        System.out.println("  - Cliente: " + nombre + " " + apellido);
        System.out.println("  - Teléfono: " + telefono);
        System.out.println("  - Profesional ID: " + id_profesional);
        System.out.println("  - Sucursal ID: " + id_sucursal);
        System.out.println("  - Servicio ID: " + id_servicio);
        System.out.println("  - Fecha: " + fecha);
        System.out.println("  - Horario ID: " + id_horario);
        
        // Validar que id_sucursal NO sea 0
        if (id_sucursal == null || "0".equals(id_sucursal)) {
            System.out.println("❌ ERROR: id_sucursal es 0 o null");
            out.print("Error: No se pudo obtener la sucursal. Por favor intenta nuevamente.");
            return;
        }
        
        int idCliente = 0;
        Integer usuarioId = (Integer) session.getAttribute("usuario_id");
        
        if (usuarioId != null) {
            System.out.println("✅ Cliente con sesión activa: " + usuarioId);
            
            String sqlBuscarCliente = "SELECT c.id_cliente FROM cliente c " +
                                     "JOIN usuario u ON c.cli_nombre = u.usu_nombre AND c.cli_apellido = u.usu_apellido " +
                                     "WHERE u.id_usuario = ? LIMIT 1";
            ps = conn.prepareStatement(sqlBuscarCliente);
            ps.setInt(1, usuarioId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                idCliente = rs.getInt("id_cliente");
            }
            
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        }
        
        if (idCliente == 0 && telefono != null) {
            String sqlBuscarCliente = "SELECT id_cliente FROM cliente WHERE cli_telefono = ?";
            ps = conn.prepareStatement(sqlBuscarCliente);
            ps.setString(1, telefono);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                idCliente = rs.getInt("id_cliente");
                System.out.println("✅ Cliente encontrado por teléfono: " + idCliente);
            } else {
                String sqlInsertCliente = "INSERT INTO cliente (cli_nombre, cli_apellido, cli_telefono, cli_email, cli_ci, id_sucursal, estado) VALUES (?, ?, ?, ?, ?, ?, 'ACTIVO') RETURNING id_cliente";
                ps = conn.prepareStatement(sqlInsertCliente);
                ps.setString(1, nombre);
                ps.setString(2, apellido);
                ps.setString(3, telefono);
                ps.setString(4, email);
                ps.setString(5, ci);
                ps.setInt(6, Integer.parseInt(id_sucursal));
                rs = ps.executeQuery();
                if (rs.next()) {
                    idCliente = rs.getInt("id_cliente");
                    System.out.println("✅ Nuevo cliente creado: " + idCliente);
                }
            }
            
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        }
        
        String sqlAgendamiento = "INSERT INTO agendamiento (age_fecha, id_cliente, id_profesional, id_sucursal, id_horario, estado, observaciones) VALUES (?, ?, ?, ?, ?, 'pendiente', 'Reserva online') RETURNING id_agendamiento";
        ps = conn.prepareStatement(sqlAgendamiento);
        ps.setDate(1, java.sql.Date.valueOf(fecha));
        ps.setInt(2, idCliente);
        ps.setInt(3, Integer.parseInt(id_profesional));
        ps.setInt(4, Integer.parseInt(id_sucursal));
        ps.setInt(5, Integer.parseInt(id_horario));
        
        System.out.println("💾 Insertando agendamiento con sucursal ID: " + id_sucursal);
        
        rs = ps.executeQuery();
        
        if (rs.next()) {
            int idAgendamiento = rs.getInt("id_agendamiento");
            
            String sqlDetalle = "INSERT INTO detalle_servicio (id_agendamiento, id_servicio, cantidad) VALUES (?, ?, 1)";
            PreparedStatement psDetalle = conn.prepareStatement(sqlDetalle);
            psDetalle.setInt(1, idAgendamiento);
            psDetalle.setInt(2, Integer.parseInt(id_servicio));
            psDetalle.executeUpdate();
            psDetalle.close();
            
            System.out.println("✅ Reserva registrada con ID: " + idAgendamiento);
            out.print("¡Reserva registrada con éxito! Te esperamos.");
        } else {
            out.print("Error al procesar la reserva.");
        }
    }
    
} catch (Exception e) {
    System.out.println("❌ ERROR CRÍTICO: " + e.getMessage());
    e.printStackTrace();
    out.print("Error: " + e.getMessage());
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
}
%>