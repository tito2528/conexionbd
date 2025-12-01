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
    <title>Nosotros - Peluquería Josephlo</title>
    
    <!-- Favicon -->
    <link href="favicon.png" rel="icon">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            --color-primary: #e60026;
            --color-primary-dark: #cc001f;
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
        }

        /* TOP HEADER */
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

        /* NAVBAR */
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

        /* HERO NOSOTROS */
        .hero-nosotros {
            background: linear-gradient(135deg, rgba(230, 0, 38, 0.8) 0%, rgba(0, 0, 0, 0.9) 100%),
                        url('img/nosotros/hero-nosotros.jpg');
            background-size: cover;
            background-position: center;
            padding: 120px 0;
            text-align: center;
        }

        .hero-nosotros h1 {
            font-size: 3.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            animation: fadeInUp 1s;
        }

        .hero-nosotros p {
            font-size: 1.3rem;
            color: var(--color-white-70);
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

        /* SECCIONES */
        .section-dark {
            background-color: var(--color-black);
            padding: 80px 0;
        }

        .section-gray {
            background-color: var(--color-gray-dark);
            padding: 80px 0;
        }

        .section-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            color: var(--color-white);
        }

        .section-subtitle {
            font-size: 1.2rem;
            color: var(--color-white-70);
            margin-bottom: 3rem;
        }

        /* CARDS */
        .info-card {
            background: var(--color-gray-dark);
            border: 1px solid var(--color-gray);
            border-radius: 15px;
            padding: 2rem;
            height: 100%;
            transition: all 0.3s;
        }

        .info-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 40px rgba(230, 0, 38, 0.3);
            border-color: var(--color-primary);
        }

        .info-card i {
            font-size: 3rem;
            color: var(--color-primary);
            margin-bottom: 1rem;
        }

        .info-card h4 {
            color: var(--color-white);
            margin-bottom: 1rem;
        }

        .info-card p {
            color: var(--color-white-70);
        }

        /* STATS */
        .stat-box {
            text-align: center;
            padding: 2rem;
            background: linear-gradient(135deg, var(--color-gray-dark) 0%, var(--color-dark) 100%);
            border: 1px solid var(--color-gray);
            border-radius: 15px;
            margin-bottom: 2rem;
        }

        .stat-number {
            font-size: 3rem;
            font-weight: 700;
            color: var(--color-primary);
            display: block;
        }

        .stat-label {
            font-size: 1.1rem;
            color: var(--color-white-70);
        }

        /* FOOTER */
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

        .bg-black {
            background-color: var(--color-black) !important;
        }

        /* WHATSAPP */
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
        }

        .float-whatsapp:hover {
            transform: scale(1.1);
            box-shadow: 0 8px 30px rgba(37, 211, 102, 0.8);
            color: var(--color-white);
        }

        /* RESPONSIVE */
        @media (max-width: 768px) {
            .hero-nosotros h1 {
                font-size: 2rem;
            }
            .section-title {
                font-size: 2rem;
            }
        }
    </style>
</head>

<body>
    <!-- WhatsApp Flotante -->
    <a href="https://api.whatsapp.com/send?phone=5950981554471&text=Hola!%20Me%20interesa%20saber%20más%20sobre%20ustedes." class="float-whatsapp" target="_blank">
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
                        <a class="nav-link" href="index_publico.jsp">Inicio</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="index_publico.jsp#servicios">Servicios</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="index_publico.jsp#galeria">Galería</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="index_publico.jsp#horarios">Horarios</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="nosotros.jsp">Nosotros</a>
                    </li>
                    
                    <% if (haySession) { %>
                        <li class="nav-item">
                            <a href="panel_cliente.jsp" class="btn btn-outline-light ms-3">
                                <i class="fas fa-user-circle"></i> Mi Panel
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="logout_cliente.jsp" class="btn btn-outline-light ms-2" style="border-color: var(--color-primary); color: var(--color-primary);">
                                <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
                            </a>
                        </li>
                    <% } else { %>
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

    <!-- HERO NOSOTROS -->
    <section class="hero-nosotros">
        <div class="container">
            <h1 class="text-white">Sobre Nosotros</h1>
            <p class="text-white-70">Más de 15 años transformando tu imagen</p>
        </div>
    </section>

    <!-- QUIÉNES SOMOS -->
    <section class="section-dark">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6 mb-4">
                    <h2 class="section-title">¿Quiénes Somos?</h2>
                    <p class="text-white-70" style="font-size: 1.1rem; line-height: 1.8;">
                        Somos <strong style="color: var(--color-primary);">Peluquería Josephlo</strong>, un equipo de profesionales apasionados por la belleza y el cuidado personal. 
                        Con más de <strong>15 años de experiencia</strong> en el rubro, nos dedicamos a potenciar tu belleza y cumplir tus expectativas.
                    </p>
                    <p class="text-white-70" style="font-size: 1.1rem; line-height: 1.8;">
                        Nuestro compromiso es brindarte un servicio de excelencia, utilizando productos de primera calidad y técnicas innovadoras 
                        para que te sientas renovado y seguro de ti mismo.
                    </p>
                </div>
                <div class="col-lg-6 mb-4">
                    <img src="img/nosotros/equipo.jpg" alt="Nuestro equipo" class="img-fluid rounded" style="box-shadow: 0 10px 40px rgba(230, 0, 38, 0.3);">
                </div>
            </div>
        </div>
    </section>

    <!-- MISIÓN Y VISIÓN -->
    <section class="section-gray">
        <div class="container">
            <div class="row">
                <div class="col-lg-6 mb-4">
                    <div class="info-card text-center">
                        <i class="fas fa-bullseye"></i>
                        <h4>Nuestra Misión</h4>
                        <p>
                            Brindar servicios de belleza y cuidado personal de la más alta calidad, utilizando técnicas innovadoras 
                            y productos premium, para que cada cliente se sienta único, renovado y satisfecho con su experiencia.
                        </p>
                    </div>
                </div>
                <div class="col-lg-6 mb-4">
                    <div class="info-card text-center">
                        <i class="fas fa-eye"></i>
                        <h4>Nuestra Visión</h4>
                        <p>
                            Ser la peluquería líder en la región, reconocida por nuestra excelencia en el servicio, 
                            innovación constante y compromiso con la satisfacción de nuestros clientes, expandiendo nuestros servicios 
                            y manteniendo siempre los más altos estándares de calidad.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 
    <section class="section-dark">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="section-title">Nuestros Logros</h2>
                <p class="section-subtitle">Números que nos respaldan</p>
            </div>
            <div class="row">
                <div class="col-md-3 mb-4">
                    <div class="stat-box">
                        <span class="stat-number">15+</span>
                        <span class="stat-label">Años de Experiencia</span>
                    </div>
                </div>
                <div class="col-md-3 mb-4">
                    <div class="stat-box">
                        <span class="stat-number">5000+</span>
                        <span class="stat-label">Clientes Satisfechos</span>
                    </div>
                </div>
                <div class="col-md-3 mb-4">
                    <div class="stat-box">
                        <span class="stat-number">22+</span>
                        <span class="stat-label">Profesionales</span>
                    </div>
                </div>
                <div class="col-md-3 mb-4">
                    <div class="stat-box">
                        <span class="stat-number">8+</span>
                        <span class="stat-label">Servicios</span>
                    </div>
                </div>
            </div>
        </div>
    </section> -->

    <!-- VALORES -->
    <section class="section-gray">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="section-title">Nuestros Valores</h2>
                <p class="section-subtitle">Lo que nos define</p>
            </div>
            <div class="row">
                <div class="col-md-4 mb-4">
                    <div class="info-card text-center">
                        <i class="fas fa-star"></i>
                        <h4>Excelencia</h4>
                        <p>Nos esforzamos por superar las expectativas en cada servicio que brindamos.</p>
                    </div>
                </div>
                <div class="col-md-4 mb-4">
                    <div class="info-card text-center">
                        <i class="fas fa-lightbulb"></i>
                        <h4>Innovación</h4>
                        <p>Siempre a la vanguardia con las últimas tendencias y técnicas del sector.</p>
                    </div>
                </div>
                <div class="col-md-4 mb-4">
                    <div class="info-card text-center">
                        <i class="fas fa-heart"></i>
                        <h4>Pasión</h4>
                        <p>Amamos lo que hacemos y eso se refleja en cada detalle de nuestro trabajo.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA -->
    <section class="section-dark text-center">
        <div class="container">
            <h2 class="section-title mb-4">¿Listo para transformar tu imagen?</h2>
            <p class="section-subtitle mb-4">Agenda tu cita ahora y descubre la diferencia</p>
            <a href="index_publico.jsp#servicios" class="btn btn-lg" style="background-color: var(--color-primary); color: white; padding: 15px 50px; border-radius: 30px; font-weight: 600;">
                <i class="fas fa-calendar-check"></i> Ver Servicios
            </a>
        </div>
    </section>

    <!-- FOOTER -->
    <footer class="footer-dark">
        <div class="container pt-5 pb-4">
            <div class="row">
                <div class="col-lg-4 mb-4">
                    <img src="img/logo-white.png" alt="Logo" class="mb-3" style="height: 60px;">
                    <p style="color: var(--color-white-50);">
                        Reservá un turno con nosotros, podés escribirnos a nuestro WhatsApp.
                    </p>
                    <p style="color: var(--color-white-50);">
                        <i class="fas fa-map-marker-alt text-danger me-2"></i>
                        Asunción, Paraguay
                    </p>
                    <p style="color: var(--color-white-50);">
                        <i class="fas fa-phone-alt text-danger me-2"></i>
                        +595 981 554 471
                    </p>
                </div>

                <div class="col-lg-4 mb-4">
                    <h5 class="text-white text-uppercase mb-4">Enlaces rápidos</h5>
                    <ul class="list-unstyled">
                        <li class="mb-2">
                            <a href="index_publico.jsp" style="color: var(--color-white-50);">
                                <i class="fas fa-angle-right me-2"></i>Inicio
                            </a>
                        </li>
                        <li class="mb-2">
                            <a href="nosotros.jsp" style="color: var(--color-white-50);">
                                <i class="fas fa-angle-right me-2"></i>Nosotros
                            </a>
                        </li>
                        <li class="mb-2">
                            <a href="index_publico.jsp#servicios" style="color: var(--color-white-50);">
                                <i class="fas fa-angle-right me-2"></i>Servicios
                            </a>
                        </li>
                    </ul>
                </div>

                <div class="col-lg-4 mb-4">
                    <h5 class="text-white text-uppercase mb-4">Síguenos</h5>
                    <div class="d-flex gap-2">
                        <a href="https://www.facebook.com" target="_blank" class="btn btn-sm" style="background-color: var(--color-primary); color: white; width: 45px; height: 45px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a href="https://www.instagram.com" target="_blank" class="btn btn-sm" style="background-color: var(--color-primary); color: white; width: 45px; height: 45px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                            <i class="fab fa-instagram"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="container-fluid bg-black py-3">
            <div class="container">
                <div class="row">
                    <div class="col-12 text-center">
                        <p class="mb-0" style="color: var(--color-white-50);">
                            &copy; 2025 <span style="color: var(--color-primary);">Peluquería Josephlo</span>. Todos los derechos reservados.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </footer>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
