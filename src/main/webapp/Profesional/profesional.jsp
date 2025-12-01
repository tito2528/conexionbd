<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%@page import="java.util.regex.*"%>
<%
    String campo = request.getParameter("campo");
    String pk = request.getParameter("pk");
    String nombre = request.getParameter("prof_nombre");
    String apellido = request.getParameter("prof_apellido");
    String telefono = request.getParameter("prof_telefono");
    String email = request.getParameter("prof_email");
    String id_especialidad = request.getParameter("id_especialidad");
    String id_sucursal = request.getParameter("id_sucursal");
    String id_horario = request.getParameter("id_horario");
    String estado = request.getParameter("estado");

    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        if (conn == null) {
            out.print("❌ Error: No hay conexión a la base de datos.");
            return;
        }

        if ("guardar".equals(campo)) {
            // ===== 1. VALIDACIÓN DE CAMPOS OBLIGATORIOS =====
            if(nombre == null || nombre.trim().isEmpty() || apellido == null || apellido.trim().isEmpty()) {
                out.print("⚠️ Error: Nombre y Apellido son obligatorios");
                return;
            }
            
            // ===== 2. VALIDACIÓN DE FORMATO DE NOMBRE Y APELLIDO =====
            // Solo letras, espacios y tildes (sin números ni caracteres especiales)
            String nombreRegex = "^[a-zA-ZáéíóúÁÉÍÓÚñÑ\\s]+$";
            Pattern nombrePattern = Pattern.compile(nombreRegex);
            
            if (!nombrePattern.matcher(nombre.trim()).matches()) {
                out.print("⚠️ Error: El nombre solo puede contener letras y espacios");
                return;
            }
            
            if (!nombrePattern.matcher(apellido.trim()).matches()) {
                out.print("⚠️ Error: El apellido solo puede contener letras y espacios");
                return;
            }
            
            // ===== 3. VALIDACIÓN DE LONGITUD =====
            if (nombre.trim().length() < 2 || nombre.trim().length() > 50) {
                out.print("⚠️ Error: El nombre debe tener entre 2 y 50 caracteres");
                return;
            }
            
            if (apellido.trim().length() < 2 || apellido.trim().length() > 50) {
                out.print("⚠️ Error: El apellido debe tener entre 2 y 50 caracteres");
                return;
            }
            
            // ===== 4. VALIDACIÓN DE FORMATO DE TELÉFONO =====
            if (telefono != null && !telefono.trim().isEmpty()) {
                // Formato paraguayo: debe empezar con 0 y tener 9-10 dígitos, permite guiones
                String telefonoRegex = "^0[0-9]{8,9}$|^0[0-9]{2,3}-[0-9]{6,7}$|^0[0-9]{3}-[0-9]{3}-[0-9]{3}$";
                Pattern telefonoPattern = Pattern.compile(telefonoRegex);
                String telefonoSinEspacios = telefono.replaceAll("\\s+", "");
                
                if (!telefonoPattern.matcher(telefonoSinEspacios).matches()) {
                    out.print("⚠️ Error: Formato de teléfono inválido. Use formato: 0981123456 o 0981-123456");
                    return;
                }
            }
            
            // ===== 5. VALIDACIÓN DE FORMATO DE EMAIL =====
            if (email != null && !email.trim().isEmpty()) {
                // Patrón RFC 5322 simplificado para emails
                String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
                Pattern emailPattern = Pattern.compile(emailRegex);
                
                if (!emailPattern.matcher(email.trim()).matches()) {
                    out.print("⚠️ Error: El email '" + email + "' no tiene un formato válido. Debe contener @ y dominio válido (ejemplo: profesional@clinica.com.py)");
                    return;
                }
                
                // Validar longitud del email
                if (email.trim().length() > 100) {
                    out.print("⚠️ Error: El email no puede superar los 100 caracteres");
                    return;
                }
            }
            
            // ===== 6. VALIDACIÓN DE DUPLICADOS =====
            // Verificar si ya existe un profesional con el mismo nombre y apellido
            String checkNombreSql = "SELECT COUNT(*) FROM profesional WHERE LOWER(TRIM(prof_nombre)) = LOWER(TRIM(?)) AND LOWER(TRIM(prof_apellido)) = LOWER(TRIM(?))";
            ps = conn.prepareStatement(checkNombreSql);
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("⚠️ Error: Ya existe un profesional con el nombre: " + nombre + " " + apellido);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            
            // Verificar email duplicado si se proporciona
            if (email != null && !email.trim().isEmpty()) {
                String checkEmailSql = "SELECT COUNT(*) FROM profesional WHERE LOWER(TRIM(prof_email)) = LOWER(TRIM(?))";
                ps = conn.prepareStatement(checkEmailSql);
                ps.setString(1, email);
                rs = ps.executeQuery();
                
                if (rs.next() && rs.getInt(1) > 0) {
                    out.print("⚠️ Error: Ya existe un profesional con el email: " + email);
                    rs.close();
                    ps.close();
                    return;
                }
                rs.close();
                ps.close();
            }
            
            // Verificar teléfono duplicado si se proporciona
            if (telefono != null && !telefono.trim().isEmpty()) {
                String checkTelefonoSql = "SELECT COUNT(*) FROM profesional WHERE TRIM(prof_telefono) = TRIM(?)";
                ps = conn.prepareStatement(checkTelefonoSql);
                ps.setString(1, telefono);
                rs = ps.executeQuery();
                
                if (rs.next() && rs.getInt(1) > 0) {
                    out.print("⚠️ Error: Ya existe un profesional con el teléfono: " + telefono);
                    rs.close();
                    ps.close();
                    return;
                }
                rs.close();
                ps.close();
            }
            // ===== FIN VALIDACIÓN DE DUPLICADOS =====
            
            String sql = "INSERT INTO profesional (prof_nombre, prof_apellido, prof_telefono, prof_email, id_especialidad, id_sucursal, id_horario, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, nombre.trim());
            ps.setString(2, apellido.trim());
            ps.setString(3, telefono != null ? telefono.trim() : null);
            ps.setString(4, email != null && !email.trim().isEmpty() ? email.trim() : null);
            if (id_especialidad == null || id_especialidad.isEmpty()) ps.setNull(5, java.sql.Types.INTEGER); else ps.setInt(5, Integer.parseInt(id_especialidad));
            if (id_sucursal == null || id_sucursal.isEmpty()) ps.setNull(6, java.sql.Types.INTEGER); else ps.setInt(6, Integer.parseInt(id_sucursal));
            if (id_horario == null || id_horario.isEmpty()) ps.setNull(7, java.sql.Types.INTEGER); else ps.setInt(7, Integer.parseInt(id_horario));
            ps.setString(8, estado != null ? estado : "ACTIVO");
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.print("✅ Profesional registrado exitosamente");
            } else {
                out.print("❌ Error: No se pudo registrar el profesional");
            }

        } else if ("modificar".equals(campo)) {
            // ===== VALIDACIONES AL MODIFICAR =====
            
            // 1. Validación de campos obligatorios
            if(nombre == null || nombre.trim().isEmpty() || apellido == null || apellido.trim().isEmpty()) {
                out.print("⚠️ Error: Nombre y Apellido son obligatorios");
                return;
            }
            
            // 2. Validación de formato de nombre y apellido
            String nombreRegex = "^[a-zA-ZáéíóúÁÉÍÓÚñÑ\\s]+$";
            Pattern nombrePattern = Pattern.compile(nombreRegex);
            
            if (!nombrePattern.matcher(nombre.trim()).matches()) {
                out.print("⚠️ Error: El nombre solo puede contener letras y espacios");
                return;
            }
            
            if (!nombrePattern.matcher(apellido.trim()).matches()) {
                out.print("⚠️ Error: El apellido solo puede contener letras y espacios");
                return;
            }
            
            // 3. Validación de longitud
            if (nombre.trim().length() < 2 || nombre.trim().length() > 50) {
                out.print("⚠️ Error: El nombre debe tener entre 2 y 50 caracteres");
                return;
            }
            
            if (apellido.trim().length() < 2 || apellido.trim().length() > 50) {
                out.print("⚠️ Error: El apellido debe tener entre 2 y 50 caracteres");
                return;
            }
            
            // 4. Validación de formato de teléfono
            if (telefono != null && !telefono.trim().isEmpty()) {
                String telefonoRegex = "^0[0-9]{8,9}$|^0[0-9]{2,3}-[0-9]{6,7}$|^0[0-9]{3}-[0-9]{3}-[0-9]{3}$";
                Pattern telefonoPattern = Pattern.compile(telefonoRegex);
                String telefonoSinEspacios = telefono.replaceAll("\\s+", "");
                
                if (!telefonoPattern.matcher(telefonoSinEspacios).matches()) {
                    out.print("⚠️ Error: Formato de teléfono inválido. Use formato: 0981123456 o 0981-123456");
                    return;
                }
            }
            
            // 5. Validación de formato de email
            if (email != null && !email.trim().isEmpty()) {
                String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
                Pattern emailPattern = Pattern.compile(emailRegex);
                
                if (!emailPattern.matcher(email.trim()).matches()) {
                    out.print("⚠️ Error: El email '" + email + "' no tiene un formato válido. Debe contener @ y dominio válido (ejemplo: profesional@clinica.com.py)");
                    return;
                }
                
                if (email.trim().length() > 100) {
                    out.print("⚠️ Error: El email no puede superar los 100 caracteres");
                    return;
                }
            }
            
            // 6. Validación de duplicados (excluyendo el registro actual)
            // Verificar nombre y apellido duplicados (excluyendo el registro actual)
            String checkNombreSql = "SELECT COUNT(*) FROM profesional WHERE LOWER(TRIM(prof_nombre)) = LOWER(TRIM(?)) AND LOWER(TRIM(prof_apellido)) = LOWER(TRIM(?)) AND id_profesional != ?";
            ps = conn.prepareStatement(checkNombreSql);
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setInt(3, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("⚠️ Error: Ya existe otro profesional con el nombre: " + nombre + " " + apellido);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            
            // Verificar email duplicado si se proporciona
            if (email != null && !email.trim().isEmpty()) {
                String checkEmailSql = "SELECT COUNT(*) FROM profesional WHERE LOWER(TRIM(prof_email)) = LOWER(TRIM(?)) AND id_profesional != ?";
                ps = conn.prepareStatement(checkEmailSql);
                ps.setString(1, email);
                ps.setInt(2, Integer.parseInt(pk));
                rs = ps.executeQuery();
                
                if (rs.next() && rs.getInt(1) > 0) {
                    out.print("⚠️ Error: Ya existe otro profesional con el email: " + email);
                    rs.close();
                    ps.close();
                    return;
                }
                rs.close();
                ps.close();
            }
            
            // Verificar teléfono duplicado
            if (telefono != null && !telefono.trim().isEmpty()) {
                String checkTelefonoSql = "SELECT COUNT(*) FROM profesional WHERE TRIM(prof_telefono) = TRIM(?) AND id_profesional != ?";
                ps = conn.prepareStatement(checkTelefonoSql);
                ps.setString(1, telefono);
                ps.setInt(2, Integer.parseInt(pk));
                rs = ps.executeQuery();
                
                if (rs.next() && rs.getInt(1) > 0) {
                    out.print("⚠️ Error: Ya existe otro profesional con el teléfono: " + telefono);
                    rs.close();
                    ps.close();
                    return;
                }
                rs.close();
                ps.close();
            }
            // ===== FIN VALIDACIÓN =====

            String sql = "UPDATE profesional SET prof_nombre=?, prof_apellido=?, prof_telefono=?, prof_email=?, id_especialidad=?, id_sucursal=?, id_horario=?, estado=? WHERE id_profesional=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, nombre.trim());
            ps.setString(2, apellido.trim());
            ps.setString(3, telefono != null ? telefono.trim() : null);
            ps.setString(4, email != null && !email.trim().isEmpty() ? email.trim() : null);
            if (id_especialidad == null || id_especialidad.isEmpty()) ps.setNull(5, java.sql.Types.INTEGER); else ps.setInt(5, Integer.parseInt(id_especialidad));
            if (id_sucursal == null || id_sucursal.isEmpty()) ps.setNull(6, java.sql.Types.INTEGER); else ps.setInt(6, Integer.parseInt(id_sucursal));
            if (id_horario == null || id_horario.isEmpty()) ps.setNull(7, java.sql.Types.INTEGER); else ps.setInt(7, Integer.parseInt(id_horario));
            ps.setString(8, estado);
            ps.setInt(9, Integer.parseInt(pk));
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.print("✅ Profesional actualizado exitosamente");
            } else {
                out.print("❌ Error: No se pudo actualizar el profesional");
            }
        
        } else if ("eliminar".equals(campo)) {
            // Verificar si tiene citas asociadas antes de eliminar
            String checkSql = "SELECT COUNT(*) FROM agendamiento WHERE id_profesional=?";
            ps = conn.prepareStatement(checkSql);
            ps.setInt(1, Integer.parseInt(pk));
            rs = ps.executeQuery();
            if(rs.next() && rs.getInt(1) > 0) {
                int cantidad = rs.getInt(1);
                String mensaje = (cantidad == 1) ? "cita asociada" : "citas asociadas";
                out.print("⚠️ No se puede eliminar: El profesional tiene " + cantidad + " " + mensaje);
                return;
            }
            if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
            if (ps != null) { try { ps.close(); } catch (SQLException ignore) {} }

            String deleteSql = "DELETE FROM profesional WHERE id_profesional=?";
            ps = conn.prepareStatement(deleteSql);
            ps.setInt(1, Integer.parseInt(pk));
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.print("✅ Profesional eliminado exitosamente");
            } else {
                out.print("❌ Error: No se pudo eliminar el profesional");
            }
        }
    } catch (SQLException e) {
        String mensaje = e.getMessage().toLowerCase();
        if (mensaje.contains("duplicate") || mensaje.contains("unique")) {
            out.print("⚠️ Error: Ya existe un registro con esos datos");
        } else if (mensaje.contains("foreign key") || mensaje.contains("constraint")) {
            out.print("⚠️ Error: No se puede eliminar porque está relacionado con otros registros");
        } else if (mensaje.contains("check")) {
            out.print("⚠️ Error: Los datos no cumplen con las restricciones de la base de datos");
        } else {
            out.print("❌ Error en la base de datos: " + e.getMessage());
        }
        e.printStackTrace();
    } catch (PatternSyntaxException e) {
        out.print("❌ Error en validación de formato: " + e.getMessage());
        e.printStackTrace();
    } catch (Exception e) {
        out.print("❌ Error general: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException ignore) {}
        }
        if (ps != null) {
            try { ps.close(); } catch (SQLException ignore) {}
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>
