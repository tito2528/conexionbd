// Función global para modificar
            function datosModif(id, nombre) {
                $("#modalTitle").text("Modificar Especialidad");
                $("#pk").val(id);
                $("[name='espe_nombre']").val(nombre);
                $("#campo").val('modificar');
            }

            // Función global para eliminar
            function dell(id) {
    Swal.fire({
        title: 'Eliminar esta especialidad?',
        text: "Esta accion no se puede deshacer",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Si, eliminar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            $.post("especialidades/especialidades.jsp", {campo: 'eliminar', pk: id}, function (data) {
                if (data.includes('✅') || data.includes('exitosamente')) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Exito',
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

            $(document).ready(function () {
                rellenar();

                // Limpiar y preparar modal para nuevo registro
                $('#btnNuevo').click(function () {
                    $("#form")[0].reset();
                    $("#pk").val('');
                    $("#campo").val('guardar');
                    $("#modalTitle").text('Nueva Especialidad');
                });

                // Limpiar modal al cerrarse
                $('#exampleModal').on('hidden.bs.modal', function () {
                    $("#form")[0].reset();
                    $("#pk").val('');
                    $("#campo").val('guardar');
                    $("#modalTitle").text('Nueva Especialidad');
                });
            });

            function rellenar() {
                $.get("especialidades/especialidades.jsp", {campo: 'listar'}, function (data) {
                    $("#listadoEspecialidades").html(data);
                });
            }

            $("#guardarRegistro").click(function () {
                let datosform = $("#form").serialize();
                $.ajax({
                    data: datosform,
                    url: 'especialidades/especialidades.jsp',
                    type: 'post',
                    success: function (response) {
                        $("#exampleModal").modal('hide');
                        setTimeout(function() {
                            if (response.includes('✅') || response.includes('exitosamente')) {
    Swal.fire({
        icon: 'success',
        title: 'Exito',
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
                            // Forzar remoción del backdrop de Bootstrap por si queda
                            $('.modal-backdrop').remove();
                            $('body').removeClass('modal-open');
                            rellenar();
                            $("#form")[0].reset();
                        }, 400);
                    }
                });
            });