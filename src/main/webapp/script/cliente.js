$(document).ready(function () {
    rellenar();

    // Limpiar y preparar modal para nuevo cliente
    $('#btnNuevoCliente').click(function () {
        $("#form")[0].reset();
        $("#pk").val('');
        $("#campo").val('guardar');
        $("#modalTitle").text('Agregar Cliente');
        $("#selectSucursal").val('');
    });

    // Limpiar modal al cerrarse
    $('#exampleModal').on('hidden.bs.modal', function () {
        $("#form")[0].reset();
        $("#pk").val('');
        $("#campo").val('guardar');
        $("#modalTitle").text('Agregar Cliente');
        $("#selectSucursal").val('');
        // Limpieza garantizada del modal
        $('body').removeClass('modal-open');
        $('.modal-backdrop').remove();
    });
});

function rellenar() {
    $.get("Cliente/clientes.jsp", {campo: 'listar'}, function (data) {
        $("#listadoclientes").html(data);
    });
}

$("#guardarRegistro").click(function () {
    // Validar campos obligatorios
    let valido = true;
    $('#form [required]').each(function() {
        if(!$(this).val()) {
            $(this).addClass('is-invalid');
            valido = false;
        } else {
            $(this).removeClass('is-invalid');
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
        url: 'Cliente/clientes.jsp',
        type: 'post',
        success: function (response) {
            // Cierre completo del modal
            $('#exampleModal').modal('hide');
            setTimeout(function() {
                // Detectar tipo de mensaje por el emoji/texto
if (response.includes('✅') || response.includes('exitosamente')) {
    Swal.fire({
        icon: 'success',
        title: '¡Éxito!',
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
                // Limpieza adicional
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
            $('#exampleModal').modal('hide');
        }
    });
});

function datosModif(id, nombre, apellido, ci, telefono, direccion, email, idSucursal) {
    // Primero cerrar cualquier modal abierto
    $('#exampleModal').modal('hide');
    
    // Esperar a que se cierre completamente antes de abrir el nuevo
    setTimeout(function() {
        $("#form")[0].reset();
        $("#modalTitle").text("Modificar Cliente");
        $("#pk").val(id);
        $("[name='cli_nombre']").val(nombre);
        $("[name='cli_apellido']").val(apellido);
        $("[name='cli_ci']").val(ci);
        $("[name='cli_telefono']").val(telefono);
        $("[name='cli_direccion']").val(direccion);
        $("[name='cli_email']").val(email || '');
        $("#campo").val('modificar');
        
        // Establecer la sucursal
        if(idSucursal && idSucursal !== '') {
            $("#selectSucursal").val(idSucursal);
        }
        
        // Abrir el modal
        $('#exampleModal').modal('show');
    }, 500);
}

function dell(id) {
    Swal.fire({
        title: '¿Eliminar este cliente?',
        text: "Esta acción no se puede deshacer",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            $.post("Cliente/clientes.jsp", {campo: 'eliminar', pk: id}, function (data) {
                if (data.includes('✅') || data.includes('exitosamente')) {
                    Swal.fire({
                        icon: 'success',
                        title: '¡Éxito!',
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
            });
        }
    });
}