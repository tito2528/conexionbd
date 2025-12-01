<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date"%>
<%
    System.out.println("🔍 ControladorMovimientosCliente.jsp - INICIANDO");

    String accion = request.getParameter("accion");
    String id_cliente = request.getParameter("id_cliente");
    String fecha_desde = request.getParameter("fecha_desde");
    String fecha_hasta = request.getParameter("fecha_hasta");
    String estado_filtro = request.getParameter("estado");

    System.out.println("📝 Parámetros recibidos:");
    System.out.println("accion: " + accion);
    System.out.println("id_cliente: " + id_cliente);
    System.out.println("fecha_desde: " + fecha_desde);
    System.out.println("fecha_hasta: " + fecha_hasta);
    System.out.println("estado: " + estado_filtro);

    if (!"listarMovimientos".equals(accion)) {
        out.println("<tr><td colspan='8'>Error: Acción no válida</td></tr>");
        return;
    }

    if (id_cliente == null || id_cliente.trim().isEmpty()) {
        out.println("<tr><td colspan='8'>Error: ID Cliente no especificado</td></tr>");
        return;
    }

    Connection conexion = null;
    PreparedStatement statement = null;
    ResultSet resultado = null;

    try {
        System.out.println("🔌 Conectando a la base de datos...");
        Class.forName("org.postgresql.Driver");
        conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin");
        System.out.println("✅ Conexión exitosa");

        // ✅ CONSULTA CON JOINS CORRECTOS Y NOMBRES REALES DE LAS COLUMNAS
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ");
        sql.append("    f.id_factura, ");
        sql.append("    f.fact_fecha, ");
        sql.append("    f.fact_total, ");
        sql.append("    f.estado, ");
        sql.append("    COALESCE(mp.mp_descripcion, 'No especificado') AS metodo_pago, ");
        sql.append("    COALESCE(s.suc_nombre, 'No especificada') AS sucursal, ");
        sql.append("    COALESCE(u.usu_nombre || ' ' || u.usu_apellido, 'No especificado') AS usuario ");
        sql.append("FROM facturacion f ");
        sql.append("LEFT JOIN metodo_pago mp ON f.id_metodo_pago = mp.id_metodo_pago ");
        sql.append("LEFT JOIN sucursal s ON f.id_sucursal = s.id_sucursal ");
        sql.append("LEFT JOIN usuario u ON f.id_usuario = u.id_usuario ");
        sql.append("WHERE f.id_cliente = ? ");

        // Agregar filtros opcionales
        if (fecha_desde != null && !fecha_desde.trim().isEmpty()) {
            sql.append("AND f.fact_fecha >= ?::date ");
        }
        if (fecha_hasta != null && !fecha_hasta.trim().isEmpty()) {
            sql.append("AND f.fact_fecha <= ?::date + interval '1 day' - interval '1 second' ");
        }
        if (estado_filtro != null && !estado_filtro.trim().isEmpty()) {
            sql.append("AND LOWER(f.estado) = LOWER(?) ");
        }

        sql.append("ORDER BY f.fact_fecha DESC ");
        sql.append("LIMIT 100");

        System.out.println("📊 SQL: " + sql.toString());

        statement = conexion.prepareStatement(sql.toString());
        
        // Setear parámetros
        int paramIndex = 1;
        statement.setInt(paramIndex++, Integer.parseInt(id_cliente));
        
        if (fecha_desde != null && !fecha_desde.trim().isEmpty()) {
            statement.setString(paramIndex++, fecha_desde);
        }
        if (fecha_hasta != null && !fecha_hasta.trim().isEmpty()) {
            statement.setString(paramIndex++, fecha_hasta);
        }
        if (estado_filtro != null && !estado_filtro.trim().isEmpty()) {
            statement.setString(paramIndex++, estado_filtro);
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
            
            // ✅ AHORA SÍ TRAEMOS LOS VALORES REALES CON LOS NOMBRES CORRECTOS
            String metodoPago = resultado.getString("metodo_pago");
            String sucursal = resultado.getString("sucursal");
            String usuario = resultado.getString("usuario");

            // Determinar color del estado
            String labelClass = "label-default";
            if ("finalizada".equalsIgnoreCase(estadoFactura)) {
                labelClass = "label-success";
            } else if ("cancelada".equalsIgnoreCase(estadoFactura)) {
                labelClass = "label-danger";
            } else if ("pendiente".equalsIgnoreCase(estadoFactura)) {
                labelClass = "label-warning";
            }

            out.println("<tr>");
            out.println("<td>" + idFactura + "</td>");
            out.println("<td>" + dateFormat.format(fecha) + "</td>");
            out.println("<td>₲ " + String.format("%,.0f", total) + "</td>");
            out.println("<td>" + metodoPago + "</td>");  // ✅ mp_descripcion
            out.println("<td>" + sucursal + "</td>");    // ✅ suc_nombre
            out.println("<td>" + usuario + "</td>");     // ✅ usu_nombre + usu_apellido
            out.println("<td><span class='label " + labelClass + "'>" + estadoFactura + "</span></td>");
            out.println("<td>");
            out.println("<button class='btn btn-primary btn-xs btn-ver-detalle' data-id='" + idFactura + "'>");
            out.println("<i class='fa fa-file-pdf-o'></i> Ver PDF");
            out.println("</button>");
            out.println("</td>");
            out.println("</tr>");
        }

        if (count == 0) {
            out.println("<tr><td colspan='8' class='text-center text-muted'>");
            out.println("<i class='fa fa-info-circle'></i> No se encontraron facturas para los filtros seleccionados");
            out.println("</td></tr>");
        }

        System.out.println("✅ Consulta completada. Registros encontrados: " + count);

    } catch (ClassNotFoundException e) {
        System.out.println("❌ Error: Driver no encontrado");
        e.printStackTrace();
        out.println("<tr><td colspan='8' class='text-danger'>Error: Driver PostgreSQL no encontrado</td></tr>");
    } catch (SQLException e) {
        System.out.println("❌ Error SQL: " + e.getMessage());
        e.printStackTrace();
        out.println("<tr><td colspan='8' class='text-danger'>Error de base de datos: " + e.getMessage() + "</td></tr>");
    } catch (Exception e) {
        System.out.println("❌ Error general: " + e.getMessage());
        e.printStackTrace();
        out.println("<tr><td colspan='8' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
    } finally {
        if (resultado != null) try {
            resultado.close();
        } catch (SQLException e) {
        }
        if (statement != null) try {
            statement.close();
        } catch (SQLException e) {
        }
        if (conexion != null) try {
            conexion.close();
        } catch (SQLException e) {
        }
    }
%>
