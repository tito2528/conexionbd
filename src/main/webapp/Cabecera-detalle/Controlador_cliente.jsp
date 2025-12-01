<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    PreparedStatement ps = null;
    ResultSet rs = null;

    String accion = request.getParameter("accion");
    System.out.println("=== CONTROLADOR CLIENTE ===");
    System.out.println("Acción: " + accion);

    try {
        if (conn == null) {
            out.print("Error: No hay conexión a la base de datos.");
            return;
        }

        if ("registrar".equals(accion)) {
            String nombre = request.getParameter("nombre");
            String apellido = request.getParameter("apellido");
            String ci = request.getParameter("ci");
            String telefono = request.getParameter("telefono");
            String email = request.getParameter("email");
            String direccion = request.getParameter("direccion");
            String usuario = request.getParameter("usuario");
            String password = request.getParameter("password");

            System.out.println("Registrando usuario: " + usuario);

            // 🔒 VALIDACIÓN CONTRASEÑA FUERTE
            if (password.length() < 6) {
                out.print("⚠️ La contraseña debe tener al menos 6 caracteres");
                return;
            }

            // 🛡️ ANTI SQL INJECTION - Validar usuario existente
            String sqlCheck = "SELECT COUNT(*) FROM usuario WHERE usu_usuario = ?";
            ps = conn.prepareStatement(sqlCheck);
            ps.setString(1, usuario);
            rs = ps.executeQuery();
            rs.next();

            if (rs.getInt(1) > 0) {
                out.print("⚠️ El usuario ya existe. Por favor elige otro.");
                return;
            }

            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }

            // Obtener ID del rol Cliente
            String sqlRol = "SELECT id_rol FROM rol WHERE rol_nombre = 'Cliente'";
            ps = conn.prepareStatement(sqlRol);
            rs = ps.executeQuery();

            int idRol = 0;
            if (rs.next()) {
                idRol = rs.getInt("id_rol");
            } else {
                out.print("❌ Error: Rol 'Cliente' no encontrado.");
                return;
            }

            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }

            // 🔒 CIFRADO DE DATOS (bcrypt) + 🛡️ ANTI SQL INJECTION (PreparedStatement)
            String sqlUsuario = "INSERT INTO usuario (usu_usuario, password, usu_nombre, usu_apellido, id_rol, estado) "
                    + "VALUES (?, crypt(?, gen_salt('bf')), ?, ?, ?, 'ACTIVO') RETURNING id_usuario";
            ps = conn.prepareStatement(sqlUsuario);
            ps.setString(1, usuario);
            ps.setString(2, password);
            ps.setString(3, nombre);
            ps.setString(4, apellido);
            ps.setInt(5, idRol);
            rs = ps.executeQuery();

            if (rs.next()) {
                int idUsuario = rs.getInt("id_usuario");

                // ========================================
                // 🆕 NUEVO: Obtener sucursal automáticamente
                // ========================================
                Integer idSucursal = null;
                String sqlSucursal = "SELECT id_sucursal FROM sucursal WHERE estado = 'ACTIVO' ORDER BY id_sucursal LIMIT 1";
                PreparedStatement psSucursal = conn.prepareStatement(sqlSucursal);
                ResultSet rsSucursal = psSucursal.executeQuery();

                if (rsSucursal.next()) {
                    idSucursal = rsSucursal.getInt("id_sucursal");
                    System.out.println("✅ Sucursal asignada automáticamente: " + idSucursal);
                }

                rsSucursal.close();
                psSucursal.close();
                // ========================================

                // Crear registro en tabla cliente CON SUCURSAL
                String sqlCliente = "INSERT INTO cliente (cli_nombre, cli_apellido, cli_ci, cli_telefono, cli_email, cli_direccion, id_sucursal, estado) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, 'ACTIVO')";
                PreparedStatement psCliente = conn.prepareStatement(sqlCliente);
                psCliente.setString(1, nombre);
                psCliente.setString(2, apellido);
                psCliente.setString(3, ci);
                psCliente.setString(4, telefono);
                psCliente.setString(5, email);
                psCliente.setString(6, direccion);

                // Asignar sucursal (o NULL si no existe)
                if (idSucursal != null) {
                    psCliente.setInt(7, idSucursal);
                } else {
                    psCliente.setNull(7, java.sql.Types.INTEGER);
                }

                psCliente.executeUpdate();
                psCliente.close();

                out.print("✅ ¡Registro exitoso! Redirigiendo al login...");
                System.out.println("✅ Usuario registrado con ID: " + idUsuario + " y sucursal: " + idSucursal);
            } else {
                out.print("❌ Error al crear el usuario.");
            }

        } else if ("login".equals(accion)) {
            String usuario = request.getParameter("usuario");
            String password = request.getParameter("password");

            System.out.println("Intento de login: " + usuario);

            // 🛡️ PROTECCIÓN ANTI-FUERZA BRUTA (usando sesión)
            Integer intentosFallidos = (Integer) session.getAttribute("intentos_fallidos_" + usuario);
            Long tiempoBloqueo = (Long) session.getAttribute("tiempo_bloqueo_" + usuario);

            if (intentosFallidos == null) {
                intentosFallidos = 0;
            }

            // Verificar si está bloqueado
            if (tiempoBloqueo != null && System.currentTimeMillis() < tiempoBloqueo) {
                long minutosRestantes = (tiempoBloqueo - System.currentTimeMillis()) / 60000;
                out.print("🔒 Cuenta bloqueada. Tiempo restante: " + minutosRestantes + " minutos");
                return;
            }

            // Si ya pasó el tiempo, resetear
            if (tiempoBloqueo != null && System.currentTimeMillis() >= tiempoBloqueo) {
                session.removeAttribute("intentos_fallidos_" + usuario);
                session.removeAttribute("tiempo_bloqueo_" + usuario);
                intentosFallidos = 0;
            }

            // 🔒 CIFRADO DE DATOS (bcrypt) + 🛡️ ANTI SQL INJECTION
            String sql = "SELECT u.id_usuario, u.usu_nombre, u.usu_apellido, r.rol_nombre "
                    + "FROM usuario u "
                    + "JOIN rol r ON u.id_rol = r.id_rol "
                    + "WHERE u.usu_usuario = ? AND u.password = crypt(?, u.password) AND u.estado = 'ACTIVO'";
            ps = conn.prepareStatement(sql);
            ps.setString(1, usuario);
            ps.setString(2, password);
            rs = ps.executeQuery();

            if (rs.next()) {
                String rolNombre = rs.getString("rol_nombre");

                if ("Cliente".equals(rolNombre)) {
                    // Limpiar intentos fallidos
                    session.removeAttribute("intentos_fallidos_" + usuario);
                    session.removeAttribute("tiempo_bloqueo_" + usuario);

                    // Crear sesión
                    session.setAttribute("usuario_id", rs.getInt("id_usuario"));
                    session.setAttribute("usuario_nombre", rs.getString("usu_nombre"));
                    session.setAttribute("usuario_apellido", rs.getString("usu_apellido"));
                    session.setAttribute("rol", rolNombre);

                    out.print("✅ Inicio de sesión exitoso");
                    System.out.println("✅ Login exitoso: " + usuario);
                } else {
                    out.print("⚠️ Esta cuenta no tiene permisos de cliente.");
                }
            } else {
                // LOGIN FALLIDO - Incrementar intentos
                intentosFallidos++;
                session.setAttribute("intentos_fallidos_" + usuario, intentosFallidos);

                // Si supera 5 intentos, bloquear por 15 minutos
                if (intentosFallidos >= 5) {
                    long tiempoBloqueoFuturo = System.currentTimeMillis() + (15 * 60 * 1000);
                    session.setAttribute("tiempo_bloqueo_" + usuario, tiempoBloqueoFuturo);
                    out.print("🔒 Cuenta bloqueada por 15 minutos (5 intentos fallidos)");
                } else {
                    int intentosRestantes = 5 - intentosFallidos;
                    out.print("❌ Usuario o contraseña incorrectos. Intentos restantes: " + intentosRestantes);
                }

                System.out.println("❌ Login fallido: " + usuario);
            }

        } else if ("verificarSesion".equals(accion)) {
            Integer usuarioId = (Integer) session.getAttribute("usuario_id");
            String rol = (String) session.getAttribute("rol");

            if (usuarioId != null && "Cliente".equals(rol)) {
                out.print("ACTIVA");
            } else {
                out.print("INACTIVA");
            }

        } else if ("cerrarSesion".equals(accion)) {
            session.invalidate();
            out.print("Sesión cerrada correctamente");

        } else if ("misCitas".equals(accion)) {
            Integer usuarioId = (Integer) session.getAttribute("usuario_id");

            if (usuarioId == null) {
                out.print("<p>No hay sesión activa</p>");
                return;
            }

            String sqlCliente = "SELECT c.id_cliente FROM cliente c "
                    + "JOIN usuario u ON c.cli_nombre = u.usu_nombre AND c.cli_apellido = u.usu_apellido "
                    + "WHERE u.id_usuario = ? LIMIT 1";
            ps = conn.prepareStatement(sqlCliente);
            ps.setInt(1, usuarioId);
            rs = ps.executeQuery();

            int idCliente = 0;
            if (rs.next()) {
                idCliente = rs.getInt("id_cliente");
            }

            if (idCliente == 0) {
                out.print("<p class='text-muted text-center'>No tienes citas registradas aún</p>");
                return;
            }

            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }

            String sql = "SELECT a.id_agendamiento, a.age_fecha, a.estado, "
                    + "h.hora_inicio, h.hora_fin, "
                    + "p.prof_nombre, p.prof_apellido, "
                    + "s.suc_nombre, "
                    + "(SELECT STRING_AGG(serv.ser_nombre, ', ') "
                    + " FROM detalle_servicio ds "
                    + " JOIN servicio serv ON ds.id_servicio = serv.id_servicio "
                    + " WHERE ds.id_agendamiento = a.id_agendamiento) as servicios "
                    + "FROM agendamiento a "
                    + "JOIN horario h ON a.id_horario = h.id_horario "
                    + "JOIN profesional p ON a.id_profesional = p.id_profesional "
                    + "JOIN sucursal s ON a.id_sucursal = s.id_sucursal "
                    + "WHERE a.id_cliente = ? "
                    + "ORDER BY a.age_fecha DESC, h.hora_inicio DESC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, idCliente);
            rs = ps.executeQuery();

            boolean hayCitas = false;
            while (rs.next()) {
                hayCitas = true;
                String estado = rs.getString("estado");
                String badgeClass = "badge-" + estado;

                out.print("<div class='cita-card'>");
                out.print("<div class='row align-items-center'>");
                out.print("<div class='col-md-8'>");
                out.print("<h5><i class='fas fa-calendar'></i> " + rs.getDate("age_fecha") + " - "
                        + rs.getString("hora_inicio").substring(0, 5) + "</h5>");
                out.print("<p class='mb-1'><strong>Servicios:</strong> " + rs.getString("servicios") + "</p>");
                out.print("<p class='mb-1'><strong>Profesional:</strong> " + rs.getString("prof_nombre") + " " + rs.getString("prof_apellido") + "</p>");
                out.print("<p class='mb-0'><strong>Sucursal:</strong> " + rs.getString("suc_nombre") + "</p>");
                out.print("</div>");
                out.print("<div class='col-md-4 text-end'>");
                out.print("<span class='badge " + badgeClass + " mb-2'>" + estado.toUpperCase() + "</span><br>");

                if ("pendiente".equalsIgnoreCase(estado) || "confirmado".equalsIgnoreCase(estado)) {
                    out.print("<button class='btn btn-danger btn-sm' onclick='cancelarCita(" + rs.getInt("id_agendamiento") + ")'>");
                    out.print("<i class='fas fa-times'></i> Cancelar");
                    out.print("</button>");
                }

                out.print("</div>");
                out.print("</div>");
                out.print("</div>");
            }

            if (!hayCitas) {
                out.print("<p class='text-muted text-center'>No tienes citas registradas aún</p>");
            }

        } else if ("cancelarCita".equals(accion)) {
            String idAgendamiento = request.getParameter("id_agendamiento");

            String sql = "UPDATE agendamiento SET estado = 'cancelado' WHERE id_agendamiento = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(idAgendamiento));

            int filasAfectadas = ps.executeUpdate();

            if (filasAfectadas > 0) {
                out.print("✅ Cita cancelada exitosamente");
            } else {
                out.print("❌ Error al cancelar la cita");
            }
        }

    } catch (Exception e) {
        System.out.println("❌ ERROR: " + e.getMessage());
        e.printStackTrace();
        out.print("❌ Error del sistema: " + e.getMessage());
    } finally {
        if (rs != null) try {
            rs.close();
        } catch (SQLException ignore) {
        }
        if (ps != null) try {
            ps.close();
        } catch (SQLException ignore) {
        }
    }
%>
