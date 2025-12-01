<%@ page import="java.sql.*, java.util.*, net.sf.jasperreports.engine.*, net.sf.jasperreports.engine.util.JRLoader" %>
<%@ page contentType="application/pdf" %>
<%
    // 1. Validar el parámetro id_factura
    String idFacturaStr = request.getParameter("id_factura");
    if (idFacturaStr == null || idFacturaStr.trim().isEmpty()) {
        out.println("ID de factura no especificado o vacío.");
        return;
    }
    int idFactura = Integer.parseInt(idFacturaStr);

    // 2. Ruta al archivo .jasper (ajusta si tu archivo está en otra carpeta o tiene otro nombre)
    String jasperPath = application.getRealPath("/reporte/prueba.jasper"); // <-- Cambia aquí si es necesario

    // 3. Crear el mapa de parámetros
    Map<String, Object> params = new HashMap<>();
    params.put("cod", idFactura); // <-- Cambia "cod" si tu reporte espera otro nombre de parámetro

    // 4. Conexión a la base de datos
    Connection conn = null;
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin"
        );

        // 5. Llenar el reporte
        JasperPrint jasperPrint = JasperFillManager.fillReport(jasperPath, params, conn);

        // 6. Exportar a PDF y enviar al navegador
        byte[] pdfBytes = JasperExportManager.exportReportToPdf(jasperPrint);
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=\"factura_" + idFactura + ".pdf\"");
        response.getOutputStream().write(pdfBytes);
        response.getOutputStream().flush();
        response.getOutputStream().close();

    } catch (Exception e) {
        out.println("Error al generar la factura: " + e.getMessage());
        java.io.StringWriter sw = new java.io.StringWriter();
        e.printStackTrace(new java.io.PrintWriter(sw));
        out.println(sw.toString());
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }
%>