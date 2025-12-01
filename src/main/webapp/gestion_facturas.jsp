<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>
<%@ include file="conexion.jsp" %>

<div class="content-wrapper">
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1><i class="fas fa-file-invoice-dollar"></i> Gestión de Facturas</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active">Gestión de Facturas</li>
                    </ol>
                </div>
            </div>
        </div>
    </section>

    <section class="content">
        <div class="container-fluid">
            <!-- FILTROS DE BÚSQUEDA -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title"><i class="fas fa-filter"></i> Filtros de Búsqueda</h3>
                </div>
                <div class="card-body">
                    <div class="row">
                        <!-- Periodo -->
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>Periodo</label>
                                <select class="form-control" id="periodo">
                                    <option value="hoy">Facturas de hoy</option>
                                    <option value="todas">Todas las facturas</option>
                                    <option value="mes">Facturas del mes actual</option>
                                    <option value="rango">Rango personalizado</option>
                                </select>
                            </div>
                        </div>

                        <!-- Ordenar por fecha -->
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>Ordenar por fecha</label>
                                <select class="form-control" id="ordenFecha">
                                    <option value="DESC">Más reciente primero</option>
                                    <option value="ASC">Más antiguo primero</option>
                                </select>
                            </div>
                        </div>

                        <!-- Estado -->
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Estado</label>
                                <select class="form-control" id="estado">
                                    <option value="todos">Todos los estados</option>
                                    <option value="pendiente">Pendiente</option>
                                    <option value="finalizada">Finalizada</option>
                                    <option value="cancelada">Cancelada</option>
                                </select>
                            </div>
                        </div>

                        <!-- Método de Pago - NUEVO -->
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Método de Pago</label>
                                <select class="form-control" id="metodoPago">
                                    <option value="todos">Todos los métodos</option>
                                    <!-- Se cargarán dinámicamente -->
                                </select>
                            </div>
                        </div>

                        <!-- Botón Buscar -->
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>&nbsp;</label>
                                <button class="btn btn-primary btn-block" id="btnBuscar">
                                    <i class="fas fa-search"></i> Buscar
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Rango de fechas (oculto por defecto) -->
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

            <!-- TARJETAS DE RESUMEN -->
            <div class="row">
                <div class="col-lg-3 col-6">
                    <div class="small-box bg-info">
                        <div class="inner">
                            <h3 id="totalFacturas">0</h3>
                            <p>Total Facturas</p>
                        </div>
                        <div class="icon">
                            <i class="fas fa-file-invoice"></i>
                        </div>
                    </div>
                </div>

                <div class="col-lg-3 col-6">
                    <div class="small-box bg-success">
                        <div class="inner">
                            <h3 id="totalFacturado">₲ 0</h3>
                            <p>Total Facturado</p>
                            <small style="font-size: 0.85em; opacity: 0.9;">Solo finalizadas</small>
                        </div>
                        <div class="icon">
                            <i class="fas fa-dollar-sign"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TARJETAS POR MÉTODO DE PAGO -->
            <div class="row mb-3">
                <div class="col-md-12">
                    <h5 class="mb-2"><i class="fas fa-credit-card"></i> Totales por Método de Pago</h5>
                </div>
            </div>
            <div class="row mb-4" id="totalesPorMetodo">
                <div class="col-md-12 text-center text-muted">
                    <small>Los totales se mostrarán después de cargar las facturas</small>
                </div>
            </div>

            <!-- TABLA DE FACTURAS -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">
                        <i class="fas fa-list"></i> Historial de Facturas
                        <span class="badge badge-info ml-2" id="contadorRegistros">0 registros</span>
                    </h3>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="thead-dark">
                                <tr>
                                    <th>N° Factura</th>
                                    <th>Fecha Emisión</th>
                                    <th>Total Factura</th>
                                    <th>Método de Pago</th>
                                    <th>Profesional</th>
                                    <th>Sucursal</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody id="tablaFacturas">
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
    </section>
</div>

<script>
$(document).ready(function() {
    // Cargar métodos de pago
    cargarMetodosPago();
    
    // Cargar facturas al iniciar
    cargarFacturas();
    
    // Evento al cambiar periodo
    $('#periodo').change(function() {
        const periodo = $(this).val();
        if (periodo === 'rango') {
            $('#rangoFechas').show();
            // Establecer fechas por defecto
            const hoy = new Date();
            const primerDia = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
            $('#fechaDesde').val(formatearFecha(primerDia));
            $('#fechaHasta').val(formatearFecha(hoy));
        } else {
            $('#rangoFechas').hide();
        }
    });
    
    // Evento botón buscar
    $('#btnBuscar').click(function() {
        cargarFacturas();
    });
    
    // También buscar al cambiar orden o estado
    $('#ordenFecha, #estado, #metodoPago').change(function() {
        cargarFacturas();
    });
});

function cargarMetodosPago() {
    $.ajax({
        url: 'Servicios/servicio_clientes_facturas.jsp',
        type: 'POST',
        data: { accion: 'listarMetodosPago' },
        success: function(response) {
            $('#metodoPago').append(response);
        },
        error: function() {
            console.error('Error al cargar métodos de pago');
        }
    });
}

function formatearFecha(fecha) {
    const year = fecha.getFullYear();
    const month = String(fecha.getMonth() + 1).padStart(2, '0');
    const day = String(fecha.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

function cargarFacturas() {
    const periodo = $('#periodo').val();
    const ordenFecha = $('#ordenFecha').val();
    const estado = $('#estado').val();
    const metodoPago = $('#metodoPago').val();
    const fechaDesde = $('#fechaDesde').val();
    const fechaHasta = $('#fechaHasta').val();
    
    // Validar rango de fechas
    if (periodo === 'rango' && (!fechaDesde || !fechaHasta)) {
        alert('Por favor, seleccione ambas fechas para el rango personalizado');
        return;
    }
    
    console.log('🔍 Cargando facturas con filtros:', {periodo, ordenFecha, estado, metodoPago});
    
    // Preparar datos
    const datos = {
        accion: 'listarFacturas',
        periodo: periodo,
        orden_fecha: ordenFecha,
        estado: estado,
        metodo_pago: metodoPago
    };
    
    if (periodo === 'rango') {
        datos.fecha_desde = fechaDesde;
        datos.fecha_hasta = fechaHasta;
    }
    
    // Mostrar loading
    $('#tablaFacturas').html('<tr><td colspan="8" class="text-center"><i class="fas fa-spinner fa-spin"></i> Cargando facturas...</td></tr>');
    
    // Hacer petición AJAX
    $.ajax({
        url: 'Servicios/servicio_clientes_facturas.jsp',
        type: 'POST',
        data: datos,
        success: function(response) {
            console.log('✅ Facturas cargadas');
            $('#tablaFacturas').html(response);
            
            // Actualizar contador
            const numFilas = $('#tablaFacturas tr').length;
            if (numFilas > 0 && !response.includes('No se encontraron')) {
                $('#contadorRegistros').text(numFilas + ' registro' + (numFilas !== 1 ? 's' : ''));
            } else {
                $('#contadorRegistros').text('0 registros');
            }
            
            // ✅ IMPORTANTE: Calcular totales después de cargar las facturas
            setTimeout(function() {
                calcularTotales();
            }, 100);
        },
        error: function(xhr, status, error) {
            console.error('❌ Error AJAX completo:');
            console.error('Status:', status);
            console.error('Error:', error);
            console.error('Response Text:', xhr.responseText);
            console.error('Ready State:', xhr.readyState);
            console.error('Status Code:', xhr.status);
            
            let errorMsg = 'Error al cargar facturas: ';
            if (xhr.status === 0) {
                errorMsg += 'No hay conexión o el archivo no existe';
            } else if (xhr.status === 404) {
                errorMsg += 'Archivo no encontrado (404) - Verifica que servicios/servicio_clientes_facturas.jsp existe';
            } else if (xhr.status === 500) {
                errorMsg += 'Error interno del servidor (500) - Revisa los logs del servidor';
            } else {
                errorMsg += error + ' (Código: ' + xhr.status + ')';
            }
            
            $('#tablaFacturas').html(`
                <tr>
                    <td colspan="8" class="text-center text-danger">
                        <i class="fas fa-exclamation-triangle"></i> ${errorMsg}
                        <br><small>Revisa la consola del navegador (F12) para más detalles</small>
                    </td>
                </tr>
            `);
        }
    });
}

function verDetalleFactura(idFactura) {
    window.open('detalle_factura.jsp?id_factura=' + idFactura, '_blank');
}

function imprimirFactura(idFactura) {
    window.open('imprimir_factura.jsp?id_factura=' + idFactura, '_blank');
}

// Función para calcular totales
function calcularTotales() {
    console.log('🧮 Calculando totales...');
    
    let totalFacturas = 0;
    let totalFacturado = 0;
    let totalPendiente = 0;
    let cantidadPendiente = 0;  // ← NUEVO
    let totalFinalizada = 0;
    
    // Objeto para almacenar totales por método de pago
    let totalesPorMetodo = {};
    
    $('#tablaFacturas tr[data-total]').each(function() {
        const total = parseFloat($(this).data('total'));
        const estado = $(this).data('estado');
        const metodoPago = $(this).data('metodo');
        
        console.log('Factura - Total:', total, 'Estado:', estado, 'Método:', metodoPago);
        
        if (!isNaN(total)) {
            totalFacturas++;
            
            if (estado === 'pendiente') {
                totalPendiente += total;
                cantidadPendiente++;
            } else if (estado === 'finalizada') {
                totalFinalizada += total;
                totalFacturado += total;  // Total Facturado = solo finalizadas
            }
            
            // Acumular por método de pago
            if (metodoPago) {
                if (!totalesPorMetodo[metodoPago]) {
                    totalesPorMetodo[metodoPago] = 0;
                }
                totalesPorMetodo[metodoPago] += total;
            }
        }
    });
    
    console.log('📊 Totales calculados:');
    console.log('  Total Facturas:', totalFacturas);
    console.log('  Total Facturado (solo finalizadas):', totalFacturado);
    console.log('  Por Método:', JSON.stringify(totalesPorMetodo, null, 2));
    
    // Actualizar tarjetas principales
    $('#totalFacturas').text(totalFacturas);
    $('#totalFacturado').text('₲ ' + totalFacturado.toLocaleString('es-PY', {maximumFractionDigits: 0}));
    
    // Actualizar tarjetas por método de pago
    let htmlMetodos = '';
    let countMetodos = 0;
    
    const colores = ['bg-success', 'bg-primary', 'bg-warning', 'bg-danger', 'bg-info'];
    let colorIndex = 0;
    
    for (let metodo in totalesPorMetodo) {
        const totalMetodo = totalesPorMetodo[metodo];
        
        // Solo mostrar si el total es mayor a 0
        if (totalMetodo > 0) {
            const color = colores[colorIndex % colores.length];
            colorIndex++;
            countMetodos++;
            
            console.log('Creando tarjeta para:', metodo, '- Total:', totalMetodo);
            
            const totalFormateado = totalMetodo.toLocaleString('es-PY', {maximumFractionDigits: 0});
            
            htmlMetodos += '<div class="col-lg-3 col-md-4 col-sm-6">';
            htmlMetodos += '  <div class="small-box ' + color + '">';
            htmlMetodos += '    <div class="inner">';
            htmlMetodos += '      <h3 style="color: white;">₲ ' + totalFormateado + '</h3>';
            htmlMetodos += '      <p style="color: white;"><strong>' + metodo + '</strong></p>';
            htmlMetodos += '    </div>';
            htmlMetodos += '    <div class="icon">';
            htmlMetodos += '      <i class="fas fa-credit-card"></i>';
            htmlMetodos += '    </div>';
            htmlMetodos += '  </div>';
            htmlMetodos += '</div>';
        }
    }
    
    console.log('Total de métodos encontrados:', countMetodos);
    console.log('HTML generado (primeros 300 chars):', htmlMetodos.substring(0, 300));
    
    if (htmlMetodos === '') {
        htmlMetodos = '<div class="col-md-12 text-center text-muted"><small><i class="fas fa-info-circle"></i> No hay facturas finalizadas para mostrar totales por método de pago</small></div>';
    }
    
    $('#totalesPorMetodo').html(htmlMetodos);
    
    console.log('🎨 Tarjetas de método insertadas en #totalesPorMetodo');
    console.log('Verificación - Cantidad de tarjetas insertadas:', $('#totalesPorMetodo .small-box').length);
    
    console.log('✅ Tarjetas actualizadas');
}

</script>

<%@ include file="footer.jsp" %>
