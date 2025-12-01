$('#form input[required]').on('blur', function() {
    if(!$(this).val()) {
        $(this).addClass('is-invalid');
        $(this).next('.text-danger').show();
    } else {
        $(this).removeClass('is-invalid');
        $(this).next('.text-danger').hide();
    }
});

function datosModif(id, nombre, apellido, telefono, email, id_especialidad, id_sucursal, id_horario, estado) {
    $("#modalTitle").text("Modificar Profesional");
    $("#pk").val(id);
    $("[name='prof_nombre']").val(nombre);
    $("[name='prof_apellido']").val(apellido);
    $("[name='prof_telefono']").val(telefono);
    $("[name='prof_email']").val(email);
    $("[name='id_especialidad']").val(id_especialidad);
    $("[name='id_sucursal']").val(id_sucursal);
    $("[name='id_horario']").val(id_horario);
    $("[name='estado']").val(estado);
    $("#campo").val('modificar');
}

function limpiarModal() {
    $("#modalTitle").text("ABM Profesional");
    $("#form")[0].reset();
    $("#campo").val("guardar");
    $("#pk").val("");
    $("[name='estado']").val("ACTIVO");
    $('.is-invalid').removeClass('is-invalid');
    $('.text-danger').hide();
}

function dell(id) {
    Swal.fire({
        title: 'Eliminar este profesional?',
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
                url: 'Profesional/profesional.jsp',
                type: 'POST',
                data: { campo: 'eliminar', pk: id },
                success: function(response) {
                    if (response.includes('✅') || response.includes('exitosamente')) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Exito!',
                            text: response,
                            timer: 2000
                        }).then(function() {
                            location.reload();
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response
                        }).then(function() {
                            location.reload();
                        });
                    }
                },
                error: function() {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Error al eliminar profesional'
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
        url: 'Profesional/profesional.jsp',
        type: 'post',
        success: function (response) {
            $("#exampleModal").modal('hide');
            setTimeout(function() {
                if (response.includes('✅') || response.includes('exitosamente')) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Exito!',
                        text: response,
                        timer: 2000
                    }).then(function() {
                        location.reload();
                    });
                } else if (response.includes('⚠️') || response.includes('Error')) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: response
                    }).then(function() {
                        location.reload();
                    });
                } else {
                    Swal.fire({
                        icon: 'info',
                        text: response
                    }).then(function() {
                        location.reload();
                    });
                }
                $('.modal-backdrop').remove();
                $('body').removeClass('modal-open');
            }, 400);
        },
        error: function(xhr, status, error) {
            Swal.fire({
                icon: 'error',
                title: 'Error al guardar',
                text: error
            });
        }
    });
});

window.onload = function() {
    const params = new URLSearchParams(window.location.search);
    if (params.get('msg') === 'guardado') {
        Swal.fire({
            icon: 'success',
            title: 'Exito!',
            text: 'Profesional guardado correctamente',
            timer: 2000
        });
    } else if (params.get('msg') === 'modificado') {
        Swal.fire({
            icon: 'success',
            title: 'Exito!',
            text: 'Profesional modificado correctamente',
            timer: 2000
        });
    } else if (params.get('msg') === 'eliminado') {
        Swal.fire({
            icon: 'success',
            title: 'Exito!',
            text: 'Profesional eliminado correctamente',
            timer: 2000
        });
    }
};