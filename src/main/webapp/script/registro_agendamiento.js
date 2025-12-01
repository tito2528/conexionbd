// Array temporal para almacenar servicios antes de guardar
var serviciosTemporales = [];

$(document).ready(function() {
    cargarClientes();
    cargarServicios();
    cargarTodosLosHorarios(); // Cargar TODOS los horarios de la tabla horario
    
    // BLOQUEAR DOMINGOS en el input de fecha
    $("#age_fecha").on('change', function() {
        var fechaValue = this.value;
        
        if (!fechaValue) {
            return;
        }
        
        var fechaSeleccionada = new Date(fechaValue + 'T00:00:00');
        var diaSemana = fechaSeleccionada.getDay(); // 0 = Domingo, 6 = Sábado
        
        if (diaSemana === 0) { // Si es Domingo
            alert("⚠️ No se pueden agendar citas los domingos. Por favor seleccione otro día.");
            $(this).val(""); // Limpiar el campo
            return;
        }
    });
    
    // Modal de búsqueda de cliente
    $("#btnBuscarCliente").click(function() {
        $("#modalBuscarCliente").modal('show');
        buscarClientes();
    });
    
    $("#busqueda_cliente").on('keyup', function() {
        buscarClientes();
    });
    
    // Cuando se selecciona un servicio
    $("#id_servicio").change(function() {
        var servicioId = $(this).val();
        if (servicioId) {
            cargarPrecioServicio(servicioId);
            cargarProfesionalesPorServicio(servicioId);
        } else {
            $("#precio_servicio").val("");
            $("#id_profesional").html("<option value=''>Seleccione servicio primero</option>");
        }
    });
    
    // Cuando se selecciona un profesional - VALIDAR DISPONIBILIDAD
    $("#id_profesional").change(function() {
        var id_profesional = $(this).val();
        if (id_profesional) {
            // Cargar la sucursal del profesional
            cargarSucursalProfesional(id_profesional);
            // Validar si está disponible en el horario seleccionado
            validarDisponibilidadProfesional();
        } else {
            $("#sucursal_nombre").val("");
            $("#id_sucursal").val("");
        }
    });
    
    // Cuando se selecciona un horario - VALIDAR si el profesional ya está seleccionado
    $("#id_horario").change(function() {
        if ($("#id_profesional").val()) {
            validarDisponibilidadProfesional();
        }
    });
    
    // Agregar servicio al detalle
    $("#btnAgregarServicio").click(function() {
        agregarServicio();
    });
    
    // Registrar cita completa
    $("#btnRegistrarCita").click(function() {
        registrarAgendamiento();
    });
});

// Cargar clientes en el select
function cargarClientes() {
    $.post('Cabecera-detalle/Controlador_agendamiento.jsp', 
        {accion: 'listarClientes'}, 
        function(response) {
            $("#id_cliente").html(response);
        }
    );
}

// Buscar clientes en el modal
function buscarClientes() {
    var termino = $("#busqueda_cliente").val();
    $.post('Cabecera-detalle/Controlador_agendamiento.jsp', {
        accion: 'buscarClientes',
        q: termino
    }, function(response) {
        $("#resultados_clientes").html(response);
        
        // Agregar evento click a los botones de selección
        $('.btn-seleccionar-cliente').off('click').on('click', function() {
            var id = $(this).data('id');
            var nombre = $(this).data('nombre');
            seleccionarClienteDesdeModal(id, nombre);
        });
    });
}

// Seleccionar cliente desde el modal
function seleccionarClienteDesdeModal(id, nombre) {
    $("#id_cliente").html("<option value='" + id + "' selected>" + nombre + "</option>");
    $("#modalBuscarCliente").modal('hide');
}

// Cargar servicios
function cargarServicios() {
    $.post('Cabecera-detalle/Controlador_agendamiento.jsp', 
        {accion: 'listarServicios'}, 
        function(response) {
            $("#id_servicio").html(response);
        }
    );
}

// Cargar TODOS los horarios disponibles de la tabla horario
function cargarTodosLosHorarios() {
    $.post('Cabecera-detalle/Controlador_agendamiento.jsp', 
        {accion: 'listarHorarios'}, 
        function(response) {
            $("#id_horario").html(response);
        }
    );
}

// Cargar precio del servicio
function cargarPrecioServicio(id_servicio) {
    $.post('Cabecera-detalle/Controlador_agendamiento.jsp', {
        accion: 'obtenerPrecioServicio',
        id_servicio: id_servicio
    }, function(response) {
        $("#precio_servicio").val(response);
    });
}

// Cargar profesionales que ofrecen el servicio seleccionado
function cargarProfesionalesPorServicio(id_servicio) {
    console.log("Cargando profesionales para servicio:", id_servicio);
    $("#id_profesional").html("<option value=''>Cargando...</option>");
    
    $.ajax({
        url: 'Cabecera-detalle/Controlador_agendamiento.jsp',
        type: 'POST',
        data: {
            accion: 'profesionalesPorServicio',
            id_servicio: id_servicio
        },
        success: function(response) {
            console.log("Respuesta profesionales:", response);
            $("#id_profesional").html(response);
        },
        error: function(xhr, status, error) {
            console.error("Error cargando profesionales:", error);
            $("#id_profesional").html("<option value=''>Error al cargar profesionales</option>");
        }
    });
}

// Cargar la sucursal del profesional
function cargarSucursalProfesional(id_profesional) {
    $.ajax({
        url: 'Cabecera-detalle/Controlador_agendamiento.jsp',
        type: 'POST',
        data: {
            accion: 'sucursalPorProfesional',
            id_profesional: id_profesional
        },
        dataType: 'json',
        success: function(data) {
            console.log("Sucursal del profesional:", data);
            $("#sucursal_nombre").val(data.sucursal);
            $("#id_sucursal").val(data.id_sucursal);
        },
        error: function(xhr, status, error) {
            console.error("Error cargando sucursal:", error);
            $("#sucursal_nombre").val("");
            $("#id_sucursal").val("");
        }
    });
}

// VALIDAR DISPONIBILIDAD DEL PROFESIONAL (SE EJECUTA POR DETRÁS)
function validarDisponibilidadProfesional() {
    var id_profesional = $("#id_profesional").val();
    var id_horario = $("#id_horario").val();
    var fecha = $("#age_fecha").val();
    
    if (!id_profesional || !id_horario || !fecha) {
        return; // No validar si falta algún dato
    }
    
    console.log("Validando disponibilidad - Profesional:", id_profesional, "Horario:", id_horario, "Fecha:", fecha);
    
    $.ajax({
        url: 'Cabecera-detalle/profesional_horario.jsp',
        type: 'POST',
        data: {
            accion: 'validarDisponibilidad',
            id_profesional: id_profesional,
            id_horario: id_horario,
            fecha: fecha
        },
        success: function(response) {
            console.log("Respuesta validación:", response);
            
            if (response.trim() !== "DISPONIBLE") {
                // Mostrar alerta si NO está disponible
                alert("⚠️ " + response);
                // Limpiar el profesional seleccionado
                $("#id_profesional").val("");
                $("#sucursal_nombre").val("");
                $("#id_sucursal").val("");
            }
        },
        error: function(xhr, status, error) {
            console.error("Error validando disponibilidad:", error);
        }
    });
}

// Agregar servicio al detalle temporal
function agregarServicio() {
    var id_servicio = $("#id_servicio").val();
    var nombre_servicio = $("#id_servicio option:selected").text();
    var precio = $("#precio_servicio").val();
    var id_profesional = $("#id_profesional").val();
    var nombre_profesional = $("#id_profesional option:selected").text();
    var fecha = $("#age_fecha").val();
    var id_horario = $("#id_horario").val();
    var horario_texto = $("#id_horario option:selected").text();
    
    // Validaciones
    if (!id_servicio) {
        alert("⚠️ Seleccione un servicio");
        return;
    }
    if (!id_profesional) {
        alert("⚠️ Seleccione un profesional");
        return;
    }
    if (!fecha) {
        alert("⚠️ Seleccione una fecha");
        return;
    }
    if (!id_horario) {
        alert("⚠️ Seleccione un horario");
        return;
    }
    
    // VALIDACIÓN: No permitir agregar el mismo servicio duplicado
    var yaExiste = serviciosTemporales.some(function(servicio) {
        return servicio.id_servicio == id_servicio;
    });
    
    if (yaExiste) {
        alert("⚠️ Este servicio ya fue agregado.");
        return;
    }
    
    // Agregar al array temporal
    serviciosTemporales.push({
        id_servicio: id_servicio,
        nombre_servicio: nombre_servicio,
        precio: precio,
        id_profesional: id_profesional,
        nombre_profesional: nombre_profesional,
        fecha: fecha,
        id_horario: id_horario,
        horario_texto: horario_texto
    });
    
    // Actualizar tabla
    actualizarTablaServicios();
    
    // Limpiar campos
    $("#id_servicio").val("");
    $("#precio_servicio").val("");
    $("#id_profesional").html("<option value=''>Seleccione servicio primero</option>");
}

// Actualizar la tabla de servicios temporales
function actualizarTablaServicios() {
    var html = "";
    
    if (serviciosTemporales.length === 0) {
        html = "<tr id='sin-servicios'><td colspan='5' class='text-center text-muted'>No hay servicios agregados</td></tr>";
    } else {
        serviciosTemporales.forEach(function(servicio, index) {
            html += "<tr>";
            html += "<td><button type='button' class='btn btn-danger btn-sm' onclick='eliminarServicio(" + index + ")'><i class='fa fa-trash'></i></button></td>";
            html += "<td>" + servicio.nombre_servicio + "</td>";
            html += "<td>Gs. " + Number(servicio.precio).toLocaleString() + "</td>";
            html += "<td>" + servicio.nombre_profesional + "</td>";
            html += "<td>" + servicio.horario_texto + "</td>";
            html += "</tr>";
        });
    }
    
    $("#detalle-servicios").html(html);
}

// Eliminar servicio del detalle temporal
function eliminarServicio(index) {
    if (confirm("¿Eliminar este servicio del detalle?")) {
        serviciosTemporales.splice(index, 1);
        actualizarTablaServicios();
    }
}

// Registrar agendamiento completo
function registrarAgendamiento() {
    // Validaciones básicas
    var id_cliente = $("#id_cliente").val();
    var fecha = $("#age_fecha").val();
    var estado = $("#estado").val();
    var observaciones = $("#observaciones").val();
    var id_sucursal = $("#id_sucursal").val();
    
    if (!id_cliente) {
        alert("⚠️ Seleccione un cliente");
        return;
    }
    
    if (!fecha) {
        alert("⚠️ Seleccione una fecha");
        return;
    }
    
    // Verificar que no sea domingo
    var fechaSeleccionada = new Date(fecha + 'T00:00:00');
    if (fechaSeleccionada.getDay() === 0) {
        alert("⚠️ No se pueden agendar citas los domingos");
        return;
    }
    
    if (serviciosTemporales.length === 0) {
        alert("⚠️ Debe agregar al menos un servicio");
        return;
    }
    
    // Preparar datos para enviar
    var datos = {
        accion: 'registrarCitaMultiple',
        id_cliente: id_cliente,
        age_fecha: fecha,
        estado: estado,
        observaciones: observaciones,
        id_sucursal: id_sucursal
    };
    
    // Agregar el primer servicio/profesional/horario como principal
    datos.id_profesional = serviciosTemporales[0].id_profesional;
    datos.id_horario = serviciosTemporales[0].id_horario;
    
    // Agregar TODOS los servicios
    serviciosTemporales.forEach(function(servicio, index) {
        datos['servicios[' + index + ']'] = servicio.id_servicio;
    });
    
    // Deshabilitar botón mientras procesa
    $("#btnRegistrarCita").prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Guardando...');
    
    $.ajax({
        url: 'Cabecera-detalle/Controlador_agendamiento.jsp',
        type: 'POST',
        data: datos,
        success: function(response) {
            console.log("Respuesta del servidor:", response);
            if (response.includes("correctamente")) {
                alert("✅ Cita registrada correctamente");
                // Redirigir al listado
        setTimeout(function() {
            window.location.href = 'listado_citas.jsp?cita_creada=true';
        }, 1000);
                // Limpiar formulario
                $("#formAgendamiento")[0].reset();
                serviciosTemporales = [];
                actualizarTablaServicios();
                $("#sucursal_nombre").val("");
                $("#id_sucursal").val("");
                cargarClientes();
                cargarServicios();
                cargarTodosLosHorarios();
            } else {
                $("#respuesta").html(response);
            }
        },
        error: function(xhr, status, error) {
            console.error("Error al guardar:", error);
            alert("❌ Error al guardar el agendamiento: " + error);
        },
        complete: function() {
            $("#btnRegistrarCita").prop('disabled', false).html('<i class="fa fa-save"></i> Guardar Cita');
        }
    });
}