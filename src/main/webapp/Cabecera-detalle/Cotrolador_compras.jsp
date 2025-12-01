<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date, java.sql.Timestamp" %>
<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin");

        String accion = request.getParameter("listar");

        if (accion != null) {

            if ("cargar".equals(accion)) {
                String id_cliente = request.getParameter("id_cliente");
                String fact_fecha = request.getParameter("fact_fecha");
                String id_usuario = request.getParameter("id_usuario");
                String id_metodo_pago = request.getParameter("id_metodo_pago");
                String id_profesional = request.getParameter("id_profesional");
                String id_sucursal = request.getParameter("id_sucursal");
                String observaciones = request.getParameter("observaciones");
                String id_servicio = request.getParameter("id_servicio");
                String cantidadStr = request.getParameter("cantidad");
                String precio_unitarioStr = request.getParameter("precio_unitario");

                StringBuilder errores = new StringBuilder();
                if (id_cliente == null || id_cliente.trim().isEmpty()) errores.append("- Seleccione un cliente\n");
                if (id_usuario == null || id_usuario.trim().isEmpty()) errores.append("- Seleccione un usuario\n");
                if (id_metodo_pago == null || id_metodo_pago.trim().isEmpty()) errores.append("- Seleccione un método de pago\n");
                if (id_sucursal == null || id_sucursal.trim().isEmpty()) errores.append("- Seleccione una sucursal\n");
                if (id_servicio == null || id_servicio.trim().isEmpty()) errores.append("- Seleccione un servicio\n");
                if (cantidadStr == null || cantidadStr.trim().isEmpty()) errores.append("- Ingrese la cantidad\n");
                if (precio_unitarioStr == null || precio_unitarioStr.trim().isEmpty()) errores.append("- Falta el precio unitario\n");
                if (id_profesional == null || id_profesional.trim().isEmpty()) errores.append("- Seleccione un profesional\n");
                if (fact_fecha == null || fact_fecha.trim().isEmpty()) errores.append("- Falta la fecha de factura\n");

                if (errores.length() > 0) {
                    out.println("Faltan completar los siguientes campos:\n" + errores.toString());
                } else {
                    if (observaciones == null || observaciones.trim().isEmpty()) observaciones = "No hay observaciones";
                    int cantidad = 0;
                    int precio_unitario = 0;
                    try {
                        cantidad = Integer.parseInt(cantidadStr);
                        precio_unitario = (int) Double.parseDouble(precio_unitarioStr);
                    } catch (NumberFormatException nfe) {
                        out.println("Error: Cantidad o precio unitario inválidos.");
                    }

                    if (cantidad <= 0) {
                        out.println("Error: La cantidad debe ser mayor a 0.");
                    } else {
                        int subtotal = cantidad * precio_unitario;
                        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                        Date parsedDate = dateFormat.parse(fact_fecha);
                        Timestamp timestamp = new Timestamp(parsedDate.getTime());

                        Integer id_factura = null;
                        ps = conn.prepareStatement("SELECT id_factura FROM facturacion WHERE estado='pendiente' LIMIT 1");
                        rs = ps.executeQuery();
                        if (rs.next()) id_factura = rs.getInt("id_factura");
                        rs.close(); ps.close();

                        if (id_factura == null) {
                            String insertFacturaSQL = "INSERT INTO facturacion (id_cliente, fact_fecha, id_usuario, id_metodo_pago, id_profesional, id_sucursal, observaciones, fact_total, estado) VALUES (?, ?, ?, ?, ?, ?, ?, 0, 'pendiente')";
                            ps = conn.prepareStatement(insertFacturaSQL, Statement.RETURN_GENERATED_KEYS);
                            ps.setInt(1, Integer.parseInt(id_cliente));
                            ps.setTimestamp(2, timestamp);
                            ps.setInt(3, Integer.parseInt(id_usuario));
                            ps.setInt(4, Integer.parseInt(id_metodo_pago));
                            ps.setInt(5, Integer.parseInt(id_profesional));
                            ps.setInt(6, Integer.parseInt(id_sucursal));
                            ps.setString(7, observaciones);
                            ps.executeUpdate();
                            rs = ps.getGeneratedKeys();
                            if (rs.next()) id_factura = rs.getInt(1);
                            rs.close(); ps.close();
                        } else {
                            // Actualizar los datos de la factura pendiente
                            String updateFacturaSQL = "UPDATE facturacion SET id_cliente=?, id_usuario=?, id_metodo_pago=?, id_profesional=?, id_sucursal=?, observaciones=? WHERE id_factura=?";
                            ps = conn.prepareStatement(updateFacturaSQL);
                            ps.setInt(1, Integer.parseInt(id_cliente));
                            ps.setInt(2, Integer.parseInt(id_usuario));
                            ps.setInt(3, Integer.parseInt(id_metodo_pago));
                            ps.setInt(4, Integer.parseInt(id_profesional));
                            ps.setInt(5, Integer.parseInt(id_sucursal));
                            ps.setString(6, observaciones);
                            ps.setInt(7, id_factura);
                            ps.executeUpdate();
                            ps.close();
                        }

                        if (id_factura != null) {
                            String insertDetalleSQL = "INSERT INTO det_facturacion (id_factura, id_servicio, cantidad, precio_unitario, id_profesional, subtotal, observaciones) VALUES (?, ?, ?, ?, ?, ?, ?)";
                            ps = conn.prepareStatement(insertDetalleSQL);
                            ps.setInt(1, id_factura);
                            ps.setInt(2, Integer.parseInt(id_servicio));
                            ps.setInt(3, cantidad);
                            ps.setInt(4, precio_unitario);
                            ps.setInt(5, Integer.parseInt(id_profesional));
                            ps.setInt(6, subtotal);
                            ps.setString(7, observaciones);
                            ps.executeUpdate(); ps.close();
                            out.println("Servicio agregado correctamente.");
                        } else out.println("Error: No se pudo obtener o crear la factura pendiente.");
                    }
                }

            } else if ("agregarServicioDesdeCita".equals(accion)) {
                String id_factura = request.getParameter("id_factura");
                String id_servicio = request.getParameter("id_servicio");
                String cantidad = request.getParameter("cantidad");
                String precio_unitario = request.getParameter("precio_unitario");
                String id_profesional = request.getParameter("id_profesional");
                String observaciones = request.getParameter("observaciones");
                
                if (id_factura == null || id_factura.isEmpty() || "No hay factura pendiente".equals(id_factura)) {
                    String insertFacturaSQL = "INSERT INTO facturacion (fact_fecha, estado, fact_total, observaciones) VALUES (NOW(), 'pendiente', 0, 'Servicios desde cita')";
                    ps = conn.prepareStatement(insertFacturaSQL, Statement.RETURN_GENERATED_KEYS);
                    ps.executeUpdate();
                    rs = ps.getGeneratedKeys();
                    if (rs.next()) {
                        id_factura = String.valueOf(rs.getInt(1));
                    }
                    rs.close();
                    ps.close();
                }
                
                if (id_servicio == null || cantidad == null || precio_unitario == null || id_profesional == null) {
                    out.print("Faltan parámetros requeridos");
                    return;
                }
                
                try {
                    int cant = Integer.parseInt(cantidad);
                    double precio = Double.parseDouble(precio_unitario);
                    double subtotal = cant * precio;
                    
                    String sqlCheck = "SELECT COUNT(*) FROM det_facturacion WHERE id_factura = ? AND id_servicio = ?";
                    ps = conn.prepareStatement(sqlCheck);
                    ps.setInt(1, Integer.parseInt(id_factura));
                    ps.setInt(2, Integer.parseInt(id_servicio));
                    rs = ps.executeQuery();
                    boolean yaExiste = false;
                    if (rs.next()) {
                        yaExiste = rs.getInt(1) > 0;
                    }
                    rs.close();
                    ps.close();
                    
                    if (!yaExiste) {
                        String sql = "INSERT INTO det_facturacion (id_factura, id_servicio, cantidad, precio_unitario, id_profesional, subtotal, observaciones) VALUES (?, ?, ?, ?, ?, ?, ?)";
                        ps = conn.prepareStatement(sql);
                        ps.setInt(1, Integer.parseInt(id_factura));
                        ps.setInt(2, Integer.parseInt(id_servicio));
                        ps.setInt(3, cant);
                        ps.setDouble(4, precio);
                        ps.setInt(5, Integer.parseInt(id_profesional));
                        ps.setDouble(6, subtotal);
                        ps.setString(7, observaciones != null ? observaciones : "Servicio desde cita");
                        
                        int rows = ps.executeUpdate();
                        if (rows > 0) {
                            out.print("OK");
                        } else {
                            out.print("Error al agregar servicio");
                        }
                    } else {
                        out.print("YA_EXISTE");
                    }
                } catch (Exception e) {
                    out.print("Error: " + e.getMessage());
                }
            } else if ("actualizarFacturaDesdeCita".equals(accion)) {
                String id_factura = request.getParameter("id_factura");
                String id_cliente = request.getParameter("id_cliente");
                String id_usuario = request.getParameter("id_usuario");
                String id_metodo_pago = request.getParameter("id_metodo_pago");
                String id_sucursal = request.getParameter("id_sucursal");
                
                if (id_factura != null && id_cliente != null && id_usuario != null && id_metodo_pago != null && id_sucursal != null) {
                    String sqlUpdate = "UPDATE facturacion SET id_cliente = ?, id_usuario = ?, id_metodo_pago = ?, id_sucursal = ? WHERE id_factura = ?";
                    ps = conn.prepareStatement(sqlUpdate);
                    ps.setInt(1, Integer.parseInt(id_cliente));
                    ps.setInt(2, Integer.parseInt(id_usuario));
                    ps.setInt(3, Integer.parseInt(id_metodo_pago));
                    ps.setInt(4, Integer.parseInt(id_sucursal));
                    ps.setInt(5, Integer.parseInt(id_factura));
                    ps.executeUpdate();
                    ps.close();
                    out.print("OK");
                } else {
                    out.print("Faltan parámetros");
                }
            } else if ("crearFacturaPendiente".equals(accion)) {
                String insertFacturaSQL = "INSERT INTO facturacion (fact_fecha, estado, fact_total, observaciones) VALUES (NOW(), 'pendiente', 0, 'Factura pendiente')";
                ps = conn.prepareStatement(insertFacturaSQL, Statement.RETURN_GENERATED_KEYS);
                ps.executeUpdate();
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int id_factura = rs.getInt(1);
                    out.print(id_factura);
                } else {
                    out.print("Error al crear factura");
                }
                rs.close();
                ps.close();
            } else if ("listar".equals(accion)) {
                int total = 0;
                StringBuilder html = new StringBuilder();
                Integer id_factura = null;

                ps = conn.prepareStatement("SELECT id_factura FROM facturacion WHERE estado='pendiente' LIMIT 1");
                rs = ps.executeQuery();
                if (rs.next()) id_factura = rs.getInt("id_factura");
                rs.close(); ps.close();

                if (id_factura != null) {
                    String sqlDetalle = "SELECT dt.id_detalle_factura, s.ser_nombre, dt.cantidad, dt.precio_unitario, p.prof_nombre, dt.subtotal " +
                                       "FROM det_facturacion dt " +
                                       "JOIN servicio s ON dt.id_servicio = s.id_servicio " +
                                       "JOIN profesional p ON dt.id_profesional = p.id_profesional " +
                                       "WHERE dt.id_factura = ?";
                    ps = conn.prepareStatement(sqlDetalle);
                    ps.setInt(1, id_factura);
                    rs = ps.executeQuery();

                    while (rs.next()) {
                        int id_detalle = rs.getInt(1);
                        String servicio = rs.getString(2);
                        int cantidad = rs.getInt(3);
                        int precio_unitario = rs.getInt(4);
                        String profesional = rs.getString(5);
                        int subtotal = rs.getInt(6);
                        total += subtotal;

                        html.append("<tr>")
                            .append("<td><button type='button' class='btn btn-danger btn-eliminar' data-id='").append(id_detalle).append("'><i class='fa fa-trash'></i></button></td>")
                            .append("<td>").append(servicio).append("</td>")
                            .append("<td>₲").append(String.format("%,d", precio_unitario)).append("</td>")
                            .append("<td>").append(cantidad).append("</td>")
                            .append("<td>").append(profesional).append("</td>")
                            .append("<td>₲").append(String.format("%,d", subtotal)).append("</td>")
                            .append("</tr>");
                    }
                    rs.close(); ps.close();
                }
                out.print(html.toString());
                out.print("<!--TOTAL-->");
                out.print(String.format("₲%,d", total));

            } else if ("eliminar".equals(accion)) {
                String id_detalle = request.getParameter("id_detalle");
                if (id_detalle != null && !id_detalle.trim().isEmpty()) {
                    String sqlDelete = "DELETE FROM det_facturacion WHERE id_detalle_factura = ?";
                    ps = conn.prepareStatement(sqlDelete);
                    ps.setInt(1, Integer.parseInt(id_detalle));
                    int rows = ps.executeUpdate();
                    ps.close();
                    out.println(rows > 0 ? "Detalle eliminado correctamente." : "No se encontró el detalle para eliminar.");
                } else out.println("ID de detalle no válido.");

            } else if ("registrar".equals(accion)) {
                Integer id_factura = null;
                ps = conn.prepareStatement("SELECT id_factura FROM facturacion WHERE estado='pendiente' LIMIT 1");
                rs = ps.executeQuery();
                if (rs.next()) id_factura = rs.getInt("id_factura");
                rs.close(); ps.close();

                if (id_factura != null) {
                    int total = 0;
                    ps = conn.prepareStatement("SELECT SUM(subtotal) FROM det_facturacion WHERE id_factura = ?");
                    ps.setInt(1, id_factura);
                    rs = ps.executeQuery();
                    if (rs.next()) total = rs.getInt(1);
                    rs.close(); ps.close();

                    // VERIFICAR SI HAY SERVICIOS EN LA FACTURA
                    boolean hayServicios = false;
                    ps = conn.prepareStatement("SELECT COUNT(*) FROM det_facturacion WHERE id_factura = ?");
                    ps.setInt(1, id_factura);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        hayServicios = rs.getInt(1) > 0;
                    }
                    rs.close(); ps.close();

                    if (!hayServicios) {
                        out.println("Error: No hay servicios en la factura.");
                        return;
                    }

                    // Obtener datos de los parámetros
                    String param_cliente = request.getParameter("id_cliente");
                    String param_usuario = request.getParameter("id_usuario");
                    String param_metodo_pago = request.getParameter("id_metodo_pago");
                    String param_metodo_pago_2 = request.getParameter("id_metodo_pago_2");
                    String param_monto_pago_1 = request.getParameter("monto_pago_1");
                    String param_monto_pago_2 = request.getParameter("monto_pago_2");
                    String param_sucursal = request.getParameter("id_sucursal");

                    // Validar datos obligatorios
                    if (param_cliente == null || param_cliente.trim().isEmpty()) {
                        out.println("Error: Cliente no seleccionado");
                        return;
                    }
                    if (param_usuario == null || param_usuario.trim().isEmpty()) {
                        out.println("Error: Usuario no seleccionado");
                        return;
                    }
                    if (param_metodo_pago == null || param_metodo_pago.trim().isEmpty()) {
                        out.println("Error: Método de pago no seleccionado");
                        return;
                    }
                    if (param_sucursal == null || param_sucursal.trim().isEmpty()) {
                        out.println("Error: Sucursal no seleccionada");
                        return;
                    }

                    // ACTUALIZAR factura a FINALIZADA con todos los datos (incluyendo 2 métodos de pago)
                    String sqlUpdate = "UPDATE facturacion SET fact_total = ?, estado = 'finalizada', observaciones = '', id_cliente = ?, id_usuario = ?, id_metodo_pago = ?, id_metodo_pago_2 = ?, monto_pago_1 = ?, monto_pago_2 = ?, id_sucursal = ? WHERE id_factura = ?";
                    ps = conn.prepareStatement(sqlUpdate);
                    ps.setInt(1, total);
                    ps.setInt(2, Integer.parseInt(param_cliente));
                    ps.setInt(3, Integer.parseInt(param_usuario));
                    ps.setInt(4, Integer.parseInt(param_metodo_pago));
                    
                    // Segundo método de pago (puede ser NULL)
                    if (param_metodo_pago_2 != null && !param_metodo_pago_2.trim().isEmpty()) {
                        ps.setInt(5, Integer.parseInt(param_metodo_pago_2));
                    } else {
                        ps.setNull(5, java.sql.Types.INTEGER);
                    }
                    
                    // Montos (valores por defecto si no vienen)
                    double monto1 = 0;
                    double monto2 = 0;
                    try {
                        monto1 = param_monto_pago_1 != null ? Double.parseDouble(param_monto_pago_1) : total;
                        monto2 = param_monto_pago_2 != null ? Double.parseDouble(param_monto_pago_2) : 0;
                    } catch (Exception e) {
                        monto1 = total;
                        monto2 = 0;
                    }
                    
                    ps.setDouble(6, monto1);
                    ps.setDouble(7, monto2);
                    ps.setInt(8, Integer.parseInt(param_sucursal));
                    ps.setInt(9, id_factura);
                    ps.executeUpdate(); 
                    ps.close();

                    // NUEVO: Cambiar estado de la cita a "finalizado" si viene de una cita
                    String id_agendamiento_param = request.getParameter("id_agendamiento");
                    if (id_agendamiento_param != null && !id_agendamiento_param.trim().isEmpty()) {
                        try {
                            int id_agendamiento = Integer.parseInt(id_agendamiento_param);
                            String sqlUpdateCita = "UPDATE agendamiento SET estado = 'finalizado' WHERE id_agendamiento = ?";
                            ps = conn.prepareStatement(sqlUpdateCita);
                            ps.setInt(1, id_agendamiento);
                            ps.executeUpdate();
                            ps.close();
                            System.out.println("✅ Cita #" + id_agendamiento + " marcada como finalizada");
                        } catch (NumberFormatException e) {
                            System.err.println("Error al parsear id_agendamiento: " + e.getMessage());
                        }
                    }

                    // Devolver OK con ID de factura y total para mostrar alert
                    out.println("OK|" + id_factura + "|" + total);
                } else {
                    out.println("No hay factura pendiente para registrar.");
                }

            } else if ("cancelarFactura".equals(accion)) {
                String id_factura_str = request.getParameter("numero_factura");
                if (id_factura_str != null && !id_factura_str.trim().isEmpty()) {
                    try {
                        int id_factura = Integer.parseInt(id_factura_str);
                        String sqlUpdate = "UPDATE facturacion SET estado = 'cancelada' WHERE id_factura = ?";
                        ps = conn.prepareStatement(sqlUpdate);
                        ps.setInt(1, id_factura);
                        ps.executeUpdate(); ps.close();

                        String sqlDelete = "DELETE FROM det_facturacion WHERE id_factura = ?";
                        ps = conn.prepareStatement(sqlDelete);
                        ps.setInt(1, id_factura);
                        ps.executeUpdate(); ps.close();

                        out.print("Factura cancelada correctamente");
                    } catch (NumberFormatException e) {
                        out.print("Error: Número de factura inválido");
                    }
                } else out.print("Error: Número de factura no proporcionado");

            } else if ("buscarcliente".equals(accion)) {
                out.println("<option value=''>Seleccione...</option>");
                String idClienteSel = request.getParameter("id_cliente");
                String sql = "SELECT c.id_cliente, c.cli_nombre, c.cli_apellido, c.cli_ci, s.suc_nombre " +
                             "FROM cliente c LEFT JOIN sucursal s ON c.id_sucursal = s.id_sucursal";
                ps = conn.prepareStatement(sql);
                rs = ps.executeQuery();
                while (rs.next()) {
                    int idCli = rs.getInt("id_cliente");
                    String selected = (idClienteSel != null && idClienteSel.equals(String.valueOf(idCli))) ? "selected" : "";
                    String nombre = rs.getString("cli_nombre");
                    String apellido = rs.getString("cli_apellido");
                    String ci = rs.getString("cli_ci");
                    String sucursal = rs.getString("suc_nombre");
                    if (sucursal == null) sucursal = "";
                    out.println("<option value='" + idCli + "' data-nombre='" + nombre + "' data-apellido='" + apellido + "' data-ci='" + ci + "' data-sucursal='" + sucursal + "' " + selected + ">" + nombre + " " + apellido + " - " + ci + " - " + sucursal + "</option>");
                }
                rs.close(); ps.close();

            } else if ("buscarservicio".equals(accion)) {
                out.println("<option value=''>Seleccione...</option>");
                String sql = "SELECT id_servicio, ser_nombre, ser_precio FROM servicio";
                ps = conn.prepareStatement(sql);
                rs = ps.executeQuery();
                while (rs.next()) {
                    int idServicio = rs.getInt("id_servicio");
                    String nombre = rs.getString("ser_nombre");
                    int precio = rs.getInt("ser_precio");
                    out.println("<option value='" + idServicio + "' data-precio='" + precio + "'>" + nombre + "</option>");
                }
                rs.close(); ps.close();

            } else if ("buscarProfesionalesPorServicio".equals(accion)) {
                String idServicio = request.getParameter("id_servicio");
                out.println("<option value=''>Seleccione...</option>");
                if(idServicio != null && !idServicio.trim().isEmpty()) {
                    String sql = "SELECT p.id_profesional, p.prof_nombre FROM profesional p JOIN profesional_servicio ps ON p.id_profesional = ps.id_profesional WHERE ps.id_servicio = ?";
                    ps = conn.prepareStatement(sql);
                    ps.setInt(1, Integer.parseInt(idServicio));
                    rs = ps.executeQuery();
                    while (rs.next()) {
                        int idProf = rs.getInt("id_profesional");
                        String nombre = rs.getString("prof_nombre");
                        out.println("<option value='" + idProf + "'>" + nombre + "</option>");
                    }
                    rs.close(); ps.close();
                }

            } else if ("buscarmetodopago".equals(accion)) {
                out.println("<option value=''>Seleccione...</option>");
                String sql = "SELECT id_metodo_pago, mp_descripcion FROM metodo_pago";
                ps = conn.prepareStatement(sql);
                rs = ps.executeQuery();
                while (rs.next()) {
                    int idMetodo = rs.getInt("id_metodo_pago");
                    String descripcion = rs.getString("mp_descripcion");
                    out.println("<option value='" + idMetodo + "'>" + descripcion + "</option>");
                }
                rs.close(); ps.close();

            } else if ("buscarusuario".equals(accion)) {
                out.println("<option value=''>Seleccione...</option>");
                String sql = "SELECT id_usuario, usu_nombre FROM usuario";
                ps = conn.prepareStatement(sql);
                rs = ps.executeQuery();
                while (rs.next()) {
                    int idUsuario = rs.getInt("id_usuario");
                    String nombre = rs.getString("usu_nombre");
                    out.println("<option value='" + idUsuario + "'>" + nombre + "</option>");
                }
                rs.close(); ps.close();

            } else if ("buscarsucursal".equals(accion)) {
                out.println("<option value=''>Seleccione...</option>");
                String sql = "SELECT id_sucursal, suc_nombre FROM sucursal";
                ps = conn.prepareStatement(sql);
                rs = ps.executeQuery();
                while (rs.next()) {
                    int idSucursal = rs.getInt("id_sucursal");
                    String nombre = rs.getString("suc_nombre");
                    out.println("<option value='" + idSucursal + "'>" + nombre + "</option>");
                }
                rs.close(); ps.close();

            } else if ("getFacturaPendiente".equals(accion)) {
                Integer id_factura = null;
                ps = conn.prepareStatement("SELECT id_factura FROM facturacion WHERE estado='pendiente' LIMIT 1");
                rs = ps.executeQuery();
                if (rs.next()) id_factura = rs.getInt("id_factura");
                rs.close(); ps.close();
                out.print(id_factura != null ? id_factura : "No hay factura pendiente");

            } else out.println("Acción no reconocida.");

        } else out.println("Acción no especificada.");

    } catch (Exception e) {
        out.println("Error del sistema: " + e.getMessage());
    } finally {
        if (rs != null) { try { rs.close(); } catch (SQLException e) {} }
        if (ps != null) { try { ps.close(); } catch (SQLException e) {} }
        if (conn != null) { try { conn.close(); } catch (SQLException e) {} }
    }
%>