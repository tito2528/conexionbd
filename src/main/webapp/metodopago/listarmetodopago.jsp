<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Listado de Métodos de Pago</title>
    <link rel="stylesheet" href="../dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="../js/jquery.min.js"></script>
</head>
<body>

<!-- Botón para abrir el modal -->
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
    <i class="fas fa-plus"></i> Agregar Método de Pago
</button>

<h1>LISTADO DE MÉTODOS DE PAGO</h1>
<table class="table table-striped">
    <thead class="thead-light">
        <tr>
            <th>#</th>
            <th>Descripción</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody id="listadoMetodosPago">
        <%  
        String tipo = request.getParameter("campo");
        if ("listar".equals(tipo)) {
            try (PreparedStatement st = conn.prepareStatement("SELECT * FROM metodo_pago ORDER BY id_metodo_pago ASC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id_metodo_pago") %></td>
            <td><%= rs.getString("mp_descripcion") %></td>
            <td>
                <i class="fas fa-edit text-primary mr-2" 
                   onclick="cargarParaEditar(<%= rs.getInt("id_metodo_pago") %>, '<%= rs.getString("mp_descripcion") %>')"
                   data-toggle="modal" data-target="#exampleModal"></i>
                <i class="fas fa-trash text-danger" 
                   onclick="confirmarEliminacion(<%= rs.getInt("id_metodo_pago") %>, '<%= rs.getString("mp_descripcion") %>')"></i>
            </td>
        </tr>
        <%
                }
            } catch (Exception e) {
                out.print("<tr><td colspan='3' class='text-danger'>Error al cargar métodos: " + e.getMessage() + "</td></tr>");
            }
        }
        %>
    </tbody>
</table>

<!-- Modal para ABM -->
<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
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
<script>
$(document).ready(function() {
    cargarMetodos();
    
    // Configurar modal cuando se abre
    $('#exampleModal').on('show.bs.modal', function(e) {
        if (!$(e.relatedTarget).hasClass('fa-edit')) {
            resetearFormulario();
        }
    });
});

function cargarMetodos() {
    $.get("metodopago.jsp", {campo: 'listar'}, function(data) {
        $("#listadoMetodosPago").html(data);
    });
}

function cargarParaEditar(id, descripcion) {
    $("#idMetodo").val(id);
    $("#descripcion").val(descripcion);
    $("#accion").val('modificar');
    $("#modalTitle").text('Editar Método de Pago');
}

function confirmarEliminacion(id, descripcion) {
    if (confirm(`¿Está seguro que desea eliminar el método de pago "${descripcion}"?`)) {
        $.post("metodopago.jsp", {campo: 'eliminar', pk: id}, function(respuesta) {
            alert(respuesta);
            cargarMetodos();
        });
    }
}

function resetearFormulario() {
    $("#formMetodoPago")[0].reset();
    $("#idMetodo").val('');
    $("#accion").val('guardar');
    $("#modalTitle").text('Nuevo Método de Pago');
}

$("#btnGuardar").click(function() {
    const datosForm = $("#formMetodoPago").serialize();
    
    $.ajax({
        url: 'metodopago.jsp',
        type: 'POST',
        data: datosForm,
        success: function(respuesta) {
            alert(respuesta);
            $('#exampleModal').modal('hide');
            cargarMetodos();
        },
        error: function() {
            alert('Error al procesar la solicitud');
        }
    });
});
</script>
</body>
</html>
