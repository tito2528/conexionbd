<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Listado de Sucursales</title>
    <link rel="stylesheet" href="../dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="../js/jquery.min.js"></script>
</head>
<body>

<!-- Botón para abrir el modal -->
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
    Agregar Sucursal
</button>

<h1>LISTADO DE SUCURSALES</h1>
<table class="table">
    <thead class="thead-light">
        <tr>
            <th>#</th>
            <th>Nombre</th>
            <th>Dirección</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody id="listadoSucursales">
        <%  
        String tipo = request.getParameter("campo");
        if ("listar".equals(tipo)) {
            try (PreparedStatement st = conn.prepareStatement("SELECT * FROM sucursal ORDER BY id_sucursal ASC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id_sucursal") %></td>
            <td><%= rs.getString("suc_nombre") %></td>
            <td><%= rs.getString("suc_direccion") %></td>
            <td>
                <i class="fas fa-edit" style="color:green" 
                   onclick="datosModif('<%= rs.getInt("id_sucursal") %>', 
                          '<%= rs.getString("suc_nombre") %>',
                          '<%= rs.getString("suc_direccion") %>')" 
                   data-toggle="modal" data-target="#exampleModal"></i>
                <i class="fas fa-trash" style="color:red" 
                   onclick="dell(<%= rs.getInt("id_sucursal") %>)"></i>
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
                <h5 class="modal-title" id="tituloModal">ABM Sucursal</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id="form" name="form">
                    <input type="hidden" name="campo" id="campo" value="guardar">
                    <input type="hidden" name="pk" id="pk" value="">

                    <div class="form-group">
                        <input type="text" class="form-control" name="suc_nombre" placeholder="Nombre de la sucursal" required>
                    </div>
                    <div class="form-group">
                        <input type="text" class="form-control" name="suc_direccion" placeholder="Dirección">
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
            $("#tituloModal").text('Nueva Sucursal');
        }
    });
});

function rellenar() {
    $.get("sucursal.jsp", {campo: 'listar'}, function (data) {
        $("#listadoSucursales").html(data);
    });
}

$("#guardarRegistro").click(function () {
    let datosform = $("#form").serialize();
    $.ajax({
        data: datosform,
        url: 'sucursal.jsp',
        type: 'post',
        success: function (response) {
            alert(response);
            $("#exampleModal").modal('hide');
            rellenar();
        }
    });
});

function datosModif(id, nombre, direccion) {
    $("#pk").val(id);
    $("[name='suc_nombre']").val(nombre);
    $("[name='suc_direccion']").val(direccion);
    $("#campo").val('modificar');
    $("#tituloModal").text('Editar Sucursal');
}

function dell(id) {
    if (confirm("¿Eliminar esta sucursal?")) {
        $.post("sucursal.jsp", {campo: 'eliminar', pk: id}, function (data) {
            alert(data);
            rellenar();
        });
    }
}
</script>
</body>
</html>