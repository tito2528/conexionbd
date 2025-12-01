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
                    <h1 class="text-white fw-bold">LISTADO DE MÉTODOS DE PAGO</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="http://localhost:8080/conexionbd/index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active text-white fw-bold">Método de Pago</li>
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
                <i class="fas fa-plus"></i> Agregar Método de Pago
            </button>
            <button type="button" class="btn btn-secondary" onclick="imprimirReporte('reporteMetododepago.jasper')">
                <i class="fas fa-print"></i> Imprimir Reporte
            </button>
            <table class="table table-striped">
                <thead class="thead-light">
                    <tr>
                        <th>#</th>
                        <th>Descripción</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="listadoMetodosPago">
                    <!-- Se carga por AJAX -->
                </tbody>
            </table>

            <!-- Modal para ABM -->
            <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="modalTitle">Nuevo Método de Pago</h5>
                            <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <form id="formMetodoPago">
                                <input type="hidden" id="accion" name="campo" value="guardar">
                                <input type="hidden" id="idMetodo" name="pk" value="">

                                <div class="form-group">
                                    <label for="descripcion">Descripción</label>
                                    <input type="text" class="form-control" id="descripcion" name="mp_descripcion" required 
                                           placeholder="Ej: Efectivo, Tarjeta de Crédito, Transferencia">
                                </div>

                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                                    <button type="button" class="btn btn-primary" id="btnGuardar">Guardar</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <script src="../dist/js/bootstrap.bundle.min.js"></script>
            <script src="script/metododepago.js"></script>
            <script>
function imprimirReporte(reporteMetododepago, parametros = {}) {
    let url = 'reporteGenerico.jsp?reporte=' + encodeURIComponent(reporteMetododepago);
    
    for (let key in parametros) {
        url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(parametros[key]);
    }

    window.open(url, '_blank');
}
// FUNCIÓN ESPECÍFICA PARA REPORTE INDIVIDUAL DE MÉTODO DE PAGO
function imprimirMetodoPagoIndividual(idMetodoPago, descripcionMetodo) {
    if (!idMetodoPago) {
        alert('Error: No se puede generar el reporte - ID no válido');
        return;
    }
    
    if (confirm('¿Generar reporte individual del método de pago: ' + (descripcionMetodo || '') + '?')) {
        // Llama directamente a Listadometododepago.jsp con el parámetro del ID
        let url = 'reporte/Listadometododepago.jsp?llamametodopago=' + encodeURIComponent(idMetodoPago);
        
        window.open(url, '_blank');
    }
}
</script>
        </div><!-- /.container-fluid -->
    </div><!-- /.content -->
</div><!-- /.content-wrapper -->

<%@ include file="footer.jsp" %>