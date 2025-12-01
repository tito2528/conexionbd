<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date"%>
<%
    System.out.println("🔍 servicio_clientes_facturas.jsp - INICIANDO");

    String accion = request.getParameter("accion");
    
    System.out.println("📝 Acción recibida: " + accion);

    // ========================================
    // ACCIÓN: listarMetodosPago
    // ========================================
    if ("listarMetodosPago".equals(accion)) {
        System.out.println("📋 Ejecutando: listarMetodosPago");
        
        Connection conexion = null;
        PreparedStatement statement = null;
        ResultSet resultado = null;

        try {
            Class.forName("org.postgresql.Driver");
            conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin");

            String sql = "SELECT id_metodo_pago, mp_descripcion FROM metodo_pago ORDER BY mp_descripcion";
            statement = conexion.prepareStatement(sql);
            resultado = statement.executeQuery();

            while (resultado.next()) {
                int idMetodo = resultado.getInt("id_metodo_pago");
                String descripcion = resultado.getString("mp_descripcion");
                out.println("<option value='" + idMetodo + "'>" + descripcion + "</option>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<option value=''>Error al cargar métodos</option>");
        } finally {
            if (resultado != null) try { resultado.close(); } catch (SQLException e) {}
            if (statement != null) try { statement.close(); } catch (SQLException e) {}
            if (conexion != null) try { conexion.close(); } catch (SQLException e) {}
        }
        
        return;
    }

    // ========================================
    // ACCIÓN: listarFacturas (TODAS LAS FACTURAS)
    // ========================================
    if ("listarFacturas".equals(accion)) {
        System.out.println("📋 Ejecutando: listarFacturas (TODAS)");
        
        String periodo = request.getParameter("periodo");
        String ordenFecha = request.getParameter("orden_fecha");
        String estadoFiltro = request.getParameter("estado");
        String metodoPagoFiltro = request.getParameter("metodo_pago");
        String fechaDesde = request.getParameter("fecha_desde");
        String fechaHasta = request.getParameter("fecha_hasta");

        System.out.println("Periodo: " + periodo);
        System.out.println("Orden: " + ordenFecha);
        System.out.println("Estado: " + estadoFiltro);
        System.out.println("Método Pago: " + metodoPagoFiltro);
        System.out.println("Desde: " + fechaDesde);
        System.out.println("Hasta: " + fechaHasta);

        Connection conexion = null;
        PreparedStatement statement = null;
        ResultSet resultado = null;

        try {
            System.out.println("🔌 Conectando a la base de datos...");
            Class.forName("org.postgresql.Driver");
            conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin");
            System.out.println("✅ Conexión exitosa");

            // Construir SQL
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT ");
            sql.append("    f.id_factura, ");
            sql.append("    f.fact_fecha, ");
            sql.append("    f.fact_total, ");
            sql.append("    f.estado, ");
            sql.append("    COALESCE(c.cli_nombre || ' ' || c.cli_apellido, 'Sin cliente') AS cliente, ");
            sql.append("    COALESCE(mp.mp_descripcion, 'No especificado') AS metodo_pago, ");
            sql.append("    COALESCE(s.suc_nombre, 'No especificada') AS sucursal, ");
            sql.append("    COALESCE(p.prof_nombre || ' ' || p.prof_apellido, 'No asignado') AS profesional, ");
            sql.append("    COALESCE(u.usu_nombre, 'No especificado') AS usuario ");
            sql.append("FROM facturacion f ");
            sql.append("LEFT JOIN cliente c ON f.id_cliente = c.id_cliente ");
            sql.append("LEFT JOIN metodo_pago mp ON f.id_metodo_pago = mp.id_metodo_pago ");
            sql.append("LEFT JOIN sucursal s ON f.id_sucursal = s.id_sucursal ");
            sql.append("LEFT JOIN profesional p ON f.id_profesional = p.id_profesional ");
            sql.append("LEFT JOIN usuario u ON f.id_usuario = u.id_usuario ");
            sql.append("WHERE 1=1 ");

            // Filtros de periodo
            if ("hoy".equals(periodo)) {
                sql.append("AND DATE(f.fact_fecha) = CURRENT_DATE ");
            } else if ("mes".equals(periodo)) {
                sql.append("AND EXTRACT(MONTH FROM f.fact_fecha) = EXTRACT(MONTH FROM CURRENT_DATE) ");
                sql.append("AND EXTRACT(YEAR FROM f.fact_fecha) = EXTRACT(YEAR FROM CURRENT_DATE) ");
            } else if ("rango".equals(periodo)) {
                if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
                    sql.append("AND f.fact_fecha >= ?::date ");
                }
                if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
                    sql.append("AND f.fact_fecha <= ?::date + interval '1 day' - interval '1 second' ");
                }
            }

            // Filtro de estado
            if (estadoFiltro != null && !estadoFiltro.trim().isEmpty() && !"todos".equals(estadoFiltro)) {
                sql.append("AND LOWER(f.estado) = LOWER(?) ");
            }

            // Filtro de método de pago - NUEVO
            if (metodoPagoFiltro != null && !metodoPagoFiltro.trim().isEmpty() && !"todos".equals(metodoPagoFiltro)) {
                sql.append("AND f.id_metodo_pago = ? ");
            }

            // Ordenamiento
            sql.append("ORDER BY f.fact_fecha ");
            sql.append(ordenFecha != null && "ASC".equals(ordenFecha) ? "ASC" : "DESC");
            sql.append(" LIMIT 500");

            System.out.println("📊 SQL: " + sql.toString());

            statement = conexion.prepareStatement(sql.toString());
            
            // Setear parámetros
            int paramIndex = 1;
            
            if ("rango".equals(periodo)) {
                if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
                    statement.setString(paramIndex++, fechaDesde);
                }
                if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
                    statement.setString(paramIndex++, fechaHasta);
                }
            }
            
            if (estadoFiltro != null && !estadoFiltro.trim().isEmpty() && !"todos".equals(estadoFiltro)) {
                statement.setString(paramIndex++, estadoFiltro);
            }
            
            if (metodoPagoFiltro != null && !metodoPagoFiltro.trim().isEmpty() && !"todos".equals(metodoPagoFiltro)) {
                statement.setInt(paramIndex++, Integer.parseInt(metodoPagoFiltro));
            }

            System.out.println("📊 Ejecutando consulta...");
            resultado = statement.executeQuery();

            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            int count = 0;

            while (resultado.next()) {
                count++;
                int idFactura = resultado.getInt("id_factura");
                Date fecha = resultado.getTimestamp("fact_fecha");
                double total = resultado.getDouble("fact_total");
                String estadoFactura = resultado.getString("estado");
                String metodoPago = resultado.getString("metodo_pago");
                String sucursal = resultado.getString("sucursal");
                String profesional = resultado.getString("profesional");
                String usuario = resultado.getString("usuario");
                
                // Asegurar que metodoPago no sea null
                if (metodoPago == null || metodoPago.trim().isEmpty()) {
                    metodoPago = "No especificado";
                }
                
                System.out.println("Factura #" + idFactura + " - Método: '" + metodoPago + "' - Total: " + total);

                // Badge de estado
                String badgeClass = "badge-secondary";
                if ("finalizada".equalsIgnoreCase(estadoFactura)) {
                    badgeClass = "badge-success";
                } else if ("pendiente".equalsIgnoreCase(estadoFactura)) {
                    badgeClass = "badge-warning";
                } else if ("cancelada".equalsIgnoreCase(estadoFactura)) {
                    badgeClass = "badge-danger";
                }

                out.println("<tr data-total='" + total + "' data-estado='" + estadoFactura.toLowerCase() + "' data-metodo='" + metodoPago + "'>");
                out.println("<td><strong>#" + idFactura + "</strong></td>");
                out.println("<td>" + dateFormat.format(fecha) + "</td>");
                out.println("<td class='text-right'><strong>₲ " + String.format("%,.0f", total) + "</strong></td>");
                out.println("<td>" + metodoPago + "</td>");
                out.println("<td>" + profesional + "</td>");
                out.println("<td>" + sucursal + "</td>");
                out.println("<td><span class='badge " + badgeClass + "'>" + estadoFactura.toUpperCase() + "</span></td>");
                out.println("<td>");
                out.println("<div class='btn-group btn-group-sm'>");
                out.println("<button class='btn btn-outline-primary' onclick='verDetalleFactura(" + idFactura + ")' title='Ver Detalle'>");
                out.println("<i class='fas fa-eye'></i>");
                out.println("</button>");
                out.println("<button class='btn btn-outline-success' onclick='imprimirFactura(" + idFactura + ")' title='Imprimir'>");
                out.println("<i class='fas fa-print'></i>");
                out.println("</button>");
                out.println("</div>");
                out.println("</td>");
                out.println("</tr>");
            }

            if (count == 0) {
                out.println("<tr><td colspan='8' class='text-center text-muted'>");
                out.println("<i class='fas fa-info-circle'></i> No se encontraron facturas con los filtros aplicados");
                out.println("</td></tr>");
            }

            System.out.println("✅ Consulta completada. Registros encontrados: " + count);

        } catch (ClassNotFoundException e) {
            System.out.println("❌ Error: Driver no encontrado");
            e.printStackTrace();
            out.println("<tr><td colspan='8' class='text-danger'>Error: Driver PostgreSQL no encontrado - " + e.getMessage() + "</td></tr>");
        } catch (SQLException e) {
            System.out.println("❌ Error SQL: " + e.getMessage());
            e.printStackTrace();
            out.println("<tr><td colspan='8' class='text-danger'>Error de base de datos: " + e.getMessage() + "</td></tr>");
        } catch (Exception e) {
            System.out.println("❌ Error general: " + e.getMessage());
            e.printStackTrace();
            out.println("<tr><td colspan='8' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
        } finally {
            if (resultado != null) try { resultado.close(); } catch (SQLException e) {}
            if (statement != null) try { statement.close(); } catch (SQLException e) {}
            if (conexion != null) try { conexion.close(); } catch (SQLException e) {}
        }
        
        return; // Salir después de procesar
    }

    // ========================================
    // ACCIÓN: obtenerFacturasCliente (POR CLIENTE)
    // ========================================
    if ("obtenerFacturasCliente".equals(accion)) {
        System.out.println("📋 Ejecutando: obtenerFacturasCliente");
        
        String idCliente = request.getParameter("id_cliente");
        String tipoFiltro = request.getParameter("tipo_filtro");
        String ordenFecha = request.getParameter("orden_fecha");
        String estadoFiltro = request.getParameter("filtro_estado");
        String fechaDesde = request.getParameter("fecha_desde");
        String fechaHasta = request.getParameter("fecha_hasta");

        if (idCliente == null || idCliente.trim().isEmpty()) {
            out.println("<tr><td colspan='8'>Error: ID Cliente no especificado</td></tr>");
            return;
        }

        Connection conexion = null;
        PreparedStatement statement = null;
        ResultSet resultado = null;

        try {
            Class.forName("org.postgresql.Driver");
            conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin");

            StringBuilder sql = new StringBuilder();
            sql.append("SELECT ");
            sql.append("    f.id_factura, ");
            sql.append("    f.fact_fecha, ");
            sql.append("    f.fact_total, ");
            sql.append("    f.estado, ");
            sql.append("    f.id_metodo_pago, ");
            sql.append("    f.id_metodo_pago_2, ");
            sql.append("    f.monto_pago_1, ");
            sql.append("    f.monto_pago_2, ");
            sql.append("    COALESCE(mp1.mp_descripcion, 'No especificado') AS metodo_pago, ");
            sql.append("    COALESCE(mp2.mp_descripcion, NULL) AS metodo_pago_2, ");
            sql.append("    COALESCE(s.suc_nombre, 'No especificada') AS sucursal, ");
            sql.append("    COALESCE(p.prof_nombre || ' ' || p.prof_apellido, 'No asignado') AS profesional, ");
            sql.append("    (SELECT COUNT(*) FROM det_facturacion df WHERE df.id_factura = f.id_factura) as items ");
            sql.append("FROM facturacion f ");
            sql.append("LEFT JOIN metodo_pago mp1 ON f.id_metodo_pago = mp1.id_metodo_pago ");
            sql.append("LEFT JOIN metodo_pago mp2 ON f.id_metodo_pago_2 = mp2.id_metodo_pago ");
            sql.append("LEFT JOIN sucursal s ON f.id_sucursal = s.id_sucursal ");
            sql.append("LEFT JOIN profesional p ON f.id_profesional = p.id_profesional ");
            sql.append("WHERE f.id_cliente = ? ");

            // Filtros de periodo
            if ("hoy".equals(tipoFiltro)) {
                sql.append("AND DATE(f.fact_fecha) = CURRENT_DATE ");
            } else if ("mes".equals(tipoFiltro)) {
                sql.append("AND EXTRACT(MONTH FROM f.fact_fecha) = EXTRACT(MONTH FROM CURRENT_DATE) ");
                sql.append("AND EXTRACT(YEAR FROM f.fact_fecha) = EXTRACT(YEAR FROM CURRENT_DATE) ");
            } else if ("rango".equals(tipoFiltro)) {
                if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
                    sql.append("AND f.fact_fecha >= ?::date ");
                }
                if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
                    sql.append("AND f.fact_fecha <= ?::date + interval '1 day' - interval '1 second' ");
                }
            }

            if (estadoFiltro != null && !estadoFiltro.trim().isEmpty() && !"todos".equals(estadoFiltro)) {
                sql.append("AND LOWER(f.estado) = LOWER(?) ");
            }

            sql.append("ORDER BY f.fact_fecha ");
            sql.append(ordenFecha != null && "ASC".equals(ordenFecha) ? "ASC" : "DESC");

            statement = conexion.prepareStatement(sql.toString());
            
            int paramIndex = 1;
            statement.setInt(paramIndex++, Integer.parseInt(idCliente));
            
            if ("rango".equals(tipoFiltro)) {
                if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
                    statement.setString(paramIndex++, fechaDesde);
                }
                if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
                    statement.setString(paramIndex++, fechaHasta);
                }
            }
            
            if (estadoFiltro != null && !estadoFiltro.trim().isEmpty() && !"todos".equals(estadoFiltro)) {
                statement.setString(paramIndex++, estadoFiltro);
            }

            resultado = statement.executeQuery();

            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            int count = 0;

            while (resultado.next()) {
                count++;
                int idFactura = resultado.getInt("id_factura");
                Date fecha = resultado.getTimestamp("fact_fecha");
                double total = resultado.getDouble("fact_total");
                String estadoFactura = resultado.getString("estado");
                String metodoPago = resultado.getString("metodo_pago");
                String metodoPago2 = resultado.getString("metodo_pago_2");
                double montoPago1 = resultado.getDouble("monto_pago_1");
                double montoPago2 = resultado.getDouble("monto_pago_2");
                String sucursal = resultado.getString("sucursal");
                String profesional = resultado.getString("profesional");
                int items = resultado.getInt("items");

                String badgeClass = "badge-secondary";
                if ("finalizada".equalsIgnoreCase(estadoFactura)) {
                    badgeClass = "badge-success";
                } else if ("pendiente".equalsIgnoreCase(estadoFactura)) {
                    badgeClass = "badge-warning";
                } else if ("cancelada".equalsIgnoreCase(estadoFactura)) {
                    badgeClass = "badge-danger";
                }
                
                // Formatear métodos de pago
                String metodosHTML = "";
                if (metodoPago2 != null && !metodoPago2.isEmpty()) {
                    // 2 métodos de pago (sin montos)
                    metodosHTML = metodoPago + "<br>" + metodoPago2;
                } else {
                    // 1 solo método
                    metodosHTML = metodoPago;
                }

                out.println("<tr>");
                out.println("<td><strong>#" + idFactura + "</strong><br><small class='text-muted'>" + items + " item(s)</small></td>");
                out.println("<td>" + dateFormat.format(fecha) + "</td>");
                out.println("<td class='text-right'><strong>₲ " + String.format("%,.0f", total) + "</strong></td>");
                out.println("<td><small>" + metodosHTML + "</small></td>");
                out.println("<td>" + profesional + "</td>");
                out.println("<td>" + sucursal + "</td>");
                out.println("<td><span class='badge " + badgeClass + "'>" + estadoFactura.toUpperCase() + "</span></td>");
                out.println("<td>");
                out.println("<div class='btn-group btn-group-sm'>");
                out.println("<button class='btn btn-outline-primary' onclick='verDetalleFactura(" + idFactura + ")' title='Ver Detalle'><i class='fas fa-eye'></i></button>");
                out.println("<button class='btn btn-outline-success' onclick=\"window.open('imprimir_factura.jsp?id_factura=" + idFactura + "', '_blank')\" title='Imprimir'><i class='fas fa-print'></i></button>");
                out.println("</div>");
                out.println("</td>");
                out.println("</tr>");
            }

            if (count == 0) {
                out.println("<tr><td colspan='8' class='text-center text-muted'><i class='fas fa-info-circle'></i> No se encontraron facturas con los filtros aplicados</td></tr>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<tr><td colspan='8' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
        } finally {
            if (resultado != null) try { resultado.close(); } catch (SQLException e) {}
            if (statement != null) try { statement.close(); } catch (SQLException e) {}
            if (conexion != null) try { conexion.close(); } catch (SQLException e) {}
        }
        
        return;
    }

    // Si llegamos aquí, la acción no es válida
    out.println("<tr><td colspan='8'>Error: Acción '" + accion + "' no reconocida</td></tr>");
%>

<script>
// Calcular totales para la página de gestión de facturas
if (typeof calcularTotales === 'function') {
    $(document).ready(function() {
        calcularTotales();
    });
}
</script>
