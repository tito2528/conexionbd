<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    PreparedStatement ps = null;
    ResultSet rs = null;

    String tipo = request.getParameter("campo");
    String usuario = request.getParameter("usu_usuario");
    String password = request.getParameter("password");
    String nombre = request.getParameter("usu_nombre");
    String apellido = request.getParameter("usu_apellido");
    String pk = request.getParameter("pk");
    String id_rol = request.getParameter("id_rol");
    String estado = request.getParameter("estado");
    
    try {
        if (conn == null) {
            out.println("Error: No hay conexión a la base de datos.");
            return; // Salida temprana si no hay conexión
        }

        if ("guardar".equals(tipo)) {
            if (usuario == null || usuario.trim().isEmpty() || password == null || password.isEmpty() || id_rol == null || id_rol.isEmpty()) {
                out.println("⚠️ Error: Usuario, contraseña y rol son obligatorios");
                return;
            }
            
            // ===== VALIDACIÓN DE DUPLICADOS =====
            // Verificar si el nombre de usuario ya existe
            String checkUsuarioSql = "SELECT COUNT(*) FROM usuario WHERE LOWER(TRIM(usu_usuario)) = LOWER(TRIM(?))";
            ps = conn.prepareStatement(checkUsuarioSql);
            ps.setString(1, usuario);
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("⚠️ Error: Ya existe un usuario con el nombre: " + usuario);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====
            
            estado = (estado != null && !estado.isEmpty()) ? estado : "ACTIVO";
            
            // 🔒 VALIDACIÓN DE CONTRASEÑA FUERTE
            if (password.length() < 8) {
                out.println("⚠️ La contraseña debe tener al menos 8 caracteres.");
                return;
            }
            
            boolean tieneMayuscula = !password.equals(password.toLowerCase());
            boolean tieneMinuscula = !password.equals(password.toUpperCase());
            boolean tieneNumero = password.matches(".*\\\\d.*");
            
            if (!tieneMayuscula || !tieneMinuscula || !tieneNumero) {
                out.println("⚠️ La contraseña debe contener: 1 mayúscula, 1 minúscula y 1 número.");
                return;
            }
            
            // 🔒 CIFRADO AUTOMÁTICO CON BCRYPT
            String sql = "INSERT INTO usuario(usu_usuario, password, usu_nombre, usu_apellido, id_rol, estado) VALUES (?, crypt(?, gen_salt('bf')), ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, usuario);
            ps.setString(2, password);  // PostgreSQL cifra automáticamente con crypt()
            ps.setString(3, nombre);
            ps.setString(4, apellido);
            ps.setInt(5, Integer.parseInt(id_rol));
            ps.setString(6, estado);
            
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.println("✅ Usuario registrado exitosamente con contraseña cifrada");
            } else {
                out.println("❌ Error: No se pudo registrar el usuario");
            }

        } else if ("listar".equals(tipo)) {
            String sql = "SELECT u.id_usuario, u.usu_usuario, u.usu_nombre, u.usu_apellido, u.id_rol, r.rol_nombre, u.estado FROM usuario u LEFT JOIN rol r ON u.id_rol = r.id_rol ORDER BY u.id_usuario ASC";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
%>
<tr>
    <td><%= rs.getInt("id_usuario") %></td>
    <td><%= rs.getString("usu_usuario") %></td>
    <td><%= rs.getString("usu_nombre") %></td>
    <td><%= rs.getString("usu_apellido") %></td>
    <td><%= rs.getString("rol_nombre") != null ? rs.getString("rol_nombre") : "Sin rol" %></td>
    <td>
        <span class="badge <%= "ACTIVO".equals(rs.getString("estado")) ? "badge-success" : "badge-danger" %>">
            <%= rs.getString("estado") %>
        </span>
    </td>
    <td>
    <i class="fas fa-edit" style="color:green; cursor:pointer"
       onclick="datosModif('<%= rs.getInt("id_usuario") %>',
                        '<%= rs.getString("usu_usuario") %>',
                        '<%= rs.getString("usu_nombre") %>',
                        '<%= rs.getString("usu_apellido") %>',
                        '<%= rs.getInt("id_rol") %>',
                        '<%= rs.getString("estado") %>')"
       data-toggle="modal" data-target="#exampleModal"></i>
    <i class="fas fa-trash" style="color:red; cursor:pointer"
       onclick="dell(<%= rs.getInt("id_usuario") %>)"></i>
    <!-- BOTÓN PARA REPORTE INDIVIDUAL DE USUARIO -->
    <i class="fas fa-print" style="color:#007bff; cursor:pointer; margin-left:5px;"
       onclick="imprimirUsuarioIndividual(<%= rs.getInt("id_usuario") %>, '<%= rs.getString("usu_usuario") %>')"
       title="Generar Reporte del Usuario"></i>
</td>
</tr>
<%
            }
        } else if ("modificar".equals(tipo)) {
            if (usuario == null || usuario.trim().isEmpty() || id_rol == null || id_rol.isEmpty()) {
                out.println("⚠️ Error: Usuario y rol son obligatorios");
                return;
            }
            
            // ===== VALIDACIÓN DE DUPLICADOS AL MODIFICAR =====
            String checkUsuarioSql = "SELECT COUNT(*) FROM usuario WHERE LOWER(TRIM(usu_usuario)) = LOWER(TRIM(?)) AND id_usuario != ?";
            ps = conn.prepareStatement(checkUsuarioSql);
            ps.setString(1, usuario);
            ps.setInt(2, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("⚠️ Error: Ya existe otro usuario con el nombre: " + usuario);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====
            
            estado = (estado != null && !estado.isEmpty()) ? estado : "ACTIVO";
            
            String sql;
            
            // 🔒 Si hay contraseña nueva, cifrarla con bcrypt
            if(password != null && !password.isEmpty()) {
                sql = "UPDATE usuario SET " +
                      "usu_usuario = ?, " +
                      "password = crypt(?, gen_salt('bf')), " +  // Cifra la nueva contraseña
                      "usu_nombre = ?, " +
                      "usu_apellido = ?, " +
                      "id_rol = ?, " +
                      "estado = ? " +
                      "WHERE id_usuario = ?";
                
                ps = conn.prepareStatement(sql);
                ps.setString(1, usuario);
                ps.setString(2, password);  // PostgreSQL cifra automáticamente
                ps.setString(3, nombre);
                ps.setString(4, apellido);
                ps.setInt(5, Integer.parseInt(id_rol));
                ps.setString(6, estado);
                ps.setInt(7, Integer.parseInt(pk));
            } else {
                // Si no hay contraseña, mantener la actual
                sql = "UPDATE usuario SET " +
                      "usu_usuario = ?, " +
                      "usu_nombre = ?, " +
                      "usu_apellido = ?, " +
                      "id_rol = ?, " +
                      "estado = ? " +
                      "WHERE id_usuario = ?";
                
                ps = conn.prepareStatement(sql);
                ps.setString(1, usuario);
                ps.setString(2, nombre);
                ps.setString(3, apellido);
                ps.setInt(4, Integer.parseInt(id_rol));
                ps.setString(5, estado);
                ps.setInt(6, Integer.parseInt(pk));
            }
            
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.println("✅ Usuario actualizado exitosamente");
            } else {
                out.println("❌ Error: No se pudo actualizar el usuario");
            }

        } else if ("eliminar".equals(tipo)) {
            String sql = "DELETE FROM usuario WHERE id_usuario=?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(pk));
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.println("✅ Usuario eliminado exitosamente");
            } else {
                out.println("❌ Error: No se pudo eliminar el usuario");
            }
        } else {
            out.println("Operación no especificada");
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
    } catch (NumberFormatException e) {
        out.println("⚠️ Error: Formato de número inválido");
        e.printStackTrace();
    } catch (Exception e) {
        out.println("❌ Error general: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException ignore) {}
        }
        if (ps != null) {
            try { ps.close(); } catch (SQLException ignore) {}
        }
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
