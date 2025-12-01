$(document).ready(function () {
    rellenar();

    // Validación en tiempo real
    $('#form input[required]').on('blur', function() {
        if(!$(this).val()) {
            $(this).addClass('is-invalid');
            $(this).next('.text-danger').show();
        } else {
            $(this).removeClass('is-invalid');
            $(this).next('.text-danger').hide();
        }
    });

    // Limpiar y preparar modal para nuevo registro
    $('#btnNuevo').click(function () {
        $("#form")[0].reset();
        $("#pk").val('');
        $("[name='estado']").val('ACTIVO');
        $("[name='duracion_minutos']").val('60');
        $("#campo").val('guardar');
        $("#modalTitle").text('Nuevo Servicio');
        $('.is-invalid').removeClass('is-invalid');
        $('.text-danger').hide();
        $('#modalServicio').modal('show');
    });

    // Limpiar modal al cerrarse
    $('#modalServicio').on('hidden.bs.modal', function () {
        $("#form")[0].reset();
        $("#pk").val('');
        $("[name='estado']").val('ACTIVO');
        $("[name='duracion_minutos']").val('60');
        $("#campo").val('guardar');
        $("#modalTitle").text('Nuevo Servicio');
        $('.is-invalid').removeClass('is-invalid');
        $('.text-danger').hide();
        // Limpieza garantizada del modal
        $('body').removeClass('modal-open');
        $('.modal-backdrop').remove();
    });
});

function rellenar() {
    $.get("Servicios/servicio.jsp", {campo: 'listar'}, function (data) {
        $("#listadoServicios").html(data);
    });
}

function datosModif(id, nombre, precio, duracion, estado) {
    $("#modalTitle").text("Modificar Servicio");
    $("#pk").val(id);
    $("[name='ser_nombre']").val(nombre);
    $("[name='ser_precio']").val(precio);
    $("[name='duracion_minutos']").val(duracion || '60');
    $("[name='estado']").val(estado);
    $("#campo").val('modificar');
    $('#modalServicio').modal('show');
}

function dell(id) {
    Swal.fire({
        title: 'Eliminar este servicio?',
        text: "Esta accion no se puede deshacer",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Si, eliminar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: "Servicios/servicio.jsp",
                type: "POST",
                data: {campo: 'eliminar', pk: id},
                success: function(data) {
                    if (data.includes('✅') || data.includes('exitosamente')) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Exito!',
                            text: data,
                            timer: 2000
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: data
                        });
                    }
                    rellenar();
                },
                error: function() {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Error al eliminar servicio'
                    });
                }
            });
        }
    });
}

$("#guardarRegistro").click(function () {
    // Validar campos obligatorios
    let valido = true;
    $('#form input[required]').each(function() {
        if(!$(this).val()) {
            $(this).addClass('is-invalid');
            $(this).next('.text-danger').show();
            valido = false;
        }
    });
    
    if(!valido) {
        Swal.fire({
    icon: 'warning',
    title: 'Campos incompletos',
    text: 'Por favor complete todos los campos obligatorios'
});
        return;
    }

    let datosform = $("#form").serialize();
    $.ajax({
        data: datosform,
        url: 'Servicios/servicio.jsp',
        type: 'post',
        success: function (response) {
            $("#modalServicio").modal('hide');
            setTimeout(function() {
                if (response.includes('✅') || response.includes('exitosamente')) {
    Swal.fire({
        icon: 'success',
        title: 'Exito!',
        text: response,
        timer: 2000
    });
} else if (response.includes('⚠️') || response.includes('Error')) {
    Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response
    });
} else {
    Swal.fire({
        icon: 'info',
        text: response
    });
}
                // Forzar remoción del backdrop de Bootstrap
                $('body').removeClass('modal-open');
                $('.modal-backdrop').remove();
                rellenar();
            }, 300);
        },
        error: function(xhr, status, error) {
            Swal.fire({
    icon: 'error',
    title: 'Error al guardar',
    text: error
});
            // Limpieza forzada en caso de error
            $('body').removeClass('modal-open');
            $('.modal-backdrop').remove();
            $('#modalServicio').modal('hide');
        }
    });
});