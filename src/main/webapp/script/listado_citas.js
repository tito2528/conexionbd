// Variables globales
var calendar;
var citasData = [];
var citaSeleccionada = null;

$(document).ready(function() {
    console.log("🟢 Sistema de Citas Cargado (con FullCalendar v5)");
    
      // 🔥 ESTABLECER RANGO DE FECHAS AUTOMÁTICAMENTE (Desde hoy hasta 15 días después)
    const fechaActual = new Date();
    const fechaHasta = new Date();
    fechaHasta.setDate(fechaActual.getDate() + 15);
    
    const fechaActualFormateada = fechaActual.toISOString().split('T')[0];
    const fechaHastaFormateada = fechaHasta.toISOString().split('T')[0];
    
    $("#filtro_desde").val(fechaActualFormateada);
    $("#filtro_hasta").val(fechaHastaFormateada);
    
    console.log("📅 Rango de fechas establecido:", {
        desde: fechaActualFormateada, 
        hasta: fechaHastaFormateada
    });
    
    // Cargar citas inicialmente
    listarCitas();
    
    // Inicializar calendario
    inicializarCalendario();
    
    // Event listeners
    $("#btnFiltrar").click(function(e) {
        e.preventDefault();
        listarCitas();
    });
    
    $("#filtro_estado").change(function() {
        listarCitas();
    });
    
    // Validación de fechas
    $("#filtro_desde").change(function(){
        var desde = $(this).val();
        $("#filtro_hasta").attr("min", desde);
        if($("#filtro_hasta").val() < desde){
            $("#filtro_hasta").val(desde);
        }
    });
    
    // Cambiar a vista calendario
    $('#calendario-tab').on('shown.bs.tab', function (e) {
        if (calendar) {
            calendar.render();
            cargarEventosCalendario();
        }
    });
    
    // Verificar pendientes cada minuto
    verificarPendientes();
    setInterval(verificarPendientes, 60000);
});

// LISTAR CITAS
function listarCitas() {
    var desde = $("#filtro_desde").val();
    var hasta = $("#filtro_hasta").val();
    var estado = $("#filtro_estado").val();
    
    console.log("📡 Cargando citas...", {desde, hasta, estado});
    
    $.ajax({
        url: 'Cabecera-detalle/api_citas.jsp',
        type: 'POST',
        dataType: 'json', // Ahora sí podemos usar JSON directo
        data: {
            accion: 'listarCitasModerno',
            desde: desde,
            hasta: hasta,
            estado: estado
        },
        success: function(response) {
            console.log("✅ Respuesta JSON recibida:", response);
            citasData = response;
            console.log("📋 Total de citas:", citasData.length);
            renderizarCitas(citasData);
            actualizarContadores(citasData);
            cargarEventosCalendario();
        },
        error: function(xhr, status, error) {
            console.error("❌ Error AJAX:", {xhr, status, error});
            console.error("Status Code:", xhr.status);
            console.error("Response Text:", xhr.responseText);
            $("#listaCitas").html('<div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i> Error de conexión ('+xhr.status+'): ' + error + '</div>');
        }
    });
}

// RENDERIZAR CITAS EN TARJETAS
function renderizarCitas(citas) {
    console.log("🎨 Renderizando", citas.length, "citas");
    var html = '';
    
    if (citas.length === 0) {
        html = '<div class="alert alert-info text-center">' +
               '<i class="fas fa-info-circle fa-3x mb-3"></i>' +
               '<h5>No hay citas para mostrar</h5>' +
               '<p>Intenta cambiar los filtros o crear una nueva cita</p>' +
               '</div>';
    } else {
        citas.forEach(function(cita) {
            var badgeClass = 'badge-' + cita.estado;
            var cardClass = cita.estado;
            var estadoTexto = cita.estado.charAt(0).toUpperCase() + cita.estado.slice(1);
            
            html += '<div class="cita-card ' + cardClass + '">';
            
            // Header
            html += '<div class="cita-info">';
            html += '<div>';
            html += '<div class="cita-cliente"><i class="fas fa-user"></i> ' + cita.cliente + '</div>';
            html += '<small class="text-muted">ID: #' + cita.id_agendamiento + '</small>';
            html += '</div>';
            html += '<span class="cita-badge ' + badgeClass + '">' + estadoTexto + '</span>';
            html += '</div>';
            
            // Detalles
            html += '<div class="cita-detalles">';
            html += '<div class="detalle-item"><i class="fas fa-calendar-day"></i><span><strong>Fecha:</strong> ' + formatearFecha(cita.fecha) + '</span></div>';
            html += '<div class="detalle-item"><i class="fas fa-clock"></i><span><strong>Hora:</strong> ' + cita.hora_inicio + ' - ' + cita.hora_fin + '</span></div>';
            html += '<div class="detalle-item"><i class="fas fa-user-tie"></i><span><strong>Profesional:</strong> ' + cita.profesional + '</span></div>';
            html += '<div class="detalle-item"><i class="fas fa-cut"></i><span><strong>Servicio:</strong> ' + (cita.servicios || 'N/A') + '</span></div>';
            html += '<div class="detalle-item"><i class="fas fa-map-marker-alt"></i><span><strong>Sucursal:</strong> ' + cita.sucursal + '</span></div>';
            if (cita.observaciones) {
                html += '<div class="detalle-item" style="grid-column: 1/-1;"><i class="fas fa-comment"></i><span><strong>Obs:</strong> ' + cita.observaciones + '</span></div>';
            }
            html += '</div>';
            
            // Acciones
            html += '<div class="cita-acciones">';
            
            // SOLO mostrar botones si NO está finalizado NI cancelado
            if (cita.estado !== 'finalizado' && cita.estado !== 'cancelado') {
                
                if (cita.estado === 'pendiente') {
                    html += '<button class="btn btn-confirmar-grande" onclick="mostrarModalConfirmar(' + cita.id_agendamiento + ')"><i class="fas fa-check-circle"></i> CONFIRMAR CITA</button>';
                }
                
                if (cita.telefono) {
                    var mensaje = 'Hola ' + cita.cliente.split(' ')[0] + ', tu cita está ' + estadoTexto.toLowerCase() + ' para el ' + formatearFecha(cita.fecha) + ' a las ' + cita.hora_inicio;
                    var urlWhatsApp = 'https://wa.me/595' + cita.telefono.replace(/\D/g, '') + '?text=' + encodeURIComponent(mensaje);
                    html += '<a href="' + urlWhatsApp + '" target="_blank" class="btn btn-whatsapp"><i class="fab fa-whatsapp"></i> WhatsApp</a>';
                }
                
                html += '<button class="btn btn-info btn-atender" data-id="' + cita.id_agendamiento + '" data-id_cliente="' + cita.id_cliente + '" data-cliente_nombre="' + cita.cliente + '" data-id_profesional="' + cita.id_profesional + '" data-profesional_nombre="' + cita.profesional + '" data-id_sucursal="' + cita.id_sucursal + '" data-sucursal_nombre="' + cita.sucursal + '"><i class="fas fa-cash-register"></i> Atender</button>';
                
                html += '<button class="btn btn-danger btn-cancelar" data-id="' + cita.id_agendamiento + '"><i class="fas fa-times-circle"></i> Cancelar</button>';
                
            } else if (cita.estado === 'finalizado') {
                // Si está finalizado, solo mostrar un mensaje
                html += '<div class="alert alert-success mb-0" style="flex: 1; text-align: center;">';
                html += '<i class="fas fa-check-circle"></i> <strong>CITA FINALIZADA Y FACTURADA</strong>';
                html += '</div>';
            } else if (cita.estado === 'cancelado') {
                // Si está cancelado, solo mostrar un mensaje
                html += '<div class="alert alert-danger mb-0" style="flex: 1; text-align: center;">';
                html += '<i class="fas fa-times-circle"></i> <strong>CITA CANCELADA</strong>';
                html += '<br><small style="font-size: 0.85rem; opacity: 0.9;">Ya se encuentra cancelada, vuelva a generar si desea otra cita.</small>';
                html += '</div>';
            }
            
            html += '</div></div>';
        });
    }
    
    $("#listaCitas").html(html);
    console.log("✅ Citas renderizadas");
}

// ACTUALIZAR CONTADORES
function actualizarContadores(citas) {
    var pendientes = citas.filter(c => c.estado === 'pendiente').length;
    var confirmadas = citas.filter(c => c.estado === 'confirmado').length;
    var finalizadas = citas.filter(c => c.estado === 'finalizado').length;
    var canceladas = citas.filter(c => c.estado === 'cancelado').length;
    
    $("#contadorPendientes").text(pendientes);
    $("#contadorConfirmadas").text(confirmadas);
    $("#contadorFinalizadas").text(finalizadas);
    $("#contadorCanceladas").text(canceladas);
    $("#badgePendientes").text(pendientes);
    
    console.log("📊 Contadores:", {pendientes, confirmadas, finalizadas, canceladas});
}

// VERIFICAR PENDIENTES
function verificarPendientes() {
    var pendientes = citasData.filter(c => c.estado === 'pendiente').length;
    if (pendientes > 0) {
        console.log("⚠️ " + pendientes + " citas pendientes");
    }
}

// INICIALIZAR CALENDARIO (FullCalendar v5)
function inicializarCalendario() {
    var calendarEl = document.getElementById('calendar');
    if (!calendarEl) return;
    
    calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        locale: 'es',
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,timeGridWeek,timeGridDay'
        },
        buttonText: {
            today: 'Hoy',
            month: 'Mes',
            week: 'Semana',
            day: 'Día'
        },
        events: [],
        eventClick: function(info) {
            var citaId = parseInt(info.event.id);
            var cita = citasData.find(c => c.id_agendamiento === citaId);
            if (cita && cita.estado === 'pendiente') {
                mostrarModalConfirmar(citaId);
            }
        }
    });
}

// CARGAR EVENTOS EN CALENDARIO
function cargarEventosCalendario() {
    if (!calendar) return;
    
    var eventos = citasData.map(function(cita) {
        return {
            id: cita.id_agendamiento,
            title: cita.cliente + ' - ' + (cita.servicios || 'Servicio'),
            start: cita.fecha + 'T' + cita.hora_inicio,
            end: cita.fecha + 'T' + cita.hora_fin,
            className: cita.estado,
            extendedProps: cita
        };
    });
    
    calendar.removeAllEvents();
    calendar.addEventSource(eventos);
    console.log("📅 Eventos cargados en calendario:", eventos.length);
}

// MODAL CONFIRMAR
function mostrarModalConfirmar(id) {
    var cita = citasData.find(c => c.id_agendamiento === id);
    if (!cita) return;
    
    citaSeleccionada = cita;
    
    var html = '<div class="p-3">';
    html += '<p><i class="fas fa-user"></i> <strong>Cliente:</strong> ' + cita.cliente + '</p>';
    html += '<p><i class="fas fa-calendar"></i> <strong>Fecha:</strong> ' + formatearFecha(cita.fecha) + '</p>';
    html += '<p><i class="fas fa-clock"></i> <strong>Hora:</strong> ' + cita.hora_inicio + ' - ' + cita.hora_fin + '</p>';
    html += '<p><i class="fas fa-user-tie"></i> <strong>Profesional:</strong> ' + cita.profesional + '</p>';
    html += '<p><i class="fas fa-cut"></i> <strong>Servicio:</strong> ' + (cita.servicios || 'N/A') + '</p>';
    html += '</div>';
    
    $("#resumenConfirmar").html(html);
    $("#modalConfirmar").modal('show');
}

$("#btnConfirmarCita").click(function() {
    if (!citaSeleccionada) return;
    
    $(this).prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Confirmando...');
    
    $.post('Cabecera-detalle/Controlador_agendamiento.jsp', {
        accion: 'actualizarEstadoCita',
        id_agendamiento: citaSeleccionada.id_agendamiento,
        estado: 'confirmado'
    }, function(response) {
        $("#modalConfirmar").modal('hide');
        alert("✅ " + response);
        listarCitas();
    }).always(function() {
        $("#btnConfirmarCita").prop('disabled', false).html('<i class="fas fa-check"></i> Sí, Confirmar');
    });
});

// EVENTOS DE BOTONES
$(document).on('click', '.btn-atender', function(){
    let id_agendamiento = $(this).data('id');
    let id_cliente = $(this).data('id_cliente');
    let cliente_nombre = $(this).data('cliente_nombre');
    let id_profesional = $(this).data('id_profesional');
    let profesional_nombre = $(this).data('profesional_nombre');
    let id_sucursal = $(this).data('id_sucursal');
    let sucursal_nombre = $(this).data('sucursal_nombre');

    $.ajax({
        url: 'Cabecera-detalle/Controlador_agendamiento.jsp',
        type: 'POST',
        data: {accion: 'obtenerServiciosCita', id_agendamiento: id_agendamiento},
        success: function(serviciosResponse) {
            try {
                var servicios = JSON.parse(serviciosResponse);
                let url = 'vistafacturacion.jsp?id_agendamiento=' + id_agendamiento + '&id_cliente=' + id_cliente + '&cliente_nombre=' + encodeURIComponent(cliente_nombre) + '&id_profesional=' + id_profesional + '&profesional_nombre=' + encodeURIComponent(profesional_nombre) + '&id_sucursal=' + id_sucursal + '&sucursal_nombre=' + encodeURIComponent(sucursal_nombre) + '&from_cita=true';
                servicios.forEach(function(servicio, index) {
                    url += '&servicio_' + index + '=' + servicio.id_servicio + '&servicio_nombre_' + index + '=' + encodeURIComponent(servicio.servicio_nombre) + '&servicio_precio_' + index + '=' + servicio.servicio_precio;
                });
                url += '&total_servicios=' + servicios.length;
                window.location.href = url;
            } catch(e) {
                alert("Error al cargar servicios");
            }
        }
    });
});

$(document).on('click', '.btn-cancelar', function() {
    var id = $(this).data('id');
    if(confirm("¿Está seguro de cancelar esta cita?")) {
        $(this).prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Cancelando...');
        
        $.post('Cabecera-detalle/Controlador_agendamiento.jsp', {
            accion: 'actualizarEstadoCita', 
            id_agendamiento: id, 
            estado: 'cancelado'
        }, function(response) {
            alert(response);
            listarCitas();
        }).fail(function() {
            alert("Error al cancelar la cita");
            listarCitas();
        });
    }
});

function formatearFecha(fecha) {
    var partes = fecha.split('-');
    return partes[2] + '/' + partes[1] + '/' + partes[0];
}
