<%@ include file="conexion.jsp" %>
<%@page import="java.sql.*"%>
<%@ include file="header.jsp" %>
<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="text-white fw-bold">LISTADO DE HORARIO</h1>
                </div><div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="http://localhost:8080/conexionbd/index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active text-white fw-bold">Horarios</li>
                    </ol>
                </div></div></div></div>
    <div class="content">
        <div class="container-fluid">

            <button type="button" class="btn btn-primary" onclick="agregarHorario()">
                <i class="fas fa-plus"></i> Agregar Horario
            </button>
            <button type="button" class="btn btn-secondary" onclick="imprimirReporte('reporteHorario.jasper')">
                <i class="fas fa-print"></i> Imprimir Reporte
            </button>
            <table class="table">
                <thead class="thead-light">
                    <tr>
                        <th>#</th>
                        <th>Hora Inicio</th>
                        <th>Hora Fin</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="listadohorarios">
                </tbody>
            </table>

            <div class="modal fade" id="exampleModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="modalTitle">Agregar Horario</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <form id="form" name="form">
                                <input type="hidden" name="campo" id="campo" value="guardar">
                                <input type="hidden" name="pk" id="pk" value="">

                                <div class="form-group">
                                    <label>Hora Inicio</label>
                                    <input type="time" class="form-control" name="hora_inicio" required>
                                </div>
                                <div class="form-group">
                                    <label>Hora Fin</label>
                                    <input type="time" class="form-control" name="hora_fin" required>
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                            <button type="button" class="btn btn-primary" id="guardarRegistro">Guardar</button>
                        </div>
                    </div>
                </div>
            </div>

        </div></div>
</div>
<script src="script/horario.js"></script>
<script>
function imprimirReporte(reporteHorario, parametros = {}) {
    let url = 'reporteGenerico.jsp?reporte=' + encodeURIComponent(reporteHorario);
    
    for (let key in parametros) {
        url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(parametros[key]);
    }

    window.open(url, '_blank');
}
// FUNCIÓN ESPECÍFICA PARA REPORTE INDIVIDUAL DE HORARIO
function imprimirHorarioIndividual(idHorario, descripcionHorario) {
    if (!idHorario) {
        alert('Error: No se puede generar el reporte - ID no válido');
        return;
    }
    
    if (confirm('¿Generar reporte individual del horario: ' + (descripcionHorario || '') + '?')) {
        // Llama directamente a Listadohorario.jsp con el parámetro del ID
        let url = 'reporte/Listadohorario.jsp?llamahorario=' + encodeURIComponent(idHorario);
        
        window.open(url, '_blank');
    }
}
</script>
<%@ include file="footer.jsp" %>