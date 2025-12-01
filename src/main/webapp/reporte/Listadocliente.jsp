<%@ page import="net.sf.jasperreports.engine.*" %> 
<%@ page import="java.util.*" %> 
<%@ page import="java.io.*" %> 
<%@ page import="java.sql.*" %> 
<%@ include file="../conexion.jsp" %>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    try {
        /*INDICAMOS EL LUGAR DONDE SE ENCUENTRA NUESTRO ARCHIVO JASPER*/
        File reportFile = new File(application.getRealPath("reporte/repoCliente.jasper"));
        
        Map parametros = new HashMap();
        
        // Obtener el ID del cliente desde parámetro (si viene individual) o usar valor por defecto
        String idClienteParam = request.getParameter("id_cliente");
        int codigo;
        
        if (idClienteParam != null && !idClienteParam.isEmpty()) {
            // Si viene parámetro individual, usar ese ID
            codigo = Integer.parseInt(idClienteParam);
        } else {
            // Si no viene parámetro, usar el valor por defecto que ya tenías
            codigo = 6; // Tu valor por defecto
        }
        
        parametros.put("llamacliente", codigo);

        byte[] bytes = JasperRunManager.runReportToPdf(reportFile.getPath(), parametros, conn);
        response.setContentType("application/pdf");
        response.setContentLength(bytes.length);
        response.setHeader("Content-Disposition", "inline; filename=cliente_" + codigo + ".pdf");

        ServletOutputStream output = response.getOutputStream();
        response.getOutputStream();
        output.write(bytes, 0, bytes.length);
        output.flush();
        output.close();
    } catch (java.io.FileNotFoundException ex) {
        out.println("Error: Archivo de reporte no encontrado");
    } catch (NumberFormatException ex) {
        out.println("Error: ID de cliente no válido");
    } catch (Exception ex) {
        out.println("Error generando reporte: " + ex.getMessage());
    }
%>