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
        
        String idFacturaParam = request.getParameter("id_factura");
        
        if (idFacturaParam == null || idFacturaParam.trim().isEmpty()) {
            out.println("Error: ID de factura no especificado");
            return;
        }
        
        int idFactura = Integer.parseInt(idFacturaParam);
        parametros.put("id_factura", idFactura);
        
        // Obtener información de la factura para el nombre del archivo
        String nombreArchivo = "factura_" + idFactura;
        
        PreparedStatement ps = conn.prepareStatement(
            "SELECT f.id_factura, c.cli_nombre, c.cli_apellido " +
            "FROM facturacion f " +
            "JOIN cliente c ON f.id_cliente = c.id_cliente " +
            "WHERE f.id_factura = ?"
        );
        ps.setInt(1, idFactura);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            nombreArchivo = "factura_" + idFactura + "_" + rs.getString("cli_nombre") + "_" + rs.getString("cli_apellido");
            nombreArchivo = nombreArchivo.replace(" ", "_");
        }
        rs.close();
        ps.close();
        
        byte[] bytes = JasperRunManager.runReportToPdf(reportFile.getPath(), parametros, conn);
        
        response.setContentType("application/pdf");
        response.setContentLength(bytes.length);
        response.setHeader("Content-Disposition", "inline; filename=" + nombreArchivo + ".pdf");

        ServletOutputStream output = response.getOutputStream();
        output.write(bytes, 0, bytes.length);
        output.flush();
        output.close();
        
    } catch (Exception e) {
        out.println("Error generando reporte de factura: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {}
        }
    }
%>