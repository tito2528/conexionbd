<%@page contentType="application/pdf" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.util.*"%>
<%@page import="net.sf.jasperreports.engine.*"%>
<%@ include file="../conexion.jsp" %>

<%
    Connection con = null;
    try {
        con = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin");

        // Recibir nombre del reporte desde URL o formulario
        String reporte = request.getParameter("reporte"); // ejemplo: "reportePersona.jasper"
        String reportPath = application.getRealPath("/reporte/" + reporte);

        // Parámetros del reporte
        Map<String, Object> parametros = new HashMap<String, Object>();
        // Ejemplo: si se pasa un parámetro opcional desde la URL
        if(request.getParameter("id_sucursal") != null) {
            parametros.put("id_sucursal", Integer.parseInt(request.getParameter("id_sucursal")));
        }

        JasperPrint jasperPrint = JasperFillManager.fillReport(reportPath, parametros, con);
        JasperExportManager.exportReportToPdfStream(jasperPrint, response.getOutputStream());

    } catch(Exception e) {
        out.print("Error al generar el reporte: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (con != null) { try { con.close(); } catch (SQLException ignore) {} }
    }
%>
