<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Listado de Horarios</title>
    <link rel="stylesheet" href="../dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="../js/jquery.min.js"></script>
</head>
<body>

<!-- Botón para abrir el modal -->
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
    Agregar Horario
</button>

<h1>LISTADO DE HORARIOS</h1>
<table class="table">
    <thead class="thead-light">
        <tr>
            <th>#</th>
            <th>Hora Inicio</th>
            <th>Hora Fin</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody id="listadoHorarios">
        <%  
        String tipo = request.getParameter("campo");
        if ("listar".equals(tipo)) {
            try (PreparedStatement st = conn.prepareStatement("SELECT * FROM horario ORDER BY id_horario ASC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id_horario") %></td>
            <td><%= rs.getString("hora_inicio") %></td>
            <td><%= rs.getString("hora_fin") %></td>
            <td>
                <i class="fas fa-edit" style="color:green" 
                   onclick="datosModif('<%= rs.getInt("id_horario") %>', 
                          '<%= rs.getString("hora_inicio") %>',
                          '<%= rs.getString("hora_fin") %>')" 
                   data-toggle="modal" data-target="#exampleModal"></i>
                <i class="fas fa-trash" style="color:red" 
                   onclick="dell(<%= rs.getInt("id_horario") %>)"></i>
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
                <h5 class="modal-title" id="tituloModal">ABM Horario</h5>
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
$(document).ready(function () {
    rellenar();
    
    // Limpiar formulario al abrir modal para nuevo registro
    $('#exampleModal').on('show.bs.modal', function (e) {
        if (!$(e.relatedTarget).hasClass('fa-edit')) {
            $("#form")[0].reset();
            $("#pk").val('');
            $("#campo").val('guardar');
            $("#tituloModal").text('Nuevo Horario');
        }
    });
});

function rellenar() {
    $.get("horario.jsp", {campo: 'listar'}, function (data) {
        $("#listadoHorarios").html(data);
    });
}

$("#guardarRegistro").click(function () {
    // Validar que hora fin sea mayor a hora inicio
    const horaInicio = $("[name='hora_inicio']").val();
    const horaFin = $("[name='hora_fin']").val();
    
    if (horaInicio >= horaFin) {
        alert("La hora de fin debe ser mayor a la hora de inicio");
        return;
    }
    
    let datosform = $("#form").serialize();
    $.ajax({
        data: datosform,
        url: 'horario.jsp',
        type: 'post',
        success: function (response) {
            alert(response);
            $("#exampleModal").modal('hide');
            rellenar();
        }
    });
});

function datosModif(id, inicio, fin) {
    $("#pk").val(id);
    $("[name='hora_inicio']").val(inicio);
    $("[name='hora_fin']").val(fin);
    $("#campo").val('modificar');
    $("#tituloModal").text('Editar Horario');
}

function dell(id) {
    if (confirm("¿Eliminar este horario?")) {
        $.post("horario.jsp", {campo: 'eliminar', pk: id}, function (data) {
            alert(data);
            rellenar();
        });
    }
}
</script>
</body>
</html>







