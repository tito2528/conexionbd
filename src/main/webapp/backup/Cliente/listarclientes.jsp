<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
   
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Listado de Clientes</title>
    <link rel="stylesheet" href="../dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.0/css/all.css" crossorigin="anonymous">
    <script src="../js/jquery.min.js"></script>
</head>
<body>

<!-- Botón para abrir el modal -->
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
    Agregar Cliente
</button>

<h1>LISTADO DE CLIENTES</h1>
<table class="table">
    <thead class="thead-light">
        <tr>
            <th>#</th>
            <th>Nombre</th>
            <th>Apellido</th>
            <th>CI</th>
            <th>Teléfono</th>
            <th>Dirección</th>
            <th>Email</th>
            <th>Sucursal</th>
            <th>Acción</th>
        </tr>
    </thead>
    <tbody id="listadoclientes">
        <%  
        String tipo = request.getParameter("campo");
        
        if ("listar".equals(tipo)) {
            try (PreparedStatement st = conn.prepareStatement("SELECT * FROM cliente ORDER BY id_cliente ASC");
                 ResultSet rs = st.executeQuery()) {
                
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id_cliente") %></td>
            <td><%= rs.getString("cli_nombre") %></td>
            <td><%= rs.getString("cli_apellido") %></td>
            <td><%= rs.getString("cli_ci") %></td>
            <td><%= rs.getString("cli_telefono") %></td>
            <td><%= rs.getString("cli_direccion") %></td>
            <td><%= rs.getString("cli_email") %></td>
            <td>
                <i class="fas fa-edit" style="color:green" 
                   onclick="datosModif('<%= rs.getInt("id_cliente") %>', 
                          '<%= rs.getString("cli_nombre") %>', 
                          '<%= rs.getString("cli_apellido") %>', 
                          '<%= rs.getString("cli_ci") %>', 
                          '<%= rs.getString("cli_telefono") %>', 
                          '<%= rs.getString("cli_direccion") %>', 
                          '<%= rs.getString("cli_email") %>')" 
                   data-toggle="modal" data-target="#exampleModal"></i>
                <i class="fas fa-trash" style="color:red" 
                   onclick="dell(<%= rs.getInt("id_cliente") %>)"></i>
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
            <h5 class="modal-title">ABM Cliente</h5>
        </div>
        <div class="modal-body">
            <form id="form" name="form">
                <input type="hidden" name="campo" id="campo" value="guardar">
                <input type="hidden" name="pk" id="pk" value="">

                <div class="form-group">
                    <input type="text" class="form-control" name="cli_nombre" placeholder="Nombre" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="cli_apellido" placeholder="Apellido" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="cli_ci" placeholder="Cédula" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="cli_telefono" placeholder="Teléfono" required>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" name="cli_direccion" placeholder="Dirección" required>
                </div>
                <div class="form-group">
                    <input type="email" class="form-control" name="cli_email" placeholder="Email">
                </div>
                <!-- Nuevos campos -->
               
                <div class="form-group">
                    <select class="form-control" name="id_sucursal" required>
                        <option value="">Seleccione sucursal</option>
                        <%  
                        try (PreparedStatement st = conn.prepareStatement("SELECT id_sucursal, suc_nombre FROM sucursal");
                             ResultSet rs = st.executeQuery()) {
                            while (rs.next()) {
                                out.println("<option value='" + rs.getInt("id_sucursal") + "'>" + rs.getString("suc_nombre") + "</option>");
                            }
                        } 
                        %>
                    </select>
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

<!-- Scripts JS -->
<script src="../dist/js/bootstrap.bundle.min.js"></script>
<script>
$(document).ready(function () {
    rellenar();
});

function rellenar() {
    $.get("clientes.jsp", {campo: 'listar'}, function (data) {
        $("#listadoclientes").html(data);
    });
}

$("#guardarRegistro").click(function () {
    let datosform = $("#form").serialize();
    $.ajax({
        data: datosform,
        url: 'clientes.jsp',  // Nuevo archivo para procesar
        type: 'post',
        success: function (response) {
            alert(response);
            $("#exampleModal").modal('hide');
            rellenar();
            $("#form")[0].reset();
        }
    });
});

function datosModif(id, nombre, apellido, ci, telefono, direccion, email) {
    $("#pk").val(id);
    $("[name='cli_nombre']").val(nombre);
    $("[name='cli_apellido']").val(apellido);
    $("[name='cli_ci']").val(ci);
    $("[name='cli_telefono']").val(telefono);
    $("[name='cli_direccion']").val(direccion);
    $("[name='cli_email']").val(email);
    $("#campo").val('modificar');
}

function dell(id) {
    if (confirm("¿Eliminar este cliente?")) {
        $.post("clientes.jsp", {campo: 'eliminar', pk: id}, function (data) {
            alert(data);
            rellenar();
        });
    }
}
</script>
</body>
</html>