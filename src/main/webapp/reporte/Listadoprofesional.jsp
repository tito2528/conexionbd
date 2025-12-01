<%@ page import="net.sf.jasperreports.engine.*" %> 
<%@ page import="java.util.*" %> 
<%@ page import="java.io.*" %> 
<%@ page import="java.sql.*" %> 
<%@ include file="../conexion.jsp" %>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    try {
        File reportFile = new File(application.getRealPath("reporte/repoProfesional.jasper"));
        Map parametros = new HashMap();
        
        // Obtener el parámetro dinámicamente desde la URL o usar valor por defecto
        String codigo = request.getParameter("llamaprofesional");
        int llama;
        
        if (codigo != null && !codigo.trim().isEmpty()) {
            // Si viene parámetro individual, usar ese ID
            llama = Integer.parseInt(codigo);
        } else {
            // Si no viene parámetro, usar valor por defecto (puedes cambiar este valor)
            throw new Exception("Parámetro profesional no especificado");
        }
        
        parametros.put("llamaprofesional", llama);

        byte[] bytes = JasperRunManager.runReportToPdf(reportFile.getPath(), parametros, conn);
        response.setContentType("application/pdf");
        response.setContentLength(bytes.length);
        response.setHeader("Content-Disposition", "inline; filename=profesional_" + llama + ".pdf");

        ServletOutputStream output = response.getOutputStream();
        output.write(bytes, 0, bytes.length);
        output.flush();
        output.close();
        
    } catch (NumberFormatException ex) {
        out.println("Error: ID de profesional no válido");
    } catch (Exception ex) {
        out.println("Error generando reporte: " + ex.getMessage());
    }
%>