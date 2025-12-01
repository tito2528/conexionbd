 $(document).ready(function () {
                rellenarRol();

                // Limpiar y preparar modal para nuevo rol
                $('#btnNuevoRol').click(function () {
                    $("#formRol")[0].reset();
                    $("#pkRol").val('');
                    $("#campoRol").val('guardar');
                    $("#modalTitleRol").text('Nuevo rol');
                });

                // Limpiar modal al cerrarse
                $('#modalRol').on('hidden.bs.modal', function () {
                    $("#formRol")[0].reset();
                    $("#pkRol").val('');
                    $("#campoRol").val('guardar');
                    $("#modalTitleRol").text('Nuevo rol');
                });
            });

            function rellenarRol() {
                $.get("Rol/rol.jsp", {campo: 'listar'}, function (data) {
                    $("#listadoRoles").html(data);
                });
            }

            $("#guardarRol").click(function () {
                let datosform = $("#formRol").serialize();
                $.ajax({
                    data: datosform,
                    url: 'Rol/rol.jsp',
                    type: 'post',
                    success: function (response) {
                        $("#modalRol").modal('hide');
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
                            $('.modal-backdrop').remove();
                            $('body').removeClass('modal-open');
                            rellenarRol();
                            $("#formRol")[0].reset();
                        }, 400);
                    }
                });
            });

            function datosModifRol(id, nombre, descripcion) {
                $("#modalTitleRol").text("Modificar rol");
                $("#pkRol").val(id);
                $("[name='rol_nombre']").val(nombre);
                $("[name='rol_descripcion']").val(descripcion);
                $("#campoRol").val('modificar');
            }

            function dellRol(id) {
    Swal.fire({
        title: 'Eliminar este rol?',
        text: "Esta accion no se puede deshacer",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Si, eliminar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            $.post("Rol/rol.jsp", {campo: 'eliminar', pk: id}, function (data) {
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
                rellenarRol();
            });
        }
    });
}