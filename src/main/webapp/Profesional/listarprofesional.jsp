<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion.jsp" %>
<%@ include file="../header.jsp" %>

<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <div class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1 class="m-0">Listado de Profesionales</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="#">Home</a></li>
              <li class="breadcrumb-item active">Profesionales</li>
            </ol>
          </div>
        </div>
      </div>
    </div>

    <!-- Main content -->
    <div class="content">
      <div class="container-fluid">
        <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
            Agregar Profesional
        </button>

        <h1>LISTADO DE PROFESIONALES</h1>
        <table class="table">
            <thead class="thead-light">
                <tr>
                    <th>#</th>
                    <th>Nombre</th>
                    <th>Apellido</th>
                    <th>Teléfono</th>
                    <th>Email</th>
                    <th>Especialidad</th>
                    <th>Sucursal</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody id="listadoprofesionales">
                <%  
                try (PreparedStatement st = conn.prepareStatement(
                    "SELECT p.id_profesional, p.prof_nombre, p.prof_apellido, p.prof_telefono, " +
                    "p.prof_email, e.espe_nombre as especialidad, s.suc_nombre as sucursal, " +
                    "p.id_especialidad, p.id_sucursal " +
                    "FROM profesional p " +
                    "LEFT JOIN especialidades e ON p.id_especialidad = e.id_especialidad " +
                    "LEFT JOIN sucursal s ON p.id_sucursal = s.id_sucursal " +
                    "ORDER BY p.id_profesional ASC");
                     ResultSet rs = st.executeQuery()) {
                    
                    while (rs.next()) {
                %>
                <tr>
                    <td><%= rs.getInt("id_profesional") %></td>
                    <td><%= rs.getString("prof_nombre") %></td>
                    <td><%= rs.getString("prof_apellido") %></td>
                    <td><%= rs.getString("prof_telefono") %></td>
                    <td><%= rs.getString("prof_email") %></td>
                    <td><%= rs.getString("especialidad") %></td>
                    <td><%= rs.getString("sucursal") %></td>
                    <td>
                        <i class="fas fa-edit" style="color:green" 
                           onclick="datosModif('<%= rs.getInt("id_profesional") %>', 
                                  '<%= rs.getString("prof_nombre") %>',
                                  '<%= rs.getString("prof_apellido") %>',
                                  '<%= rs.getString("prof_telefono") %>',
                                  '<%= rs.getString("prof_email") %>',
                                  '<%= rs.getObject("id_especialidad") != null ? rs.getInt("id_especialidad") : "" %>',
                                  '<%= rs.getObject("id_sucursal") != null ? rs.getInt("id_sucursal") : "" %>')" 
                           data-toggle="modal" data-target="#exampleModal"></i>
                        <i class="fas fa-trash" style="color:red" 
                           onclick="dell(<%= rs.getInt("id_profesional") %>)"></i>
                    </td>
                </tr>
                <%
                    }
                } catch (Exception e) {
                    out.print("<tr><td colspan='8'>Error al cargar datos: " + e.getMessage() + "</td></tr>");
                }
                %>
            </tbody>
        </table>

        <!-- Modal para ABM -->
        <div class="modal fade" id="exampleModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">ABM Profesional</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form id="form" name="form" action="profesional.jsp" method="post">
                            <input type="hidden" name="campo" id="campo" value="guardar">
                            <input type="hidden" name="pk" id="pk" value="">

                            <div class="form-group">
                                <label>Nombre</label>
                                <input type="text" class="form-control" name="prof_nombre" placeholder="Nombre" required>
                            </div>
                            <div class="form-group">
                                <label>Apellido</label>
                                <input type="text" class="form-control" name="prof_apellido" placeholder="Apellido" required>
                            </div>
                            <div class="form-group">
                                <label>Teléfono</label>
                                <input type="text" class="form-control" name="prof_telefono" placeholder="Teléfono">
                            </div>
                            <div class="form-group">
                                <label>Email</label>
                                <input type="email" class="form-control" name="prof_email" placeholder="Email">
                            </div>
                            <div class="form-group">
                                <label>Especialidad</label>
                                <select class="form-control" name="id_especialidad">
                                    <option value="">Seleccione especialidad</option>
                                    <%  
                                    try (PreparedStatement st = conn.prepareStatement("SELECT id_especialidad, espe_nombre FROM especialidades");
                                         ResultSet rs = st.executeQuery()) {
                                        while (rs.next()) {
                                            out.println("<option value='" + rs.getInt("id_especialidad") + "'>" + rs.getString("espe_nombre") + "</option>");
                                        }
                                    } 
                                    %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Sucursal</label>
                                <select class="form-control" name="id_sucursal">
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
                                <button type="submit" class="btn btn-primary">Guardar</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
      </div>
    </div>
</div>

<script>
function datosModif(id, nombre, apellido, telefono, email, id_especialidad, id_sucursal) {
    $("#pk").val(id);
    $("[name='prof_nombre']").val(nombre);
    $("[name='prof_apellido']").val(apellido);
    $("[name='prof_telefono']").val(telefono);
    $("[name='prof_email']").val(email);
    $("[name='id_especialidad']").val(id_especialidad);
    $("[name='id_sucursal']").val(id_sucursal);
    $("#campo").val('modificar');
}

function dell(id) {
    if (confirm("¿Eliminar este profesional?")) {
        window.location.href = "profesional.jsp?campo=eliminar&pk=" + id;
    }
}
</script>

<%@ include file="../footer.jsp" %>