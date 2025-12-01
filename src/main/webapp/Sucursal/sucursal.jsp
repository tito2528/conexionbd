<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    String campo = request.getParameter("campo");
    String pk = request.getParameter("pk");
    String nombre = request.getParameter("suc_nombre");
    String direccion = request.getParameter("suc_direccion");
    String estado = request.getParameter("estado");

    PreparedStatement ps = null;
    ResultSet rs = null;
    
    // Variables adicionales para la operación de 'eliminar'
    PreparedStatement checkClientes = null;
    PreparedStatement checkProfesionales = null;
    ResultSet rsClientes = null;
    ResultSet rsProfesionales = null;

    try {
        if (conn == null) {
            out.print("Error: No hay conexión a la base de datos.");
            return;
        }

        if ("guardar".equals(campo)) {
            if(nombre == null || nombre.trim().isEmpty()) {
                out.print("⚠️ Error: El nombre es obligatorio");
                return;
            }
            
            // ===== VALIDACIÓN DE DUPLICADOS =====
            // Verificar si el nombre de sucursal ya existe
            String checkNombreSql = "SELECT COUNT(*) FROM sucursal WHERE LOWER(TRIM(suc_nombre)) = LOWER(TRIM(?))";
            ps = conn.prepareStatement(checkNombreSql);
            ps.setString(1, nombre);
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("⚠️ Error: Ya existe una sucursal con el nombre: " + nombre);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====
            
            String sql = "INSERT INTO sucursal (suc_nombre, suc_direccion, estado) VALUES (?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, direccion);
            ps.setString(3, estado != null ? estado : "ACTIVO");
            
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.print("✅ Sucursal registrada exitosamente");
            } else {
                out.print("❌ Error: No se pudo registrar la sucursal");
            }

        } else if ("modificar".equals(campo)) {
            // ===== VALIDACIÓN DE DUPLICADOS AL MODIFICAR =====
            String checkNombreSql = "SELECT COUNT(*) FROM sucursal WHERE LOWER(TRIM(suc_nombre)) = LOWER(TRIM(?)) AND id_sucursal != ?";
            ps = conn.prepareStatement(checkNombreSql);
            ps.setString(1, nombre);
            ps.setInt(2, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("⚠️ Error: Ya existe otra sucursal con el nombre: " + nombre);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====

            String sql = "UPDATE sucursal SET suc_nombre=?, suc_direccion=?, estado=? WHERE id_sucursal=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, direccion);
            ps.setString(3, estado);
            ps.setInt(4, Integer.parseInt(pk));
            
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.print("✅ Sucursal actualizada exitosamente");
            } else {
                out.print("❌ Error: No se pudo actualizar la sucursal");
            }
            
        } else if ("eliminar".equals(campo)) {
            boolean puedeEliminar = true;
            String mensajeError = "";
            
            checkClientes = conn.prepareStatement("SELECT COUNT(*) FROM cliente WHERE id_sucursal = ?");
            checkClientes.setInt(1, Integer.parseInt(pk));
            rsClientes = checkClientes.executeQuery();
            rsClientes.next();
            int numClientes = rsClientes.getInt(1);
            
            checkProfesionales = conn.prepareStatement("SELECT COUNT(*) FROM profesional WHERE id_sucursal = ?");
            checkProfesionales.setInt(1, Integer.parseInt(pk));
            rsProfesionales = checkProfesionales.executeQuery();
            rsProfesionales.next();
            int numProfesionales = rsProfesionales.getInt(1);
            
            if(numClientes > 0 || numProfesionales > 0) {
                puedeEliminar = false;
                mensajeError = "⚠️ No se puede eliminar: La sucursal tiene " +
                               (numClientes > 0 ? numClientes + " cliente(s)" : "") +
                               (numClientes > 0 && numProfesionales > 0 ? " y " : "") +
                               (numProfesionales > 0 ? numProfesionales + " profesional(es)" : "") +
                               " asociados";
            }
            
            if(puedeEliminar) {
                String deleteSql = "DELETE FROM sucursal WHERE id_sucursal=?";
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, Integer.parseInt(pk));
                int filasAfectadas = ps.executeUpdate();
                if (filasAfectadas > 0) {
                    out.print("✅ Sucursal eliminada exitosamente");
                } else {
                    out.print("❌ Error: No se pudo eliminar la sucursal");
                }
            } else {
                out.print(mensajeError);
            }
        } else {
            out.print("Operación no especificada");
        }
    } catch (SQLException e) {
        String mensaje = e.getMessage().toLowerCase();
        if (mensaje.contains("duplicate") || mensaje.contains("unique")) {
            out.print("⚠️ Error: Ya existe un registro con esos datos");
        } else if (mensaje.contains("foreign key") || mensaje.contains("constraint")) {
            out.print("⚠️ Error: No se puede eliminar porque está relacionado con otros registros");
        } else {
            out.print("❌ Error en la base de datos: " + e.getMessage());
        }
        e.printStackTrace();
    } catch (Exception e) {
        out.print("❌ Error general: " + e.getMessage());
        e.printStackTrace();
    } finally {
        try {
            if (rsClientes != null) { try { rsClientes.close(); } catch (SQLException ignore) {} }
            if (rsProfesionales != null) { try { rsProfesionales.close(); } catch (SQLException ignore) {} }
            if (checkClientes != null) { try { checkClientes.close(); } catch (SQLException ignore) {} }
            if (checkProfesionales != null) { try { checkProfesionales.close(); } catch (SQLException ignore) {} }
            if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
            if (ps != null) { try { ps.close(); } catch (SQLException ignore) {} }
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>