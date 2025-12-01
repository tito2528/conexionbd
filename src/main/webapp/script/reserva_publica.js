// Variables globales para la reserva
var reservaData = {
    servicio: null,
    profesional: null,
    fecha: null,
    horario: null
};

$(document).ready(function() {
    cargarServicios();
    
    // Event listeners
    $("#btnContinuar").on('click', continuarReserva);
    $("#btnConfirmarReserva").on('click', confirmarReserva);
});

// VERIFICAR SESIÓN ANTES DE RESERVAR
function verificarSesionYReservar() {
    if (!haySession) {
        Swal.fire({
            icon: 'info',
            title: 'Inicia sesión para continuar',
            text: 'Necesitas tener una cuenta para reservar una cita',
            showCancelButton: true,
            confirmButtonText: 'Iniciar Sesión',
            cancelButtonText: 'Registrarme',
            confirmButtonColor: '#667eea',
            cancelButtonColor: '#e67e22'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = 'login_cliente.jsp';
            } else if (result.dismiss === Swal.DismissReason.cancel) {
                window.location.href = 'registro_cliente.jsp';
            }
        });
    } else {
        abrirModalReserva();
    }
}

// Abrir modal
function abrirModalReserva() {
    if (!haySession) {
        verificarSesionYReservar();
        return;
    }
    
    $('#modalReserva').modal('show');
    resetearReserva();
}

// Abrir modal con servicio pre-seleccionado (desde landing page)
function abrirModalConServicio(id, nombre, precio) {
    if (!haySession) {
        verificarSesionYReservar();
        return;
    }
    
    $('#modalReserva').modal('show');
    resetearReserva();
    
    // Auto-seleccionar el servicio después de cargar
    setTimeout(function() {
        seleccionarServicio(id, nombre, precio);
    }, 500);
}

// Resetear reserva
function resetearReserva() {
    reservaData = {
        servicio: null,
        profesional: null,
        fecha: null,
        horario: null
    };
    mostrarPaso(1);
}

// Navegar entre pasos
function mostrarPaso(paso) {
    $('.paso-reserva').hide();
    $('#paso' + paso).show();
    
    // Ocultar todos los botones
    $('#btnContinuar').hide();
    $('#btnConfirmarReserva').hide();
    
    // Mostrar botón según el paso
    if (paso === 3 && reservaData.fecha && reservaData.horario) {
        $('#btnContinuar').show();
    } else if (paso === 4) {
        $('#btnConfirmarReserva').show();
    } else if (paso === 5) {
        $('#btnConfirmarReserva').show();
    }
}

function volverPaso(paso) {
    mostrarPaso(paso);
}

// CARGAR SERVICIOS
function cargarServicios() {
    $.ajax({
        url: 'Cabecera-detalle/Controlador_reserva_publica.jsp',
        type: 'POST',
        data: { accion: 'listarServicios' },
        dataType: 'json',
        success: function(response) {
            console.log("Servicios cargados:", response);
            $('#listaServicios').html(response.grid);
            $('#serviciosModal').html(response.modal);
        },
        error: function(error) {
            console.error("Error cargando servicios:", error);
        }
    });
}

// Seleccionar servicio
function seleccionarServicio(id, nombre, precio) {
    reservaData.servicio = { id, nombre, precio };
    console.log("Servicio seleccionado:", reservaData.servicio);
    
    // Actualizar título
    $('#tituloServicio').text(nombre);
    
    // Marcar como seleccionado
    $('.servicio-card-modal').removeClass('selected');
    $('#servicio-' + id).addClass('selected');
    
    // Cargar profesionales
    setTimeout(function() {
        cargarProfesionales(id);
        mostrarPaso(2);
    }, 300);
}

// CARGAR PROFESIONALES
function cargarProfesionales(id_servicio) {
    $.ajax({
        url: 'Cabecera-detalle/Controlador_reserva_publica.jsp',
        type: 'POST',
        data: { 
            accion: 'listarProfesionalesPorServicio',
            id_servicio: id_servicio
        },
        success: function(response) {
            console.log("Profesionales cargados:", response);
            $('#profesionalesModal').html(response);
        },
        error: function(error) {
            console.error("Error cargando profesionales:", error);
        }
    });
}

// Seleccionar profesional
function seleccionarProfesional(id, nombre, id_sucursal, sucursal) {
    reservaData.profesional = { id, nombre, id_sucursal, sucursal };
    console.log("Profesional seleccionado:", reservaData.profesional);
    
    // Marcar como seleccionado
    $('.servicio-card-modal').removeClass('selected');
    $('.profesional-card-cualquiera').removeClass('selected');
    
    if (id === 0) {
        $('.profesional-card-cualquiera').addClass('selected');
    } else {
        $('#profesional-' + id).addClass('selected');
    }
    
    // Actualizar info
    $('#infoProfesional').text(nombre);
    
    // Generar calendario de la semana
    setTimeout(function() {
        generarCalendarioSemana();
        mostrarPaso(3);
    }, 300);
}

// GENERAR CALENDARIO TIPO BOOKSY (7 días)
function generarCalendarioSemana() {
    var html = '';
    var hoy = new Date();
    
    var diasSemana = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    
    for (var i = 0; i < 14; i++) { // Mostrar 2 semanas
        var fecha = new Date();
        fecha.setDate(hoy.getDate() + i);
        
        // Saltar domingos (día 0)
        if (fecha.getDay() === 0) continue;
        
        var fechaStr = fecha.getFullYear() + '-' + 
               String(fecha.getMonth() + 1).padStart(2, '0') + '-' + 
               String(fecha.getDate()).padStart(2, '0');
        var diaNombre = diasSemana[fecha.getDay()];
        var diaNumero = fecha.getDate();
        
        html += '<div class="dia-semana-btn" id="dia-' + fechaStr + '" onclick="seleccionarFecha(\'' + fechaStr + '\')">';
        html += '<span class="dia-nombre">' + diaNombre + '</span>';
        html += '<span class="dia-numero">' + diaNumero + '</span>';
        html += '</div>';
    }
    
    $('#calendarioSemana').html(html);
}

// SELECCIONAR FECHA
function seleccionarFecha(fecha) {
    reservaData.fecha = fecha;
    console.log("Fecha seleccionada:", fecha);
    
    // Marcar como seleccionado
    $('.dia-semana-btn').removeClass('selected');
    $('#dia-' + fecha).addClass('selected');
    
    // Cargar horarios
    cargarHorariosDisponibles();
}

// CARGAR HORARIOS DISPONIBLES
function cargarHorariosDisponibles() {
    var fecha = reservaData.fecha;
    
    if (!fecha) {
        return;
    }
    
    $('#horariosDisponibles').html('<div class="spinner-border text-primary" role="status"></div>');
    
    // Si es "Cualquiera", buscar cualquier profesional disponible
    var idProfesional = reservaData.profesional.id;
    
    $.ajax({
        url: 'Cabecera-detalle/Controlador_reserva_publica.jsp',
        type: 'POST',
        data: { 
            accion: 'obtenerHorariosDisponibles',
            id_profesional: idProfesional,
            id_servicio: reservaData.servicio.id,
            fecha: fecha
        },
        success: function(response) {
            console.log("Horarios disponibles:", response);
            $('#horariosDisponibles').html(response);
        },
        error: function(error) {
            console.error("Error cargando horarios:", error);
            $('#horariosDisponibles').html('<p class="text-danger">Error al cargar horarios</p>');
        }
    });
}

// Seleccionar horario
function seleccionarHorario(id, hora_inicio, hora_fin, id_profesional_asignado, id_sucursal_asignada) {
    reservaData.horario = { id, hora_inicio, hora_fin };
    
    // Si era "Cualquiera", actualizar con el profesional y sucursal asignados
    if (reservaData.profesional.id === 0 && id_profesional_asignado) {
        reservaData.profesional.id = id_profesional_asignado;
        reservaData.profesional.id_sucursal = id_sucursal_asignada;
        console.log("✅ Profesional asignado automáticamente: " + id_profesional_asignado + ", Sucursal: " + id_sucursal_asignada);
    }
    
    console.log("Horario seleccionado:", reservaData.horario);
    console.log("Datos completos:", reservaData);
    
    // Marcar como seleccionado
    $('.horario-btn').removeClass('selected');
    $('#horario-' + id).addClass('selected');
    
    // Mostrar botón continuar
    $('#btnContinuar').show();
}

// CONTINUAR (decide si mostrar paso 4 o 5)
function continuarReserva() {
    if (haySession) {
        // Usuario ya logueado → Mostrar confirmación (paso 5)
        mostrarResumenFinal();
        mostrarPaso(5);
    } else {
        // Usuario NO logueado → Mostrar formulario (paso 4)
        mostrarResumen();
        mostrarPaso(4);
    }
}

// Mostrar resumen (para paso 4)
function mostrarResumen() {
    $('#resumenServicio').text(reservaData.servicio.nombre);
    $('#resumenProfesional').text(reservaData.profesional.nombre);
    $('#resumenFecha').text(formatearFecha(reservaData.fecha));
    $('#resumenHora').text(reservaData.horario.hora_inicio.substring(0, 5) + ' - ' + reservaData.horario.hora_fin.substring(0, 5));
    $('#resumenPrecio').text('Gs. ' + Number(reservaData.servicio.precio).toLocaleString());
}

// Mostrar resumen final (para paso 5)
function mostrarResumenFinal() {
    $('#resumenServicio2').text(reservaData.servicio.nombre);
    $('#resumenProfesional2').text(reservaData.profesional.nombre);
    $('#resumenFecha2').text(formatearFecha(reservaData.fecha));
    $('#resumenHora2').text(reservaData.horario.hora_inicio.substring(0, 5) + ' - ' + reservaData.horario.hora_fin.substring(0, 5));
    $('#resumenPrecio2').text('Gs. ' + Number(reservaData.servicio.precio).toLocaleString());
}

// Formatear fecha
function formatearFecha(fecha) {
    var partes = fecha.split('-');
    return partes[2] + '/' + partes[1] + '/' + partes[0];
}

// CONFIRMAR RESERVA
function confirmarReserva() {
    var datos = {
        accion: 'registrarReserva',
        id_servicio: reservaData.servicio.id,
        id_profesional: reservaData.profesional.id,
        id_sucursal: reservaData.profesional.id_sucursal,
        fecha: reservaData.fecha,
        id_horario: reservaData.horario.id
    };
    
    // Si NO hay sesión, agregar datos del cliente
    if (!haySession) {
        if (!$('#formDatosCliente')[0].checkValidity()) {
            $('#formDatosCliente')[0].reportValidity();
            return;
        }
        
        datos.nombre = $('#nombreCliente').val();
        datos.apellido = $('#apellidoCliente').val();
        datos.telefono = $('#telefonoCliente').val();
        datos.email = $('#emailCliente').val();
        datos.ci = $('#ciCliente').val();
    }
    
    console.log("Enviando reserva:", datos);
    
    // Deshabilitar botón
    $('#btnConfirmarReserva').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Procesando...');
    
    $.ajax({
        url: 'Cabecera-detalle/Controlador_reserva_publica.jsp',
        type: 'POST',
        data: datos,
        success: function(response) {
            console.log("Respuesta:", response);
            
            var respuestaLimpia = response.trim();
            
            if (respuestaLimpia.toLowerCase().indexOf('xito') !== -1 || respuestaLimpia.toLowerCase().indexOf('correctamente') !== -1) {
                $('#modalReserva').modal('hide');
                
                Swal.fire({
                    icon: 'success',
                    title: '¡Reserva Confirmada!',
                    html: '<p>Tu cita ha sido agendada exitosamente.</p>' +
                          '<p><strong>Fecha:</strong> ' + formatearFecha(reservaData.fecha) + '</p>' +
                          '<p><strong>Hora:</strong> ' + reservaData.horario.hora_inicio.substring(0, 5) + '</p>' +
                          '<p>¡Te esperamos!</p>',
                    confirmButtonColor: '#e67e22'
                });
                
                resetearFormulario();
                
                // Si no había sesión, sugerir que inicie sesión
                if (!haySession) {
                    setTimeout(function() {
                        Swal.fire({
                            icon: 'info',
                            title: '¿Quieres ver tus citas?',
                            text: 'Crea una cuenta para ver y gestionar tus reservas',
                            showCancelButton: true,
                            confirmButtonText: 'Crear cuenta',
                            cancelButtonText: 'Más tarde',
                            confirmButtonColor: '#667eea'
                        }).then((result) => {
                            if (result.isConfirmed) {
                                window.location.href = 'registro_cliente.jsp';
                            }
                        });
                    }, 2000);
                }
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: respuestaLimpia,
                    confirmButtonColor: '#e67e22'
                });
            }
        },
        error: function(error) {
            console.error("Error:", error);
            Swal.fire({
                icon: 'error',
                title: 'Error',
                text: 'Ocurrió un error al procesar tu reserva. Por favor intenta nuevamente.',
                confirmButtonColor: '#e67e22'
            });
        },
        complete: function() {
            $('#btnConfirmarReserva').prop('disabled', false).html('<i class="fas fa-check"></i> Confirmar Reserva');
        }
    });
}

// Resetear formulario
function resetearFormulario() {
    $('#formDatosCliente')[0].reset();
    resetearReserva();
}
