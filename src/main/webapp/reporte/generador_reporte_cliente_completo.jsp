<%@ page import="net.sf.jasperreports.engine.*" %> 
<%@ page import="java.util.*" %> 
<%@ page import="java.io.*" %> 
<%@ page import="java.sql.*" %> 
<%@ include file="../conexion.jsp" %>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Connection conn = null;
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin");
        
        File reportFile = new File(application.getRealPath("reporte/prueba.jasper"));
        
        if (!reportFile.exists()) {
            out.println("Error: Archivo de reporte no encontrado en: " + reportFile.getAbsolutePath());
            return;
        }
        
        Map<String, Object> parametros = new HashMap<String, Object>();
        
        String idClienteParam = request.getParameter("id_cliente");
        
        if (idClienteParam == null || idClienteParam.trim().isEmpty()) {
            out.println("Error: ID de cliente no especificado");
            return;
        }
        
        int idCliente = Integer.parseInt(idClienteParam);
        parametros.put("id_cliente", idCliente);
        
        // Obtener información del cliente para el nombre del archivo
        String nombreArchivo = "reporte_cliente";
        
        PreparedStatement ps = conn.prepareStatement(
            "SELECT cli_nombre, cli_apellido, cli_ci FROM cliente WHERE id_cliente = ?"
        );
        ps.setInt(1, idCliente);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            nombreArchivo = "reporte_completo_" + rs.getString("cli_nombre") + "_" + rs.getString("cli_apellido");
            nombreArchivo = nombreArchivo.replace(" ", "_");
            
            // Agregar parámetros adicionales para el reporte
            parametros.put("nombre_cliente", rs.getString("cli_nombre") + " " + rs.getString("cli_apellido"));
            parametros.put("cedula_cliente", rs.getString("cli_ci"));
        }
        rs.close();
        ps.close();
        
        parametros.put("fecha_generacion", new java.util.Date());
        
        byte[] bytes = JasperRunManager.runReportToPdf(reportFile.getPath(), parametros, conn);
        
        response.setContentType("application/pdf");
        response.setContentLength(bytes.length);
        response.setHeader("Content-Disposition", "inline; filename=" + nombreArchivo + ".pdf");

        ServletOutputStream output = response.getOutputStream();
        output.write(bytes, 0, bytes.length);
        output.flush();
        output.close();
        
    } catch (Exception e) {
        out.println("Error generando reporte completo del cliente: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {}
        }
    }
%>