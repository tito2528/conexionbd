<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="conexion.jsp" %>
<%@ include file="header.jsp" %>
<%@page import="java.sql.*"%>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="text-white fw-bold">LISTADO DE PROFESIONALES</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active text-white fw-bold">Profesionales</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
    <div class="content">
        <div class="container-fluid">

            <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal" onclick="limpiarModal()">
                Agregar Profesional
            </button>
            <button type="button" class="btn btn-secondary" onclick="imprimirReporte('reporteProfesional.jasper')">
                <i class="fas fa-print"></i> Imprimir Reporte
            </button>

            <table class="table table-striped">
                <thead class="thead-light">
                    <tr>
                        <th>#</th>
                        <th>Nombre</th>
                        <th>Apellido</th>
                        <th>Teléfono</th>
                        <th>Email</th>
                        <th>Especialidad</th>
                        <th>Sucursal</th>
                        <th>Horarios Asignados</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="listadoprofesionales">
                    <%  
                    try (PreparedStatement st = conn.prepareStatement(
                        "SELECT p.id_profesional, p.prof_nombre, p.prof_apellido, p.prof_telefono, " +
                        "p.prof_email, e.espe_nombre as especialidad, s.suc_nombre as sucursal, " +
                        "p.id_especialidad, p.id_sucursal, p.estado " +
                        "FROM profesional p " +
                        "LEFT JOIN especialidades e ON p.id_especialidad = e.id_especialidad " +
                        "LEFT JOIN sucursal s ON p.id_sucursal = s.id_sucursal " +
                        "ORDER BY p.id_profesional ASC");
                         ResultSet rs = st.executeQuery()) {
                        
                        String[] dias = {"", "Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"};
                        
                        while (rs.next()) {
                            int idProfesional = rs.getInt("id_profesional");
                            
                            // Obtener TODOS los horarios del profesional desde profesional_horario
                            StringBuilder horariosHTML = new StringBuilder();
                            try (PreparedStatement psHorarios = conn.prepareStatement(
                                "SELECT ph.dia_semana, h.hora_inicio, h.hora_fin " +
                                "FROM profesional_horario ph " +
                                "JOIN horario h ON ph.id_horario = h.id_horario " +
                                "WHERE ph.id_profesional = ? " +
                                "ORDER BY ph.dia_semana, h.hora_inicio");
                            ) {
                                psHorarios.setInt(1, idProfesional);
                                ResultSet rsHorarios = psHorarios.executeQuery();
                                
                                if (!rsHorarios.next()) {
                                    horariosHTML.append("<span class='badge badge-warning'>Sin horarios</span>");
                                } else {
                                    horariosHTML.append("<small>");
                                    do {
                                        int diaSemana = rsHorarios.getInt("dia_semana");
                                        String horaInicio = rsHorarios.getString("hora_inicio");
                                        String horaFin = rsHorarios.getString("hora_fin");
                                        
                                        horariosHTML.append("<div class='mb-1'>");
                                        horariosHTML.append("<span class='badge badge-info'>")
                                                   .append(dias[diaSemana])
                                                   .append("</span> ");
                                        horariosHTML.append(horaInicio.substring(0, 5))
                                                   .append("-")
                                                   .append(horaFin.substring(0, 5));
                                        horariosHTML.append("</div>");
                                    } while (rsHorarios.next());
                                    horariosHTML.append("</small>");
                                }
                            }
                    %>
                    <tr>
                        <td><%= idProfesional %></td>
                        <td><%= rs.getString("prof_nombre") %></td>
                        <td><%= rs.getString("prof_apellido") %></td>
                        <td><%= rs.getString("prof_telefono") %></td>
                        <td><%= rs.getString("prof_email") %></td>
                        <td><%= rs.getString("especialidad") %></td>
                        <td><%= rs.getString("sucursal") %></td>
                        <td><%= horariosHTML.toString() %></td>
                        <td>
                            <span class="badge <%= "ACTIVO".equals(rs.getString("estado")) ? "badge-success" : "badge-danger" %>">
                                <%= rs.getString("estado") %>
                            </span>
                        </td>
                        <td>
                            <i class="fas fa-edit" style="color:green; cursor:pointer"
                               onclick="datosModif('<%= idProfesional %>', 
                                      '<%= rs.getString("prof_nombre") %>',
                                      '<%= rs.getString("prof_apellido") %>',
                                      '<%= rs.getString("prof_telefono") %>',
                                      '<%= rs.getString("prof_email") %>',
                                      '<%= rs.getObject("id_especialidad") != null ? rs.getInt("id_especialidad") : "" %>',
                                      '<%= rs.getObject("id_sucursal") != null ? rs.getInt("id_sucursal") : "" %>',
                                      '<%= rs.getString("estado") %>')" 
                               data-toggle="modal" data-target="#exampleModal"></i>
                            <i class="fas fa-trash" style="color:red; cursor:pointer"
                               onclick="dell(<%= idProfesional %>)"></i>
                            <i class="fas fa-print" style="color:#007bff; cursor:pointer; margin-left:5px;"
                               onclick="imprimirProfesionalIndividual(<%= idProfesional %>, '<%= rs.getString("prof_nombre") %>')"
                               title="Generar Reporte del Profesional"></i>
                            <!-- NUEVO: Botón para gestionar horarios -->
                            <i class="fas fa-clock" style="color:#28a745; cursor:pointer; margin-left:5px;"
                               onclick="window.location.href='listar_horarios_profesional.jsp'"
                               title="Gestionar Horarios"></i>
                        </td>
                    </tr>
                    <%
                        }
                    } catch (Exception e) {
                        out.print("<tr><td colspan='10'>Error al cargar datos: " + e.getMessage() + "</td></tr>");
                    }
                    %>
                </tbody>
            </table>

            <!-- Modal para ABM -->
            <div class="modal fade" id="exampleModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="modalTitle">ABM Profesional</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <form id="form" name="form">
                                <input type="hidden" name="campo" id="campo" value="guardar">
                                <input type="hidden" name="pk" id="pk" value="">

                                <div class="form-group">
                                    <label>Nombre *</label>
                                    <input type="text" class="form-control" name="prof_nombre" placeholder="Nombre" required>
                                    <small class="text-danger" style="display:none;">Este campo es obligatorio</small>
                                </div>
                                <div class="form-group">
                                    <label>Apellido *</label>
                                    <input type="text" class="form-control" name="prof_apellido" placeholder="Apellido" required>
                                    <small class="text-danger" style="display:none;">Este campo es obligatorio</small>
                                </div>
                                <div class="form-group">
                                    <label>Teléfono</label>
                                    <input type="text" class="form-control" name="prof_telefono" placeholder="Teléfono">
                                </div>
                                <div class="form-group">
                                    <label>Email</label>
                                    <input type="email" class="form-control" name="prof_email" placeholder="Email">
                                </div>
                                <div class="form-group">
                                    <label>Especialidad</label>
                                    <select class="form-control" name="id_especialidad">
                                        <option value="">Seleccione especialidad</option>
                                        <%  
                                        try (PreparedStatement st = conn.prepareStatement("SELECT id_especialidad, espe_nombre FROM especialidades");
                                             ResultSet rs = st.executeQuery()) {
                                            while (rs.next()) {
                                                out.println("<option value='" + rs.getInt("id_especialidad") + "'>" + rs.getString("espe_nombre") + "</option>");
                                            }
                                        } 
                                        %>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Sucursal</label>
                                    <select class="form-control" name="id_sucursal">
                                        <option value="">Seleccione sucursal</option>
                                        <%  
                                        try (PreparedStatement st = conn.prepareStatement("SELECT id_sucursal, suc_nombre FROM sucursal");
                                             ResultSet rs = st.executeQuery()) {
                                            while (rs.next()) {
                                                out.println("<option value='" + rs.getInt("id_sucursal") + "'>" + rs.getString("suc_nombre") + "</option>");
                                            }
                                        } 
                                        %>
                                    </select>
                                </div>
                                <!-- ELIMINADO: Campo de horario único -->
                                <div class="alert alert-info">
                                    <i class="fas fa-info-circle"></i> 
                                    <strong>Nota:</strong> Los horarios ahora se gestionan desde el módulo "Horarios de Profesionales"
                                </div>
                                <div class="form-group">
                                    <label>Estado</label>
                                    <select class="form-control" name="estado">
                                        <option value="ACTIVO">Activo</option>
                                        <option value="INACTIVO">Inactivo</option>
                                    </select>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="limpiarModal()">Cerrar</button>
                                    <button type="button" class="btn btn-primary" id="guardarRegistro">Guardar</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
            <script src="script/profesional.js"></script>
            <script>
                function imprimirReporte(reporteProfesional, parametros = {}) {
                    let url = 'reporteGenerico.jsp?reporte=' + encodeURIComponent(reporteProfesional);
                    
                    for (let key in parametros) {
                        url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(parametros[key]);
                    }

                    window.open(url, '_blank');
                }
                
                function imprimirProfesionalIndividual(idProfesional, nombreProfesional) {
                    if (!idProfesional) {
                        alert('Error: No se puede generar el reporte - ID no válido');
                        return;
                    }
                    
                    if (confirm('¿Generar reporte individual del profesional: ' + (nombreProfesional || '') + '?')) {
                        let url = 'reporte/Listadoprofesional.jsp?llamaprofesional=' + encodeURIComponent(idProfesional);
                        window.open(url, '_blank');
                    }
                }
            </script>
        </div>
    </div>
</div>
<%@ include file="footer.jsp" %>