<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Listado de Usuarios</title>
    <link rel="stylesheet" href="../dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="../js/jquery.min.js"></script>
</head>
<body>

<!-- Botón para abrir el modal -->
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
    Agregar Usuario
</button>

<h1>LISTADO DE USUARIOS</h1>
<table class="table">
    <thead class="thead-light">
        <tr>
            <th>#</th>
            <th>Usuario</th>
            <th>Nombre</th>
            <th>Apellido</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody id="listadoUsuarios">
        <%  
        String tipo = request.getParameter("campo");
        if ("listar".equals(tipo)) {
            try (PreparedStatement st = conn.prepareStatement("SELECT * FROM usuario ORDER BY id_usuario ASC");
                 ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id_usuario") %></td>
            <td><%= rs.getString("usu_usuario") %></td>
            <td><%= rs.getString("usu_nombre") %></td>
            <td><%= rs.getString("usu_apellido") %></td>
            <td>
                <i class="fas fa-edit" style="color:green" 
                   onclick="datosModif('<%= rs.getInt("id_usuario") %>', 
                          '<%= rs.getString("usu_usuario") %>',
                          '<%= rs.getString("usu_nombre") %>',
                          '<%= rs.getString("usu_apellido") %>')" 
                   data-toggle="modal" data-target="#exampleModal"></i>
                <i class="fas fa-trash" style="color:red" 
                   onclick="dell(<%= rs.getInt("id_usuario") %>)"></i>
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
                <h5 class="modal-title">ABM Usuario</h5>
            </div>
            <div class="modal-body">
                <form id="form" name="form">
                    <input type="hidden" name="campo" id="campo" value="guardar">
                    <input type="hidden" name="pk" id="pk" value="">

                    <div class="form-group">
                        <input type="text" class="form-control" name="usu_usuario" placeholder="Nombre de usuario" required>
                    </div>
                    <div class="form-group">
                        <input type="password" class="form-control" name="password" placeholder="Contraseña" required>
                    </div>
                    <div class="form-group">
                        <input type="text" class="form-control" name="usu_nombre" placeholder="Nombre">
                    </div>
                    <div class="form-group">
                        <input type="text" class="form-control" name="usu_apellido" placeholder="Apellido">
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
    $.get("usuario.jsp", {campo: 'listar'}, function (data) {
        $("#listadoUsuarios").html(data);
    });
}

$("#guardarRegistro").click(function () {
    let datosform = $("#form").serialize();
    $.ajax({
        data: datosform,
        url: 'usuario.jsp',
        type: 'post',
        success: function (response) {
            alert(response);
            $("#exampleModal").modal('hide');
            rellenar();
            $("#form")[0].reset();
        }
    });
});

function datosModif(id, usuario, nombre, apellido) {
    $("#pk").val(id);
    $("[name='usu_usuario']").val(usuario);
    $("[name='usu_nombre']").val(nombre);
    $("[name='usu_apellido']").val(apellido);
    $("[name='password']").val('').attr('placeholder', 'Dejar en blanco para no cambiar');
    $("#campo").val('modificar');
}

function dell(id) {
    if (confirm("¿Eliminar este usuario?")) {
        $.post("usuario.jsp", {campo: 'eliminar', pk: id}, function (data) {
            alert(data);
            rellenar();
        });
    }
}
</script>
</body>
</html>