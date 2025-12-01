<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%@page import="java.util.regex.*"%>
<%
    PreparedStatement ps = null;
    ResultSet rs = null;

    String campo = request.getParameter("campo");
    String pk = request.getParameter("pk");
    String nombre = request.getParameter("cli_nombre");
    String apellido = request.getParameter("cli_apellido");
    String ci = request.getParameter("cli_ci");
    String telefono = request.getParameter("cli_telefono");
    String direccion = request.getParameter("cli_direccion");
    String email = request.getParameter("cli_email");
    String id_sucursal = request.getParameter("id_sucursal");
    
    try {
        if (conn == null) {
            out.print("❌ Error: No hay conexión a la base de datos.");
            return;
        }

        if ("guardar".equals(campo)) {
            // Validación de campos obligatorios
            if (nombre == null || nombre.trim().isEmpty() || 
                apellido == null || apellido.trim().isEmpty() ||
                ci == null || ci.trim().isEmpty() || 
                telefono == null || telefono.trim().isEmpty() ||
                direccion == null || direccion.trim().isEmpty()) {
                out.print("⚠️ Error: Todos los campos obligatorios deben ser completados");
                return;
            }

            // ===== VALIDACIÓN DE FORMATO DE EMAIL =====
            if (email != null && !email.trim().isEmpty()) {
                // Patrón de email válido
                String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
                Pattern pattern = Pattern.compile(emailRegex);
                Matcher matcher = pattern.matcher(email.trim());
                
                if (!matcher.matches()) {
                    out.print("⚠️ Error: El email '" + email + "' no tiene un formato válido. Debe contener @ y un dominio (ejemplo: usuario@correo.com)");
                    return;
                }
            }
            // ===== FIN VALIDACIÓN DE FORMATO =====

            // ===== VALIDACIÓN DE DUPLICADOS =====
            // 1. Verificar si ya existe un cliente con el mismo nombre y apellido
            String checkNombreSql = "SELECT COUNT(*) FROM cliente WHERE LOWER(TRIM(cli_nombre)) = LOWER(TRIM(?)) AND LOWER(TRIM(cli_apellido)) = LOWER(TRIM(?))";
            ps = conn.prepareStatement(checkNombreSql);
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("⚠️ Error: Ya existe un cliente con el nombre: " + nombre + " " + apellido);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            
            // 2. Verificar si ya existe un cliente con la misma cédula
            String checkCISql = "SELECT COUNT(*) FROM cliente WHERE TRIM(cli_ci) = TRIM(?)";
            ps = conn.prepareStatement(checkCISql);
            ps.setString(1, ci);
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("⚠️ Error: Ya existe un cliente con la cédula: " + ci);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            
            // 3. Verificar email duplicado si se proporciona
            if (email != null && !email.trim().isEmpty()) {
                String checkEmailSql = "SELECT COUNT(*) FROM cliente WHERE LOWER(TRIM(cli_email)) = LOWER(TRIM(?))";
                ps = conn.prepareStatement(checkEmailSql);
                ps.setString(1, email);
                rs = ps.executeQuery();
                
                if (rs.next() && rs.getInt(1) > 0) {
                    out.print("⚠️ Error: Ya existe un cliente con el email: " + email);
                    rs.close();
                    ps.close();
                    return;
                }
                rs.close();
                ps.close();
            }
            
            // 4. Verificar teléfono duplicado
            String checkTelefonoSql = "SELECT COUNT(*) FROM cliente WHERE TRIM(cli_telefono) = TRIM(?)";
            ps = conn.prepareStatement(checkTelefonoSql);
            ps.setString(1, telefono);
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("⚠️ Error: Ya existe un cliente con el teléfono: " + telefono);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN DE DUPLICADOS =====

            String sql = "INSERT INTO cliente (cli_nombre, cli_apellido, cli_ci, cli_telefono, cli_direccion, cli_email, id_sucursal, estado) VALUES (?, ?, ?, ?, ?, ?, ?, 'ACTIVO')";
            ps = conn.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setString(3, ci);
            ps.setString(4, telefono);
            ps.setString(5, direccion);
            ps.setString(6, email);
            if (id_sucursal == null || id_sucursal.isEmpty()) {
                ps.setNull(7, java.sql.Types.INTEGER);
            } else {
                ps.setInt(7, Integer.parseInt(id_sucursal));
            }
            
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.print("✅ Cliente registrado exitosamente");
            } else {
                out.print("❌ Error: No se pudo guardar el cliente");
            }

        } else if ("listar".equals(campo)) {
            String sql = "SELECT c.*, s.suc_nombre FROM cliente c LEFT JOIN sucursal s ON c.id_sucursal = s.id_sucursal ORDER BY c.id_cliente ASC";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            int contador = 1;
            while (rs.next()) {
%>
<tr>
    <td><%= contador %></td>
    <td><%= rs.getString("cli_nombre") %></td>
    <td><%= rs.getString("cli_apellido") %></td>
    <td><%= rs.getString("cli_ci") %></td>
    <td><%= rs.getString("cli_telefono") %></td>
    <td><%= rs.getString("cli_email") != null ? rs.getString("cli_email") : "" %></td>
    <td><%= rs.getString("cli_direccion") %></td>
    <td><%= rs.getString("suc_nombre") != null ? rs.getString("suc_nombre") : "Sin asignar" %></td>
    <td>
        <span class="badge <%= "ACTIVO".equals(rs.getString("estado")) ? "badge-success" : "badge-danger" %>">
            <%= rs.getString("estado") %>
        </span>
    </td>
    <td>
    <i class="fas fa-edit" style="color:green; cursor:pointer"
       onclick="datosModif('<%= rs.getInt("id_cliente") %>',
                        '<%= rs.getString("cli_nombre") %>',
                        '<%= rs.getString("cli_apellido") %>',
                        '<%= rs.getString("cli_ci") %>',
                        '<%= rs.getString("cli_telefono") %>',
                        '<%= rs.getString("cli_direccion") %>',
                        '<%= rs.getString("cli_email") != null ? rs.getString("cli_email") : "" %>',
                        '<%= rs.getString("id_sucursal") != null ? rs.getString("id_sucursal") : "" %>')"
       data-toggle="modal" data-target="#exampleModal"></i>
    <i class="fas fa-trash" style="color:red; cursor:pointer"
       onclick="dell(<%= rs.getInt("id_cliente") %>)"></i>
    <!-- NUEVO BOTÓN DE REPORTE INDIVIDUAL DEL CLIENTE -->
    <i class="fas fa-print" style="color:#007bff; cursor:pointer; margin-left:5px;"
       onclick="imprimirClienteIndividual(<%= rs.getInt("id_cliente") %>, '<%= rs.getString("cli_nombre") %>')"
       title="Imprimir Reporte Individual del Cliente"></i>
</td>
</tr>
<%
                contador++;
            }
            
        } else if ("modificar".equals(campo)) {
            // ===== VALIDACIÓN DE FORMATO DE EMAIL AL MODIFICAR =====
            if (email != null && !email.trim().isEmpty()) {
                // Patrón de email válido
                String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
                Pattern pattern = Pattern.compile(emailRegex);
                Matcher matcher = pattern.matcher(email.trim());
                
                if (!matcher.matches()) {
                    out.print("⚠️ Error: El email '" + email + "' no tiene un formato válido. Debe contener @ y un dominio (ejemplo: usuario@correo.com)");
                    return;
                }
            }
            // ===== FIN VALIDACIÓN DE FORMATO =====
            
            // ===== VALIDACIÓN DE DUPLICADOS AL MODIFICAR =====
            // 1. Verificar nombre y apellido duplicados (excluyendo el registro actual)
            String checkNombreSql = "SELECT COUNT(*) FROM cliente WHERE LOWER(TRIM(cli_nombre)) = LOWER(TRIM(?)) AND LOWER(TRIM(cli_apellido)) = LOWER(TRIM(?)) AND id_cliente != ?";
            ps = conn.prepareStatement(checkNombreSql);
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setInt(3, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("⚠️ Error: Ya existe otro cliente con el nombre: " + nombre + " " + apellido);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            
            // 2. Verificar cédula duplicada (excluyendo el registro actual)
            String checkCISql = "SELECT COUNT(*) FROM cliente WHERE TRIM(cli_ci) = TRIM(?) AND id_cliente != ?";
            ps = conn.prepareStatement(checkCISql);
            ps.setString(1, ci);
            ps.setInt(2, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("⚠️ Error: Ya existe otro cliente con la cédula: " + ci);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            
            // 3. Verificar email duplicado si se proporciona (excluyendo el registro actual)
            if (email != null && !email.trim().isEmpty()) {
                String checkEmailSql = "SELECT COUNT(*) FROM cliente WHERE LOWER(TRIM(cli_email)) = LOWER(TRIM(?)) AND id_cliente != ?";
                ps = conn.prepareStatement(checkEmailSql);
                ps.setString(1, email);
                ps.setInt(2, Integer.parseInt(pk));
                rs = ps.executeQuery();
                
                if (rs.next() && rs.getInt(1) > 0) {
                    out.print("⚠️ Error: Ya existe otro cliente con el email: " + email);
                    rs.close();
                    ps.close();
                    return;
                }
                rs.close();
                ps.close();
            }
            
            // 4. Verificar teléfono duplicado (excluyendo el registro actual)
            String checkTelefonoSql = "SELECT COUNT(*) FROM cliente WHERE TRIM(cli_telefono) = TRIM(?) AND id_cliente != ?";
            ps = conn.prepareStatement(checkTelefonoSql);
            ps.setString(1, telefono);
            ps.setInt(2, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.print("⚠️ Error: Ya existe otro cliente con el teléfono: " + telefono);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN DE DUPLICADOS =====
            
            String sql = "UPDATE cliente SET cli_nombre=?, cli_apellido=?, cli_ci=?, cli_telefono=?, cli_direccion=?, cli_email=?, id_sucursal=? WHERE id_cliente=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setString(3, ci);
            ps.setString(4, telefono);
            ps.setString(5, direccion);
            ps.setString(6, email);
            if (id_sucursal == null || id_sucursal.isEmpty()) {
                ps.setNull(7, java.sql.Types.INTEGER);
            } else {
                ps.setInt(7, Integer.parseInt(id_sucursal));
            }
            ps.setInt(8, Integer.parseInt(pk));
            
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.print("✅ Cliente actualizado exitosamente");
            } else {
                out.print("❌ Error: No se pudo actualizar el cliente");
            }

        } else if ("eliminar".equals(campo)) {
            // Verificar si tiene facturas asociadas
            String checkSql = "SELECT COUNT(*) FROM facturacion WHERE id_cliente = ?";
            ps = conn.prepareStatement(checkSql);
            ps.setInt(1, Integer.parseInt(pk));
            rs = ps.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                int cantidad = rs.getInt(1);
                String mensaje = (cantidad == 1) ? "factura asociada" : "facturas asociadas";
                out.print("⚠️ No se puede eliminar: El cliente tiene " + cantidad + " " + mensaje);
                return;
            }
            
            if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
            if (ps != null) { try { ps.close(); } catch (SQLException ignore) {} }
            
            String deleteSql = "DELETE FROM cliente WHERE id_cliente = ?";
            ps = conn.prepareStatement(deleteSql);
            ps.setInt(1, Integer.parseInt(pk));
            int filasAfectadas = ps.executeUpdate();
            if (filasAfectadas > 0) {
                out.print("✅ Cliente eliminado exitosamente");
            } else {
                out.print("❌ Error: No se pudo eliminar el cliente");
            }
        } else {
            out.print("⚠️ Operación no especificada");
        }
    } catch (SQLException e) {
        String mensaje = e.getMessage().toLowerCase();
        if (mensaje.contains("duplicate") || mensaje.contains("unique")) {
            out.print("⚠️ Error: Ya existe un registro con esos datos");
        } else if (mensaje.contains("foreign key") || mensaje.contains("constraint")) {
            out.print("⚠️ Error: No se puede eliminar porque está relacionado con otros registros");
        } else if (mensaje.contains("check") || mensaje.contains("constraint")) {
            out.print("⚠️ Error: Los datos no cumplen con el formato requerido. Verifique que el email sea válido (ejemplo: usuario@correo.com)");
        } else {
            out.print("❌ Error en la base de datos: " + e.getMessage());
        }
        e.printStackTrace();
    } catch (NumberFormatException e) {
        out.print("❌ Error de formato: " + e.getMessage());
    } catch (Exception e) {
        out.print("❌ Error general: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
        if (ps != null) { try { ps.close(); } catch (SQLException ignore) {} }
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
