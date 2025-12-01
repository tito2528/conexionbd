$(document).ready(function() {
    console.log("✅ horarios_profesionales.js CARGADO");
    cargarHorariosProfesionales();
    cargarSelects();
    
    $("#btnGuardarHorario").click(function() {
        console.log("🟡 Botón Guardar clickeado");
        guardarHorarioProfesional();
    });
});

function cargarHorariosProfesionales() {
    console.log("📋 Cargando horarios de profesionales...");
    $.ajax({
        url: 'Cabecera-detalle/profesional_horario.jsp',
        type: 'POST',
        data: {accion: 'listarHorariosProfesional'},
        success: function(response) {
            console.log("✅ Horarios cargados:", response);
            $("#tablaHorariosProfesionales").html(response);
        },
        error: function(xhr, status, error) {
            console.error("❌ Error cargando horarios:", error);
            console.error("Response:", xhr.responseText);
            $("#tablaHorariosProfesionales").html(
                "<tr><td colspan='4' class='text-center text-danger'>Error al cargar los horarios: " + error + "</td></tr>"
            );
        }
    });
}

function cargarSelects() {
    console.log("📋 Cargando selects...");
    
    // Cargar profesionales
    $.ajax({
        url: 'Cabecera-detalle/profesional_horario.jsp',
        type: 'POST',
        data: {accion: 'listarProfesionales'},
        success: function(response) {
            console.log("✅ Profesionales cargados:", response);
            $("#selectProfesional").html(response);
        },
        error: function(xhr, status, error) {
            console.error("❌ Error cargando profesionales:", error);
            $("#selectProfesional").html("<option value=''>Error al cargar profesionales</option>");
        }
    });
    
    // Cargar horarios
    $.ajax({
        url: 'Cabecera-detalle/profesional_horario.jsp',
        type: 'POST',
        data: {accion: 'listarHorarios'},
        success: function(response) {
            console.log("✅ Horarios cargados:", response);
            $("#selectHorario").html(response);
        },
        error: function(xhr, status, error) {
            console.error("❌ Error cargando horarios:", error);
            $("#selectHorario").html("<option value=''>Error al cargar horarios</option>");
        }
    });
}

function guardarHorarioProfesional() {
    console.log("🔤 Guardando horario profesional...");
    
    // Verificar que todos los campos estén llenos
    var id_profesional = $("#selectProfesional").val();
    var dia_semana = $("#selectDia").val();
    var id_horario = $("#selectHorario").val();
    
    console.log("🔍 Campos:", {
        profesional: id_profesional,
        dia: dia_semana,
        horario: id_horario
    });
    
if (!id_profesional || !dia_semana || !id_horario) {
    $("#modalAgregarHorario").modal('hide');
    setTimeout(function() {
        Swal.fire({
            icon: 'warning',
            title: 'Campos incompletos',
            text: 'Complete todos los campos'
        });
    }, 300);
    return;
}
    
    console.log("📤 Haciendo petición AJAX...");
    
    $.ajax({
        url: 'Cabecera-detalle/profesional_horario.jsp',
        type: 'POST',
        data: {
            accion: 'guardarHorario',
            id_profesional: id_profesional,
            dia_semana: dia_semana,
            id_horario: id_horario
        },
success: function(response) {
    console.log("✅ Respuesta del servidor:", response);
    $("#modalAgregarHorario").modal('hide');
    
    setTimeout(function() {
        if (response.includes('✅') || response.includes('correctamente')) {
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
        
        if (response.includes("correctamente")) {
            $("#formHorarioProfesional")[0].reset();
            cargarHorariosProfesionales();
        }
    }, 300);
},
error: function(xhr, status, error) {
    console.error("❌ Error AJAX:", {
        status: status,
        error: error,
        responseText: xhr.responseText
    });
    Swal.fire({
        icon: 'error',
        title: 'Error al guardar',
        text: error
    });
}
    });
}

function eliminarHorarioProfesional(id) {
    console.log("🗑️ Eliminando horario ID:", id);
    Swal.fire({
        title: 'Eliminar este horario del profesional?',
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
                url: 'Cabecera-detalle/profesional_horario.jsp',
                type: 'POST',
                data: {
                    accion: 'eliminarHorario',
                    id: id
                },
                success: function(response) {
                    console.log("✅ Respuesta eliminar:", response);
                    if (response.includes('✅') || response.includes('correctamente')) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Exito!',
                            text: response,
                            timer: 2000
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response
                        });
                    }
                    cargarHorariosProfesionales();
                },
                error: function(xhr, status, error) {
                    console.error("❌ Error eliminando horario:", error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error al eliminar',
                        text: error
                    });
                }
            });
        }
    });
}