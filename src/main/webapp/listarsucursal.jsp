<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="conexion.jsp" %>
<%@ include file="header.jsp" %>
<%@page import="java.sql.*"%>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="text-white fw-bold">LISTADO DE SUCURSALES</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active text-white fw-bold">Sucursales</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
    <div class="content">
        <div class="container-fluid">

            <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal" onclick="limpiarModal()">
                Agregar Sucursal
            </button>
            <button type="button" class="btn btn-secondary" onclick="imprimirReporte('reporteSucursal.jasper')">
                <i class="fas fa-print"></i> Imprimir Reporte
            </button>
            <table class="table">
                <thead class="thead-light">
                    <tr>
                        <th>#</th>
                        <th>Nombre</th>
                        <th>Dirección</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="listadoSucursales">
                    <%
                    try (PreparedStatement st = conn.prepareStatement("SELECT * FROM sucursal ORDER BY id_sucursal ASC");
                         ResultSet rs = st.executeQuery()) {
                        while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getInt("id_sucursal") %></td>
                        <td><%= rs.getString("suc_nombre") %></td>
                        <td><%= rs.getString("suc_direccion") %></td>
                        <td>
                            <span class="badge <%= "ACTIVO".equals(rs.getString("estado")) ? "badge-success" : "badge-danger" %>">
                                <%= rs.getString("estado") %>
                            </span>
                        </td>
                        <td>
    <i class="fas fa-edit" style="color:green; cursor:pointer"
       onclick="datosModif('<%= rs.getInt("id_sucursal") %>',
                       '<%= rs.getString("suc_nombre") %>',
                       '<%= rs.getString("suc_direccion") %>',
                       '<%= rs.getString("estado") %>')"
       data-toggle="modal" data-target="#exampleModal"></i>
    <i class="fas fa-trash" style="color:red; cursor:pointer"
       onclick="dell(<%= rs.getInt("id_sucursal") %>)"></i>
    <!-- BOTÓN PARA REPORTE INDIVIDUAL DE SUCURSAL -->
    <i class="fas fa-print" style="color:#007bff; cursor:pointer; margin-left:5px;"
       onclick="imprimirSucursalIndividual(<%= rs.getInt("id_sucursal") %>, '<%= rs.getString("suc_nombre") %>')"
       title="Generar Reporte de la Sucursal"></i>
</td>
                    </tr>
                    <%
                        }
                    } catch (Exception e) {
                        out.print("<tr><td colspan='5'>Error al cargar datos: " + e.getMessage() + "</td></tr>");
                    }
                    %>
                </tbody>
            </table>

            <!-- Modal para ABM -->
            <div class="modal fade" id="exampleModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="modalTitle">ABM Sucursal</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <form id="form" name="form">
                                <input type="hidden" name="campo" id="campo" value="guardar">
                                <input type="hidden" name="pk" id="pk" value="">

                                <div class="form-group">
                                    <label>Nombre de la sucursal *</label>
                                    <input type="text" class="form-control" name="suc_nombre" placeholder="Nombre" required>
                                    <small class="text-danger" style="display:none;">Este campo es obligatorio</small>
                                </div>
                                <div class="form-group">
                                    <label>Dirección</label>
                                    <input type="text" class="form-control" name="suc_direccion" placeholder="Dirección">
                                </div>
                                <div class="form-group">
                                    <label>Estado</label>
                                    <select class="form-control" name="estado">
                                        <option value="ACTIVO">Activo</option>
                                        <option value="INACTIVO">Inactivo</option>
                                    </select>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="limpiarModal()">Cerrar</button>
                                    <button type="button" class="btn btn-primary" id="guardarRegistro">Guardar</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
            <script src="script/sucursal.js"></script>
            <script>
function imprimirReporte(reporteSucursal, parametros = {}) {
    let url = 'reporteGenerico.jsp?reporte=' + encodeURIComponent(reporteSucursal);
    
    for (let key in parametros) {
        url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(parametros[key]);
    }

    window.open(url, '_blank');
}
// FUNCIÓN ESPECÍFICA PARA REPORTE INDIVIDUAL DE SUCURSAL
function imprimirSucursalIndividual(idSucursal, nombreSucursal) {
    if (!idSucursal) {
        alert('Error: No se puede generar el reporte - ID no válido');
        return;
    }
    
    if (confirm('¿Generar reporte individual de la sucursal: ' + (nombreSucursal || '') + '?')) {
        // Llama directamente a ListadoSucursal.jsp con el parámetro del ID
        let url = 'reporte/ListadoSucursal.jsp?llamasucursal=' + encodeURIComponent(idSucursal);
        
        window.open(url, '_blank');
    }
}
</script>
        </div>
    </div>
</div>
<%@ include file="footer.jsp" %>