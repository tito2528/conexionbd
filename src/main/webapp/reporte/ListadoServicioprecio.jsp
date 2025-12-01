<%@ page import="net.sf.jasperreports.engine.*" %> 
<%@ page import="java.util.*" %> 
<%@ page import="java.io.*" %> 
<%@ page import="java.sql.*" %> 
<%@ include file="../conexion.jsp" %>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    try {
        File reportFile = new File(application.getRealPath("reporte/repoServicioprecio.jasper"));
        Map parametros = new HashMap();
        
        // Parámetro específico para servicio
        String codigo = request.getParameter("llamaservicio");
        int idServicio;
        
        if (codigo != null && !codigo.trim().isEmpty()) {
            // Si viene parámetro individual, usar ese ID
            idServicio = Integer.parseInt(codigo);
        } else {
            // Si no viene parámetro, mostrar error
            throw new Exception("Parámetro de servicio no especificado");
        }
        
        // Parámetro para el reporte de servicio
        parametros.put("llamaservicio", idServicio);

        byte[] bytes = JasperRunManager.runReportToPdf(reportFile.getPath(), parametros, conn);
        response.setContentType("application/pdf");
        response.setContentLength(bytes.length);
        response.setHeader("Content-Disposition", "inline; filename=servicio_" + idServicio + ".pdf");

        ServletOutputStream output = response.getOutputStream();
        output.write(bytes, 0, bytes.length);
        output.flush();
        output.close();
        
    } catch (NumberFormatException ex) {
        out.println("Error: ID de servicio no válido");
    } catch (Exception ex) {
        out.println("Error generando reporte: " + ex.getMessage());
    }
%>