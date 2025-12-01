// Función global para editar
            function cargarParaEditar(id, descripcion) {
                $("#formMetodoPago")[0].reset();
                $("#idMetodo").val(id);
                $("#descripcion").val(descripcion);
                $("#accion").val('modificar');
                $("#modalTitle").text('Editar Método de Pago');
                $('#exampleModal').modal('show');
            }

            // Función global para eliminar
            function confirmarEliminacion(id, descripcion) {
    Swal.fire({
        title: 'Esta seguro que desea eliminar el metodo de pago "' + descripcion + '"?',
        text: "Esta accion no se puede deshacer",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Si, eliminar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            $.post("metodopago/metodopago.jsp", {campo: 'eliminar', pk: id}, function(data) {
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
                cargarMetodos();
            });
        }
    });
}

            // Limpiar y preparar modal para nuevo registro
            function resetearFormulario() {
                $("#formMetodoPago")[0].reset();
                $("#idMetodo").val('');
                $("#accion").val('guardar');
                $("#modalTitle").text('Nuevo Método de Pago');
            }

            $(document).ready(function() {
                cargarMetodos();

                $('#btnNuevo').click(function () {
                    resetearFormulario();
                    $('#exampleModal').modal('show');
                });

                // Limpiar modal al cerrarse
                $('#exampleModal').on('hidden.bs.modal', function () {
                    resetearFormulario();
                });
            });

            function cargarMetodos() {
                $.get("metodopago/metodopago.jsp", {campo: 'listar'}, function(data) {
                    $("#listadoMetodosPago").html(data);
                });
            }

            $("#btnGuardar").click(function() {
                const datosForm = $("#formMetodoPago").serialize();
                $.ajax({
                    url: 'metodopago/metodopago.jsp',
                    type: 'POST',
                    data: datosForm,
                    success: function(response) {
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
                            $('.modal-backdrop').remove();
                            $('body').removeClass('modal-open');
                            cargarMetodos();
                        }, 400);
                    },
                    error: function() {
                        Swal.fire({
    icon: 'error',
    title: 'Error',
    text: 'Error al procesar la solicitud'
});
                    }
                });
            });