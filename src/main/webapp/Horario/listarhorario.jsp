<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<%@ include file="../header.jsp" %>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">Gestión de Horarios</h1>
                </div><!-- /.col -->
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="#">Inicio</a></li>
                        <li class="breadcrumb-item active">Horarios</li>
                    </ol>
                </div><!-- /.col -->
            </div><!-- /.row -->
        </div><!-- /.container-fluid -->
    </div>
    <!-- /.content-header -->

    <!-- Main content -->
    <div class="content">
        <div class="container-fluid">

            <!-- Botón para abrir el modal -->
            <button type="button" class="btn btn-primary" onclick="agregarHorario()">
                <i class="fas fa-plus"></i> Agregar Horario
            </button>

            <h3>Listado de Horarios</h3>
            <table class="table table-bordered table-striped">
                <thead class="thead-dark">
                    <tr>
                        <th>#</th>
                        <th>Hora Inicio</th>
                        <th>Hora Fin</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="listadohorarios">
                    <!-- Los datos se cargarán aquí dinámicamente -->
                </tbody>
            </table>

            <!-- Modal para ABM -->
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

        </div><!-- /.container-fluid -->
    </div>
    <!-- /.content -->
</div>
<!-- /.content-wrapper -->

<script>
    $(document).ready(function () {
        // Inicializar tooltips
        $('[data-toggle="tooltip"]').tooltip();
        
        // Cargar lista inicial de horarios
        rellenar();
        
        // Resetear formulario al cerrar el modal
        $('#exampleModal').on('hidden.bs.modal', function () {
            $("#form")[0].reset();
            $("#modalTitle").text("Agregar Horario");
            $("#campo").val("guardar");
            $("#pk").val("");
        });
    });

    // Función para abrir modal en modo agregar
    function agregarHorario() {
        $("#exampleModal").modal('show');
    }

    // Cargar lista de horarios
    function rellenar() {
        $.get("horario.jsp", {campo: 'listar'}, function (data) {
            $("#listadohorarios").html(data);
            // Volver a inicializar tooltips para los nuevos elementos
            $('[data-toggle="tooltip"]').tooltip();
        });
    }

    // Manejar el guardado (tanto insert como update)
    $("#guardarRegistro").click(function () {
        let datosform = $("#form").serialize();
        let accion = $("#campo").val() === "guardar" ? "registrado" : "actualizado";
        
        // Validar que hora fin sea mayor a hora inicio
        let horaInicio = $("[name='hora_inicio']").val();
        let horaFin = $("[name='hora_fin']").val();
        
        if (horaInicio >= horaFin) {
            alert("La hora de fin debe ser mayor a la hora de inicio");
            return;
        }
        
        $.ajax({
            data: datosform,
            url: 'horario.jsp',
            type: 'post',
            success: function (response) {
                alert("Horario " + accion + " correctamente");
                $("#exampleModal").modal('hide');
                rellenar();
            },
            error: function(xhr, status, error) {
                alert("Error al procesar la solicitud: " + error);
            }
        });
    });

    // Preparar modal para edición
    function datosModif(id, horaInicio, horaFin) {
        $("#modalTitle").text("Modificar Horario");
        $("#pk").val(id);
        $("[name='hora_inicio']").val(horaInicio);
        $("[name='hora_fin']").val(horaFin);
        $("#campo").val('modificar');
        $("#exampleModal").modal('show');
    }

    // Eliminar horario
    function eliminarHorario(id) {
        if (confirm("¿Está seguro que desea eliminar este horario?")) {
            $.post("horario.jsp", {campo: 'eliminar', pk: id}, function (data) {
                alert(data);
                rellenar();
            }).fail(function() {
                alert("Error al intentar eliminar el horario");
            });
        }
    }
</script>

<%@ include file="../footer.jsp" %>