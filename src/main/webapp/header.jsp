<%@page import="java.sql.*"%>
<%@include file="validarSesion.jsp"%>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>PELUCLICK</title>
  
  <!-- Google Font: Source Sans Pro -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
  <!-- Font Awesome Icons -->
  <link rel="stylesheet" href="plugins/fontawesome-free/css/all.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="dist/css/adminlte.min.css">
  <link rel="stylesheet" href="dist/css/sweetalert2.min.css">
  
  <script src="js/jquery.min.js"></script>
  <script src="dist/js/bootstrap.bundle.min.js"></script>
  <script src="plugins/jquery/jquery.min.js"></script>
  <script src="js/sweetalert2.all.min.js"></script>
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

    /* Overlay mejorado con menor opacidad y degradado sutil */
    .content-wrapper::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        /* OPCIÓN 1: Overlay más claro (20% de opacidad) */
        background: rgba(0, 0, 0, 0.2);
        
        /* OPCIÓN 2: Degradado sutil de arriba hacia abajo (descomenta para usar) */
        /* background: linear-gradient(180deg, 
            rgba(0, 0, 0, 0.3) 0%, 
            rgba(0, 0, 0, 0.15) 50%, 
            rgba(0, 0, 0, 0.25) 100%); */
        
        /* OPCIÓN 3: Sin overlay (solo imagen de fondo) */
        /* background: transparent; */
        
        z-index: 0;
    }

    /* Contenido por encima del overlay */
    .content-wrapper > * {
        position: relative;
        z-index: 1;
    }
    
    /* Mejorar legibilidad de las tarjetas y contenido */
    .content-wrapper .card {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
    }
    
    .content-wrapper .card-header {
        background: rgba(255, 255, 255, 0.98);
        border-bottom: 1px solid rgba(0, 0, 0, 0.1);
    }
    
    /* Mejorar contraste del texto sobre la imagen */
    .content-wrapper h1,
    .content-wrapper h2,
    .content-wrapper h3,
    .content-wrapper .breadcrumb {
        text-shadow: 0 2px 4px rgba(255, 255, 255, 0.8);
    }
    
    /* Tablas más legibles */
    .content-wrapper table {
        background: rgba(255, 255, 255, 0.95);
    }
    
    body.modal-open {
        overflow: auto;
        padding-right: 0 !important;
    }
    
    .modal-backdrop {
        display: none !important;
    }
    
    /* Mejorar visibilidad de modales sobre el fondo */
    .modal-content {
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
    }
    /* SOLUCIÓN: Solo mantener el sidebar fijo */
.main-sidebar {
    position: fixed !important;
    height: 100vh;
    overflow-y: auto;
}
/* Asegurar que los modales aparezcan por encima de todo */
.modal {
    z-index: 9999 !important;
}

.modal-backdrop {
    z-index: 9998 !important;
}

/* Centrar el modal perfectamente */
.modal-dialog {
    display: flex !important;
    align-items: center !important;
    min-height: calc(100% - 1rem) !important;
    margin: 0.1rem auto !important;
}
/* Forzar que el botón de cerrar sesión NUNCA se oculte */
.navbar-nav .nav-item,
.navbar-nav .nav-item a {
    display: block !important;
    visibility: visible !important;
    opacity: 1 !important;
}
/* Asegurar que el sidebar no tape el modal */
.main-sidebar {
    z-index: 1000 !important;
}

body {
    padding-right: 0 !important;
    overflow-x: hidden !important;
}

body[style*="padding-right"] {
    padding-right: 0 !important;
}

html {
    overflow-x: hidden !important;
}

.wrapper {
    overflow-x: hidden !important;
}
  </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">

  <!-- Navbar -->
  <nav class="main-header navbar navbar-expand navbar-white navbar-light">
    <!-- Left navbar links -->
    <ul class="navbar-nav">
      <li class="nav-item">
        <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
      </li>
      <li class="nav-item d-none d-sm-inline-block">
        <a href="http://localhost:8080/conexionbd/index.jsp" class="nav-link">Inicio</a>
      </li>
      <li class="nav-item d-none d-sm-inline-block">
        <a href="#" class="nav-link">Dashboard</a>
      </li>
    </ul>

    <!-- Right navbar links -->
    <ul class="navbar-nav ml-auto">
      <!-- Botón de Cerrar Sesión -->
      <li class="nav-item">
        <a href="logout.jsp" class="nav-link text-danger" onclick="return confirm('¿Seguro que deseas cerrar sesión?');">
          <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
        </a>
      </li>
      
      <li class="nav-item">
        <a class="nav-link" data-widget="fullscreen" href="#" role="button">
          <i class="fas fa-expand-arrows-alt"></i>
        </a>
      </li>
      <li class="nav-item">
        <a class="nav-link" data-widget="control-sidebar" data-slide="true" href="#" role="button">
          <i class="fas fa-th-large"></i>
        </a>
      </li>
    </ul>
  </nav>
  <!-- /.navbar -->

  <!-- Main Sidebar Container -->
  <aside class="main-sidebar sidebar-dark-primary elevation-4">
    <!-- Brand Logo -->
    <a href="index.jsp" class="brand-link">
      <img src="dist/img/AdminLTELogo.png" alt="AdminLTE Logo" class="brand-image img-circle elevation-3" style="opacity: .8">
      <span class="brand-text font-weight-light">JOSEPHLO</span>
    </a>

    <!-- Sidebar -->
    <div class="sidebar">
      <!-- Sidebar user panel (optional) -->
      <div class="user-panel mt-3 pb-3 mb-3 d-flex">
        <div class="image">
          <img src="dist/img/yo.jpg" class="img-circle elevation-2" alt="User Image">
        </div>
        <div class="info">
          <a href="#" class="d-block">Ignacio Pane</a>
        </div>
      </div>

      <!-- Sidebar Menu -->
      <nav class="mt-2">
        <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
          
          <!-- PRIMER MENÚ - REFERENCIALES -->
          <li class="nav-item menu-open">
            <a href="http://localhost:8080/conexionbd/index.jsp" class="nav-link active">
              <i class="nav-icon fas fa-tachometer-alt"></i>
              <p>
                Referenciales
                <i class="right fas fa-angle-left"></i>
              </p>
            </a>
            <ul class="nav nav-treeview">
              
              
              <li class="nav-item">
                <a href="listarclientes.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Cliente</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="listarprofesional.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Profesional</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="listarusuario.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Usuario</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="listarservicio.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Servicio-Precio</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="listarsucursal.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Sucursal</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="listarespecialidades.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Especialidad</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="listarmetodopago.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Metodo de Pago</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="listarhorario.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Horario</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="listarroles.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Roles</p>
                </a>
              </li>
              
              <li class="nav-item">
                <a href="listar_horarios_profesional.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Horarios profesionales</p>
                </a>
              </li>
              
            </ul>
          </li>

          <!-- SEGUNDO MENÚ - MOVIMIENTOS -->
          <li class="nav-item menu-open">
            <a href="http://localhost:8080/conexionbd/index.jsp" class="nav-link active">
              <i class="nav-icon fas fa-calendar-alt"></i>
              <p>
                Movimientos
                <i class="right fas fa-angle-left"></i>
              </p>
            </a>
            <ul class="nav nav-treeview">
              <li class="nav-item">
                <a href="registro_agendamiento.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Agendamiento</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="listado_citas.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Citas</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="vistafacturacion.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Facturacion</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="gestion_clientes.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Gestión de Clientes - Facturas</p>
                </a>
              </li>
              <li class="nav-item">
                <a href="gestion_facturas.jsp" class="nav-link active">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Gestión de Facturas</p>
                </a>
              </li>
            </ul>
          </li>

        </ul>
      </nav>
    </div>
  </aside>