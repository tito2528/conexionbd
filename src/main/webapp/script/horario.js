$(document).ready(function () {
        // Inicializar tooltips
        $('[data-toggle="tooltip"]').tooltip();
        
        // Cargar lista inicial de horarios
        rellenar();
        
        // Resetear formulario al cerrar el modal
        $('#exampleModal').on('hidden.bs.modal', function () {
            $("#form")[0].reset();
            $("#modalTitle").text("Agregar Horario");
            $("#campo").val("guardar");
            $("#pk").val("");
        });
    });

    // Función para abrir modal en modo agregar
    function agregarHorario() {
        $("#exampleModal").modal('show');
    }

    // Cargar lista de horarios
    function rellenar() {
        $.get("Horario/horario.jsp", {campo: 'listar'}, function (data) {
            $("#listadohorarios").html(data);
            // Volver a inicializar tooltips para los nuevos elementos
            $('[data-toggle="tooltip"]').tooltip();
        });
    }

    // Manejar el guardado (tanto insert como update)
    $("#guardarRegistro").click(function () {
        let datosform = $("#form").serialize();
        let accion = $("#campo").val() === "guardar" ? "registrado" : "actualizado";
        
        // Validar que hora fin sea mayor a hora inicio
        let horaInicio = $("[name='hora_inicio']").val();
        let horaFin = $("[name='hora_fin']").val();
        
        if (horaInicio >= horaFin) {
            Swal.fire({
    icon: 'warning',
    title: 'Horario invalido',
    text: 'La hora de fin debe ser mayor a la hora de inicio'
});
            return;
        }
        
        $.ajax({
            data: datosform,
            url: 'Horario/horario.jsp',
            type: 'post',
            success: function (response) {
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
} // Limpiar la respuesta para el alert
                $("#exampleModal").modal('hide');
                rellenar();
            },
            error: function(xhr, status, error) {
                Swal.fire({
    icon: 'error',
    title: 'Error al procesar',
    text: error
});
            }
        });
    });

    // Preparar modal para edición
    function datosModif(id, horaInicio, horaFin) {
        $("#modalTitle").text("Modificar Horario");
        $("#pk").val(id);
        $("[name='hora_inicio']").val(horaInicio);
        $("[name='hora_fin']").val(horaFin);
        $("#campo").val('modificar');
        $("#exampleModal").modal('show');
    }

    // Eliminar horario
    function eliminarHorario(id) {
    Swal.fire({
        title: 'Esta seguro que desea eliminar este horario?',
        text: "Esta accion no se puede deshacer",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Si, eliminar',
        cancelButtonText: 'Cancelar'
    }).then((result) => {
        if (result.isConfirmed) {
            $.post("Horario/horario.jsp", {campo: 'eliminar', pk: id}, function (data) {
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
            }).fail(function() {
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: 'Error al intentar eliminar el horario'
                });
            });
        }
    });
}