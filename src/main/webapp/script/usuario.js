$(document).ready(function () {
                rellenar();

                // Limpiar y preparar modal para nuevo usuario
                $('#btnNuevo').click(function () {
                    $("#form")[0].reset();
                    $("#pk").val('');
                    $("#campo").val('guardar');
                    $("#modalTitle").text('Nuevo usuario');
                    $("[name='password']").attr('placeholder', 'Contraseña').prop('required', true);
                    $("#id_rol").val('');
                    $("[name='estado']").val('ACTIVO');
                });

                // Limpiar modal al cerrarse
                $('#exampleModal').on('hidden.bs.modal', function () {
                    $("#form")[0].reset();
                    $("#pk").val('');
                    $("#campo").val('guardar');
                    $("#modalTitle").text('Nuevo usuario');
                    $("[name='password']").attr('placeholder', 'Contraseña').prop('required', true);
                    $("#id_rol").val('');
                    $("[name='estado']").val('ACTIVO');
                    // Limpieza garantizada del modal
                    $('body').removeClass('modal-open');
                    $('.modal-backdrop').remove();
                });
            });

            function rellenar() {
                $.get("Usuario/usuario.jsp", {campo: 'listar'}, function (data) {
                    $("#listadoUsuarios").html(data);
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
                    url: 'Usuario/usuario.jsp',
                    type: 'post',
                    success: function (response) {
                        // Cierre completo del modal
                        $('#exampleModal').modal('hide');
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

            function datosModif(id, usuario, nombre, apellido, id_rol, estado) {
                $("#modalTitle").text("Modificar usuario");
                $("#pk").val(id);
                $("[name='usu_usuario']").val(usuario);
                $("[name='usu_nombre']").val(nombre);
                $("[name='usu_apellido']").val(apellido);
                $("[name='password']").val('').attr('placeholder', 'Dejar en blanco para no cambiar').prop('required', false);
                $("#id_rol").val(id_rol);
                $("[name='estado']").val(estado);
                $("#campo").val('modificar');
            }

            function dell(id) {
    Swal.fire({
        title: 'Eliminar este usuario?',
        text: "Esta accion no se puede deshacer",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Si, eliminar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            $.post("Usuario/usuario.jsp", {campo: 'eliminar', pk: id}, function (data) {
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
            });
        }
    });
}