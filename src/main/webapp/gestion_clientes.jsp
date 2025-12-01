<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%@ include file="conexion.jsp" %>
<%@page import="java.sql.*"%>

<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1><i class="fas fa-users"></i> GESTIÓN DE CLIENTES</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active">Clientes y Facturas</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>

    <div class="content">
        <div class="container-fluid">
            <!-- Lista de clientes -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Lista de Clientes Registrados</h3>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover table-striped">
                            <thead class="thead-dark">
                                <tr>
                                    <th>#</th>
                                    <th>Información del Cliente</th>
                                    <th>Contacto</th>
                                    <th>Sucursal</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    String sql = "SELECT c.id_cliente, c.cli_nombre, c.cli_apellido, c.cli_ci, c.cli_telefono, c.cli_email, " +
                                                "s.suc_nombre, c.estado " +
                                                "FROM cliente c " +
                                                "LEFT JOIN sucursal s ON c.id_sucursal = s.id_sucursal " +
                                                "ORDER BY c.cli_nombre, c.cli_apellido";
                                    
                                    Statement st = conn.createStatement();
                                    ResultSet rs = st.executeQuery(sql);
                                    int contador = 1;
                                    
                                    while (rs.next()) {
                                %>
                                <tr>
                                    <td><%= contador++ %></td>
                                    <td>
                                        <strong><%= rs.getString("cli_nombre") %> <%= rs.getString("cli_apellido") %></strong><br>
                                        <small class="text-muted">Cédula/RUC: <%= rs.getString("cli_ci") %></small>
                                    </td>
                                    <td>
                                        <i class="fas fa-phone"></i> <%= rs.getString("cli_telefono") != null ? rs.getString("cli_telefono") : "N/A" %><br>
                                        <i class="fas fa-envelope"></i> <%= rs.getString("cli_email") != null ? rs.getString("cli_email") : "N/A" %>
                                    </td>
                                    <td><%= rs.getString("suc_nombre") != null ? rs.getString("suc_nombre") : "Sin sucursal" %></td>
                                    <td>
                                        <span class="badge badge-<%= "ACTIVO".equals(rs.getString("estado")) ? "success" : "danger" %>">
                                            <%= rs.getString("estado") %>
                                        </span>
                                    </td>
                                    <td>
                                        <button class="btn btn-sm btn-info" 
                                                onclick="abrirModalFacturas(
                                                    <%= rs.getInt("id_cliente") %>, 
                                                    '<%= rs.getString("cli_nombre") %>', 
                                                    '<%= rs.getString("cli_apellido") %>', 
                                                    '<%= rs.getString("cli_ci") %>', 
                                                    '<%= rs.getString("cli_telefono") != null ? rs.getString("cli_telefono") : "" %>', 
                                                    '<%= rs.getString("cli_email") != null ? rs.getString("cli_email") : "" %>', 
                                                    '<%= rs.getString("suc_nombre") != null ? rs.getString("suc_nombre") : "" %>'
                                                )">
                                            <i class="fas fa-file-invoice-dollar"></i> Ver Facturas
                                        </button>
                                    </td>
                                </tr>
                                <%
                                    }
                                    
                                    if (contador == 1) {
                                %>
                                <tr>
                                    <td colspan="6" class="text-center text-muted">
                                        <i class="fas fa-search"></i> No se encontraron clientes
                                    </td>
                                </tr>
                                <%
                                    }
                                    
                                } catch (Exception e) {
                                %>
                                <tr>
                                    <td colspan="6" class="text-center text-danger">
                                        <i class="fas fa-exclamation-triangle"></i> Error al cargar clientes: <%= e.getMessage() %>
                                    </td>
                                </tr>
                                <%
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal para ver facturas del cliente -->
<div class="modal fade" id="modalFacturasCliente" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header bg-primary">
                <h5 class="modal-title text-white">
                    <i class="fas fa-file-invoice-dollar"></i> 
                    <span id="tituloModalFacturas">FACTURAS DEL CLIENTE</span>
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <!-- Información del cliente -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <div class="card card-info">
                            <div class="card-header">
                                <h4 class="card-title">Información del Cliente</h4>
                            </div>
                            <div class="card-body">
                                <div class="row" id="infoClienteDetalle">
                                    <!-- Información se carga por JavaScript -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filtros de búsqueda -->
                <div class="row mb-3">
                    <div class="col-md-12">
                        <div class="card">
                            <div class="card-header bg-light">
                                <h5 class="card-title mb-0">
                                    <i class="fas fa-filter"></i> Filtros de Búsqueda
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <!-- Tipo de filtro -->
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>Periodo</label>
                                            <select class="form-control" id="tipoFiltro" onchange="cambiarTipoFiltro()">
                                                <option value="todas">Todas las facturas</option>
                                                <option value="hoy">Facturas de hoy</option>
                                                <option value="mes">Facturas del mes actual</option>
                                                <option value="rango">Rango personalizado</option>
                                            </select>
                                        </div>
                                    </div>

                                    <!-- Ordenamiento -->
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>Ordenar por fecha</label>
                                            <select class="form-control" id="ordenFecha" onchange="aplicarFiltros()">
                                                <option value="DESC">Más reciente primero</option>
                                                <option value="ASC">Más antiguo primero</option>
                                            </select>
                                        </div>
                                    </div>

                                    <!-- Filtro de estado -->
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>Estado</label>
                                            <select class="form-control" id="filtroEstado" onchange="aplicarFiltros()">
                                                <option value="todos">Todos los estados</option>
                                                <option value="pendiente">Pendiente</option>
                                                <option value="pagado">Pagado</option>
                                                <option value="cancelado">Cancelado</option>
                                            </select>
                                        </div>
                                    </div>

                                    <!-- Botón aplicar -->
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label>&nbsp;</label>
                                            <button class="btn btn-primary btn-block" onclick="aplicarFiltros()">
                                                <i class="fas fa-search"></i> Buscar
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <!-- Rango de fechas (oculto inicialmente) -->
                                <div class="row" id="rangoFechas" style="display: none;">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Fecha desde</label>
                                            <input type="date" class="form-control" id="fechaDesde">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Fecha hasta</label>
                                            <input type="date" class="form-control" id="fechaHasta">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>


                <!-- Lista de facturas -->
                <div class="row">
                    <div class="col-md-12">
                        <div class="card">
                            <div class="card-header">
                                <h4 class="card-title">
                                    <i class="fas fa-list"></i> Historial de Facturas
                                    <span class="badge badge-info ml-2" id="contadorFacturas">0 registros</span>
                                </h4>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-bordered table-hover table-sm">
                                        <thead class="thead-light">
                                            <tr>
                                                <th width="8%">N° Factura</th>
                                                <th width="12%">Fecha Emisión</th>
                                                <th width="12%">Total Factura</th>
                                                <th width="15%">Método de Pago</th>
                                                <th width="15%">Profesional</th>
                                                <th width="15%">Sucursal</th>
                                                <th width="10%">Estado</th>
                                                <th width="13%">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody id="listaFacturasCliente">
                                            <tr>
                                                <td colspan="8" class="text-center text-muted">
                                                    <i class="fas fa-info-circle"></i> Seleccione un cliente para ver sus facturas
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">
                    <i class="fas fa-times"></i> Cerrar
                </button>
            </div>
        </div>
    </div>
</div>

<script src="script/controlador_clientes_facturas.js"></script>

<%@ include file="footer.jsp" %></th>
                                                <th width="15%">Método de Pago</th>
                                                <th width="15%">Profesional</th>
                                                <th width="15%">Sucursal</th>
                                                <th width="10%">Estado</th>
                                                <th width="13%">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody id="listaFacturasCliente">
                                            <tr>
                                                <td colspan="8" class="text-center text-muted">
                                                    <i class="fas fa-spinner fa-spin"></i> Cargando facturas...
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">
                    <i class="fas fa-times"></i> Cerrar
                </button>
                <button type="button" class="btn btn-success" onclick="exportarExcel()">
                    <i class="fas fa-file-excel"></i> Exportar a Excel
                </button>
                <button type="button" class="btn btn-danger" onclick="exportarPDF()">
                    <i class="fas fa-file-pdf"></i> Exportar a PDF
                </button>
            </div>
        </div>
    </div>
</div>

<script src="script/controlador_clientes_facturas.js"></script>

<%@ include file="footer.jsp" %>
