<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@ include file="../conexion.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Listado de Especialidades</title>
    <link rel="stylesheet" href="../dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="../js/jquery.min.js"></script>
</head>
<body>

<!-- Botón para abrir el modal -->
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
    Agregar Especialidad
</button>

<h1>LISTADO DE ESPECIALIDADES</h1>
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
                <i class="fas fa-edit" style="color:green" 
                   onclick="datosModif('<%= rs.getInt("id_especialidad") %>', 
                          '<%= rs.getString("espe_nombre") %>')" 
                   data-toggle="modal" data-target="#exampleModal"></i>
                <i class="fas fa-trash" style="color:red" 
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
                <h5 class="modal-title">ABM Especialidad</h5>
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
$(document).ready(function () {
    rellenar();
});

function rellenar() {
    $.get("especialidades.jsp", {campo: 'listar'}, function (data) {
        $("#listadoEspecialidades").html(data);
    });
}

$("#guardarRegistro").click(function () {
    let datosform = $("#form").serialize();
    $.ajax({
        data: datosform,
        url: 'especialidades.jsp',
        type: 'post',
        success: function (response) {
            alert(response);
            $("#exampleModal").modal('hide');
            rellenar();
            $("#form")[0].reset();
        }
    });
});

function datosModif(id, nombre) {
    $("#pk").val(id);
    $("[name='espe_nombre']").val(nombre);
    $("#campo").val('modificar');
}

function dell(id) {
    if (confirm("¿Eliminar esta especialidad?")) {
        $.post("especialidades.jsp", {campo: 'eliminar', pk: id}, function (data) {
            alert(data);
            rellenar();
        });
    }
}
</script>
</body>
</html>