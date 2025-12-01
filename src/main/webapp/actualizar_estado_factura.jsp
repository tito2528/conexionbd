<%@page contentType="text/plain" pageEncoding="UTF-8"%>
<%@ include file="conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    String idFacturaStr = request.getParameter("id_factura");
    String nuevoEstado = request.getParameter("nuevo_estado");

    if (idFacturaStr == null || nuevoEstado == null || idFacturaStr.trim().isEmpty() || nuevoEstado.trim().isEmpty()) {
        out.print("Parámetros inválidos.");
        return;
    }

    try {
        int idFactura = Integer.parseInt(idFacturaStr);
        String sql = "UPDATE facturacion SET estado = ? WHERE id_factura = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idFactura);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                out.print("Factura anulada correctamente.");
            } else {
                out.print("No se encontró la factura para actualizar.");
            }
        }
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
    }
%>
