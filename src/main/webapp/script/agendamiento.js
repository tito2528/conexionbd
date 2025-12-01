// Función para debuggear - muestra todos los elementos y eventos
function debugElements() {
    console.log("=== DEBUG ELEMENTOS ===");
    console.log("Botón Filtrar:", $("#btnFiltrar").length);
    console.log("Botones Atender:", $(".btn-atender").length);
    console.log("Form Agendamiento:", $("#formAgendamiento").length);
    console.log("Tabla Citas:", $("#tbodyCitas").length);
}

// Cargar datos iniciales
function cargarClientes() {
    $.post('Cabecera-detalle/Controlador_agendamiento.jsp', {accion: 'listarClientes'}, function(resp){
        $("#id_cliente").html(resp);
    });
}

function cargarServicios() {
    $.post('Cabecera-detalle/Controlador_agendamiento.jsp', {accion: 'listarServicios'}, function(resp){
        $("#id_servicio").html(resp);
    });
}

function cargarHorarios() {
    $.post('Cabecera-detalle/Controlador_agendamiento.jsp', {accion: 'listarHorarios'}, function(resp){
        $("#id_horario").html(resp);
    });
}

// Listar citas - FUNCIÓN PRINCIPAL
function listarCitas() {
    var desde = $("#filtro_desde").val();
    var hasta = $("#filtro_hasta").val();
    
    console.log("Buscando citas desde:", desde, "hasta:", hasta);
    
    $.ajax({
        url: 'Cabecera-detalle/Controlador_agendamiento.jsp',
        type: 'POST',
        data: {accion: 'listarCitas', desde: desde, hasta: hasta},
        success: function(response) {
            console.log("Citas recibidas, longitud:", response.length);
            $("#tbodyCitas").html(response);
        },
        error: function(xhr, status, error) {
            console.error("Error al cargar citas:", error);
            alert("Error al cargar citas: " + error);
        }
    });
}

// REGISTRAR EVENTOS - VERSIÓN CORREGIDA (SIN DUPLICACIÓN)
function registrarEventos() {
    console.log("Registrando eventos...");
    
    // 1. BOTÓN FILTRAR - Limpiar eventos previos y agregar uno nuevo
    $("#btnFiltrar").off('click').on('click', function(e) {
        e.preventDefault();
        console.log("✅ Botón FILTRAR clickeado");
        listarCitas();
    });
}

// Servicio → Profesionales
$("#id_servicio").change(function(){
    var id_servicio = $(this).val();
    if (id_servicio) {
        $.post('Cabecera-detalle/Controlador_agendamiento.jsp', 
            {accion: 'profesionalesPorServicio', id_servicio: id_servicio}, 
            function(resp) {
                $("#id_profesional").html(resp);
            }
        );
    }
});

// Profesional → Sucursal  
$("#id_profesional").change(function(){
    var id_profesional = $(this).val();
    if(id_profesional){
        $.post('Cabecera-detalle/Controlador_agendamiento.jsp', 
            {accion: 'sucursalPorProfesional', id_profesional: id_profesional}, 
            function(resp) {
                try {
                    var data = JSON.parse(resp);
                    $("#sucursal_nombre").val(data.sucursal || '');
                    $("#id_sucursal").val(data.id_sucursal || '');
                } catch(e) {
                    $("#sucursal_nombre").val('');
                    $("#id_sucursal").val('');
                }
            }
        );
    }
});

// Búsqueda de clientes
$("#btnBuscarCliente").click(function(){
    $("#modalBuscarCliente").modal('show');
    $("#busqueda_cliente").val('');
    $("#resultados_clientes").html('');
});

$("#busqueda_cliente").keyup(function(){
    var q = $(this).val();
    if (q.length >= 2) {
        $.post('Cabecera-detalle/Controlador_agendamiento.jsp', 
            {accion: 'buscarClientes', q: q}, 
            function(resp) {
                $("#resultados_clientes").html(resp);
            }
        );
    } else if (q.length === 0) {
        $("#resultados_clientes").html('');
    }
});

// Seleccionar cliente desde modal
$(document).on('click', '.btn-seleccionar-cliente', function(){
    var id = $(this).data('id');
    var nombre = $(this).data('nombre');
    
    // Verificar si ya existe la opción
    if ($("#id_cliente option[value='" + id + "']").length === 0) {
        $("#id_cliente").append('<option value="' + id + '">' + nombre + '</option>');
    }
    $("#id_cliente").val(id);
    $("#modalBuscarCliente").modal('hide');
});

// REGISTRAR CITA - VERSIÓN CORREGIDA (EVENTO ÚNICO)
$("#btnRegistrar").off('click').on('click', function() {
    var datos = $("#formAgendamiento").serialize();
    
    // Deshabilitar botón para evitar múltiples clics
    var $btn = $(this);
    $btn.prop('disabled', true).html('<span class="fa fa-spinner fa-spin"></span> Registrando...');
    
    $.ajax({
        url: 'Cabecera-detalle/Controlador_agendamiento.jsp',
        type: 'POST',
        data: datos,
        success: function(response) {
            $("#respuesta").html(response);
            if (response.includes('correctamente')) {
                $("#formAgendamiento")[0].reset();
                // Restablecer valores mínimos de fecha
                $("#age_fecha").val('<%=fechaFormateada%>');
                listarCitas();
            }
            
            // Rehabilitar botón después de 2 segundos
            setTimeout(function() {
                $btn.prop('disabled', false).html('<span class="fa fa-save"></span> Registrar Cita');
            }, 2000);
        },
        error: function(xhr, status, error) {
            $("#respuesta").html('<div class="alert alert-danger">Error: ' + error + '</div>');
            $btn.prop('disabled', false).html('<span class="fa fa-save"></span> Registrar Cita');
        }
    });
});

// BOTÓN ATENDER - VERSIÓN CORREGIDA (EVENTO ÚNICO)
$(document).off('click', '.btn-atender').on('click', '.btn-atender', function(){
    // Obtener todos los datos directamente desde los atributos data del botón
    let id_agendamiento = $(this).data('id');
    let id_cliente = $(this).data('id_cliente');
    let cliente_nombre = $(this).data('cliente_nombre');
    let id_profesional = $(this).data('id_profesional');
    let profesional_nombre = $(this).data('profesional_nombre');
    let id_servicio = $(this).data('id_servicio');
    let servicio_nombre = $(this).data('servicio_nombre');
    let servicio_precio = $(this).data('servicio_precio');
    let id_sucursal = $(this).data('id_sucursal');
    let sucursal_nombre = $(this).data('sucursal_nombre');

    // Construir URL con todos los parámetros
    let url = 'vistafacturacion.jsp?' +
              'id_agendamiento=' + id_agendamiento +
              '&id_cliente=' + id_cliente +
              '&cliente_nombre=' + encodeURIComponent(cliente_nombre) +
              '&id_servicio=' + id_servicio +
              '&servicio_nombre=' + encodeURIComponent(servicio_nombre) +
              '&servicio_precio=' + servicio_precio +
              '&id_profesional=' + id_profesional +
              '&profesional_nombre=' + encodeURIComponent(profesional_nombre) +
              '&id_sucursal=' + id_sucursal +
              '&sucursal_nombre=' + encodeURIComponent(sucursal_nombre) +
              '&from_cita=true';

    console.log("Redireccionando a facturación:", url);
    
    // Redireccionar inmediatamente
    window.location.href = url;
});

// BOTÓN ELIMINAR - VERSIÓN CORREGIDA (EVENTO ÚNICO)
$(document).off('click', '.btn-eliminar').on('click', '.btn-eliminar', function() {
    var id = $(this).data('id');
    
    // Verificar si ya está procesando
    if ($(this).hasClass('processing')) return;
    $(this).addClass('processing');
    
    if(confirm("¿Eliminar esta cita?")) {
        $.post('Cabecera-detalle/Controlador_agendamiento.jsp', 
            {accion: 'eliminarCita', id_agendamiento: id}, 
            function(response) {
                alert(response);
                listarCitas();
                // Remover clase de procesamiento
                $('.btn-eliminar').removeClass('processing');
            }
        );
    } else {
        $('.btn-eliminar').removeClass('processing');
    }
});

// CAMBIO ESTADO - VERSIÓN CORREGIDA (EVENTO ÚNICO)
$(document).off('change', '.estado-cita').on('change', '.estado-cita', function() {
    var id = $(this).data('id');
    var estado = $(this).val();
    
    // Verificar si ya está procesando
    if ($(this).hasClass('processing')) return;
    $(this).addClass('processing');
    
    if(confirm("¿Cambiar estado a " + estado + "?")) {
        $.post('Cabecera-detalle/Controlador_agendamiento.jsp', 
            {accion: 'actualizarEstadoCita', id_agendamiento: id, estado: estado}, 
            function(response) {
                alert(response);
                listarCitas();
                // Remover clase de procesamiento
                $('.estado-cita').removeClass('processing');
            }
        );
    } else {
        // Si cancela, revertir al valor anterior
        $(this).val($(this).data('prev-value'));
        $('.estado-cita').removeClass('processing');
    }
});

// Validación de fechas
$("#filtro_desde").change(function(){
    var desde = $(this).val();
    $("#filtro_hasta").attr("min", desde);
    if($("#filtro_hasta").val() < desde){
        $("#filtro_hasta").val(desde);
    }
});

$("#filtro_hasta").change(function(){
    var hasta = $(this).val();
    var desde = $("#filtro_desde").val();
    if(hasta < desde){
        alert("La fecha 'Hasta' no puede ser menor que la fecha 'Desde'");
        $(this).val(desde);
    }
});

// Al cargar la página
$(document).ready(function() {
    console.log("🟢 agendamiento.js CARGADO");
    
    // Cargar datos iniciales
    cargarClientes();
    cargarServicios();
    cargarHorarios();
    
    // Cargar citas iniciales
    listarCitas();
    
    // Registrar eventos iniciales (solo una vez)
    registrarEventos();
    
    // Establecer fechas mínimas
    var today = new Date().toISOString().split('T')[0];
    $("#age_fecha").attr('min', today);
    $("#filtro_desde").attr('min', today);
    $("#filtro_hasta").attr('min', today);
    
    console.log("✅ Todos los eventos registrados correctamente (sin duplicación)");
});