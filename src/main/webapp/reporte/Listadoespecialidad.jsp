<%@ page import="net.sf.jasperreports.engine.*" %> 
<%@ page import="java.util.*" %> 
<%@ page import="java.io.*" %> 
<%@ page import="java.sql.*" %> 
<%@ include file="../conexion.jsp" %>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    try {
        File reportFile = new File(application.getRealPath("reporte/repoEspecialidad.jasper"));
        Map parametros = new HashMap();
        
        // CORRECIÓN: Parámetro para especialidad
        String codigo = request.getParameter("llamaespecialidad");
        int idEspecialidad;
        
        if (codigo != null && !codigo.trim().isEmpty()) {
            // Si viene parámetro individual, usar ese ID
            idEspecialidad = Integer.parseInt(codigo);
        } else {
            // Si no viene parámetro, mostrar error
            throw new Exception("Parámetro de especialidad no especificado");
        }
        
        // CORRECIÓN: Parámetro correcto para el reporte de especialidad
        parametros.put("llamaespecialidad", idEspecialidad);

        byte[] bytes = JasperRunManager.runReportToPdf(reportFile.getPath(), parametros, conn);
        response.setContentType("application/pdf");
        response.setContentLength(bytes.length);
        response.setHeader("Content-Disposition", "inline; filename=especialidad_" + idEspecialidad + ".pdf");

        ServletOutputStream output = response.getOutputStream();
        output.write(bytes, 0, bytes.length);
        output.flush();
        output.close();
        
    } catch (NumberFormatException ex) {
        out.println("Error: ID de especialidad no válido");
    } catch (Exception ex) {
        out.println("Error generando reporte: " + ex.getMessage());
    }
%>