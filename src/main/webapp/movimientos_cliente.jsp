<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="conexion.jsp" %>
<%@ include file="header.jsp" %>
<%@page import="java.sql.*, java.util.*, java.text.SimpleDateFormat"%>
<%
    String id_cliente = request.getParameter("id_cliente");
    String cliente_nombre = "";
    
    if (id_cliente == null || id_cliente.trim().isEmpty()) {
        response.sendRedirect("vistafacturacion.jsp");
        return;
    }
    
    // SOLUCIÓN: Usar nombres de variables diferentes
    Connection conexion = null;
    PreparedStatement statement = null;
    ResultSet resultado = null;
    
    try {
        Class.forName("org.postgresql.Driver");
        conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/proyecto_2025", "postgres", "admin");
        
        // Obtener nombre del cliente
        String sqlCliente = "SELECT cli_nombre, cli_apellido FROM cliente WHERE id_cliente = ?";
        statement = conexion.prepareStatement(sqlCliente);
        statement.setInt(1, Integer.parseInt(id_cliente));
        resultado = statement.executeQuery();
        if (resultado.next()) {
            cliente_nombre = resultado.getString("cli_nombre") + " " + resultado.getString("cli_apellido");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (resultado != null) try { resultado.close(); } catch (SQLException e) {}
        if (statement != null) try { statement.close(); } catch (SQLException e) {}
        if (conexion != null) try { conexion.close(); } catch (SQLException e) {}
    }
%>

<div class="content-wrapper">
    <section class="content">
        <div class="row">
            <div class="col-md-12">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">
                            <i class="fa fa-file-text-o"></i> Movimientos del Cliente: <strong><%= cliente_nombre %></strong>
                        </h3>
                        <div class="box-tools pull-right">
                            <button type="button" class="btn btn-box-tool" data-widget="collapse">
                                <i class="fa fa-minus"></i>
                            </button>
                        </div>
                    </div>
                    <div class="box-body">
                        <div class="row">
                            <div class="col-md-12">
                                <!-- Filtros -->
                                <div class="form-inline" style="margin-bottom: 15px;">
                                    <div class="form-group">
                                        <label for="fecha_desde">Desde:</label>
                                        <input type="date" class="form-control" id="fecha_desde" style="margin: 0 10px;">
                                    </div>
                                    <div class="form-group">
                                        <label for="fecha_hasta">Hasta:</label>
                                        <input type="date" class="form-control" id="fecha_hasta" style="margin: 0 10px;">
                                    </div>
                                    <div class="form-group">
                                        <label for="estado">Estado:</label>
                                        <select class="form-control" id="estado" style="margin: 0 10px;">
                                            <option value="">Todos</option>
                                            <option value="finalizada">Finalizada</option>
                                            <option value="cancelada">Cancelada</option>
                                            <option value="pendiente">Pendiente</option>
                                        </select>
                                    </div>
                                    <button type="button" class="btn btn-primary" id="btn-filtrar">
                                        <i class="fa fa-filter"></i> Filtrar
                                    </button>
                                    <button type="button" class="btn btn-success" id="btn-generar-pdf" style="margin-left: 10px;">
                                        <i class="fa fa-file-pdf-o"></i> Generar PDF
                                    </button>
                                    <button type="button" class="btn btn-default" onclick="window.history.back()" style="margin-left: 10px;">
                                        <i class="fa fa-arrow-left"></i> Volver
                                    </button>
                                </div>
                                
                                <!-- Tabla de resultados -->
                                <div class="table-responsive">
                                    <table id="tabla-movimientos" class="table table-striped table-bordered table-hover">
                                        <thead>
                                            <tr>
                                                <th>N° Factura</th>
                                                <th>Fecha</th>
                                                <th>Total</th>
                                                <th>Método Pago</th>
                                                <th>Sucursal</th>
                                                <th>Usuario</th>
                                                <th>Estado</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tbody-movimientos">
                                            <!-- Los datos se cargan via AJAX -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
$(document).ready(function() {
    const clienteId = '<%= id_cliente %>';
    
    // Cargar movimientos al iniciar
    cargarMovimientos();
    
    // Filtrar movimientos
    $('#btn-filtrar').click(function() {
        cargarMovimientos();
    });
    
    // Generar PDF
    $('#btn-generar-pdf').click(function() {
        generarPDF();
    });
    
function cargarMovimientos() {
    const fechaDesde = $('#fecha_desde').val();
    const fechaHasta = $('#fecha_hasta').val();
    const estado = $('#estado').val();
    
    console.log("🔄 Cargando movimientos para cliente:", clienteId);
    
    // Mostrar loading
    $('#tbody-movimientos').html('<tr><td colspan="8" class="text-center"><i class="fa fa-spinner fa-spin"></i> Cargando movimientos...</td></tr>');
    
    $.ajax({
        url: 'Cabecera-detalle/ControladorMovimientosCliente.jsp',
        type: 'POST',
        data: {
            accion: 'listarMovimientos',
            id_cliente: clienteId,
            fecha_desde: fechaDesde,
            fecha_hasta: fechaHasta,
            estado: estado
        },
        success: function(response) {
            console.log("✅ Respuesta recibida:", response);
            $('#tbody-movimientos').html(response);
        },
        error: function(xhr, status, error) {
            console.error("❌ Error AJAX completo:");
            console.error("Status:", status);
            console.error("Error:", error);
            console.error("Response Text:", xhr.responseText);
            console.error("Ready State:", xhr.readyState);
            console.error("Status Code:", xhr.status);
            
            let errorMsg = "Error al cargar movimientos: ";
            if (xhr.status === 0) {
                errorMsg += "No hay conexión o el archivo no existe";
            } else if (xhr.status === 404) {
                errorMsg += "Archivo no encontrado (404)";
            } else if (xhr.status === 500) {
                errorMsg += "Error interno del servidor (500)";
            } else {
                errorMsg += error + " (Código: " + xhr.status + ")";
            }
            
            $('#tbody-movimientos').html('<tr><td colspan="8" class="text-center text-danger">' + errorMsg + '</td></tr>');
        }
    });
}
    
    function generarPDF() {
        const fechaDesde = $('#fecha_desde').val();
        const fechaHasta = $('#fecha_hasta').val();
        const estado = $('#estado').val();
        
        const url = `GenerarReporteMovimientos?accion=generarPDF&id_cliente=${clienteId}&fecha_desde=${fechaDesde}&fecha_hasta=${fechaHasta}&estado=${estado}`;
        window.open(url, '_blank');
    }
    
    // Ver detalle de factura
    // Ver detalle de factura
// Ver detalle de factura - USA TU JSP EXISTENTE
// Ver detalle de factura - USA imprimir_factura.jsp que YA FUNCIONA
// Ver detalle de factura - VERSIÓN MEJORADA
// SOLUCIÓN DEFINITIVA - Obtener ID directamente de la tabla
$(document).on('click', '.btn-ver-detalle', function() {
    // Obtener la fila completa donde está el botón
    var fila = $(this).closest('tr');
    
    // Obtener el ID de la factura de la PRIMERA columna (N° Factura)
    var idFactura = fila.find('td:eq(0)').text().trim();
    
    console.log("📍 Fila encontrada:", fila.length);
    console.log("🔢 ID Factura obtenido:", idFactura);
    
    // Validar que sea un número
    if (!idFactura || idFactura === "" || isNaN(idFactura)) {
        alert("ERROR: No se pudo obtener un ID de factura válido. Valor: '" + idFactura + "'");
        return;
    }
    
    // Construir la URL con el ID
    var url = 'imprimir_factura.jsp?id_factura=' + idFactura;
    console.log("🌐 URL a abrir:", url);
    
    // Abrir en nueva pestaña
    window.open(url, '_blank');
});
});
</script>

<%@ include file="footer.jsp" %>