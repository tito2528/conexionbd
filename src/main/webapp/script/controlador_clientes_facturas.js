// Variables globales
let clienteSeleccionado = null;
let datosClienteActual = null;

// Función para abrir el modal de facturas de un cliente
function abrirModalFacturas(idCliente, nombre, apellido, cedula, telefono, email, sucursal) {
    clienteSeleccionado = idCliente;
    datosClienteActual = {
        id: idCliente,
        nombre: nombre,
        apellido: apellido,
        cedula: cedula,
        telefono: telefono,
        email: email,
        sucursal: sucursal
    };
    
    // Actualizar título del modal
    $('#tituloModalFacturas').text('FACTURAS DE: ' + nombre + ' ' + apellido);
    
    // Cargar información del cliente
    cargarInformacionCliente();
    
    // Resetear filtros
    $('#tipoFiltro').val('todas');
    $('#ordenFecha').val('DESC');
    $('#filtroEstado').val('todos');
    $('#rangoFechas').hide();
    
    // Cargar facturas del cliente
    cargarFacturasCliente();
    
    // Mostrar el modal
    $('#modalFacturasCliente').modal('show');
}

// Función para cargar información detallada del cliente
function cargarInformacionCliente() {
    if (!datosClienteActual) return;
    
    const infoHTML = `
        <div class="col-md-3">
            <strong><i class="fas fa-id-card"></i> Cédula/RUC:</strong><br>
            ${datosClienteActual.cedula || 'No especificado'}
        </div>
        <div class="col-md-3">
            <strong><i class="fas fa-phone"></i> Teléfono:</strong><br>
            ${datosClienteActual.telefono || 'No especificado'}
        </div>
        <div class="col-md-3">
            <strong><i class="fas fa-envelope"></i> Email:</strong><br>
            ${datosClienteActual.email || 'No especificado'}
        </div>
        <div class="col-md-3">
            <strong><i class="fas fa-store"></i> Sucursal:</strong><br>
            ${datosClienteActual.sucursal || 'No asignada'}
        </div>
    `;
    
    $('#infoClienteDetalle').html(infoHTML);
}

// ✅ NUEVA FUNCIÓN: Cambiar tipo de filtro
function cambiarTipoFiltro() {
    const tipoFiltro = $('#tipoFiltro').val();
    
    if (tipoFiltro === 'rango') {
        $('#rangoFechas').show();
        
        // Establecer fechas por defecto (primer día del mes hasta hoy)
        const hoy = new Date();
        const primerDiaMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
        
        $('#fechaDesde').val(formatearFecha(primerDiaMes));
        $('#fechaHasta').val(formatearFecha(hoy));
    } else {
        $('#rangoFechas').hide();
    }
    
    // Recargar facturas con el nuevo filtro
    cargarFacturasCliente();
}

// ✅ NUEVA FUNCIÓN: Formatear fecha a YYYY-MM-DD
function formatearFecha(fecha) {
    const year = fecha.getFullYear();
    const month = String(fecha.getMonth() + 1).padStart(2, '0');
    const day = String(fecha.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

// ✅ NUEVA FUNCIÓN: Aplicar filtros
function aplicarFiltros() {
    cargarFacturasCliente();
}

// ✅ FUNCIÓN MEJORADA: Cargar facturas con filtros
function cargarFacturasCliente() {
    if (!clienteSeleccionado) return;
    
    const tipoFiltro = $('#tipoFiltro').val();
    const ordenFecha = $('#ordenFecha').val();
    const filtroEstado = $('#filtroEstado').val();
    const fechaDesde = $('#fechaDesde').val();
    const fechaHasta = $('#fechaHasta').val();
    
    // Validar rango de fechas
    if (tipoFiltro === 'rango' && (!fechaDesde || !fechaHasta)) {
        alert('Por favor, seleccione ambas fechas para el rango personalizado');
        return;
    }
    
    console.log("📋 Cargando facturas para cliente:", clienteSeleccionado);
    console.log("🔍 Filtros:", { tipoFiltro, ordenFecha, filtroEstado, fechaDesde, fechaHasta });
    
    // Preparar datos para enviar
    const datos = {
        accion: 'obtenerFacturasCliente',
        id_cliente: clienteSeleccionado,
        tipo_filtro: tipoFiltro,
        orden_fecha: ordenFecha,
        filtro_estado: filtroEstado
    };
    
    // Agregar fechas si es rango
    if (tipoFiltro === 'rango') {
        datos.fecha_desde = fechaDesde;
        datos.fecha_hasta = fechaHasta;
    }
    
    $.ajax({
        url: 'Servicios/servicio_clientes_facturas.jsp',
        type: 'POST',
        data: datos,
        beforeSend: function() {
            $('#listaFacturasCliente').html('<tr><td colspan="8" class="text-center"><div class="spinner-border text-primary" role="status"></div> Cargando facturas...</td></tr>');
        },
        success: function(response) {
            console.log("✅ Facturas cargadas correctamente");
            $('#listaFacturasCliente').html(response);
            
            // Actualizar contador de facturas
            const numFilas = $('#listaFacturasCliente tr').length;
            if (numFilas > 0 && !response.includes('No se encontraron')) {
                $('#contadorFacturas').text(numFilas + ' registro' + (numFilas !== 1 ? 's' : ''));
            } else {
                $('#contadorFacturas').text('0 registros');
            }
        },
        error: function(xhr, status, error) {
            console.error('❌ Error cargando facturas:', error);
            $('#listaFacturasCliente').html(`
                <tr>
                    <td colspan="8" class="text-center text-danger">
                        <i class="fas fa-exclamation-triangle"></i> Error al cargar las facturas
                        <br><small>${error}</small>
                    </td>
                </tr>
            `);
        }
    });
}

// Función para ver detalle de factura (puedes usar tu página existente)
function verDetalleFactura(idFactura) {
    // Abrir tu página de detalle de factura existente
    window.open('detalle_factura.jsp?id_factura=' + idFactura, '_blank');
}
