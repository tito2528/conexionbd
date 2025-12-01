<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="conexion.jsp" %>
<%@ include file="header.jsp" %>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    Date fechaActual = new Date();
    SimpleDateFormat formateadorFecha = new SimpleDateFormat("yyyy-MM-dd");
    String fechaFormateada = formateadorFecha.format(fechaActual);
    
    String citaCreada = request.getParameter("cita_creada");
%>

<!-- FullCalendar CSS -->
<link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css' rel='stylesheet' />

<style>
    .content-wrapper {
        background: #f4f6f9;
    }
    
    /* Header con notificaciones */
    .citas-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 30px;
        border-radius: 15px;
        margin-bottom: 30px;
        box-shadow: 0 5px 20px rgba(102, 126, 234, 0.3);
    }
    
    .notificaciones-badge {
        position: relative;
        display: inline-block;
    }
    
    .badge-notif {
        position: absolute;
        top: -10px;
        right: -10px;
        background: #e74c3c;
        color: white;
        border-radius: 50%;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        font-size: 0.9rem;
        animation: pulse 2s infinite;
    }
    
    @keyframes pulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.1); }
    }
    
    /* Pestañas de vista */
    .vista-tabs {
        background: white;
        border-radius: 10px;
        padding: 15px;
        margin-bottom: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    .vista-tabs .nav-link {
        border: none;
        color: #7f8c8d;
        font-weight: 600;
        padding: 10px 25px;
        border-radius: 8px;
        transition: all 0.3s;
    }
    
    .vista-tabs .nav-link.active {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
    }
    
    /* Tarjetas de citas */
    .cita-card {
        background: white;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 15px;
        box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        border-left: 5px solid #3498db;
        transition: all 0.3s;
    }
    
    .cita-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 5px 20px rgba(0,0,0,0.15);
    }
    
    .cita-card.pendiente { border-left-color: #f39c12; }
    .cita-card.confirmado { border-left-color: #27ae60; }
    .cita-card.finalizado { border-left-color: #9b59b6; }
    .cita-card.cancelado { border-left-color: #e74c3c; }
    
    .cita-info {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
    }
    
    .cita-cliente {
        font-size: 1.2rem;
        font-weight: bold;
        color: #2c3e50;
    }
    
    .cita-badge {
        padding: 8px 15px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 0.85rem;
    }
    
    .badge-pendiente { background: #fff3cd; color: #856404; }
    .badge-confirmado { background: #d4edda; color: #155724; }
    .badge-finalizado { background: #e8daef; color: #6c3483; }
    .badge-cancelado { background: #f8d7da; color: #721c24; }
    
    .cita-detalles {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 15px;
        margin-bottom: 15px;
    }
    
    .detalle-item {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .detalle-item i {
        color: #667eea;
        font-size: 1.1rem;
    }
    
    .cita-acciones {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }
    
    .btn-confirmar-grande {
        background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
        color: white;
        padding: 12px 30px;
        border: none;
        border-radius: 10px;
        font-weight: 600;
        font-size: 1rem;
        box-shadow: 0 4px 15px rgba(39, 174, 96, 0.3);
        transition: all 0.3s;
    }
    
    .btn-confirmar-grande:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(39, 174, 96, 0.4);
        color: white;
    }
    
    .btn-whatsapp {
        background: #25D366;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 8px;
        font-weight: 600;
    }
    
    .btn-whatsapp:hover {
        background: #128C7E;
        color: white;
    }
    
    /* Calendario FullCalendar personalizado */
    .fc-event {
        border-radius: 5px;
        padding: 5px;
        cursor: pointer;
    }
    
    .fc-event.pendiente { background: #f39c12; border-color: #f39c12; }
    .fc-event.confirmado { background: #27ae60; border-color: #27ae60; }
    .fc-event.cancelado { background: #e74c3c; border-color: #e74c3c; }
    
    /* Filtros */
    .filtros-container {
        background: white;
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    .contador-estados {
        display: flex;
        gap: 20px;
        margin-bottom: 20px;
    }
    
    .contador-card {
        flex: 1;
        padding: 20px;
        border-radius: 10px;
        text-align: center;
        color: white;
        box-shadow: 0 3px 10px rgba(0,0,0,0.2);
    }
    
    .contador-card.pendiente { background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%); }
    .contador-card.confirmado { background: linear-gradient(135deg, #27ae60 0%, #229954 100%); }
    .contador-card.finalizado { background: linear-gradient(135deg, #9b59b6 0%, #8e44ad 100%); }
    .contador-card.cancelado { background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%); }
    
    .contador-numero {
        font-size: 2.5rem;
        font-weight: bold;
        margin-bottom: 5px;
    }
    
    .contador-texto {
        font-size: 0.9rem;
        opacity: 0.9;
    }
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
    /* ========================================
   OVERLAY OSCURO PARA TODAS LAS PÁGINAS
   Agregar este código en el <style> de header.jsp
   ======================================== */

/* Overlay para oscurecer la imagen y mejorar legibilidad */
.content-wrapper::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5); /* 0.6 = 60% de oscuridad */
    z-index: 0;
}

/* Contenido por encima del overlay */
.content-wrapper > * {
    position: relative;
    z-index: 1;
}

/* Asegurar que los modales estén por encima de todo */
.modal {
    z-index: 9999 !important;
}

.modal-backdrop {
    z-index: 9998 !important;
}

/* Mejorar legibilidad de textos sobre la imagen */
.content-header h1,
.content-header h3,
.content-header .breadcrumb {
    color: #fff !important;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.8);
}

.breadcrumb-item a {
    color: #fff !important;
}

.breadcrumb-item.active {
    color: rgba(255, 255, 255, 0.8) !important;
}

/* Mejorar contraste de las tablas */
.table {
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
}

/* Botones más visibles */
.btn {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}
</style>

<div class="content-wrapper">
    <section class="content" style="padding: 20px;">
        
        <!-- Header con notificaciones -->
        <div class="citas-header">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h2 class="mb-0">
                        <i class="fas fa-calendar-alt"></i> Gestión de Citas
                    </h2>
                    <p class="mb-0 mt-2" style="opacity: 0.9;">Administra y confirma las reservas de tus clientes</p>
                </div>
                <div class="col-md-6 text-right">
                    <div class="notificaciones-badge d-inline-block mr-3">
                        <i class="fas fa-bell fa-2x"></i>
                        <span class="badge-notif" id="badgePendientes">0</span>
                    </div>
                    <a href="registro_agendamiento.jsp" class="btn btn-light btn-lg">
                        <i class="fas fa-plus"></i> Nueva Cita
                    </a>
                </div>
            </div>
        </div>
        
        <% if ("true".equals(citaCreada)) { %>
        <div class="alert alert-success alert-dismissible">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="fas fa-check-circle"></i> <strong>¡Éxito!</strong> Cita registrada correctamente.
        </div>
        <% } %>
        
        <!-- Contadores de estado -->
        <div class="contador-estados">
            <div class="contador-card pendiente">
                <div class="contador-numero" id="contadorPendientes">0</div>
                <div class="contador-texto">PENDIENTES</div>
            </div>
            <div class="contador-card confirmado">
                <div class="contador-numero" id="contadorConfirmadas">0</div>
                <div class="contador-texto">CONFIRMADAS</div>
            </div>
            <div class="contador-card finalizado">
                <div class="contador-numero" id="contadorFinalizadas">0</div>
                <div class="contador-texto">FINALIZADAS</div>
            </div>
            <div class="contador-card cancelado">
                <div class="contador-numero" id="contadorCanceladas">0</div>
                <div class="contador-texto">CANCELADAS</div>
            </div>
        </div>
        
        <!-- Pestañas de vista -->
        <div class="vista-tabs">
            <ul class="nav nav-tabs" id="vistaTabs" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" id="lista-tab" data-toggle="tab" href="#vistaLista" role="tab">
                        <i class="fas fa-list"></i> Lista
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="calendario-tab" data-toggle="tab" href="#vistaCalendario" role="tab">
                        <i class="fas fa-calendar"></i> Calendario
                    </a>
                </li>
            </ul>
        </div>
        
        <!-- Filtros -->
        <div class="filtros-container">
            <div class="row align-items-end">
                <div class="col-md-4">
                    <label><i class="fas fa-calendar-day"></i> Desde</label>
                    <input type="date" class="form-control" id="filtro_desde" value="<%=fechaFormateada%>">
                </div>
                <div class="col-md-4">
                    <label><i class="fas fa-calendar-day"></i> Hasta</label>
                    <input type="date" class="form-control" id="filtro_hasta" value="<%=fechaFormateada%>">
                </div>
                <div class="col-md-2">
                    <label><i class="fas fa-filter"></i> Estado</label>
                    <select class="form-control" id="filtro_estado">
                        <option value="">Todos</option>
                        <option value="pendiente">Pendientes</option>
                        <option value="confirmado">Confirmadas</option>
                        <option value="finalizado">Finalizadas</option>
                        <option value="cancelado">Canceladas</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button class="btn btn-primary btn-block" id="btnFiltrar">
                        <i class="fas fa-search"></i> Filtrar
                    </button>
                </div>
            </div>
        </div>
        
        <!-- Contenido de las pestañas -->
        <div class="tab-content" id="vistaTabsContent">
            
            <!-- Vista Lista -->
            <div class="tab-pane fade show active" id="vistaLista" role="tabpanel">
                <div id="listaCitas">
                    <div class="text-center py-5">
                        <div class="spinner-border text-primary" role="status"></div>
                        <p class="mt-3">Cargando citas...</p>
                    </div>
                </div>
            </div>
            
            <!-- Vista Calendario -->
            <div class="tab-pane fade" id="vistaCalendario" role="tabpanel">
                <div style="background: white; padding: 20px; border-radius: 10px;">
                    <div id="calendar"></div>
                </div>
            </div>
        </div>
        
    </section>
</div>

<!-- Modal Confirmar Cita -->
<div class="modal fade" id="modalConfirmar" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 15px;">
            <div class="modal-header" style="background: linear-gradient(135deg, #27ae60 0%, #229954 100%); color: white; border-radius: 15px 15px 0 0;">
                <h5 class="modal-title"><i class="fas fa-check-circle"></i> Confirmar Cita</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="text-center mb-3">
                    <i class="fas fa-calendar-check fa-4x" style="color: #27ae60;"></i>
                </div>
                <h5 class="text-center mb-3">¿Confirmar esta cita?</h5>
                <div id="resumenConfirmar"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-success" id="btnConfirmarCita">
                    <i class="fas fa-check"></i> Sí, Confirmar
                </button>
            </div>
        </div>
    </div>
</div>

<!-- FullCalendar JS -->
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/locales/es.js'></script>
<script src="script/listado_citas.js"></script>

<%@ include file="footer.jsp" %>
