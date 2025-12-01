<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
// Verificar si hay sesión activa
Integer usuarioId = (Integer) session.getAttribute("usuario_id");
String rol = (String) session.getAttribute("rol");
boolean haySession = (usuarioId != null && "Cliente".equals(rol));
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Peluquería Josephlo - Reserva tu cita</title>
    
    <!-- Meta tags -->
    <meta name="keywords" content="Peluquería, barbería, cortes, tratamientos, belleza, reservas online"/>
    <meta name="description" content="Somos expertos en belleza. Reserva tu cita online y disfruta de nuestros servicios premium.">
    <meta name="author" content="Peluquería Josephlo"/>
    
    <!-- Favicon -->
    <link href="favicon.png" rel="icon">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- SweetAlert2 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">

    <style>
        /* ==========================================
           VARIABLES Y RESET
           ========================================== */
        :root {
            --color-primary: #e60026;
            --color-primary-dark: #cc001f;
            --color-secondary: #f56649;
            --color-black: #000000;
            --color-dark: #1a1a1a;
            --color-gray-dark: #2a2a2a;
            --color-gray: #444444;
            --color-white: #ffffff;
            --color-white-50: rgba(255, 255, 255, 0.5);
            --color-white-70: rgba(255, 255, 255, 0.7);
            --font-family: 'Poppins', sans-serif;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: var(--font-family);
            background-color: var(--color-black) !important;
            color: var(--color-white) !important;
            line-height: 1.6;
            overflow-x: hidden;
        }

        /* ==========================================
           TOP HEADER
           ========================================== */
        .bg-custom {
            background-color: var(--color-black) !important;
            border-bottom: 1px solid var(--color-gray);
        }

        .header-text {
            color: var(--color-white) !important;
            font-size: 0.9rem;
        }

        .header-text i {
            color: var(--color-primary) !important;
        }

        .header-text small {
            color: var(--color-white-70) !important;
        }

        .bg-custom a {
            color: var(--color-white) !important;
            transition: color 0.3s;
        }

        .bg-custom a:hover {
            color: var(--color-primary) !important;
        }

        /* ==========================================
           NAVBAR
           ========================================== */
        .navbar {
            background-color: var(--color-black) !important;
            border-bottom: 3px solid var(--color-primary) !important;
            padding: 1rem 0;
            box-shadow: 0 2px 10px rgba(230, 0, 38, 0.3);
        }

        .navbar-brand img {
            filter: brightness(0) invert(1);
            transition: transform 0.3s;
        }

        .navbar-brand img:hover {
            transform: scale(1.05);
        }

        .navbar-nav .nav-link {
            color: var(--color-white) !important;
            font-weight: 500;
            padding: 0.5rem 1rem !important;
            transition: all 0.3s;
            position: relative;
        }

        .navbar-nav .nav-link::after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: 0;
            left: 50%;
            background-color: var(--color-primary);
            transition: all 0.3s;
            transform: translateX(-50%);
        }

        .navbar-nav .nav-link:hover::after,
        .navbar-nav .nav-link.active::after {
            width: 80%;
        }

        .navbar-nav .nav-link:hover,
        .navbar-nav .nav-link.active {
            color: var(--color-primary) !important;
        }

        /* ==========================================
           BOTONES
           ========================================== */
        .btn-outline-light {
            border: 2px solid var(--color-white);
            color: var(--color-white);
            font-weight: 600;
            border-radius: 25px;
            padding: 0.5rem 1.5rem;
            transition: all 0.3s;
        }

        .btn-outline-light:hover {
            background-color: var(--color-white);
            color: var(--color-black);
            transform: translateY(-2px);
        }

        .btn-primary {
            background-color: var(--color-primary) !important;
            border-color: var(--color-primary) !important;
            color: var(--color-white) !important;
            font-weight: 600;
            border-radius: 25px;
            padding: 0.6rem 2rem;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(230, 0, 38, 0.3);
        }

        .btn-primary:hover {
            background-color: var(--color-primary-dark) !important;
            border-color: var(--color-primary-dark) !important;
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(230, 0, 38, 0.5);
        }

        /* ==========================================
           HERO SECTION
           ========================================== */
        .hero-section {
            background-color: var(--color-black);
            padding: 80px 0 40px 0;
            position: relative;
            overflow: hidden;
        }

        .hero-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(230, 0, 38, 0.1) 0%, rgba(0, 0, 0, 0.8) 100%);
            z-index: 0;
        }

        .hero-section .container {
            position: relative;
            z-index: 1;
        }

        .hero-section h1 {
            font-size: 3.5rem;
            font-weight: 700;
            line-height: 1.2;
            margin-bottom: 1.5rem;
            animation: fadeInUp 1s;
        }

        .hero-section .text-primary {
            color: var(--color-primary) !important;
        }

        .hero-section .lead {
            font-size: 1.25rem;
            margin-bottom: 2rem;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* ==========================================
           SERVICIOS
           ========================================== */
        #servicios {
            background-color: var(--color-black);
            padding: 60px 0 80px 0;
        }

        .service-card {
            background-color: var(--color-gray-dark) !important;
            border: 1px solid var(--color-gray) !important;
            border-radius: 20px;
            overflow: hidden;
            transition: all 0.3s;
            height: 100%;
            display: flex;
            flex-direction: column;
            cursor: pointer;
        }

        .service-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 40px rgba(230, 0, 38, 0.3);
            border-color: var(--color-primary) !important;
        }

        .service-card .card-img-top {
            width: 100%;
            height: 280px;
            object-fit: cover;
            transition: transform 0.5s;
        }

        .service-card:hover .card-img-top {
            transform: scale(1.1);
        }

        .service-card .card-body {
            padding: 2rem;
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .service-card .card-title {
            color: var(--color-white) !important;
            font-size: 1.4rem;
            font-weight: 600;
            margin-bottom: 1rem;
            min-height: 60px;
        }

        .service-card .card-text {
            color: var(--color-white-70) !important;
            font-size: 0.95rem;
            line-height: 1.6;
            margin-bottom: 1rem;
            flex: 1;
        }

        .price-tag {
            text-align: center;
            padding: 0.8rem;
            background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
            border-radius: 10px;
            margin-bottom: 1rem;
        }

        .price-tag .price {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--color-white);
        }

        .btn-reservar-card {
            background-color: var(--color-primary) !important;
            border-color: var(--color-primary) !important;
            color: var(--color-white) !important;
            font-weight: 600;
            border-radius: 10px;
            padding: 0.8rem;
            transition: all 0.3s;
            width: 100%;
        }

        .btn-reservar-card:hover {
            background-color: var(--color-primary-dark) !important;
            transform: translateY(-2px);
        }

        /* ==========================================
           GALERÍA
           ========================================== */
        #galeria {
            padding: 80px 0;
        }

        .bg-dark-secondary {
            background-color: #0a0a0a !important;
        }

        .gallery-item {
            position: relative;
            overflow: hidden;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.5);
            transition: all 0.3s;
        }

        .gallery-item:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(230, 0, 38, 0.4);
        }

        .gallery-item img {
            width: 100%;
            height: 300px;
            object-fit: cover;
            transition: transform 0.5s;
        }

        .gallery-item:hover img {
            transform: scale(1.15);
        }

        /* ==========================================
           HORARIOS
           ========================================== */
        #horarios {
            background-color: var(--color-black);
            padding: 80px 0;
        }

        .horario-card {
            background: linear-gradient(135deg, var(--color-gray-dark) 0%, var(--color-dark) 100%);
            border: 1px solid var(--color-gray);
            border-left: 4px solid var(--color-primary);
            border-radius: 15px;
            padding: 1.5rem 2rem;
            transition: all 0.3s;
        }

        .horario-card:hover {
            transform: translateX(10px);
            box-shadow: 0 5px 20px rgba(230, 0, 38, 0.3);
        }

        .horario-dia {
            font-weight: 600;
            font-size: 1.1rem;
            color: var(--color-white);
        }

        .horario-hora {
            font-weight: 700;
            font-size: 1.2rem;
            color: var(--color-primary);
        }

        /* ==========================================
           FOOTER
           ========================================== */
        .footer-dark {
            background-color: var(--color-dark) !important;
            border-top: 3px solid var(--color-primary) !important;
            margin-top: 3rem;
        }

        .footer-dark h5 {
            color: var(--color-white) !important;
            font-weight: 600;
            margin-bottom: 1.5rem;
        }

        .footer-dark a {
            color: var(--color-white-50) !important;
            text-decoration: none;
            transition: all 0.3s;
        }

        .footer-dark a:hover {
            color: var(--color-primary) !important;
            padding-left: 5px;
        }

        .footer-dark .social-icons .btn {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
        }

        .footer-dark .social-icons .btn:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(230, 0, 38, 0.5);
        }

        .bg-black {
            background-color: var(--color-black) !important;
        }

        /* ==========================================
           WHATSAPP FLOTANTE
           ========================================== */
        .float-whatsapp {
            position: fixed;
            width: 60px;
            height: 60px;
            bottom: 30px;
            right: 30px;
            background-color: #25d366;
            color: var(--color-white);
            border-radius: 50%;
            text-align: center;
            font-size: 30px;
            box-shadow: 0 5px 20px rgba(37, 211, 102, 0.5);
            z-index: 1000;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            animation: pulse 2s infinite;
        }

        .float-whatsapp:hover {
            transform: scale(1.1);
            box-shadow: 0 8px 30px rgba(37, 211, 102, 0.8);
            color: var(--color-white);
        }

        @keyframes pulse {
            0% {
                box-shadow: 0 5px 20px rgba(37, 211, 102, 0.5);
            }
            50% {
                box-shadow: 0 5px 30px rgba(37, 211, 102, 0.8);
            }
            100% {
                box-shadow: 0 5px 20px rgba(37, 211, 102, 0.5);
            }
        }

        /* ==========================================
           BOTÓN VOLVER ARRIBA
           ========================================== */
        .btn-back-to-top {
            position: fixed;
            bottom: 30px;
            right: 100px;
            width: 50px;
            height: 50px;
            background-color: var(--color-primary);
            color: var(--color-white);
            border-radius: 50%;
            display: none;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            box-shadow: 0 5px 20px rgba(230, 0, 38, 0.5);
            z-index: 999;
            transition: all 0.3s;
            cursor: pointer;
            text-decoration: none;
        }

        .btn-back-to-top:hover {
            background-color: var(--color-primary-dark);
            transform: translateY(-5px);
            box-shadow: 0 8px 30px rgba(230, 0, 38, 0.8);
            color: var(--color-white);
        }

        /* ==========================================
           LOADING
           ========================================== */
        .loading-servicios {
            text-align: center;
            padding: 3rem;
        }

        .spinner-border-custom {
            width: 3rem;
            height: 3rem;
            border: 4px solid var(--color-gray);
            border-top-color: var(--color-primary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* ==========================================
           UTILIDADES
           ========================================== */
        .text-white-50 {
            color: var(--color-white-50) !important;
        }

        .text-white-70 {
            color: var(--color-white-70) !important;
        }

        /* ==========================================
           SCROLLBAR PERSONALIZADA
           ========================================== */
        ::-webkit-scrollbar {
            width: 12px;
        }

        ::-webkit-scrollbar-track {
            background: var(--color-black);
        }

        ::-webkit-scrollbar-thumb {
            background: var(--color-primary);
            border-radius: 6px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: var(--color-primary-dark);
        }

        /* ==========================================
           RESPONSIVE
           ========================================== */
        @media (max-width: 991px) {
            .hero-section h1 {
                font-size: 2.5rem;
            }

            .hero-section {
                padding: 60px 0 30px 0;
            }

            .navbar-nav .nav-link {
                padding: 0.5rem 0 !important;
                text-align: center;
            }

            .navbar-nav .nav-link::after {
                display: none;
            }

            .service-card .card-img-top {
                height: 250px;
            }

            .float-whatsapp {
                width: 50px;
                height: 50px;
                font-size: 24px;
                bottom: 20px;
                right: 20px;
            }

            .btn-back-to-top {
                right: 80px;
                width: 45px;
                height: 45px;
                bottom: 20px;
            }
        }

        @media (max-width: 768px) {
            .hero-section h1 {
                font-size: 2rem;
            }

            .display-4 {
                font-size: 2rem;
            }

            .service-card .card-body {
                padding: 1.5rem;
            }

            .gallery-item img {
                height: 200px;
            }

            .horario-card {
                padding: 1rem 1.5rem;
            }
        }

        @media (max-width: 576px) {
            .hero-section {
                padding: 40px 0 20px 0;
            }

            .hero-section h1 {
                font-size: 1.8rem;
            }

            .btn-primary {
                padding: 0.5rem 1.5rem;
            }

            .service-card .card-img-top {
                height: 200px;
            }

            #servicios,
            #galeria,
            #horarios {
                padding: 40px 0;
            }
        }
    </style>
</head>

<body>
    <!-- WhatsApp Flotante -->
    <a href="https://api.whatsapp.com/send?phone=5950981554471&text=Hola!%20Me%20interesa%20reservar%20una%20cita." class="float-whatsapp" target="_blank">
        <i class="fab fa-whatsapp"></i>
    </a>

    <!-- TOP HEADER -->
    <div class="container-fluid bg-custom py-3">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <div class="d-flex align-items-center">
                        <span class="header-text me-4">
                            <i class="fas fa-phone-alt me-2"></i>
                            <small>+595 981 554 471</small>
                        </span>
                        <span class="header-text">
                            <i class="fas fa-envelope me-2"></i>
                            <small>info@josephlo.com</small>
                        </span>
                    </div>
                </div>
                <div class="col-lg-6 text-end">
                    <div class="d-inline-flex align-items-center">
                        <a class="text-white px-2" href="https://www.facebook.com/josephlo" target="_blank">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a class="text-white px-2" href="https://www.instagram.com/josephlo" target="_blank">
                            <i class="fab fa-instagram"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- NAVBAR -->
    <nav class="navbar navbar-expand-lg navbar-dark sticky-top">
        <div class="container">
            <a class="navbar-brand" href="index_publico.jsp">
                <img src="img/logo-white.png" alt="Josephlo Logo" style="height: 50px;">
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto align-items-center">
                    <li class="nav-item">
                        <a class="nav-link active" href="#inicio">Inicio</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#servicios">Servicios</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#galeria">Galería</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#horarios">Horarios</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="nosotros.jsp">Nosotros</a>
                    </li>
                    
                    <% if (haySession) { 
                        // Obtener nombre del usuario desde la sesión
                        String nombreUsuario = (String) session.getAttribute("usuario_nombre");
                        
                        // Si aún no hay nombre, usar "Usuario" por defecto
                        if (nombreUsuario == null || nombreUsuario.trim().isEmpty()) {
                            nombreUsuario = "Usuario";
                        }
                    %>
                        <!-- Usuario logueado -->
                        <li class="nav-item">
                            <span class="nav-link" style="color: var(--color-white-70);">
                                <i class="fas fa-user-circle text-primary"></i> Bienvenido, <strong class="text-white"><%= nombreUsuario %></strong>
                            </span>
                        </li>
                        <li class="nav-item">
                            <a href="panel_cliente.jsp" class="btn btn-outline-light ms-2">
                                <i class="fas fa-th-large"></i> Mi Panel
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="logout_cliente.jsp" class="btn btn-outline-light ms-2" style="border-color: var(--color-primary); color: var(--color-primary);">
                                <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
                            </a>
                        </li>
                    <% } else { %>
                        <!-- Usuario sin sesión -->
                        <li class="nav-item">
                            <a href="login_cliente.jsp" class="btn btn-outline-light ms-3">
                                <i class="fas fa-sign-in-alt"></i> Iniciar Sesión
                            </a>
                        </li>
                    <% } %>
                </ul>
            </div>
        </div>
    </nav>

    <!-- HERO SECTION (Sin botón) -->
    <section id="inicio" class="hero-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-12 text-center">
                    <h1 class="display-3 fw-bold mb-4 text-white">
                        Tu imagen, <span class="text-primary">nuestra inspiración.</span>
                    </h1>
                    <p class="lead text-white-50 mb-4">
                        Experimenta el arte del cuidado personal profesional con más de 15 años de experiencia.
                    </p>
                    <p class="text-white-70">
                        <i class="fas fa-arrow-down text-primary me-2"></i>
                        Selecciona un servicio para comenzar tu reserva
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- SERVICIOS -->
    <section id="servicios" class="py-5">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="display-4 fw-bold text-white mb-3">Nuestros Servicios</h2>
                <p class="text-white-50 lead">Descubre nuestros packs premium</p>
            </div>

            <!-- Aquí se cargan los servicios dinámicamente -->
            <div class="row" id="listaServicios">
                <div class="loading-servicios">
                    <div class="spinner-border-custom"></div>
                    <p class="text-white-50 mt-3">Cargando servicios...</p>
                </div>
            </div>
        </div>
    </section>

    <!-- GALERÍA -->
    <section id="galeria" class="py-5 bg-dark-secondary">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="display-4 fw-bold text-white mb-3">Galería de Trabajos</h2>
                <p class="text-white-50 lead">Nuestros mejores resultados</p>
            </div>

            <div class="row g-3">
                <div class="col-md-4">
                    <div class="gallery-item">
                        <img src="img/galeria/trabajo1.jpg" alt="Trabajo 1" class="img-fluid rounded">
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="gallery-item">
                        <img src="img/galeria/trabajo2.jpg" alt="Trabajo 2" class="img-fluid rounded">
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="gallery-item">
                        <img src="img/galeria/trabajo3.jpg" alt="Trabajo 3" class="img-fluid rounded">
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="gallery-item">
                        <img src="img/galeria/trabajo4.jpg" alt="Trabajo 4" class="img-fluid rounded">
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="gallery-item">
                        <img src="img/galeria/trabajo5.jpg" alt="Trabajo 5" class="img-fluid rounded">
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="gallery-item">
                        <img src="img/galeria/trabajo6.jpg" alt="Trabajo 6" class="img-fluid rounded">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- HORARIOS -->
    <section id="horarios" class="py-5">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="display-4 fw-bold text-white mb-3">Horarios de Atención</h2>
                <p class="text-white-50 lead">Estamos aquí para ti</p>
            </div>

            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="horario-card mb-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="horario-dia">Lunes - Viernes</span>
                            <span class="horario-hora">07:00 - 19:00</span>
                        </div>
                    </div>
                    <div class="horario-card mb-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="horario-dia">Sábado</span>
                            <span class="horario-hora">08:00 - 15:00</span>
                        </div>
                    </div>
                    <div class="horario-card">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="horario-dia">Domingo</span>
                            <span class="horario-hora text-danger">Cerrado</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- FOOTER -->
    <footer class="footer-dark">
        <div class="container pt-5 pb-4">
            <div class="row">
                <div class="col-lg-4 mb-4">
                    <img src="img/logo-white.png" alt="Logo" class="mb-3" style="height: 60px;">
                    <p class="text-white-50">
                        Reservá un turno con nosotros, podés escribirnos a nuestro WhatsApp.
                    </p>
                    <p class="text-white-50">
                        <i class="fas fa-map-marker-alt text-primary me-2"></i>
                        Asunción, Paraguay
                    </p>
                    <p class="text-white-50">
                        <i class="fas fa-phone-alt text-primary me-2"></i>
                        +595 981 554 471
                    </p>
                    <div class="social-icons mt-3">
                        <a href="https://www.facebook.com" target="_blank" class="btn btn-primary btn-sm me-2">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a href="https://www.instagram.com" target="_blank" class="btn btn-primary btn-sm">
                            <i class="fab fa-instagram"></i>
                        </a>
                    </div>
                </div>

                <div class="col-lg-4 mb-4">
                    <h5 class="text-white text-uppercase mb-4">Enlaces rápidos</h5>
                    <ul class="list-unstyled">
                        <li class="mb-2">
                            <a href="#inicio" class="text-white-50">
                                <i class="fas fa-angle-right me-2"></i>Inicio
                            </a>
                        </li>
                        <li class="mb-2">
                            <a href="nosotros.jsp" class="text-white-50">
                                <i class="fas fa-angle-right me-2"></i>Nosotros
                            </a>
                        </li>
                        <li class="mb-2">
                            <a href="#servicios" class="text-white-50">
                                <i class="fas fa-angle-right me-2"></i>Servicios
                            </a>
                        </li>
                        <li class="mb-2">
                            <a href="#galeria" class="text-white-50">
                                <i class="fas fa-angle-right me-2"></i>Galería
                            </a>
                        </li>
                        <li class="mb-2">
                            <a href="#horarios" class="text-white-50">
                                <i class="fas fa-angle-right me-2"></i>Horarios
                            </a>
                        </li>
                    </ul>
                </div>

                <div class="col-lg-4 mb-4">
                    <h5 class="text-white text-uppercase mb-4">Nuestros servicios</h5>
                    <ul class="list-unstyled">
                        <li class="mb-2">
                            <a href="#servicios" class="text-white-50">
                                <i class="fas fa-angle-right me-2"></i>Cortes
                            </a>
                        </li>
                        <li class="mb-2">
                            <a href="#servicios" class="text-white-50">
                                <i class="fas fa-angle-right me-2"></i>Rulos
                            </a>
                        </li>
                        <li class="mb-2">
                            <a href="#servicios" class="text-white-50">
                                <i class="fas fa-angle-right me-2"></i>Lavados
                            </a>
                        </li>
                        <li class="mb-2">
                            <a href="#servicios" class="text-white-50">
                                <i class="fas fa-angle-right me-2"></i>Peinados
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="container-fluid bg-black py-3">
            <div class="container">
                <div class="row">
                    <div class="col-md-6 text-center text-md-start">
                        <p class="mb-0 text-white-50">
                            &copy; 2025 <a href="#" class="text-primary">Peluquería Josephlo</a>. Todos los derechos reservados.
                        </p>
                    </div>
                    <div class="col-md-6 text-center text-md-end">
                        <p class="mb-0 text-white-50">
                            Desarrollado por Ignacio Pane
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </footer>

    <!-- Botón volver arriba -->
    <a href="#" class="btn-back-to-top">
        <i class="fas fa-angle-double-up"></i>
    </a>

    <!-- Variable JavaScript con estado de sesión -->
    <script>
        var haySession = <%= haySession %>;
    </script>

    <!-- Incluir el modal de reserva -->
    <%@ include file="modal_reserva_booksy.jsp" %>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="script/reserva_publica.js"></script>
    
    <!-- Script para cargar servicios -->
    <script>
        $(document).ready(function() {
            cargarServicios();
        });

        // CARGAR SERVICIOS DESDE LA BD (Usando sistema original)
        function cargarServicios() {
            $.ajax({
                url: 'Cabecera-detalle/Controlador_reserva_publica.jsp',
                type: 'POST',
                data: { accion: 'listarServicios' },
                dataType: 'json',
                success: function(response) {
                    console.log("Servicios cargados:", response);
                    
                    // Usar el HTML que viene del servidor
                    if (response.grid) {
                        $('#listaServicios').html(response.grid);
                    } else {
                        $('#listaServicios').html('<div class="col-12 text-center"><p class="text-white-50">No hay servicios disponibles</p></div>');
                    }
                },
                error: function(error) {
                    console.error("Error cargando servicios:", error);
                    $('#listaServicios').html('<div class="col-12 text-center"><p class="text-danger">Error al cargar servicios. Por favor recarga la página.</p></div>');
                }
            });
        }

        // FUNCIÓN PARA ABRIR MODAL DIRECTO AL PASO 2
        function abrirModalConServicioDirecto(id, nombre, precio) {
            if (!haySession) {
                Swal.fire({
                    icon: 'info',
                    title: 'Inicia sesión para continuar',
                    text: 'Necesitas tener una cuenta para reservar una cita',
                    showCancelButton: true,
                    confirmButtonText: 'Iniciar Sesión',
                    cancelButtonText: 'Registrarme',
                    confirmButtonColor: '#e60026',
                    cancelButtonColor: '#666'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = 'login_cliente.jsp';
                    } else if (result.dismiss === Swal.DismissReason.cancel) {
                        window.location.href = 'registro_cliente.jsp';
                    }
                });
                return;
            }
            
            // Guardar servicio en reservaData
            reservaData.servicio = { id: id, nombre: nombre, precio: precio };
            
            console.log("Servicio seleccionado:", reservaData.servicio);
            
            // Abrir modal y cargar profesionales
            $('#modalReserva').modal('show');
            cargarProfesionales(id);
            mostrarPaso(2); // Ir directo al paso 2 (profesionales)
        }

        // SMOOTH SCROLL
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // BOTÓN VOLVER ARRIBA
        const backToTop = document.querySelector('.btn-back-to-top');
        
        window.addEventListener('scroll', () => {
            if (window.pageYOffset > 300) {
                backToTop.style.display = 'flex';
            } else {
                backToTop.style.display = 'none';
            }
        });

        backToTop.addEventListener('click', (e) => {
            e.preventDefault();
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    </script>
</body>
</html>
