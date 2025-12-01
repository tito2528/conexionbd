// Variables de control
var serviciosAgregados = false;
var clienteSeleccionado = null;
var servicioYaAgregado = false;
var facturaCreada = false;
var usuarioValor = null;
var sucursalValor = null;
var fromCita = false;
var serviciosDesdeCita = [];

// ==========================================
// FUNCIONES DE PERSISTENCIA CON LOCALSTORAGE
// ==========================================
function guardarCarritoEnStorage() {
    try {
        var carrito = [];
        $("#resultados tr").each(function () {
            var fila = $(this);
            carrito.push({
                servicio_id: fila.find('td:eq(0)').data('id_servicio'),
                servicio_nombre: fila.find('td:eq(1)').text(),
                precio: fila.find('td:eq(2)').text().replace('₲', '').replace(/,/g, '').trim(),
                cantidad: fila.find('td:eq(3)').text(),
                profesional_id: fila.find('td:eq(0)').data('id_profesional'),
                profesional_nombre: fila.find('td:eq(4)').text(),
                subtotal: fila.find('td:eq(5)').text().replace('₲', '').replace(/,/g, '').trim()
            });
        });

        localStorage.setItem('carritoFacturacion', JSON.stringify(carrito));
        console.log("💾 Carrito guardado:", carrito.length, "items");
    } catch (e) {
        console.error("Error guardando carrito:", e);
    }
}

function guardarDatosFacturaEnStorage() {
    try {
        var id_cliente = $("#id_cliente").val();

        // NO guardar si no hay cliente seleccionado
        if (!id_cliente || id_cliente === '') {
            console.log("⚠️ No se guarda: cliente vacío");
            return;
        }

        var datos = {
            numero_factura: $("#numero_factura").val(),
            id_cliente: id_cliente,
            cliente_nombre: $("#id_cliente option:selected").text(),
            ci_cliente: $("#ci_cliente").val(),
            sucursal_cliente: $("#sucursal_cliente").val(),
            id_metodo_pago: $("#id_metodo_pago").val(),
            id_usuario: $("#id_usuario").val(),
            id_sucursal: $("#id_sucursal").val(),
            id_agendamiento: getParameterByName('id_agendamiento')
        };

        localStorage.setItem('datosFactura', JSON.stringify(datos));
        console.log("💾 Datos de factura guardados:", {id_cliente: id_cliente, ci: datos.ci_cliente});
    } catch (e) {
        console.error("Error guardando datos:", e);
    }
}

function recuperarCarritoDeStorage() {
    try {
        var carritoGuardado = localStorage.getItem('carritoFacturacion');
        if (carritoGuardado) {
            var carrito = JSON.parse(carritoGuardado);
            console.log("📦 Recuperando carrito:", carrito.length, "items");

            // Limpiar tabla actual
            $("#resultados").empty();

            // Recrear filas
            carrito.forEach(function (item) {
                var nuevaFila = '<tr>' +
                        '<td data-id_servicio="' + item.servicio_id + '" data-id_profesional="' + item.profesional_id + '">' +
                        '<button type="button" class="btn btn-danger btn-sm eliminar" title="Eliminar">' +
                        '<span class="fa fa-trash"></span></button></td>' +
                        '<td>' + item.servicio_nombre + '</td>' +
                        '<td>₲' + Number(item.precio).toLocaleString() + '</td>' +
                        '<td>' + item.cantidad + '</td>' +
                        '<td>' + item.profesional_nombre + '</td>' +
                        '<td>₲' + Number(item.subtotal).toLocaleString() + '</td>' +
                        '</tr>';
                $("#resultados").append(nuevaFila);
            });

            // Recalcular total
            recalcularTotal();
            return true;
        }
    } catch (e) {
        console.error("Error recuperando carrito:", e);
    }
    return false;
}

function recuperarDatosFacturaDeStorage() {
    try {
        var datosGuardados = localStorage.getItem('datosFactura');
        if (datosGuardados) {
            var datos = JSON.parse(datosGuardados);
            console.log("📦 RECUPERANDO DATOS DE FACTURA:", datos);

            // Función para esperar a que un select tenga opciones
            function esperarSelectCargado(selector, callback) {
                var intentos = 0;
                var intervalo = setInterval(function () {
                    var opciones = $(selector + " option").length;
                    console.log("⏳ Esperando " + selector + " - Opciones: " + opciones);
                    if (opciones > 1 || intentos > 25) {
                        clearInterval(intervalo);
                        if (opciones > 1) {
                            callback();
                        } else {
                            console.warn("⚠️ Timeout esperando " + selector);
                        }
                    }
                    intentos++;
                }, 300);
            }

            // Restaurar valores cuando los selects estén listos
            setTimeout(function () {
                if (datos.numero_factura) {
                    $("#numero_factura").val(datos.numero_factura);
                    console.log("✅ Número de factura restaurado:", datos.numero_factura);
                }

                // Esperar y restaurar cliente
                if (datos.id_cliente) {
                    esperarSelectCargado("#id_cliente", function () {
                        $("#id_cliente").val(datos.id_cliente);
                        // NO usar .trigger('change') para evitar sobrescribir storage

                        // Manualmente actualizar CI y Sucursal
                        if (datos.ci_cliente) {
                            $("#ci_cliente").val(datos.ci_cliente);
                        }
                        if (datos.sucursal_cliente) {
                            $("#sucursal_cliente").val(datos.sucursal_cliente);
                        }

                        console.log("✅ Cliente restaurado:", datos.id_cliente);
                    });
                }

                // Esperar y restaurar método de pago
                if (datos.id_metodo_pago) {
                    esperarSelectCargado("#id_metodo_pago", function () {
                        $("#id_metodo_pago").val(datos.id_metodo_pago);
                        console.log("✅ Método de pago restaurado");
                    });
                }

                // Esperar y restaurar usuario
                if (datos.id_usuario && !fromCita) {
                    esperarSelectCargado("#id_usuario", function () {
                        $("#id_usuario").val(datos.id_usuario);
                        console.log("✅ Usuario restaurado");
                    });
                }

                // Esperar y restaurar sucursal
                if (datos.id_sucursal) {
                    esperarSelectCargado("#id_sucursal", function () {
                        $("#id_sucursal").val(datos.id_sucursal);
                        console.log("✅ Sucursal restaurada");
                    });
                }
            }, 1500);

            return true;
        } else {
            console.log("ℹ️ No hay datos guardados en storage");
        }
    } catch (e) {
        console.error("❌ Error recuperando datos:", e);
    }
    return false;
}

function limpiarStorage() {
    localStorage.removeItem('carritoFacturacion');
    localStorage.removeItem('datosFactura');
    console.log("🗑️ Storage limpiado");
}

function recalcularTotal() {
    var total = 0;
    $("#resultados tr").each(function () {
        var subtotalText = $(this).find('td:eq(5)').text().replace('₲', '').replace(/,/g, '').trim();
        total += parseInt(subtotalText) || 0;
    });
    $("#txtTotal").val(total);
    $("#txtTotalFactura").val('₲' + total.toLocaleString());
}
// ==========================================
// FIN FUNCIONES DE PERSISTENCIA
// ==========================================

function getParameterByName(name) {
    let url = window.location.href;
    name = name.replace(/[\[\]]/g, '\\$&');
    let regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)');
    let results = regex.exec(url);
    if (!results)
        return null;
    if (!results[2])
        return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}

// Función para debuggear parámetros
function debugParametros() {
    console.log("🔍 PARÁMETROS RECIBIDOS:");
    const params = [
        'id_agendamiento', 'id_cliente', 'cliente_nombre', 'id_servicio',
        'servicio_nombre', 'servicio_precio', 'id_profesional',
        'profesional_nombre', 'id_sucursal', 'sucursal_nombre', 'from_cita',
        'total_servicios'
    ];

    params.forEach(param => {
        console.log(param + ":", getParameterByName(param));
    });
}

// NUEVA FUNCIÓN: Cargar múltiples servicios desde cita
function cargarServiciosDesdeCita() {
    var total_servicios = getParameterByName('total_servicios');

    if (total_servicios) {
        serviciosDesdeCita = [];
        for (var i = 0; i < parseInt(total_servicios); i++) {
            var servicio = {
                id_servicio: getParameterByName('servicio_' + i),
                servicio_nombre: getParameterByName('servicio_nombre_' + i),
                servicio_precio: getParameterByName('servicio_precio_' + i),
                id_profesional: getParameterByName('id_profesional'),
                profesional_nombre: getParameterByName('profesional_nombre')
            };
            if (servicio.id_servicio) {
                serviciosDesdeCita.push(servicio);
            }
        }
        console.log("Servicios cargados desde cita:", serviciosDesdeCita);
    }
}

// NUEVA FUNCIÓN: Refrescar página automáticamente si viene de cita
function autoRefreshIfFromCita() {
    var from_cita = getParameterByName('from_cita');
    var already_refreshed = sessionStorage.getItem('already_refreshed');

    if (from_cita === 'true' && !already_refreshed) {
        console.log("🔄 Viene de cita, refrescando página automáticamente...");
        sessionStorage.setItem('already_refreshed', 'true');

        // Esperar 500ms y luego refrescar
        setTimeout(function () {
            window.location.reload();
        }, 500);
    } else if (already_refreshed) {
        // Limpiar la bandera después del refresco
        setTimeout(function () {
            sessionStorage.removeItem('already_refreshed');
        }, 1000);
    }
}

function crearFacturaPendiente(callback) {
    console.log("🔄 Creando nueva factura pendiente...");

    $.ajax({
        data: {listar: 'crearFacturaPendiente'},
        url: 'Cabecera-detalle/Cotrolador_compras.jsp',
        type: 'post',
        success: function (response) {
            var id_factura = response.trim();
            console.log("Nueva factura creada:", id_factura);

            if (id_factura && id_factura !== '' && !isNaN(id_factura)) {
                $("#numero_factura").val(id_factura);
                facturaCreada = true;
                if (callback)
                    callback(id_factura);
            } else {
                console.error("❌ No se pudo crear factura:", response);
            }
        },
        error: function (xhr, status, error) {
            console.error("❌ Error al crear factura:", error);
        }
    });
}

function cargarNumeroFactura(callback) {
    console.log("🔄 Cargando número de factura...");

    $.ajax({
        data: {listar: 'getFacturaPendiente'},
        url: 'Cabecera-detalle/Cotrolador_compras.jsp',
        type: 'post',
        success: function (response) {
            var id_factura = response.trim();
            console.log("Número de factura recibido:", id_factura);

            if (id_factura && id_factura !== '' && id_factura !== 'No hay factura pendiente') {
                $("#numero_factura").val(id_factura);
                if (callback)
                    callback(id_factura);
            } else {
                // Si no hay factura pendiente, crear una nueva
                crearFacturaPendiente(callback);
            }
        },
        error: function (xhr, status, error) {
            console.error("❌ Error al cargar número de factura:", error);
            // Si hay error, intentar crear una nueva factura
            crearFacturaPendiente(callback);
        }
    });
}

// NUEVA FUNCIÓN: Agregar múltiples servicios desde cita
function agregarServiciosDesdeCita(id_factura) {
    if (serviciosDesdeCita.length === 0) {
        console.log("No hay servicios para agregar desde cita");
        return;
    }

    console.log("Agregando", serviciosDesdeCita.length, "servicios desde cita...");

    // PRIMERO ACTUALIZAR LOS DATOS PRINCIPALES DE LA FACTURA
    var datosFactura = {
        listar: 'actualizarFacturaDesdeCita',
        id_factura: id_factura,
        id_cliente: $("#id_cliente").val(),
        id_usuario: usuarioValor || $("#id_usuario").val(),
        id_metodo_pago: $("#id_metodo_pago").val(),
        id_sucursal: sucursalValor || $("#id_sucursal").val()
    };

    $.ajax({
        data: datosFactura,
        url: 'Cabecera-detalle/Cotrolador_compras.jsp',
        type: 'post',
        success: function (response) {
            console.log("Datos de factura actualizados:", response);
            // Luego agregar los servicios
            agregarServiciosIndividualmente(id_factura);
        },
        error: function (error) {
            console.error("Error al actualizar datos de factura:", error);
            // De todos modos intentar agregar servicios
            agregarServiciosIndividualmente(id_factura);
        }
    });
}

// Función auxiliar para agregar servicios individualmente
function agregarServiciosIndividualmente(id_factura) {
    var serviciosAgregados = 0;
    var serviciosConError = 0;

    serviciosDesdeCita.forEach(function (servicio, index) {
        setTimeout(function () {
            var datos = {
                listar: 'agregarServicioDesdeCita',
                id_factura: id_factura,
                id_servicio: servicio.id_servicio,
                cantidad: 1,
                precio_unitario: servicio.servicio_precio,
                id_profesional: servicio.id_profesional,
                observaciones: 'Servicio agendado desde cita - ' + servicio.servicio_nombre
            };

            $.ajax({
                data: datos,
                url: 'Cabecera-detalle/Cotrolador_compras.jsp',
                type: 'post',
                success: function (response) {
                    console.log("Respuesta del servidor para servicio", servicio.servicio_nombre + ":", response);
                    if (response === 'OK' || response === 'YA_EXISTE') {
                        serviciosAgregados++;
                        console.log("✅ Servicio agregado:", servicio.servicio_nombre);
                    } else {
                        serviciosConError++;
                        console.error("❌ Error al agregar servicio:", servicio.servicio_nombre, response);
                    }

                    // Cuando se completen todos los servicios, cargar el detalle
                    if (serviciosAgregados + serviciosConError === serviciosDesdeCita.length) {
                        console.log("✅ Todos los servicios procesados. Agregados:", serviciosAgregados, "Errores:", serviciosConError);
                        servicioYaAgregado = true;

                        // Forzar recarga del detalle después de agregar todos los servicios
                        setTimeout(function () {
                            cargardetalle();
                        }, 500);
                    }
                },
                error: function (xhr, status, error) {
                    serviciosConError++;
                    console.error("❌ Error AJAX al agregar servicio:", servicio.servicio_nombre, error);

                    if (serviciosAgregados + serviciosConError === serviciosDesdeCita.length) {
                        console.log("✅ Todos los servicios procesados. Agregados:", serviciosAgregados, "Errores:", serviciosConError);
                        servicioYaAgregado = true;

                        setTimeout(function () {
                            cargardetalle();
                        }, 500);
                    }
                }
            });
        }, index * 300);
    });
}

function actualizarDatosCliente() {
    var selected = $("#id_cliente").find('option:selected');
    var ci = selected.attr('data-ci');
    var sucursal = selected.attr('data-sucursal');

    console.log("🔍 Actualizando datos cliente:", {
        cliente_id: selected.val(),
        ci: ci,
        sucursal: sucursal,
        html: selected[0] ? selected[0].outerHTML : 'no existe'
    });

    $("#ci_cliente").val(ci ? ci : '');
    $("#sucursal_cliente").val(sucursal ? sucursal : '');
}

function buscarcliente() {
    var id_cliente_url = getParameterByName('id_cliente');
    var cliente_nombre_url = getParameterByName('cliente_nombre');

    // Verificar si hay datos en storage
    var hayStorage = localStorage.getItem('datosFactura') !== null;

    if (id_cliente_url && cliente_nombre_url) {
        // Si viene de cita, cargar cliente específico (IGNORAR storage)
        console.log("🔗 Viene de cita con cliente:", id_cliente_url);

        $.ajax({
            data: {listar: 'buscarcliente', id_cliente: id_cliente_url},
            url: 'Cabecera-detalle/Cotrolador_compras.jsp',
            type: 'post',
            success: function (response) {
                $("#id_cliente").html(response);
                $("#id_cliente").val(id_cliente_url);

                // Forzar la actualización de datos del cliente
                setTimeout(function () {
                    actualizarDatosCliente();

                    // GUARDAR EN STORAGE después de actualizar
                    setTimeout(function () {
                        guardarDatosFacturaEnStorage();
                        console.log("💾 Datos de cita guardados en storage");
                    }, 200);
                }, 100);

                clienteSeleccionado = id_cliente_url;
            }
        });
    } else {
        // Cargar todos los clientes (sin seleccionar ninguno si hay storage)
        $.ajax({
            data: {listar: 'buscarcliente'},
            url: 'Cabecera-detalle/Cotrolador_compras.jsp',
            type: 'post',
            success: function (response) {
                $("#id_cliente").html(response);

                // Solo actualizar si NO hay storage
                if (!hayStorage) {
                    setTimeout(function () {
                        actualizarDatosCliente();
                    }, 100);
                }
            }
        });
    }
}

function buscarservicio() {
    var id_servicio_url = getParameterByName('id_servicio');

    // Siempre cargar todos los servicios
    $.ajax({
        data: {listar: 'buscarservicio'},
        url: 'Cabecera-detalle/Cotrolador_compras.jsp',
        type: 'post',
        success: function (response) {
            $("#id_servicio").html(response);

            // Si viene de cita, seleccionar el primer servicio
            if (id_servicio_url) {
                setTimeout(function () {
                    $("#id_servicio").val(id_servicio_url);
                    var precio = $("#id_servicio option:selected").data('precio');
                    $("#precio_unitario").val(precio || '');
                }, 200);
            }
        }
    });
}

function buscarProfesionalesPorServicio(idServicio) {
    var id_profesional_url = getParameterByName('id_profesional');

    if (idServicio) {
        $.ajax({
            data: {listar: 'buscarProfesionalesPorServicio', id_servicio: idServicio},
            url: 'Cabecera-detalle/Cotrolador_compras.jsp',
            type: 'post',
            success: function (response) {
                $("#id_profesional").html(response);

                // Si viene de cita, seleccionar el profesional
                if (id_profesional_url) {
                    setTimeout(function () {
                        $("#id_profesional").val(id_profesional_url);
                    }, 200);
                }
            }
        });
    }
}

function buscarmetodopago() {
    $.ajax({
        data: {listar: 'buscarmetodopago'},
        url: 'Cabecera-detalle/Cotrolador_compras.jsp',
        type: 'post',
        success: function (response) {
            console.log("📋 Métodos de pago recibidos:", response);

            // Cargar primer select
            $("#id_metodo_pago").html(response);

            // NUEVO: Cargar segundo select (eliminar la primera opción vacía y agregar "No usar")
            var opciones = response;
            // Reemplazar cualquier variante de "Seleccione"
            opciones = opciones.replace(/<option value=""[^>]*>.*?<\/option>/i, '');
            $("#id_metodo_pago_2").html('<option value="">No usar segundo método</option>' + opciones);

            console.log("✅ Segundo select de método de pago cargado");

            if ($("#id_metodo_pago option").length > 1) {
                setTimeout(function () {
                    $("#id_metodo_pago").val($("#id_metodo_pago option:eq(1)").val());

                    // Guardar en storage
                    setTimeout(function () {
                        guardarDatosFacturaEnStorage();
                    }, 100);
                }, 100);
            }
        }
    });
}

function buscarusuario() {
    $.ajax({
        data: {listar: 'buscarusuario'},
        url: 'Cabecera-detalle/Cotrolador_compras.jsp',
        type: 'post',
        success: function (response) {
            $("#id_usuario").html(response);
            if ($("#id_usuario option").length > 1) {
                setTimeout(function () {
                    // Usar el usuario logueado si existe, sino el primero
                    if (typeof usuarioLogueadoId !== 'undefined' && usuarioLogueadoId !== null) {
                        usuarioValor = usuarioLogueadoId;
                    } else {
                        usuarioValor = $("#id_usuario option:eq(1)").val();
                    }
                    $("#id_usuario").val(usuarioValor);
                    // Bloquear si hay usuario logueado
                    if (typeof usuarioLogueadoId !== 'undefined' && usuarioLogueadoId !== null) {
                        $("#id_usuario").prop('disabled', true).css({
                            'background-color': '#e9ecef',
                            'cursor': 'not-allowed'
                        });
                    }

                    // Guardar en storage
                    setTimeout(function () {
                        guardarDatosFacturaEnStorage();
                    }, 100);
                }, 100);
            }
        }
    });
}

function buscarsucursal() {
    var id_sucursal_url = getParameterByName('id_sucursal');
    var sucursal_nombre_url = getParameterByName('sucursal_nombre');

    if (id_sucursal_url && sucursal_nombre_url) {
        console.log("🔗 Viene de cita con sucursal:", id_sucursal_url);

        $.ajax({
            data: {listar: 'buscarsucursal'},
            url: 'Cabecera-detalle/Cotrolador_compras.jsp',
            type: 'post',
            success: function (response) {
                $("#id_sucursal").html(response);
                setTimeout(function () {
                    sucursalValor = id_sucursal_url;
                    $("#id_sucursal").val(sucursalValor);
                    $("#id_sucursal").prop('readonly', true).css({
                        'background-color': '#e9ecef',
                        'cursor': 'not-allowed'
                    });

                    // Guardar en storage
                    setTimeout(function () {
                        guardarDatosFacturaEnStorage();
                    }, 100);
                }, 100);
            }
        });
    } else {
        $.ajax({
            data: {listar: 'buscarsucursal'},
            url: 'Cabecera-detalle/Cotrolador_compras.jsp',
            type: 'post',
            success: function (response) {
                $("#id_sucursal").html(response);
                if ($("#id_sucursal option").length > 1) {
                    setTimeout(function () {
                        sucursalValor = $("#id_sucursal option:eq(1)").val();
                        $("#id_sucursal").val(sucursalValor);
                        $("#id_sucursal").prop('readonly', true).css({
                            'background-color': '#e9ecef',
                            'cursor': 'not-allowed'
                        });

                        // Guardar en storage
                        setTimeout(function () {
                            guardarDatosFacturaEnStorage();
                        }, 100);
                    }, 100);
                }
            }
        });
    }
}

function cargardetalle() {
    $.ajax({
        data: {listar: 'listar'},
        url: 'Cabecera-detalle/Cotrolador_compras.jsp',
        type: 'post',
        success: function (response) {
            var partes = response.split('<!--TOTAL-->');
            $("#resultados").html(partes[0]);
            if (partes[1]) {
                $("#txtTotalFactura").val(partes[1]);
                $("#txtTotal").val(partes[1].replace(/[^\d]/g, ''));
            }

            console.log("Detalles cargados: " + $("#resultados tr").length + " elementos");
        }
    });
}

function limpiarFormulario() {
    $("#cantidad").val('1');
    $("#precio_unitario").val('');
    $("#id_profesional").html('<option value="">Seleccione un servicio primero</option>');
    $("#respuesta").html('');
}

// Función personalizada para serializar el formulario incluyendo campos readonly
function serializarFormulario() {
    var formData = $("#form").serializeArray();

    if (usuarioValor) {
        formData.push({name: "id_usuario", value: usuarioValor});
    }
    if (sucursalValor) {
        formData.push({name: "id_sucursal", value: sucursalValor});
    }

    return $.param(formData);
}

// Eventos
$(document).on('change', '#id_cliente', function () {
    actualizarDatosCliente();
    clienteSeleccionado = $(this).val();
});

$(document).on('change', '#id_servicio', function () {
    var selectedOption = $(this).find('option:selected');
    var precio = selectedOption.attr('data-precio');
    var idServicio = selectedOption.val();

    $("#precio_unitario").val(precio ? precio : '');
    buscarProfesionalesPorServicio(idServicio);
});

$("#AgregaServicioFactura").click(function () {
    var datosform = serializarFormulario();

    $.ajax({
        data: datosform,
        url: 'Cabecera-detalle/Cotrolador_compras.jsp',
        type: 'post',
        success: function (response) {
            if (response.includes("Faltan completar")) {
                alert(response);
            } else if (response.includes("Error")) {
                alert("Error: " + response);
            } else {
                $("#respuesta").html('<div class="alert alert-success">' + response + '</div>');
                cargardetalle();
                cargarNumeroFactura();

                serviciosAgregados = true;
                clienteSeleccionado = $("#id_cliente").val();

                // Guardar en storage
                setTimeout(function () {
                    guardarCarritoEnStorage();
                    guardarDatosFacturaEnStorage();
                }, 500);

                limpiarFormulario();
            }
        }
    });
});

$(document).on('click', '.btn-eliminar', function () {
    var id_detalle = $(this).data('id');
    $.ajax({
        data: {listar: 'eliminar', id_detalle: id_detalle},
        url: 'Cabecera-detalle/Cotrolador_compras.jsp',
        type: 'post',
        success: function (response) {
            cargardetalle();
            cargarNumeroFactura();
            // Guardar en storage
            setTimeout(function () {
                guardarCarritoEnStorage();
            }, 500);
        }
    });
});

$("#btn-submit").click(function () {
    var cliente = $("#id_cliente").val();
    var metodo_pago = $("#id_metodo_pago").val();
    var metodo_pago_2 = $("#id_metodo_pago_2").val();
    var monto_pago_1 = parseFloat($("#monto_pago_1").val()) || 0;
    var monto_pago_2 = parseFloat($("#monto_pago_2").val()) || 0;
    var usuario = usuarioValor || $("#id_usuario").val();
    var sucursal = sucursalValor || $("#id_sucursal").val();
    var total = parseFloat($("#txtTotal").val()) || 0;
    var id_agendamiento = getParameterByName('id_agendamiento');

    // Validaciones básicas
    if (!cliente) {
        Swal.fire({
            icon: 'warning',
            title: 'Atención',
            text: 'Seleccione un cliente',
            confirmButtonColor: '#667eea'
        });
        return;
    }
    if (!metodo_pago) {
        Swal.fire({
            icon: 'warning',
            title: 'Atención',
            text: 'Seleccione un método de pago',
            confirmButtonColor: '#667eea'
        });
        return;
    }

    // NUEVA VALIDACIÓN: Verificar montos si usa 2 métodos de pago
    if (metodo_pago_2 && metodo_pago_2 !== '') {
        // Si seleccionó segundo método, validar montos
        if (monto_pago_1 <= 0 || monto_pago_2 <= 0) {
            Swal.fire({
                icon: 'warning',
                title: 'Atención',
                text: 'Debe ingresar los montos para ambos métodos de pago',
                confirmButtonColor: '#667eea'
            });
            return;
        }

        var suma_montos = monto_pago_1 + monto_pago_2;
        if (Math.abs(suma_montos - total) > 0.01) { // Tolerancia de 1 centavo
            Swal.fire({
                icon: 'warning',
                title: 'Error en montos',
                html: 'La suma de los pagos (' + suma_montos.toLocaleString() + ') debe ser igual al total (' + total.toLocaleString() + ')',
                confirmButtonColor: '#667eea'
            });
            return;
        }
    } else {
        // Si NO usa segundo método, poner todo el monto en método 1
        monto_pago_1 = total;
        monto_pago_2 = 0;
    }

    if (!usuario) {
        Swal.fire({
            icon: 'warning',
            title: 'Atención',
            text: 'Seleccione un usuario',
            confirmButtonColor: '#667eea'
        });
        return;
    }
    if (!sucursal) {
        Swal.fire({
            icon: 'warning',
            title: 'Atención',
            text: 'Seleccione una sucursal',
            confirmButtonColor: '#667eea'
        });
        return;
    }

    var numero_factura = $("#numero_factura").val();

    if (!numero_factura || numero_factura === 'No hay factura pendiente') {
        Swal.fire({
            icon: 'error',
            title: 'Error',
            text: 'No hay una factura válida para registrar',
            confirmButtonColor: '#667eea'
        });
        return;
    }

    // VERIFICAR SI HAY SERVICIOS EN LA TABLA
    if ($("#resultados tr").length === 0) {
        Swal.fire({
            icon: 'warning',
            title: 'Sin servicios',
            text: 'Debe agregar al menos un servicio a la factura',
            confirmButtonColor: '#667eea'
        });
        return;
    }

    // Deshabilitar botón para evitar doble clic
    var $btn = $(this);
    $btn.prop('disabled', true).html('<span class="fa fa-spinner fa-spin"></span> Procesando...');

    $.ajax({
        data: {
            listar: 'registrar',
            id_factura: numero_factura,
            id_cliente: cliente,
            id_metodo_pago: metodo_pago,
            id_metodo_pago_2: metodo_pago_2 || '',
            monto_pago_1: monto_pago_1,
            monto_pago_2: monto_pago_2,
            id_usuario: usuario,
            id_sucursal: sucursal,
            id_agendamiento: id_agendamiento,
            total: total
        },
        url: 'Cabecera-detalle/Cotrolador_compras.jsp',
        type: 'post',
        success: function (response) {
            console.log("Respuesta del servidor:", response);

            // Limpiar la respuesta (trim espacios y saltos de línea)
            var respuestaLimpia = response.trim();

            if (respuestaLimpia.includes("Error:")) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: respuestaLimpia,
                    confirmButtonColor: '#667eea'
                });
                $btn.prop('disabled', false).html('<span class="fa fa-save"></span> Registrar Factura');
            } else if (respuestaLimpia.startsWith("OK|")) {
                // Nueva respuesta: OK|id_factura|total
                var partes = respuestaLimpia.split("|");
                var id_factura = partes[1];
                var totalFactura = partes[2];

                // Limpiar localStorage
                limpiarStorage();

                // Alert bonito con opción de imprimir
                Swal.fire({
                    icon: 'success',
                    title: '¡Factura Registrada!',
                    html: '<p>Factura #' + id_factura + '</p>' +
                            '<p><strong>Total:</strong> ₲' + Number(totalFactura).toLocaleString() + '</p>' +
                            '<p>¿Deseas imprimir la factura?</p>',
                    showCancelButton: true,
                    confirmButtonText: '<i class="fa fa-print"></i> Sí, Imprimir',
                    cancelButtonText: 'No, gracias',
                    confirmButtonColor: '#27ae60',
                    cancelButtonColor: '#95a5a6',
                    allowOutsideClick: false
                }).then((result) => {
                    if (result.isConfirmed) {
                        // Abrir impresión en nueva ventana
                        window.open('imprimir_factura.jsp?id_factura=' + id_factura, '_blank');

                        // Pequeño delay antes de recargar
                        setTimeout(function () {
                            window.location.href = 'vistafacturacion.jsp';
                        }, 1000);
                    } else {
                        // Recargar inmediatamente
                        window.location.href = 'vistafacturacion.jsp';
                    }
                });
            } else if (respuestaLimpia.includes("correctamente")) {
                // Respuesta antigua (compatibilidad)
                limpiarStorage();
                Swal.fire({
                    icon: 'success',
                    title: '¡Éxito!',
                    text: respuestaLimpia,
                    confirmButtonColor: '#27ae60'
                }).then(() => {
                    window.location.href = 'vistafacturacion.jsp';
                });
            } else {
                Swal.fire({
                    icon: 'info',
                    title: 'Respuesta del servidor',
                    text: respuestaLimpia,
                    confirmButtonColor: '#667eea'
                });
                $btn.prop('disabled', false).html('<span class="fa fa-save"></span> Registrar Factura');
            }
        },
        error: function (xhr, status, error) {
            Swal.fire({
                icon: 'error',
                title: 'Error de conexión',
                text: 'No se pudo registrar la factura: ' + error,
                confirmButtonColor: '#667eea'
            });
            $btn.prop('disabled', false).html('<span class="fa fa-save"></span> Registrar Factura');
        }
    });
});

$("#btn-cancelar").click(function () {
    if (confirm("¿Cancelar esta factura? Se perderán todos los datos.")) {
        var numero_factura = $("#numero_factura").val();
        if (numero_factura && numero_factura !== 'No hay factura pendiente') {
            $.ajax({
                data: {listar: 'cancelarFactura', numero_factura: numero_factura},
                url: 'Cabecera-detalle/Cotrolador_compras.jsp',
                type: 'post',
                success: function (response) {
                    console.log("Factura cancelada:", response);
                    limpiarStorage();
                    window.location.href = 'vistafacturacion.jsp';
                }
            });
        } else {
            limpiarStorage();
            window.location.href = 'vistafacturacion.jsp';
        }
    }
});

$("#btn-ver-movimientos").click(function () {
    var clienteId = $("#id_cliente").val();
    if (!clienteId) {
        Swal.fire({
            icon: 'warning',
            title: 'Atención',
            text: 'Por favor, seleccione un cliente primero',
            confirmButtonColor: '#667eea'
        });
        return;
    }
    window.location.href = "movimientos_cliente.jsp?id_cliente=" + clienteId;
});

// INICIALIZACIÓN
$(document).ready(function () {
    console.log("✅ vistafacturacion.jsp cargado");

    // Debug: mostrar parámetros recibidos
    debugParametros();

    // Verificar si hay datos guardados en storage
    var hayStorage = localStorage.getItem('datosFactura') !== null || localStorage.getItem('carritoFacturacion') !== null;

    // Verificar si viene de cita por URL
    fromCita = getParameterByName('from_cita') === 'true';

    console.log("🔍 Hay storage:", hayStorage, "| Viene de cita:", fromCita);

    // 1. Cargar servicios desde cita si aplica
    if (fromCita) {
        cargarServiciosDesdeCita();
    }

    // 2. REFRESCO AUTOMÁTICO si viene de cita
    autoRefreshIfFromCita();

    // 3. Cargar número de factura primero
    cargarNumeroFactura(function (id_factura) {
        console.log("✅ Factura obtenida/creada:", id_factura);

        // 4. Cargar datos del formulario
        setTimeout(function () {
            buscarcliente();
            buscarservicio();
            buscarmetodopago();
            buscarusuario();
            buscarsucursal();
        }, 300);

        // 5. Decidir qué hacer según el contexto
        if (fromCita && serviciosDesdeCita.length > 0 && !servicioYaAgregado) {
            // Viene de cita con servicios → Agregarlos
            setTimeout(function () {
                console.log("📋 Viene de cita, agregando", serviciosDesdeCita.length, "servicios...");
                agregarServiciosDesdeCita(id_factura);
            }, 1500);
        } else {
            // NO viene de cita O ya procesó los servicios → Cargar detalle de BD
            setTimeout(function () {
                console.log("📦 Cargando detalle desde BD...");
                cargardetalle();
            }, 800);
        }
    });

    // Eventos
    $("#id_cliente").change(function () {
        actualizarDatosCliente();
        guardarDatosFacturaEnStorage(); // Persistencia
    });

    $("#id_servicio").change(function () {
        var idServicio = $(this).val();
        buscarProfesionalesPorServicio(idServicio);
        $("#precio_unitario").val($(this).find('option:selected').data('precio') || '');
    });

    // RECUPERAR DATOS DEL STORAGE (después de que todo esté cargado)
    setTimeout(function () {
        var hayCarrito = recuperarCarritoDeStorage();
        var hayDatos = recuperarDatosFacturaDeStorage();

        if (hayCarrito || hayDatos) {
            console.log("✅ Datos recuperados del storage");
        }
    }, 3000); // Aumentado a 3 segundos para dar tiempo a que carguen los selects

    // Actualizar datos automáticamente desde parámetros URL
    setTimeout(function () {
        var sucursal_url = getParameterByName('sucursal_nombre');
        if (sucursal_url) {
            $("#sucursal_cliente").val(sucursal_url);
            console.log("✅ Sucursal cargada desde URL:", sucursal_url);
        }
    }, 1000);

    console.log("🔄 Todos los procesos iniciados");
});