<%@page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date"%>
<%@ include file="../conexion.jsp" %>

<%
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        if (conn == null) {
            out.print("No hay conexión a la base de datos.");
            return;
        }

        String accion = request.getParameter("accion");
        if (accion == null) {
            out.print("Acción no especificada.");
            return;
        }

        if ("listarClientes".equals(accion)) {
            out.println("<option value=''>Seleccione...</option>");
            String sql = "SELECT id_cliente, cli_nombre, cli_apellido, cli_ci FROM cliente WHERE estado IS NULL OR estado <> 'inactivo'";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                out.println("<option value='" + rs.getInt(1) + "'>" + rs.getString(2) + " " + rs.getString(3) + " - " + rs.getString(4) + "</option>");
            }
        } else if ("listarServicios".equals(accion)) {
            out.println("<option value=''>Seleccione...</option>");
            String sql = "SELECT id_servicio, ser_nombre, ser_precio FROM servicio WHERE estado IS NULL OR estado <> 'inactivo'";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                out.println("<option value='" + rs.getInt(1) + "' data-precio='" + rs.getInt(3) + "'>" + rs.getString(2) + "</option>");
            }
        } else if ("profesionalesPorServicio".equals(accion)) {
            String id_servicio = request.getParameter("id_servicio");
            out.println("<option value=''>Seleccione...</option>");
            String sql = "SELECT p.id_profesional, p.prof_nombre, p.prof_apellido FROM profesional p JOIN profesional_servicio ps ON p.id_profesional=ps.id_profesional WHERE ps.id_servicio=?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(id_servicio));
            rs = ps.executeQuery();
            while (rs.next()) {
                out.println("<option value='" + rs.getInt(1) + "'>" + rs.getString(2) + " " + rs.getString(3) + "</option>");
            }
        } else if ("sucursalPorProfesional".equals(accion)) {
            String id_profesional = request.getParameter("id_profesional");
            String sql = "SELECT s.id_sucursal, s.suc_nombre FROM profesional p JOIN sucursal s ON p.id_sucursal=s.id_sucursal WHERE p.id_profesional=?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(id_profesional));
            rs = ps.executeQuery();
            if (rs.next()) {
                out.print("{\"id_sucursal\":\"" + rs.getInt(1) + "\", \"sucursal\":\"" + rs.getString(2) + "\"}");
            }
        }  else if ("listarHorarios".equals(accion)) {
    out.println("<option value=''>Seleccione...</option>");
    
    // Query simple: solo traer horarios de 30 minutos
    String sql = "SELECT id_horario, hora_inicio, hora_fin " +
                 "FROM horario " +
                 "WHERE EXTRACT(EPOCH FROM (hora_fin - hora_inicio))/60 = 30 " + // Solo intervalos de 30 min
                 "AND hora_inicio >= '07:00:00' " +  // Desde las 7am
                 "AND hora_fin <= '19:00:00' " +     // Hasta las 7pm
                 "ORDER BY hora_inicio";
    
    ps = conn.prepareStatement(sql);
    rs = ps.executeQuery();
    
    while (rs.next()) {
        int idHorario = rs.getInt("id_horario");
        String horaInicio = rs.getString("hora_inicio").substring(0, 5); // 07:00
        String horaFin = rs.getString("hora_fin").substring(0, 5);       // 07:30
        
        // Mostrar UNA SOLA VEZ cada horario
        out.println("<option value='" + idHorario + "'>" + horaInicio + " - " + horaFin + "</option>");
    }
        } else if ("buscarClientes".equals(accion)) {
            String q = request.getParameter("q");
            String sql = "SELECT id_cliente, cli_nombre, cli_apellido, cli_ci FROM cliente WHERE (cli_nombre ILIKE ? OR cli_apellido ILIKE ? OR cli_ci ILIKE ?) AND (estado IS NULL OR estado <> 'inactivo')";
            ps = conn.prepareStatement(sql);
            String like = "%" + (q == null ? "" : q) + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            rs = ps.executeQuery();
            while (rs.next()) {
                out.print("<div><button type='button' class='btn btn-link btn-seleccionar-cliente' data-id='" + rs.getInt(1) + "' data-nombre='" + rs.getString(2) + " " + rs.getString(3) + " - " + rs.getString(4) + "'>");
                out.print(rs.getString(2) + " " + rs.getString(3) + " - " + rs.getString(4));
                out.print("</button></div>");
            }
        } else if ("listarProfesionales".equals(accion)) {
            out.println("<option value=''>Seleccione...</option>");
            String sql = "SELECT id_profesional, prof_nombre, prof_apellido FROM profesional WHERE estado IS NULL OR estado <> 'inactivo' ORDER BY prof_nombre, prof_apellido";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                out.println("<option value='" + rs.getInt(1) + "'>" + rs.getString(2) + " " + rs.getString(3) + "</option>");
            }
        } else if ("obtenerPrecioServicio".equals(accion)) {
            String id_servicio = request.getParameter("id_servicio");
            String sql = "SELECT ser_precio FROM servicio WHERE id_servicio = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(id_servicio));
            rs = ps.executeQuery();
            if (rs.next()) {
                out.print(rs.getInt("ser_precio"));
            } else {
                out.print("0");
            }
        } else if ("registrarCitaMultiple".equals(accion)) {
            String id_cliente = request.getParameter("id_cliente");
            String id_profesional = request.getParameter("id_profesional");
            String id_sucursal = request.getParameter("id_sucursal");
            String age_fecha = request.getParameter("age_fecha");
            String id_horario = request.getParameter("id_horario");
            String estado = request.getParameter("estado");
            String observaciones = request.getParameter("observaciones");

            // Obtener arrays de servicios
            java.util.Enumeration<String> parametros = request.getParameterNames();
            java.util.List<String> serviciosList = new java.util.ArrayList<>();

            while (parametros.hasMoreElements()) {
                String paramName = parametros.nextElement();
                if (paramName.startsWith("servicios[")) {
                    String valor = request.getParameter(paramName);
                    if (valor != null && !valor.trim().isEmpty()) {
                        serviciosList.add(valor);
                    }
                }
            }

            // Si no hay observaciones, poner valor por defecto
            if (observaciones == null || observaciones.trim().isEmpty()) {
                observaciones = "No hay observaciones";
            }

            StringBuilder errores = new StringBuilder();
            if (id_cliente == null || id_cliente.isEmpty()) {
                errores.append("- Seleccione un cliente<br>");
            }
            if (id_profesional == null || id_profesional.isEmpty()) {
                errores.append("- Seleccione un profesional principal<br>");
            }
            if (id_sucursal == null || id_sucursal.isEmpty()) {
                errores.append("- Seleccione una sucursal<br>");
            }
            if (age_fecha == null || age_fecha.isEmpty()) {
                errores.append("- Seleccione una fecha<br>");
            }
            if (id_horario == null || id_horario.isEmpty()) {
                errores.append("- Seleccione un horario<br>");
            }
            if (serviciosList.isEmpty()) {
                errores.append("- Agregue al menos un servicio<br>");
            }

            if (errores.length() > 0) {
                out.print("<div class='alert alert-danger'>" + errores.toString() + "</div>");
                return;
            }

            // Verificar solape de horario
            String sqlSolape = "SELECT COUNT(*) FROM agendamiento WHERE id_profesional=? AND age_fecha=? AND id_horario=? AND (estado IS NULL OR estado NOT IN ('cancelado'))";
            ps = conn.prepareStatement(sqlSolape);
            ps.setInt(1, Integer.parseInt(id_profesional));
            ps.setDate(2, java.sql.Date.valueOf(age_fecha));
            ps.setInt(3, Integer.parseInt(id_horario));
            rs = ps.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("<div class='alert alert-warning'>El profesional ya tiene una cita en ese horario.</div>");
                return;
            }

            // Insertar UNA SOLA cita principal CON OBSERVACIONES
            String sqlInsert = "INSERT INTO agendamiento (age_fecha, id_cliente, id_profesional, id_sucursal, id_horario, estado, observaciones) VALUES (?, ?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS);
            ps.setDate(1, java.sql.Date.valueOf(age_fecha));
            ps.setInt(2, Integer.parseInt(id_cliente));
            ps.setInt(3, Integer.parseInt(id_profesional));
            ps.setInt(4, Integer.parseInt(id_sucursal));
            ps.setInt(5, Integer.parseInt(id_horario));
            ps.setString(6, estado);
            ps.setString(7, observaciones);
            int filasAfectadas = ps.executeUpdate();

            if (filasAfectadas > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int id_agendamiento = rs.getInt(1);

                    // Insertar MÚLTIPLES servicios en la MISMA cita
                    String sqlDet = "INSERT INTO detalle_servicio (id_agendamiento, id_servicio, cantidad) VALUES (?, ?, 1)";
                    PreparedStatement psDet = conn.prepareStatement(sqlDet);

                    int serviciosRegistrados = 0;
                    for (String id_servicio : serviciosList) {
                        if (id_servicio != null && !id_servicio.trim().isEmpty()) {
                            psDet.setInt(1, id_agendamiento);
                            psDet.setInt(2, Integer.parseInt(id_servicio));
                            psDet.addBatch();
                            serviciosRegistrados++;
                        }
                    }

                    if (serviciosRegistrados > 0) {
                        int[] resultados = psDet.executeBatch();
                        out.print("<div class='alert alert-success'>Cita registrada correctamente con " + serviciosRegistrados + " servicio(s). Observaciones: " + observaciones + "</div>");
                    } else {
                        out.print("<div class='alert alert-warning'>Cita registrada pero no se pudieron agregar los servicios.</div>");
                    }
                    psDet.close();
                } else {
                    out.print("<div class='alert alert-danger'>Error al obtener el ID de la cita creada.</div>");
                }
            } else {
                out.print("<div class='alert alert-danger'>Error al registrar la cita.</div>");
            }

        } else if ("listarCitas".equals(accion)) {
            String desde = request.getParameter("desde");
            String hasta = request.getParameter("hasta");

            if (desde == null || desde.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                desde = sdf.format(new Date());
            }
            if (hasta == null || hasta.isEmpty()) {
                hasta = desde;
            }

            // CONSULTA MODIFICADA para mostrar TODOS los servicios de cada cita Y OBSERVACIONES
            String sql = "SELECT a.id_agendamiento, c.id_cliente, c.cli_nombre, c.cli_apellido, "
                    + "p.id_profesional, p.prof_nombre, p.prof_apellido, "
                    + "su.id_sucursal, su.suc_nombre, "
                    + "h.hora_inicio, h.hora_fin, a.estado, a.age_fecha, a.observaciones, "
                    + "(SELECT STRING_AGG(s.ser_nombre, ', ') FROM detalle_servicio ds "
                    + " JOIN servicio s ON ds.id_servicio = s.id_servicio "
                    + " WHERE ds.id_agendamiento = a.id_agendamiento) as servicios "
                    + "FROM agendamiento a "
                    + "JOIN cliente c ON a.id_cliente = c.id_cliente "
                    + "JOIN profesional p ON a.id_profesional = p.id_profesional "
                    + "JOIN sucursal su ON a.id_sucursal = su.id_sucursal "
                    + "JOIN horario h ON a.id_horario = h.id_horario "
                    + "WHERE a.age_fecha BETWEEN ? AND ? "
                    + "ORDER BY a.age_fecha, h.hora_inicio";

            ps = conn.prepareStatement(sql);
            ps.setDate(1, java.sql.Date.valueOf(desde));
            ps.setDate(2, java.sql.Date.valueOf(hasta));
            rs = ps.executeQuery();

            while (rs.next()) {
                int id = rs.getInt("id_agendamiento");
                String cliente = rs.getString("cli_nombre") + " " + rs.getString("cli_apellido");
                String profesional = rs.getString("prof_nombre") + " " + rs.getString("prof_apellido");
                String servicios = rs.getString("servicios");
                String sucursal = rs.getString("suc_nombre");
                String horario = rs.getString("hora_inicio") + " - " + rs.getString("hora_fin");
                String estado = rs.getString("estado");
                String fecha = rs.getString("age_fecha");
                String observaciones = rs.getString("observaciones");

                // Datos COMPLETOS para el botón Atender
                int id_cliente = rs.getInt("id_cliente");
                int id_profesional = rs.getInt("id_profesional");
                int id_sucursal = rs.getInt("id_sucursal");

                out.print("<tr>");
                out.print("<td>" + cliente + "</td>");
                out.print("<td>" + profesional + "</td>");
                out.print("<td>" + (servicios != null ? servicios : "Sin servicios") + "</td>");
                out.print("<td>" + sucursal + "</td>");
                out.print("<td>" + fecha + " " + horario + "</td>");
                out.print("<td>");
                out.print("<select class='form-control estado-cita' data-id='" + id + "'>");
                out.print("<option value='pendiente'" + ("pendiente".equals(estado) ? " selected" : "") + ">Pendiente</option>");
                out.print("<option value='confirmado'" + ("confirmado".equals(estado) ? " selected" : "") + ">Confirmado</option>");
                out.print("<option value='cancelado'" + ("cancelado".equals(estado) ? " selected" : "") + ">Cancelado</option>");
                out.print("</select>");
                out.print("</td>");
                out.print("<td>");
                out.print("<button class='btn btn-success btn-atender' "
                        + "data-id='" + id + "' "
                        + "data-id_cliente='" + id_cliente + "' "
                        + "data-cliente_nombre='" + cliente + "' "
                        + "data-id_profesional='" + id_profesional + "' "
                        + "data-profesional_nombre='" + profesional + "' "
                        + "data-id_sucursal='" + id_sucursal + "' "
                        + "data-sucursal_nombre='" + sucursal + "' "
                        + "data-observaciones='" + (observaciones != null ? observaciones : "No hay observaciones") + "' "
                        + "title='Atender'><i class='fa fa-user-md'></i> Atender</button> ");
                out.print("<button class='btn btn-danger btn-eliminar' data-id='" + id + "' title='Eliminar'><i class='fa fa-trash'></i></button>");
                out.print("</td>");
                out.print("</tr>");
            }

        } else if ("listarCitasModerno".equals(accion)) {
            // Nueva acción para devolver JSON en lugar de HTML
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
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
            
            // Filtro de estado opcional
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

            // Construir JSON manualmente
            out.print("[");
            boolean first = true;
            
            while (rs.next()) {
                if (!first) out.print(",");
                first = false;
                
                String horaInicio = rs.getString("hora_inicio");
                String horaFin = rs.getString("hora_fin");
                
                out.print("{");
                out.print("\"id_agendamiento\":" + rs.getInt("id_agendamiento") + ",");
                out.print("\"id_cliente\":" + rs.getInt("id_cliente") + ",");
                out.print("\"cliente\":\"" + rs.getString("cli_nombre") + " " + rs.getString("cli_apellido") + "\",");
                out.print("\"telefono\":\"" + (rs.getString("cli_telefono") != null ? rs.getString("cli_telefono") : "") + "\",");
                out.print("\"id_profesional\":" + rs.getInt("id_profesional") + ",");
                out.print("\"profesional\":\"" + rs.getString("prof_nombre") + " " + rs.getString("prof_apellido") + "\",");
                out.print("\"id_sucursal\":" + rs.getInt("id_sucursal") + ",");
                out.print("\"sucursal\":\"" + rs.getString("suc_nombre") + "\",");
                out.print("\"hora_inicio\":\"" + (horaInicio != null ? horaInicio.substring(0, 5) : "") + "\",");
                out.print("\"hora_fin\":\"" + (horaFin != null ? horaFin.substring(0, 5) : "") + "\",");
                out.print("\"estado\":\"" + rs.getString("estado") + "\",");
                out.print("\"fecha\":\"" + rs.getString("age_fecha") + "\",");
                out.print("\"observaciones\":\"" + (rs.getString("observaciones") != null ? rs.getString("observaciones").replace("\"", "\\\"") : "") + "\",");
                out.print("\"servicios\":\"" + (rs.getString("servicios") != null ? rs.getString("servicios").replace("\"", "\\\"") : "Sin servicios") + "\"");
                out.print("}");
            }
            
            out.print("]");

        } else if ("obtenerServiciosCita".equals(accion)) {
            String id_agendamiento = request.getParameter("id_agendamiento");
            String sql = "SELECT s.id_servicio, s.ser_nombre, s.ser_precio "
                    + "FROM detalle_servicio ds "
                    + "JOIN servicio s ON ds.id_servicio = s.id_servicio "
                    + "WHERE ds.id_agendamiento = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(id_agendamiento));
            rs = ps.executeQuery();

            out.print("[");
            boolean primero = true;
            while (rs.next()) {
                if (!primero) {
                    out.print(",");
                }
                out.print("{\"id_servicio\":\"" + rs.getInt("id_servicio") + "\",");
                out.print("\"servicio_nombre\":\"" + rs.getString("ser_nombre") + "\",");
                out.print("\"servicio_precio\":\"" + rs.getInt("ser_precio") + "\"}");
                primero = false;
            }
            out.print("]");

        } else if ("actualizarEstadoCita".equals(accion)) {
            String id_agendamiento = request.getParameter("id_agendamiento");
            String estado = request.getParameter("estado");

            if (id_agendamiento != null && estado != null) {
                String sql = "UPDATE agendamiento SET estado = ? WHERE id_agendamiento = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, estado);
                ps.setInt(2, Integer.parseInt(id_agendamiento));
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    out.print("Estado actualizado correctamente");
                } else {
                    out.print("Error al actualizar estado");
                }
            } else {
                out.print("Parámetros inválidos");
            }
        } else if ("eliminarCita".equals(accion)) {
            String id_agendamiento = request.getParameter("id_agendamiento");
            if (id_agendamiento != null && !id_agendamiento.isEmpty()) {
                String sqlDet = "DELETE FROM detalle_servicio WHERE id_agendamiento = ?";
                ps = conn.prepareStatement(sqlDet);
                ps.setInt(1, Integer.parseInt(id_agendamiento));
                ps.executeUpdate();

                String sql = "DELETE FROM agendamiento WHERE id_agendamiento = ?";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(id_agendamiento));
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    out.print("Cita eliminada correctamente.");
                } else {
                    out.print("No se encontró la cita.");
                }
            } else {
                out.print("ID de cita no válido.");
            }
        } else {
            out.print("Acción no reconocida.");
        }
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException ignore) {
            }
        }
        if (ps != null) {
            try {
                ps.close();
            } catch (SQLException ignore) {
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                out.print("Error al cerrar la conexión: " + e.getMessage());
            }
        }
    }
%>
