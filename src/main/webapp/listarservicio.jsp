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
                    <h1 class="text-white fw-bold">LISTADO DE SERVICIOS</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active text-white fw-bold">Servicios</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
    <!-- /.content-header -->

    <!-- Main content -->
    <div class="content">
        <div class="container-fluid">
            <button type="button" class="btn btn-primary" id="btnNuevo">
                <i class="fas fa-plus"></i> Agregar Servicio
            </button>
            <button type="button" class="btn btn-secondary" onclick="imprimirReporte('reporteServicioprecio.jasper')">
                <i class="fas fa-print"></i> Imprimir Reporte
            </button>
            <table class="table">
                <thead class="thead-light">
                    <tr>
                        <th>#</th>
                        <th>Nombre</th>
                        <th>Precio</th>
                        <th>Tiempo estimado</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="listadoServicios">
                    <!-- Aquí se cargan los servicios por AJAX -->
                </tbody>
            </table>

            <!-- Modal para ABM -->
            <div class="modal fade" id="modalServicio" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="modalTitle">Nuevo Servicio</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <form id="form" name="form">
                                <input type="hidden" name="campo" id="campo" value="guardar">
                                <input type="hidden" name="pk" id="pk" value="">

                                <div class="form-group">
                                    <label>Nombre del servicio *</label>
                                    <input type="text" class="form-control" name="ser_nombre" placeholder="Nombre del servicio" required>
                                    <small class="text-danger" style="display:none;">Este campo es obligatorio</small>
                                </div>
                                <div class="form-group">
                                    <label>Precio *</label>
                                    <input type="number" class="form-control" name="ser_precio" placeholder="Precio" min="10000" step="10000" required>
                                    <small class="text-danger" style="display:none;">Este campo es obligatorio</small>
                                </div>
                                <div class="form-group">
                                    <label>Duración (minutos)</label>
                                    <input type="number" class="form-control" name="duracion_minutos" placeholder="Duración en minutos" min="15" step="15" value="60">
                                </div>
                                <div class="form-group">
                                    <label>Estado</label>
                                    <select class="form-control" name="estado">
                                        <option value="ACTIVO">Activo</option>
                                        <option value="INACTIVO">Inactivo</option>
                                    </select>
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
            <script src="script/servicio.js"></script>
            <script>
function imprimirReporte(reporteServicioprecio, parametros = {}) {
    let url = 'reporteGenerico.jsp?reporte=' + encodeURIComponent(reporteServicioprecio);
    
    for (let key in parametros) {
        url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(parametros[key]);
    }

    window.open(url, '_blank');
}

function imprimirServicioIndividual(idServicio, nombreServicio) {
    if (!idServicio) {
        alert('Error: No se puede generar el reporte - ID no válido');
        return;
    }
    
    if (confirm('¿Generar reporte individual del servicio: ' + (nombreServicio || '') + '?')) {
        let url = 'reporte/ListadoServicioprecio.jsp?llamaservicio=' + encodeURIComponent(idServicio);
        window.open(url, '_blank');
    }
}
</script>
        </div><!-- /.container-fluid -->
    </div><!-- /.content -->
</div><!-- /.content-wrapper -->

<%@ include file="footer.jsp" %>