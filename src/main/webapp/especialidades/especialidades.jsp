<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("espe_nombre");
    String pk = request.getParameter("pk");

    if (tipo == null) {
        out.println("Operación no especificada");
        return;
    }
    
    try {
        con = conn; // Asumiendo que 'conn' es el objeto Connection del archivo incluido.

        if ("guardar".equals(tipo)) {
            // Validar campos obligatorios
            if (nombre == null || nombre.trim().isEmpty()) {
                out.println("⚠️ Error: El nombre de la especialidad es obligatorio");
                return;
            }

            // ===== VALIDACIÓN DE DUPLICADOS =====
            // Verificar si la especialidad ya existe
            String checkNombreSql = "SELECT COUNT(*) FROM especialidades WHERE LOWER(TRIM(espe_nombre)) = LOWER(TRIM(?))";
            ps = con.prepareStatement(checkNombreSql);
            ps.setString(1, nombre);
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("⚠️ Error: Ya existe una especialidad con el nombre: " + nombre);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====

            // Se usa PreparedStatement para prevenir inyección SQL.
            ps = con.prepareStatement("INSERT INTO especialidades(espe_nombre) VALUES(?)");
            ps.setString(1, nombre);
            ps.executeUpdate();
            out.println("✅ Especialidad registrada exitosamente");
        } else if ("listar".equals(tipo)) {
            // Se usa PreparedStatement para una ejecución más segura, aunque Statement también podría usarse aquí.
            ps = con.prepareStatement("SELECT id_especialidad, espe_nombre FROM especialidades ORDER BY id_especialidad ASC");
            rs = ps.executeQuery();
            while (rs.next()) {
%>
<tr>
    <td><%= rs.getInt("id_especialidad") %></td>
    <td><%= rs.getString("espe_nombre") %></td>
    <td>
    <i class="fas fa-edit" style="color:green; cursor:pointer"
       onclick="datosModif('<%= rs.getInt("id_especialidad") %>',
                     '<%= rs.getString("espe_nombre") %>')"
       data-toggle="modal" data-target="#exampleModal"></i>
    <i class="fas fa-trash" style="color:red; cursor:pointer"
       onclick="dell(<%= rs.getInt("id_especialidad") %>)"></i>
    <!-- BOTÓN PARA REPORTE INDIVIDUAL DE ESPECIALIDAD -->
    <i class="fas fa-print" style="color:#007bff; cursor:pointer; margin-left:5px;"
       onclick="imprimirEspecialidadIndividual(<%= rs.getInt("id_especialidad") %>, '<%= rs.getString("espe_nombre") %>')"
       title="Generar Reporte de la Especialidad"></i>
</td>
</tr>
<%
            }
        } else if ("modificar".equals(tipo)) {
            // ===== VALIDACIÓN DE DUPLICADOS AL MODIFICAR =====
            String checkNombreSql = "SELECT COUNT(*) FROM especialidades WHERE LOWER(TRIM(espe_nombre)) = LOWER(TRIM(?)) AND id_especialidad != ?";
            ps = con.prepareStatement(checkNombreSql);
            ps.setString(1, nombre);
            ps.setInt(2, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                out.println("⚠️ Error: Ya existe otra especialidad con el nombre: " + nombre);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====

            // Se usa PreparedStatement para prevenir inyección SQL.
            ps = con.prepareStatement("UPDATE especialidades SET espe_nombre=? WHERE id_especialidad=?");
            ps.setString(1, nombre);
            ps.setInt(2, Integer.parseInt(pk));
            ps.executeUpdate();
            out.println("✅ Especialidad actualizada exitosamente");
        } else if ("eliminar".equals(tipo)) {
            // ===== VALIDAR RELACIONES ANTES DE ELIMINAR =====
            // Verificar si tiene profesionales asociados
            String checkProfesionalesSql = "SELECT COUNT(*) FROM profesional WHERE id_especialidad = ?";
            ps = con.prepareStatement(checkProfesionalesSql);
            ps.setInt(1, Integer.parseInt(pk));
            rs = ps.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                int cantidad = rs.getInt(1);
                String mensaje = (cantidad == 1) ? "profesional asociado" : "profesionales asociados";
                out.println("⚠️ No se puede eliminar: La especialidad tiene " + cantidad + " " + mensaje);
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
            // ===== FIN VALIDACIÓN =====

            // Se usa PreparedStatement para prevenir inyección SQL.
            ps = con.prepareStatement("DELETE FROM especialidades WHERE id_especialidad=?");
            ps.setInt(1, Integer.parseInt(pk));
            ps.executeUpdate();
            out.println("✅ Especialidad eliminada exitosamente");
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
        try {
            // Se cierran los recursos en el orden correcto para liberar memoria.
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null && !con.isClosed()) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>