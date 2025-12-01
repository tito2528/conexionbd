<%@ include file="header.jsp" %>

<style>
    /* Contenedor principal con imagen de fondo */
    .content-wrapper {
        position: relative;
        min-height: calc(100vh - 57px);
        background-image: url('imagenes/image.jpg'); /* CAMBIA ESTA RUTA */
        background-size: cover;
        background-position: center;
        background-attachment: fixed;
        background-repeat: no-repeat;
    }

    /* Overlay para oscurecer la imagen y mejorar legibilidad */
    .content-wrapper::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5); /* Ajusta la opacidad aquí */
        z-index: 0;
    }

    /* Contenido por encima del overlay */
    .content-wrapper > * {
        position: relative;
        z-index: 1;
    }

    /* Estilo del título del dashboard */
    .dashboard-title {
        color: #fff;
        text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.7);
        font-weight: bold;
        font-size: 2.5rem;
        margin-bottom: 30px;
        text-align: center;
    }

    /* Grid de las cajas de estado */
    .dashboard-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 25px;
        padding: 20px;
        max-width: 1200px;
        margin: 0 auto;
    }

    /* Caja de estado */
    .estado-card {
        background: rgba(255, 255, 255, 0.95);
        border-radius: 15px;
        padding: 30px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-height: 200px;
        backdrop-filter: blur(10px);
        border: 3px solid transparent;
    }

    .estado-card:hover {
        transform: translateY(-10px) scale(1.05);
        box-shadow: 0 15px 40px rgba(0, 0, 0, 0.5);
    }

    /* Colores por estado */
    .estado-card.pendiente {
        border-color: #ffc107;
    }

    .estado-card.pendiente:hover {
        background: rgba(255, 193, 7, 0.15);
        border-color: #ffc107;
    }

    .estado-card.confirmado {
        border-color: #28a745;
    }

    .estado-card.confirmado:hover {
        background: rgba(40, 167, 69, 0.15);
        border-color: #28a745;
    }

    .estado-card.finalizado {
        border-color: #007bff;
    }

    .estado-card.finalizado:hover {
        background: rgba(0, 123, 255, 0.15);
        border-color: #007bff;
    }

    .estado-card.cancelado {
        border-color: #dc3545;
    }

    .estado-card.cancelado:hover {
        background: rgba(220, 53, 69, 0.15);
        border-color: #dc3545;
    }

    /* Icono de la caja */
    .estado-icon {
        font-size: 4rem;
        margin-bottom: 15px;
    }

    .estado-card.pendiente .estado-icon {
        color: #ffc107;
    }

    .estado-card.confirmado .estado-icon {
        color: #28a745;
    }

    .estado-card.finalizado .estado-icon {
        color: #007bff;
    }

    .estado-card.cancelado .estado-icon {
        color: #dc3545;
    }

    /* Contador */
    .estado-contador {
        font-size: 3.5rem;
        font-weight: bold;
        color: #333;
        margin: 10px 0;
        line-height: 1;
    }

    /* Título del estado */
    .estado-titulo {
        font-size: 1.3rem;
        font-weight: 600;
        color: #555;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin: 0;
    }

    /* Badge animado para pendientes */
    .estado-card.pendiente .estado-contador {
        animation: pulse 2s infinite;
    }

    @keyframes pulse {
        0%, 100% {
            transform: scale(1);
        }
        50% {
            transform: scale(1.1);
        }
    }

    /* Responsive */
    @media (max-width: 768px) {
        .dashboard-title {
            font-size: 2rem;
        }

        .dashboard-grid {
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            padding: 15px;
        }

        .estado-card {
            padding: 20px;
            min-height: 160px;
        }

        .estado-icon {
            font-size: 3rem;
        }

        .estado-contador {
            font-size: 2.5rem;
        }

        .estado-titulo {
            font-size: 1.1rem;
        }
    }

    /* Ocultar el breadcrumb si no lo necesitas */
    .content-header {
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(10px);
    }

    .content-header h1,
    .content-header .breadcrumb {
        color: #fff !important;
        text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.7);
    }

    .breadcrumb-item a {
        color: #fff !important;
    }

    .breadcrumb-item.active {
        color: rgba(255, 255, 255, 0.8) !important;
    }

    /* Spinner de carga */
    .loading-spinner {
        display: none;
        text-align: center;
        padding: 50px;
        color: #fff;
        font-size: 1.5rem;
    }

    .loading-spinner i {
        font-size: 3rem;
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        from {
            transform: rotate(0deg);
        }
        to {
            transform: rotate(360deg);
        }
    }
</style>

<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">Dashboard de Citas</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="#">Home</a></li>
                        <li class="breadcrumb-item active">Dashboard</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
    <!-- /.content-header -->

    <!-- Main content -->
    <div class="content">
        <div class="container-fluid">
            
            <!-- Título del Dashboard -->
            <h2 class="dashboard-title">Estado de las Citas</h2>

            <!-- Spinner de carga -->
            <div class="loading-spinner" id="loadingSpinner">
                <i class="fas fa-circle-notch"></i>
                <p>Cargando datos...</p>
            </div>

            <!-- Grid de cajas de estado -->
            <div class="dashboard-grid" id="dashboardGrid" style="display: none;">
                
                <!-- PENDIENTES -->
                <a href="listado_citas.jsp?filtro=pendiente" class="estado-card pendiente">
                    <i class="fas fa-clock estado-icon"></i>
                    <div class="estado-contador" id="contadorPendientes">0</div>
                    <p class="estado-titulo">Pendientes</p>
                </a>

                <!-- CONFIRMADAS -->
                <a href="listado_citas.jsp?filtro=confirmado" class="estado-card confirmado">
                    <i class="fas fa-check-circle estado-icon"></i>
                    <div class="estado-contador" id="contadorConfirmadas">0</div>
                    <p class="estado-titulo">Confirmadas</p>
                </a>

                <!-- FINALIZADAS -->
                <a href="listado_citas.jsp?filtro=finalizado" class="estado-card finalizado">
                    <i class="fas fa-flag-checkered estado-icon"></i>
                    <div class="estado-contador" id="contadorFinalizadas">0</div>
                    <p class="estado-titulo">Finalizadas</p>
                </a>

                <!-- CANCELADAS -->
                <a href="listado_citas.jsp?filtro=cancelado" class="estado-card cancelado">
                    <i class="fas fa-times-circle estado-icon"></i>
                    <div class="estado-contador" id="contadorCanceladas">0</div>
                    <p class="estado-titulo">Canceladas</p>
                </a>

            </div>

        </div>
    </div>
    <!-- /.content -->
</div>
<!-- /.content-wrapper -->

<script>
$(document).ready(function() {
    console.log("🟢 Dashboard de Citas Cargado");
    
    // Cargar estadísticas al iniciar
    cargarEstadisticas();
    
    // Actualizar cada 30 segundos
    setInterval(cargarEstadisticas, 30000);
});

function cargarEstadisticas() {
    console.log("📊 Cargando estadísticas...");
    
    // Mostrar spinner
    $("#loadingSpinner").show();
    $("#dashboardGrid").hide();
    
    // Obtener fecha actual para el filtro
    var hoy = new Date();
    var desde = hoy.toISOString().split('T')[0];
    
    // Obtener 15 días hacia adelante
    var futuro = new Date();
    futuro.setDate(futuro.getDate() + 15);
    var hasta = futuro.toISOString().split('T')[0];
    
    $.ajax({
        url: 'Cabecera-detalle/Controlador_agendamiento.jsp',
        type: 'POST',
        dataType: 'json',
        data: {
            accion: 'listarCitasModerno',
            desde: desde,
            hasta: hasta
        },
        success: function(response) {
            console.log("✅ Datos recibidos:", response);
            
            // Contar por estado
            var pendientes = response.filter(c => c.estado === 'pendiente').length;
            var confirmadas = response.filter(c => c.estado === 'confirmado').length;
            var finalizadas = response.filter(c => c.estado === 'finalizado').length;
            var canceladas = response.filter(c => c.estado === 'cancelado').length;
            
            // Actualizar contadores con animación
            animarContador('#contadorPendientes', pendientes);
            animarContador('#contadorConfirmadas', confirmadas);
            animarContador('#contadorFinalizadas', finalizadas);
            animarContador('#contadorCanceladas', canceladas);
            
            console.log("📊 Estadísticas:", {
                pendientes: pendientes,
                confirmadas: confirmadas,
                finalizadas: finalizadas,
                canceladas: canceladas
            });
            
            // Ocultar spinner y mostrar grid
            $("#loadingSpinner").hide();
            $("#dashboardGrid").fadeIn();
            
        },
        error: function(xhr, status, error) {
            console.error("❌ Error al cargar estadísticas:", error);
            $("#loadingSpinner").html(
                '<i class="fas fa-exclamation-triangle"></i>' +
                '<p>Error al cargar datos</p>' +
                '<button class="btn btn-light mt-3" onclick="cargarEstadisticas()">Reintentar</button>'
            );
        }
    });
}

// Función para animar el contador
function animarContador(selector, valorFinal) {
    var $contador = $(selector);
    var valorActual = parseInt($contador.text()) || 0;
    
    if (valorActual === valorFinal) return;
    
    var incremento = valorFinal > valorActual ? 1 : -1;
    var duracion = 1000; // 1 segundo
    var pasos = Math.abs(valorFinal - valorActual);
    var delay = duracion / pasos;
    
    var contador = valorActual;
    var intervalo = setInterval(function() {
        contador += incremento;
        $contador.text(contador);
        
        if (contador === valorFinal) {
            clearInterval(intervalo);
        }
    }, delay);
}

// Notificación de citas pendientes
function verificarPendientes() {
    var pendientes = parseInt($("#contadorPendientes").text()) || 0;
    
    if (pendientes > 0) {
        console.log("⚠️ Tienes " + pendientes + " citas pendientes");
        
        // Puedes agregar aquí una notificación visual o sonora si lo deseas
        // Por ejemplo, cambiar el título de la página
        document.title = "(" + pendientes + ") Citas Pendientes - Dashboard";
    } else {
        document.title = "Dashboard de Citas";
    }
}

// Verificar pendientes cada minuto
setInterval(verificarPendientes, 60000);
</script>

<%@ include file="footer.jsp" %>
