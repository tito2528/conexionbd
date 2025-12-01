<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Agendamiento de Citas | Joseph Coiffure</title>
  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
  <!-- Tu CSS personalizado -->
  <link rel="stylesheet" href="style.css">
  <style>
    body {
      background: url('https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1500&q=80') no-repeat center center fixed;
      background-size: cover;
      min-height: 100vh;
      position: relative;
      z-index: 1;
      padding-top: 70px; /* Espacio para navbar fija */
    }
    body::before {
      content: "";
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0,0,0,0.4);
      z-index: -1;
    }
    .whatsapp-float {
      position: fixed;
      bottom: 25px;
      right: 25px;
      z-index: 999;
      transition: transform 0.2s;
    }
    .whatsapp-float:hover {
      transform: scale(1.1);
    }
    footer {
      margin-top: 60px;
    }
    .service-card img {
      width: 100%;
      height: 180px;
      object-fit: cover;
    }
    .service-card {
      transition: box-shadow 0.2s;
    }
    .service-card:hover {
      box-shadow: 0 4px 16px rgba(0,0,0,0.15);
    }
    .modal-header {
      background: #0d6efd;
      color: #fff;
    }
  </style>
</head>
<body>
  <!-- HEADER / NAVBAR -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow fixed-top">
    <div class="container">
      <a class="navbar-brand fw-bold" href="Inicio - Joseph Coiffure Mariano.html">
        Joseph Coiffure
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav ms-auto">
          <li class="nav-item"><a class="nav-link" href="Inicio - Joseph Coiffure Mariano.html">Inicio</a></li>
          <li class="nav-item"><a class="nav-link" href="Servicios.html">Servicios</a></li>
          <li class="nav-item"><a class="nav-link" href="Combos - Joseph Coiffure Mariano.html">Combos</a></li>
          <li class="nav-item"><a class="nav-link" href="SPA - Joseph Coiffure Mariano.html">SPA</a></li>
          <li class="nav-item"><a class="nav-link" href="Servicios Peluquería - Joseph Coiffure Mariano.html">Peluquería</a></li>
          <li class="nav-item"><a class="nav-link" href="Tratamiento Corporal Método Renata França - Joseph Coiffure Mariano.html">Tratamientos</a></li>
          <li class="nav-item"><a class="nav-link" href="galeria.html">Galería</a></li>
          <li class="nav-item"><a class="nav-link" href="Nosotros - Joseph Coiffure Mariano.html">Nosotros</a></li>
          <li class="nav-item"><a class="nav-link" href="contactos.html">Contacto</a></li>
        </ul>
      </div>
    </div>
  </nav>
  <!-- Fin Header -->

  <!-- CONTENIDO PRINCIPAL -->
  <main class="container py-5 text-white">
    <!-- Hero Section -->
    <section class="py-5 text-center">
      <div class="container">
        <h1 class="display-5">Agenda tu cita en minutos</h1>
        <p class="lead">Elige el servicio, selecciona el horario y reserva tu lugar fácilmente.</p>
        <div class="mt-4">
          <button class="btn btn-outline-light me-2" data-bs-toggle="modal" data-bs-target="#loginModal">Iniciar Sesión</button>
          <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#registerModal">Registrarse</button>
          <button class="btn btn-danger d-none" id="logoutBtn">Cerrar Sesión</button>
        </div>
      </div>
    </section>

    <!-- Servicios -->
    <section class="container py-5">
      <h2 class="mb-4 text-center">Nuestros Servicios</h2>
      <div class="row" id="serviciosContainer">
        <!-- Servicios se cargan dinámicamente -->
      </div>
    </section>

    <!-- Formulario de Agendamiento -->
    <section class="container py-4 d-none" id="agendamientoSection">
      <div class="card shadow">
        <div class="card-header bg-primary text-white">
          <h5 class="mb-0">Agendar una cita</h5>
        </div>
        <div class="card-body">
          <form id="agendarForm">
            <div class="row g-3">
              <div class="col-md-6">
                <label for="servicioSelect" class="form-label">Servicio</label>
                <select class="form-select" id="servicioSelect" required>
                  <option value="">Seleccione un servicio</option>
                  <!-- Opciones dinámicas -->
                </select>
              </div>
              <div class="col-md-6">
                <label for="profesionalSelect" class="form-label">Profesional</label>
                <select class="form-select" id="profesionalSelect" required>
                  <option value="">Seleccione un profesional</option>
                  <!-- Opciones dinámicas -->
                </select>
              </div>
              <div class="col-md-6">
                <label for="fechaInput" class="form-label">Fecha</label>
                <input type="date" class="form-control" id="fechaInput" required min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
              </div>
              <div class="col-md-6">
                <label for="horarioSelect" class="form-label">Horario</label>
                <select class="form-select" id="horarioSelect" required>
                  <option value="">Seleccione un horario</option>
                  <!-- Opciones dinámicas -->
                </select>
              </div>
              <div class="col-12">
                <label for="observacionesInput" class="form-label">Observaciones (opcional)</label>
                <textarea class="form-control" id="observacionesInput" rows="2"></textarea>
              </div>
            </div>
            <div class="mt-4 text-end">
              <button type="submit" class="btn btn-success">Agendar Cita</button>
            </div>
          </form>
        </div>
      </div>
    </section>
  </main>

  <!-- Modal Registro -->
  <div class="modal fade" id="registerModal" tabindex="-1" aria-labelledby="registerModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <form class="modal-content" id="registerForm">
        <div class="modal-header">
          <h5 class="modal-title" id="registerModalLabel">Registro de Cliente</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label for="regNombre" class="form-label">Nombre</label>
            <input type="text" class="form-control" id="regNombre" required>
          </div>
          <div class="mb-3">
            <label for="regApellido" class="form-label">Apellido</label>
            <input type="text" class="form-control" id="regApellido" required>
          </div>
          <div class="mb-3">
            <label for="regEmail" class="form-label">Email</label>
            <input type="email" class="form-control" id="regEmail" required>
          </div>
          <div class="mb-3">
            <label for="regTelefono" class="form-label">Teléfono</label>
            <input type="text" class="form-control" id="regTelefono" required>
          </div>
          <div class="mb-3">
            <label for="regPassword" class="form-label">Contraseña</label>
            <input type="password" class="form-control" id="regPassword" required>
          </div>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-primary">Registrarse</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Modal Login -->
  <div class="modal fade" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <form class="modal-content" id="loginForm">
        <div class="modal-header">
          <h5 class="modal-title" id="loginModalLabel">Iniciar Sesión</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label for="loginEmail" class="form-label">Email</label>
            <input type="email" class="form-control" id="loginEmail" required>
          </div>
          <div class="mb-3">
            <label for="loginPassword" class="form-label">Contraseña</label>
            <input type="password" class="form-control" id="loginPassword" required>
          </div>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-success">Ingresar</button>
        </div>
      </form>
    </div>
  </div>

  <!-- FOOTER -->
  <footer class="bg-dark text-white pt-4 pb-2 mt-5">
    <div class="container text-center">
      <div class="mb-3">
        <a href="https://wa.me/595XXXXXXXXX" target="_blank" class="text-success fs-3 me-3" title="WhatsApp">
          <i class="bi bi-whatsapp"></i>
        </a>
        <a href="https://www.instagram.com/" target="_blank" class="text-white fs-3 me-3" title="Instagram">
          <i class="bi bi-instagram"></i>
        </a>
        <a href="https://www.facebook.com/" target="_blank" class="text-white fs-3" title="Facebook">
          <i class="bi bi-facebook"></i>
        </a>
      </div>
      <div>
        <small>&copy; 2024 Joseph Coiffure. Todos los derechos reservados.</small>
      </div>
    </div>
  </footer>
  <!-- Fin Footer -->

  <!-- Botón flotante de WhatsApp -->
  <a href="https://wa.me/595XXXXXXXXX" class="whatsapp-float" target="_blank" title="Chatea por WhatsApp">
    <img src="https://cdn.jsdelivr.net/gh/edent/SuperTinyIcons/images/svg/whatsapp.svg" alt="WhatsApp" width="60">
  </a>

  <!-- Bootstrap JS y tu JS personalizado -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script src="script/agendamiento_cliente.js"></script>
</body>
</html>