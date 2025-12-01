<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Listado de Servicios</title>
    <link rel="stylesheet" href="../dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="../js/jquery.min.js"></script>
</head>
<body>

<!-- Botón para abrir el modal -->
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
    Agregar Servicio
</button>

<h1>LISTADO DE SERVICIOS</h1>
<table class="table">
    <thead class="thead-light">
        <tr>
            <th>#</th>
            <th>Nombre</th>
            <th>Precio</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody id="listadoServicios">
        <%  
        String tipo = request.getParameter("campo");
        if ("listar".equals(tipo)) {
            try (PreparedStatement st = conn.prepareStatement("SELECT * FROM servicio ORDER BY id_servicio ASC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id_servicio") %></td>
            <td><%= rs.getString("ser_nombre") %></td>
            <td>$<%= rs.getBigDecimal("ser_precio") %></td>
            <td>
                <i class="fas fa-edit" style="color:green" 
                   onclick="datosModif('<%= rs.getInt("id_servicio") %>', 
                          '<%= rs.getString("ser_nombre") %>',
                          '<%= rs.getBigDecimal("ser_precio") %>')" 
                   data-toggle="modal" data-target="#exampleModal"></i>
                <i class="fas fa-trash" style="color:red" 
                   onclick="dell(<%= rs.getInt("id_servicio") %>)"></i>
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
                <h5 class="modal-title">ABM Servicio</h5>
            </div>
            <div class="modal-body">
                <form id="form" name="form">
                    <input type="hidden" name="campo" id="campo" value="guardar">
                    <input type="hidden" name="pk" id="pk" value="">

                    <div class="form-group">
                        <input type="text" class="form-control" name="ser_nombre" placeholder="Nombre del servicio" required>
                    </div>
                    <div class="form-group">
                        <input type="number" class="form-control" name="ser_precio" placeholder="Precio" min="0" step="0.01" required>
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
        }
    });
});

function rellenar() {
    $.get("servicio.jsp", {campo: 'listar'}, function (data) {
        $("#listadoServicios").html(data);
    });
}

$("#guardarRegistro").click(function () {
    let datosform = $("#form").serialize();
    $.ajax({
        data: datosform,
        url: 'servicio.jsp',
        type: 'post',
        success: function (response) {
            alert(response);
            $("#exampleModal").modal('hide');
            rellenar();
        }
    });
});

function datosModif(id, nombre, precio) {
    $("#pk").val(id);
    $("[name='ser_nombre']").val(nombre);
    $("[name='ser_precio']").val(precio);
    $("#campo").val('modificar');
}

function dell(id) {
    if (confirm("¿Eliminar este servicio?")) {
        $.post("servicio.jsp", {campo: 'eliminar', pk: id}, function (data) {
            alert(data);
            rellenar();
        });
    }
}
</script>
</body>
</html>