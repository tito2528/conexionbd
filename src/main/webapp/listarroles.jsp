<%@ include file="conexion.jsp" %>
<%@page import="java.sql.*"%>
<%@ include file="header.jsp" %>
<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="text-white fw-bold">LISTADO DE ROLES</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active text-white fw-bold">Roles</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
    <div class="content">
        <div class="container-fluid">
            <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#modalRol" id="btnNuevoRol">
                Agregar Rol
            </button>
            <button type="button" class="btn btn-secondary" onclick="imprimirReporte('reporteRoles.jasper')">
                <i class="fas fa-print"></i> Imprimir Reporte
            </button>
            <table class="table">
                <thead class="thead-light">
                    <tr>
                        <th>#</th>
                        <th>Nombre</th>
                        <th>Descripción</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="listadoRoles">
                    <!-- Aquí se cargan los roles por AJAX -->
                </tbody>
            </table>
            <!-- Modal para ABM -->
            <div class="modal fade" id="modalRol" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="modalTitleRol">Nuevo rol</h5>
                        </div>
                        <div class="modal-body">
                            <form id="formRol" name="formRol" autocomplete="off">
                                <input type="hidden" name="campo" id="campoRol" value="guardar">
                                <input type="hidden" name="pk" id="pkRol" value="">
                                <div class="form-group">
                                    <input type="text" class="form-control" name="rol_nombre" placeholder="Nombre del rol" required>
                                </div>
                                <div class="form-group">
                                    <input type="text" class="form-control" name="rol_descripcion" placeholder="Descripción">
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                    <button type="button" class="btn btn-primary" id="guardarRol">Guardar</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <script src="script/roles.js"></script>
            <script src="../dist/js/bootstrap.bundle.min.js"></script>
            <script>
function imprimirReporte(reporteRoles, parametros = {}) {
    let url = 'reporteGenerico.jsp?reporte=' + encodeURIComponent(reporteRoles);
    
    for (let key in parametros) {
        url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(parametros[key]);
    }

    window.open(url, '_blank');
}
// FUNCIÓN ESPECÍFICA PARA REPORTE INDIVIDUAL DE ROL
function imprimirRolIndividual(idRol, nombreRol) {
    if (!idRol) {
        alert('Error: No se puede generar el reporte - ID no válido');
        return;
    }
    
    if (confirm('¿Generar reporte individual del rol: ' + (nombreRol || '') + '?')) {
        // Llama directamente a Listadoroles.jsp con el parámetro del ID
        let url = 'reporte/Listadoroles.jsp?llamarol=' + encodeURIComponent(idRol);
        
        window.open(url, '_blank');
    }
}
</script>
        </div>
    </div>
</div>
<%@ include file="footer.jsp" %>