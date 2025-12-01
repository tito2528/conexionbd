<%@ page import="net.sf.jasperreports.engine.*" %> 
<%@ page import="java.util.*" %> 
<%@ page import="java.io.*" %> 
<%@ page import="java.sql.*" %> 
<%@ include file="../conexion.jsp" %>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    try {
        File reportFile = new File(application.getRealPath("reporte/repoRoles.jasper"));
        Map parametros = new HashMap();
        
        // CORRECIÓN: Parámetro para rol
        String codigo = request.getParameter("llamarol");
        int idRol;
        
        if (codigo != null && !codigo.trim().isEmpty()) {
            // Si viene parámetro individual, usar ese ID
            idRol = Integer.parseInt(codigo);
        } else {
            // Si no viene parámetro, mostrar error
            throw new Exception("Parámetro de rol no especificado");
        }
        
        // CORRECIÓN: Parámetro correcto para el reporte de rol
        parametros.put("llamarol", idRol);

        byte[] bytes = JasperRunManager.runReportToPdf(reportFile.getPath(), parametros, conn);
        response.setContentType("application/pdf");
        response.setContentLength(bytes.length);
        response.setHeader("Content-Disposition", "inline; filename=rol_" + idRol + ".pdf");

        ServletOutputStream output = response.getOutputStream();
        output.write(bytes, 0, bytes.length);
        output.flush();
        output.close();
        
    } catch (NumberFormatException ex) {
        out.println("Error: ID de rol no válido");
    } catch (Exception ex) {
        out.println("Error generando reporte: " + ex.getMessage());
    }
%>