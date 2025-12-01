<%@ page import="net.sf.jasperreports.engine.*" %> 
<%@ page import="java.util.*" %> 
<%@ page import="java.io.*" %> 
<%@ page import="java.sql.*" %> 
<%@ include file="../conexion.jsp" %>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Connection conn = null;
    try {
        // Cargar driver y establecer conexión
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin");
        
        // Ruta del archivo .jasper compilado
        File reportFile = new File(application.getRealPath("reporte/prueba.jasper"));
        
        // Verificar si el archivo existe
        if (!reportFile.exists()) {
            out.println("Error: Archivo de reporte no encontrado en: " + reportFile.getAbsolutePath());
            return;
        }
        
        // Parámetros para el reporte
        Map<String, Object> parametros = new HashMap<String, Object>();
        
        String idClienteParam = request.getParameter("id_cliente");
        
        if (idClienteParam == null || idClienteParam.trim().isEmpty()) {
            out.println("Error: ID de cliente no especificado");
            return;
        }
        
        int idCliente = Integer.parseInt(idClienteParam);
        parametros.put("id_cliente", idCliente);
        
        // Obtener información del cliente para el título
        String nombreCliente = "Cliente";
        String cedulaCliente = "";
        
        PreparedStatement ps = conn.prepareStatement(
            "SELECT cli_nombre, cli_apellido, cli_ci FROM cliente WHERE id_cliente = ?"
        );
        ps.setInt(1, idCliente);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            nombreCliente = rs.getString("cli_nombre") + " " + rs.getString("cli_apellido");
            cedulaCliente = rs.getString("cli_ci");
        }
        rs.close();
        ps.close();
        
        // Agregar parámetros adicionales
        parametros.put("nombre_cliente", nombreCliente);
        parametros.put("cedula_cliente", cedulaCliente);
        parametros.put("fecha_generacion", new java.util.Date());
        
        // Generar el reporte
        byte[] bytes = JasperRunManager.runReportToPdf(reportFile.getPath(), parametros, conn);
        
        // Configurar la respuesta
        response.setContentType("application/pdf");
        response.setContentLength(bytes.length);
        response.setHeader("Content-Disposition", "inline; filename=resumen_facturas_" + nombreCliente.replace(" ", "_") + ".pdf");

        // Enviar el PDF al navegador
        ServletOutputStream output = response.getOutputStream();
        output.write(bytes, 0, bytes.length);
        output.flush();
        output.close();
        
    } catch (ClassNotFoundException e) {
        out.println("Error: Driver de PostgreSQL no encontrado - " + e.getMessage());
    } catch (SQLException e) {
        out.println("Error de conexión a la base de datos - " + e.getMessage());
    } catch (FileNotFoundException e) {
        out.println("Error: Archivo de reporte no encontrado - " + e.getMessage());
    } catch (NumberFormatException e) {
        out.println("Error: ID de cliente no válido");
    } catch (Exception e) {
        out.println("Error generando reporte: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                // Ignorar error al cerrar
            }
        }
    }
%>