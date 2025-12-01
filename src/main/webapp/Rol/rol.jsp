<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("rol_nombre");
    String descripcion = request.getParameter("rol_descripcion");
    String pk = request.getParameter("pk");

    // Bloque principal try-catch-finally para asegurar el cierre de la conexión
    try {
        if (tipo == null) {
            out.println("Operación no especificada");
            return;
        }

        if (conn == null) {
            out.println("Error: No se pudo conectar a la base de datos.");
            return;
        }

        if ("guardar".equals(tipo)) {
            // Validar campos obligatorios
            if (nombre == null || nombre.trim().isEmpty()) {
                out.println("⚠️ Error: El nombre del rol es obligatorio");
                return;
            }

            // ===== VALIDACIÓN DE DUPLICADOS =====
            // Verificar si el nombre del rol ya existe
            String checkNombreSql = "SELECT COUNT(*) FROM rol WHERE LOWER(TRIM(rol_nombre)) = LOWER(TRIM(?))";
            try (PreparedStatement psCheck = conn.prepareStatement(checkNombreSql)) {
                psCheck.setString(1, nombre);
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                        out.println("⚠️ Error: Ya existe un rol con el nombre: " + nombre);
                        return;
                    }
                }
            }
            // ===== FIN VALIDACIÓN =====

            String sql = "INSERT INTO rol(rol_nombre, rol_descripcion) VALUES(?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, nombre != null ? nombre : "");
                ps.setString(2, descripcion != null ? descripcion : "");
                ps.executeUpdate();
                out.println("✅ Rol registrado exitosamente");
            }
        } else if ("listar".equals(tipo)) {
            String sql = "SELECT id_rol, rol_nombre, rol_descripcion FROM rol ORDER BY id_rol ASC";
            try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
                while (rs.next()) {
%>
<tr>
    <td><%= rs.getInt("id_rol") %></td>
    <td><%= rs.getString("rol_nombre") %></td>
    <td><%= rs.getString("rol_descripcion") != null ? rs.getString("rol_descripcion") : "" %></td>
    <td>
    <i class="fas fa-edit" style="color:green; cursor:pointer"
       onclick="datosModifRol('<%= rs.getInt("id_rol") %>',
                 '<%= rs.getString("rol_nombre") %>',
                 '<%= rs.getString("rol_descripcion") != null ? rs.getString("rol_descripcion") : "" %>')"
       data-toggle="modal" data-target="#modalRol"></i>
    <i class="fas fa-trash" style="color:red; cursor:pointer"
       onclick="dellRol(<%= rs.getInt("id_rol") %>)"></i>
    <!-- BOTÓN PARA REPORTE INDIVIDUAL DE ROL -->
    <i class="fas fa-print" style="color:#007bff; cursor:pointer; margin-left:5px;"
       onclick="imprimirRolIndividual(<%= rs.getInt("id_rol") %>, '<%= rs.getString("rol_nombre") %>')"
       title="Generar Reporte del Rol"></i>
</td>
</tr>
<%
                }
            }
        } else if ("modificar".equals(tipo)) {
            // ===== VALIDACIÓN DE DUPLICADOS AL MODIFICAR =====
            // Verificar si el nombre ya existe en otro registro
            String checkNombreSql = "SELECT COUNT(*) FROM rol WHERE LOWER(TRIM(rol_nombre)) = LOWER(TRIM(?)) AND id_rol != ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkNombreSql)) {
                psCheck.setString(1, nombre);
                psCheck.setInt(2, Integer.parseInt(pk));
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                        out.println("⚠️ Error: Ya existe otro rol con el nombre: " + nombre);
                        return;
                    }
                }
            }
            // ===== FIN VALIDACIÓN =====

            String sql = "UPDATE rol SET rol_nombre=?, rol_descripcion=? WHERE id_rol=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, nombre != null ? nombre : "");
                ps.setString(2, descripcion != null ? descripcion : "");
                ps.setInt(3, Integer.parseInt(pk));
                ps.executeUpdate();
                out.println("✅ Rol actualizado exitosamente");
            }
        } else if ("eliminar".equals(tipo)) {
            // ===== VALIDAR RELACIONES ANTES DE ELIMINAR =====
            // Verificar si tiene usuarios asociados
            String checkUsuariosSql = "SELECT COUNT(*) FROM usuario WHERE id_rol = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkUsuariosSql)) {
                psCheck.setInt(1, Integer.parseInt(pk));
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                        int cantidad = rsCheck.getInt(1);
                        String mensaje = (cantidad == 1) ? "usuario asociado" : "usuarios asociados";
                        out.println("⚠️ No se puede eliminar: El rol tiene " + cantidad + " " + mensaje);
                        return;
                    }
                }
            }
            // ===== FIN VALIDACIÓN =====

            String sql = "DELETE FROM rol WHERE id_rol=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, Integer.parseInt(pk));
                ps.executeUpdate();
                out.println("✅ Rol eliminado exitosamente");
            }
        }
    } catch (SQLException e) {
        String mensaje = e.getMessage().toLowerCase();
        if (mensaje.contains("duplicate") || mensaje.contains("unique")) {
            out.println("⚠️ Error: Ya existe un registro con esos datos");
        } else if (mensaje.contains("foreign key") || mensaje.contains("constraint")) {
            out.println("⚠️ Error: No se puede eliminar porque está relacionado con otros registros");
        } else {
            out.println("❌ Error en la base de datos: " + e.getMessage());
        }
        e.printStackTrace();
    } catch (Exception e) {
        out.println("❌ Error general: " + e.getMessage());
        e.printStackTrace();
    } finally {
        // Cierre de la conexión en el bloque finally
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                out.println("Error al cerrar la conexión: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }
%>