<%@ include file="conexion.jsp" %>
<%@page import="java.sql.*"%>
<%@ include file="header.jsp" %>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="text-white fw-bold">LISTADO DE ESPECIALIDADES</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="http://localhost:8080/conexionbd/index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active text-white fw-bold">Especialidades</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
    <!-- /.content-header -->

    <!-- Main content -->
    <div class="content">
        <div class="container-fluid">

            <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal" id="btnNuevo">
                Agregar Especialidad
            </button>
            <button type="button" class="btn btn-secondary" onclick="imprimirReporte('reporteEspecialidades.jasper')">
                <i class="fas fa-print"></i> Imprimir Reporte
            </button>
            <table class="table">
                <thead class="thead-light">
                    <tr>
                        <th>#</th>
                        <th>Nombre</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="listadoEspecialidades">
                    <%  
                    String tipo = request.getParameter("campo");
                    if ("listar".equals(tipo)) {
                        try (PreparedStatement st = conn.prepareStatement("SELECT * FROM especialidades ORDER BY id_especialidad ASC");
                             ResultSet rs = st.executeQuery()) {
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
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.print("Error al listar: " + e.getMessage());
                        }
                    }
                    %>
                </tbody>
            </table>

            <!-- Modal para ABM -->
            <div class="modal fade" id="exampleModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="modalTitle">Nueva Especialidad</h5>
                        </div>
                        <div class="modal-body">
                            <form id="form" name="form">
                                <input type="hidden" name="campo" id="campo" value="guardar">
                                <input type="hidden" name="pk" id="pk" value="">

                                <div class="form-group">
                                    <input type="text" class="form-control" name="espe_nombre" placeholder="Nombre de la especialidad" required>
                                </div>

                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                    <button type="button" class="btn btn-primary" id="guardarRegistro">Guardar</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <script src="../dist/js/bootstrap.bundle.min.js"></script>
<script>
function imprimirReporte(reporteEspecialidades, parametros = {}) {
    let url = 'reporteGenerico.jsp?reporte=' + encodeURIComponent(reporteEspecialidades);
    
    for (let key in parametros) {
        url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(parametros[key]);
    }

    window.open(url, '_blank');
}
// FUNCIÓN ESPECÍFICA PARA REPORTE INDIVIDUAL DE ESPECIALIDAD
function imprimirEspecialidadIndividual(idEspecialidad, nombreEspecialidad) {
    if (!idEspecialidad) {
        alert('Error: No se puede generar el reporte - ID no válido');
        return;
    }
    
    if (confirm('¿Generar reporte individual de la especialidad: ' + (nombreEspecialidad || '') + '?')) {
        // Llama directamente a Listadoespecialidad.jsp con el parámetro del ID
        let url = 'reporte/Listadoespecialidad.jsp?llamaespecialidad=' + encodeURIComponent(idEspecialidad);
        
        window.open(url, '_blank');
    }
}
</script>
            <script src="script/especialidad.js"></script> 
        </div><!-- /.container-fluid -->
    </div><!-- /.content -->
</div><!-- /.content-wrapper -->

<%@ include file="footer.jsp" %>