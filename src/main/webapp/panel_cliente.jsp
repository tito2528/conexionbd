<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
// Verificar sesión
Integer usuarioId = (Integer) session.getAttribute("usuario_id");
String rol = (String) session.getAttribute("rol");

if (usuarioId == null || !"Cliente".equals(rol)) {
    response.sendRedirect("login_cliente.jsp");
    return;
}

String nombreUsuario = (String) session.getAttribute("usuario_nombre");
String apellidoUsuario = (String) session.getAttribute("usuario_apellido");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Panel - Cliente</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            background: #000000;
            font-family: 'Poppins', sans-serif;
            color: #ffffff;
        }
        
        .navbar-custom {
            background: linear-gradient(135deg, #e60026 0%, #cc001f 100%);
            padding: 15px 0;
            box-shadow: 0 2px 10px rgba(230, 0, 38, 0.3);
        }
        
        .navbar-custom .navbar-brand {
            color: white;
            font-weight: bold;
            font-size: 1.5rem;
        }
        
        .navbar-custom .nav-link {
            color: white;
            margin: 0 10px;
            transition: all 0.3s;
        }
        
        .navbar-custom .nav-link:hover {
            color: #ffcccc;
        }
        
        .welcome-banner {
            background: linear-gradient(135deg, #e60026 0%, #cc001f 100%);
            color: white;
            padding: 40px;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 5px 20px rgba(230, 0, 38, 0.3);
        }
        
        .stat-card {
            background: #1a1a1a;
            border: 1px solid #444444;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            margin-bottom: 20px;
            transition: all 0.3s;
            color: #ffffff;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(230, 0, 38, 0.3);
            border-color: #e60026;
        }
        
        .stat-icon {
            font-size: 3rem;
            margin-bottom: 15px;
        }
        
        .stat-card h3 {
            color: #ffffff;
        }
        
        .stat-card h4 {
            color: #ffffff;
        }
        
        .stat-card .text-muted {
            color: rgba(255, 255, 255, 0.7) !important;
        }
        
        .cita-card {
            background: #2a2a2a;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.3);
            border-left: 5px solid #e60026;
            transition: all 0.3s;
        }
        
        .cita-card:hover {
            transform: translateX(5px);
            box-shadow: 0 5px 15px rgba(230, 0, 38, 0.3);
        }
        
        .cita-card h5 {
            color: #e60026;
        }
        
        .cita-card p {
            color: rgba(255, 255, 255, 0.9);
        }
        
        .badge-pendiente { background: #f39c12; }
        .badge-confirmado { background: #27ae60; }
        .badge-cancelado { background: #e74c3c; }
        
        .btn-agendar {
            background: linear-gradient(135deg, #e60026 0%, #cc001f 100%);
            color: white;
            padding: 15px 40px;
            border-radius: 30px;
            border: none;
            font-weight: 600;
            box-shadow: 0 5px 15px rgba(230, 0, 38, 0.3);
            transition: all 0.3s;
        }
        
        .btn-agendar:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(230, 0, 38, 0.5);
        }
        
        .spinner-border {
            color: #e60026 !important;
        }
        
        .text-danger {
            color: #e60026 !important;
        }
        
        .btn-danger {
            background-color: #e60026 !important;
            border-color: #e60026 !important;
        }
    </style>
</head>
<body>
    <!-- NAVBAR -->
    <nav class="navbar navbar-custom navbar-expand-lg">
        <div class="container">
            <a class="navbar-brand" href="#">
                <i class="fas fa-cut"></i> Mi Panel
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="index_publico.jsp"><i class="fas fa-home"></i> Inicio</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="logout_cliente.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <!-- BANNER DE BIENVENIDA -->
        <div class="welcome-banner">
            <h2><i class="fas fa-user-circle"></i> Hola, <%=nombreUsuario%> <%=apellidoUsuario%>!</h2>
            <p class="mb-0">Bienvenido a tu panel personal</p>
        </div>

        <div class="row">
            <!-- BOTÓN NUEVA CITA -->
            <div class="col-12 text-center mb-4">
                <button class="btn btn-agendar btn-lg" onclick="window.location.href='index_publico.jsp#servicios'">
                    <i class="fas fa-calendar-plus"></i> Agendar Nueva Cita
                </button>
            </div>
        </div>

        <div class="row">
            <!-- ESTADÍSTICAS -->
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-icon" style="color: #e60026;">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <h3 id="totalCitas">0</h3>
                    <p class="text-muted">Total de Citas</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-icon" style="color: #27ae60;">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <h3 id="citasConfirmadas">0</h3>
                    <p class="text-muted">Confirmadas</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card text-center">
                    <div class="stat-icon" style="color: #f39c12;">
                        <i class="fas fa-clock"></i>
                    </div>
                    <h3 id="citasPendientes">0</h3>
                    <p class="text-muted">Pendientes</p>
                </div>
            </div>
        </div>

        <!-- MIS CITAS -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="stat-card">
                    <h4><i class="fas fa-list"></i> Mis Citas</h4>
                    <hr style="border-color: #444444;">
                    <div id="listaCitas">
                        <div class="text-center">
                            <div class="spinner-border text-primary" role="status"></div>
                            <p>Cargando citas...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        $(document).ready(function() {
            cargarMisCitas();
        });
        
        function cargarMisCitas() {
            $.ajax({
                url: 'Cabecera-detalle/Controlador_cliente.jsp',
                type: 'POST',
                data: { accion: 'misCitas' },
                success: function(response) {
                    $('#listaCitas').html(response);
                    calcularEstadisticas();
                },
                error: function() {
                    $('#listaCitas').html('<p class="text-danger">Error al cargar las citas</p>');
                }
            });
        }
        
        function calcularEstadisticas() {
            var total = $('.cita-card').length;
            var confirmadas = $('.badge-confirmado').length;
            var pendientes = $('.badge-pendiente').length;
            
            $('#totalCitas').text(total);
            $('#citasConfirmadas').text(confirmadas);
            $('#citasPendientes').text(pendientes);
        }
        
        function cancelarCita(id) {
            Swal.fire({
                title: '¿Cancelar cita?',
                text: "Esta acción no se puede deshacer",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#e60026',
                cancelButtonColor: '#666666',
                confirmButtonText: 'Sí, cancelar',
                cancelButtonText: 'No'
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        url: 'Cabecera-detalle/Controlador_cliente.jsp',
                        type: 'POST',
                        data: { 
                            accion: 'cancelarCita',
                            id_agendamiento: id
                        },
                        success: function(response) {
                            if (response.includes('éxito') || response.includes('correctamente') || response.includes('✅')) {
                                Swal.fire({
                                    title: 'Cancelada',
                                    text: 'Tu cita ha sido cancelada',
                                    icon: 'success',
                                    confirmButtonColor: '#e60026'
                                });
                                cargarMisCitas();
                            } else {
                                Swal.fire({
                                    title: 'Error',
                                    text: response,
                                    icon: 'error',
                                    confirmButtonColor: '#e60026'
                                });
                            }
                        }
                    });
                }
            });
        }
        
        function cerrarSesion() {
            $.post('Cabecera-detalle/Controlador_cliente.jsp', 
                { accion: 'cerrarSesion' },
                function() {
                    window.location.href = 'index_publico.jsp';
                }
            );
        }
    </script>
</body>
</html>
