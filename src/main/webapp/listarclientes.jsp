text-white fw-bold<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%@ include file="../conexion.jsp" %>
<%@page import="java.sql.*"%>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h2 class="text-white fw-bold">LISTADO CLIENTES</h2>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active text-white fw-bold">Clientes</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
    <div class="content">
        <div class="container-fluid">

            <div class="mb-3 d-flex">
                <button type="button" class="btn btn-primary mr-2" data-toggle="modal" data-target="#exampleModal" id="btnNuevoCliente">
                    <i class="fas fa-plus"></i> Agregar Cliente
                </button>
                <button type="button" class="btn btn-secondary" onclick="imprimirReporte('reportePersona.jasper')">
                    <i class="fas fa-print"></i> Imprimir Reporte
                </button>
            </div>
          
            <table class="table">
                <thead class="thead-light">
                    <tr>
                        <th>#</th>
                        <th>Nombre</th>
                        <th>Apellido</th>
                        <th>CI/RUC</th>
                        <th>Teléfono</th>
                        <th>Email</th>
                        <th>Dirección</th>
                        <th>Sucursal</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="listadoclientes">
                    <!-- Los clientes se cargan aquí por AJAX -->
                </tbody>
            </table>

            <!-- Modal de cliente -->
            <div class="modal fade" id="exampleModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="modalTitle">Agregar Cliente</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <form id="form" name="form" autocomplete="off">
                                <input type="hidden" name="campo" id="campo" value="guardar">
                                <input type="hidden" name="pk" id="pk" value="">
                              
                                <div class="form-group">
                                    <label>Nombre *</label>
                                    <input type="text" class="form-control" name="cli_nombre" required>
                                </div>
                                <div class="form-group">
                                    <label>Apellido *</label>
                                    <input type="text" class="form-control" name="cli_apellido" required>
                                </div>
                                <div class="form-group">
                                    <label>Cédula de Identidad/RUC *</label>
                                    <input type="text" class="form-control" name="cli_ci" required>
                                </div>
                                <div class="form-group">
                                    <label>Teléfono *</label>
                                    <input type="text" class="form-control" name="cli_telefono" required>
                                </div>
                                <div class="form-group">
                                    <label>Dirección *</label>
                                    <input type="text" class="form-control" name="cli_direccion" required>
                                </div>
                                <div class="form-group">
                                    <label>Email</label>
                                    <input type="email" class="form-control" name="cli_email">
                                </div>
                                <div class="form-group">
                                    <label>Sucursal</label>
                                    <select class="form-control" name="id_sucursal" id="selectSucursal">
                                        <option value="">Seleccione sucursal</option>
                                        <%
                                        try (Statement st = conn.createStatement();
                                             ResultSet rs = st.executeQuery("SELECT id_sucursal, suc_nombre FROM sucursal ORDER BY suc_nombre")) {
                                            while (rs.next()) {
                                        %>
                                        <option value="<%= rs.getInt("id_sucursal") %>"><%= rs.getString("suc_nombre") %></option>
                                        <%
                                            }
                                        } catch (Exception e) { 
                                            out.print("<option>Error cargando sucursales</option>"); 
                                        }
                                        %>
                                    </select>
                                </div>
                                <small class="form-text text-muted">* Campos obligatorios</small>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                            <button type="button" class="btn btn-primary" id="guardarRegistro">Guardar</button>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>
<script src="script/cliente.js"></script>
<script>
function imprimirReporte(reportePersona, parametros = {}) {
    let url = 'reporteGenerico.jsp?reporte=' + encodeURIComponent(reportePersona);
    
    for (let key in parametros) {
        url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(parametros[key]);
    }

    window.open(url, '_blank');
}
// FUNCIÓN ESPECÍFICA PARA REPORTE INDIVIDUAL DE CLIENTE
function imprimirClienteIndividual(idCliente, nombreCliente) {
    if (!idCliente) {
        alert('Error: No se puede generar el reporte - ID no válido');
        return;
    }
    
    if (confirm('¿Generar reporte individual del cliente: ' + (nombreCliente || '') + '?')) {
        // Llama directamente a Listadocliente.jsp con el parámetro del ID
        let url = 'reporte/Listadocliente.jsp?id_cliente=' + encodeURIComponent(idCliente);
        
        window.open(url, '_blank');
    }
}
</script>
<%@ include file="footer.jsp" %>