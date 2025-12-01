package com.tupaquete;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import net.sf.jasperreports.engine.*;
import net.sf.jasperreports.engine.export.JRPdfExporter;
import net.sf.jasperreports.export.SimpleExporterInput;
import net.sf.jasperreports.export.SimpleOutputStreamExporterOutput;

@WebServlet("/GenerarReporteMovimientos")
public class GenerarReporteMovimientos extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        Connection conn = null;
        
        try {
            // Conexión a la base de datos
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/proyecto_2025", 
                "postgres", 
                "admin"
            );
            
            if ("generarPDF".equals(accion)) {
                generarReporteMovimientos(request, response, conn);
            } else if ("verDetalleFactura".equals(accion)) {
                generarDetalleFactura(request, response, conn);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) {}
            }
        }
    }
    
    private void generarReporteMovimientos(HttpServletRequest request, HttpServletResponse response, Connection conn) 
            throws Exception {
        
        String id_cliente = request.getParameter("id_cliente");
        String fecha_desde = request.getParameter("fecha_desde");
        String fecha_hasta = request.getParameter("fecha_hasta");
        String estado = request.getParameter("estado");
        
        // Cargar reporte Jasper
        String reportPath = getServletContext().getRealPath("/reporte/movimientos_cliente.jasper");
        
        // Parámetros para el reporte
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("id_cliente", Integer.parseInt(id_cliente));
        
        if (fecha_desde != null && !fecha_desde.isEmpty()) {
            parameters.put("fecha_desde", fecha_desde);
        }
        
        if (fecha_hasta != null && !fecha_hasta.isEmpty()) {
            parameters.put("fecha_hasta", fecha_hasta);
        }
        
        if (estado != null && !estado.isEmpty()) {
            parameters.put("estado", estado);
        }
        
        // Generar PDF
        JasperPrint jasperPrint = JasperFillManager.fillReport(reportPath, parameters, conn);
        
        // Configurar respuesta
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=\"movimientos_cliente_" + id_cliente + ".pdf\"");
        
        // Exportar a PDF
        JRPdfExporter exporter = new JRPdfExporter();
        exporter.setExporterInput(new SimpleExporterInput(jasperPrint));
        exporter.setExporterOutput(new SimpleOutputStreamExporterOutput(response.getOutputStream()));
        exporter.exportReport();
    }
    
    private void generarDetalleFactura(HttpServletRequest request, HttpServletResponse response, Connection conn) 
            throws Exception {
        
        String id_factura = request.getParameter("id_factura");
        
        // Cargar reporte Jasper
        String reportPath = getServletContext().getRealPath("/reportes/detalle_factura.jasper");
        
        // Parámetros para el reporte
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("id_factura", Integer.parseInt(id_factura));
        
        // Generar PDF
        JasperPrint jasperPrint = JasperFillManager.fillReport(reportPath, parameters, conn);
        
        // Configurar respuesta
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=\"factura_" + id_factura + ".pdf\"");
        
        // Exportar a PDF
        JRPdfExporter exporter = new JRPdfExporter();
        exporter.setExporterInput(new SimpleExporterInput(jasperPrint));
        exporter.setExporterOutput(new SimpleOutputStreamExporterOutput(response.getOutputStream()));
        exporter.exportReport();
    }
}
