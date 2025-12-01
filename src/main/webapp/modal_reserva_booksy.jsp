<!-- MODAL DE RESERVA MODIFICADO (Empieza en Paso 2 - Profesionales) -->
<div class="modal fade" id="modalReserva" tabindex="-1" data-bs-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="border-radius: 20px; border: none; background-color: #2a2a2a; color: #ffffff;">
            <div class="modal-header" style="background: linear-gradient(135deg, #e60026 0%, #cc001f 100%); color: white; border-radius: 20px 20px 0 0; padding: 25px; border-bottom: none;">
                <div>
                    <h5 class="modal-title mb-1"><i class="fas fa-calendar-check"></i> Reservar Cita</h5>
                    <small id="tituloServicio" style="opacity: 0.9;"></small>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" style="padding: 30px; max-height: 70vh; overflow-y: auto; background-color: #2a2a2a;">
                
                <!-- PASO 2: Seleccionar Profesional -->
                <div id="paso2" class="paso-reserva">
                    <h6 class="mb-3 fw-bold" style="color: #ffffff;">
                        <span class="badge bg-danger me-2">1</span> Selecciona el profesional
                    </h6>
                    
                    <!-- Opción "Cualquiera" -->
                    <div class="mb-3">
                        <div class="card profesional-card-cualquiera" onclick="seleccionarProfesional(0, 'Cualquiera', 0, 'Cualquiera')" style="cursor: pointer; border: 2px solid #444444; border-radius: 12px; transition: all 0.3s; background-color: #1a1a1a;">
                            <div class="card-body text-center py-4">
                                <i class="fas fa-users fa-3x mb-2" style="color: #e60026;"></i>
                                <h5 class="mb-1" style="color: #ffffff;">Cualquier profesional</h5>
                                <p class="text-muted mb-0">El primer profesional disponible</p>
                            </div>
                        </div>
                    </div>

                    <p class="text-muted mb-2"><small>O elige un profesional específico:</small></p>
                    
                    <div class="row" id="profesionalesModal">
                        <!-- Se carga dinámicamente -->
                    </div>
                </div>

                <!-- PASO 3: Seleccionar Fecha y Hora -->
                <div id="paso3" class="paso-reserva" style="display: none;">
                    <button class="btn btn-link text-decoration-none mb-3 p-0" onclick="volverPaso(2)" style="color: #e60026;">
                        <i class="fas fa-arrow-left"></i> Volver
                    </button>
                    
                    <h6 class="mb-3 fw-bold" style="color: #ffffff;">
                        <span class="badge bg-danger me-2">2</span> Selecciona fecha y horario
                    </h6>

                    <!-- Info del profesional seleccionado -->
                    <div class="alert mb-3" style="background: #1a1a1a; border: 1px solid #e60026; border-radius: 10px; color: #ffffff;">
                        <small>
                            <i class="fas fa-user text-danger"></i> <strong>Profesional:</strong> <span id="infoProfesional"></span>
                        </small>
                    </div>
                    
                    <!-- Selector de Fecha tipo Booksy -->
                    <div class="mb-4">
                        <label class="form-label fw-bold" style="color: #ffffff;">Selecciona una fecha:</label>
                        <div id="calendarioSemana" class="d-flex gap-2 overflow-auto pb-2" style="white-space: nowrap;">
                            <!-- Se genera dinámicamente con JavaScript -->
                        </div>
                    </div>

                    <!-- Horarios Disponibles -->
                    <div class="mb-3">
                        <label class="form-label fw-bold" style="color: #ffffff;">Horarios disponibles:</label>
                        <div id="horariosDisponibles" class="d-flex flex-wrap gap-2">
                            <div class="text-muted">Selecciona una fecha para ver horarios</div>
                        </div>
                    </div>
                </div>

                <!-- PASO 4: Datos del Cliente (solo si NO hay sesión) -->
                <div id="paso4" class="paso-reserva" style="display: none;">
                    <button class="btn btn-link text-decoration-none mb-3 p-0" onclick="volverPaso(3)" style="color: #e60026;">
                        <i class="fas fa-arrow-left"></i> Volver
                    </button>
                    
                    <h6 class="mb-3 fw-bold" style="color: #ffffff;">
                        <span class="badge bg-danger me-2">3</span> Completa tus datos
                    </h6>
                    
                    <form id="formDatosCliente">
                        <div class="row">
                            <!-- FILA 1: Nombre y Apellido -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label" style="color: #ffffff;"><i class="fas fa-user"></i> Nombre *</label>
                                <input type="text" class="form-control" id="nombreCliente" required 
                                       style="border-radius: 10px; background-color: #1a1a1a; color: #ffffff; border: 1px solid #444444;" placeholder="Juan">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label" style="color: #ffffff;"><i class="fas fa-user"></i> Apellido *</label>
                                <input type="text" class="form-control" id="apellidoCliente" required 
                                       style="border-radius: 10px; background-color: #1a1a1a; color: #ffffff; border: 1px solid #444444;" placeholder="Pérez">
                            </div>
                            
                            <!-- FILA 2: CI/RUC y Teléfono -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label" style="color: #ffffff;"><i class="fas fa-id-card"></i> CI/RUC *</label>
                                <input type="text" class="form-control" id="ciCliente" required 
                                       style="border-radius: 10px; background-color: #1a1a1a; color: #ffffff; border: 1px solid #444444;" placeholder="1234567-8" maxlength="20">
                                <small class="text-muted">Cedula de identidad o RUC</small>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label" style="color: #ffffff;"><i class="fas fa-phone"></i> Teléfono *</label>
                                <input type="tel" class="form-control" id="telefonoCliente" required 
                                       style="border-radius: 10px; background-color: #1a1a1a; color: #ffffff; border: 1px solid #444444;" placeholder="0981-123456" maxlength="15">
                            </div>
                            
                            <!-- FILA 3: Email -->
                            <div class="col-md-12 mb-3">
                                <label class="form-label" style="color: #ffffff;"><i class="fas fa-envelope"></i> Email</label>
                                <input type="email" class="form-control" id="emailCliente" 
                                       style="border-radius: 10px; background-color: #1a1a1a; color: #ffffff; border: 1px solid #444444;" placeholder="juan@ejemplo.com">
                                <small class="text-muted">Opcional</small>
                            </div>
                        </div>
                        
                        <!-- Nota informativa -->
                        <div class="alert" style="border-radius: 10px; background: #1a1a1a; border: 1px solid #e60026; color: #ffffff;">
                            <small><i class="fas fa-info-circle"></i> Los campos marcados con (*) son obligatorios</small>
                        </div>
                    </form>

                    <!-- Resumen -->
                    <div class="alert" style="border-radius: 15px; background: #1a1a1a; border: 2px solid #444444; color: #ffffff;">
                        <h6 style="color: #e60026; font-weight: 600;">
                            <i class="fas fa-clipboard-list"></i> Resumen de tu reserva
                        </h6>
                        <hr style="border-color: #444444;">
                        <p class="mb-2"><i class="fas fa-cut text-danger"></i> <strong>Servicio:</strong> <span id="resumenServicio"></span></p>
                        <p class="mb-2"><i class="fas fa-user text-info"></i> <strong>Profesional:</strong> <span id="resumenProfesional"></span></p>
                        <p class="mb-2"><i class="fas fa-calendar text-warning"></i> <strong>Fecha:</strong> <span id="resumenFecha"></span></p>
                        <p class="mb-2"><i class="fas fa-clock text-info"></i> <strong>Hora:</strong> <span id="resumenHora"></span></p>
                        <p class="mb-0"><i class="fas fa-money-bill-wave text-success"></i> <strong>Precio:</strong> <span id="resumenPrecio"></span></p>
                    </div>
                </div>

                <!-- PASO 5: Confirmación (si HAY sesión) -->
                <div id="paso5" class="paso-reserva" style="display: none;">
                    <button class="btn btn-link text-decoration-none mb-3 p-0" onclick="volverPaso(3)" style="color: #e60026;">
                        <i class="fas fa-arrow-left"></i> Volver
                    </button>
                    
                    <div class="text-center py-4">
                        <i class="fas fa-check-circle fa-5x mb-3" style="color: #27ae60;"></i>
                        <h5 class="mb-3" style="color: #ffffff;">�Todo listo para confirmar!</h5>
                        
                        <!-- Resumen final -->
                        <div class="alert text-start" style="border-radius: 15px; background: #1a1a1a; border: 2px solid #444444; color: #ffffff;">
                            <h6 style="color: #e60026; font-weight: 600;">
                                <i class="fas fa-clipboard-list"></i> Resumen de tu reserva
                            </h6>
                            <hr style="border-color: #444444;">
                            <p class="mb-2"><i class="fas fa-cut text-danger"></i> <strong>Servicio:</strong> <span id="resumenServicio2"></span></p>
                            <p class="mb-2"><i class="fas fa-user text-info"></i> <strong>Profesional:</strong> <span id="resumenProfesional2"></span></p>
                            <p class="mb-2"><i class="fas fa-calendar text-warning"></i> <strong>Fecha:</strong> <span id="resumenFecha2"></span></p>
                            <p class="mb-2"><i class="fas fa-clock text-info"></i> <strong>Hora:</strong> <span id="resumenHora2"></span></p>
                            <p class="mb-0"><i class="fas fa-money-bill-wave text-success"></i> <strong>Precio:</strong> <span id="resumenPrecio2"></span></p>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="modal-footer" style="border: none; padding: 20px 30px; background-color: #2a2a2a;">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="border-radius: 10px; background-color: #666666; border: none;">
                    Cancelar
                </button>
                <button type="button" class="btn btn-primary" id="btnContinuar" style="border-radius: 10px; background: #e60026; border: none; display: none;">
                    <i class="fas fa-arrow-right"></i> Continuar
                </button>
                <button type="button" class="btn btn-success" id="btnConfirmarReserva" style="border-radius: 10px; background: #27ae60; border: none; display: none;">
                    <i class="fas fa-check"></i> Confirmar Reserva
                </button>
            </div>
        </div>
    </div>
</div>

<style>
/* Estilos del modal dark */
.servicio-card-modal {
    border: 2px solid #444444;
    border-radius: 15px;
    padding: 20px;
    cursor: pointer;
    transition: all 0.3s;
    text-align: center;
    height: 100%;
    background-color: #1a1a1a;
    color: #ffffff;
}

.servicio-card-modal:hover {
    border-color: #e60026;
    transform: translateY(-3px);
    box-shadow: 0 5px 15px rgba(230, 0, 38, 0.4);
}

.servicio-card-modal.selected {
    border-color: #e60026;
    background: rgba(230, 0, 38, 0.1);
    box-shadow: 0 5px 15px rgba(230, 0, 38, 0.5);
}

.profesional-card-cualquiera:hover {
    border-color: #e60026 !important;
    box-shadow: 0 5px 15px rgba(230, 0, 38, 0.3);
}

.profesional-card-cualquiera.selected {
    border-color: #e60026 !important;
    background: rgba(230, 0, 38, 0.1) !important;
}

/* Días de la semana */
.dia-semana-btn {
    min-width: 80px;
    padding: 15px 10px;
    border: 2px solid #444444;
    border-radius: 12px;
    background: #1a1a1a;
    cursor: pointer;
    transition: all 0.3s;
    text-align: center;
    color: #ffffff;
}

.dia-semana-btn:hover {
    border-color: #e60026;
    background: rgba(230, 0, 38, 0.1);
}

.dia-semana-btn.selected {
    border-color: #e60026;
    background: #e60026;
    color: white;
}

.dia-semana-btn .dia-nombre {
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
    display: block;
    margin-bottom: 5px;
}

.dia-semana-btn .dia-numero {
    font-size: 1.5rem;
    font-weight: bold;
    display: block;
}

/* Botones de horario */
.horario-btn {
    padding: 12px 20px;
    border: 2px solid #444444;
    border-radius: 10px;
    background: #1a1a1a;
    cursor: pointer;
    transition: all 0.3s;
    font-weight: 600;
    font-size: 0.95rem;
    color: #ffffff;
}

.horario-btn:hover {
    border-color: #e60026;
    background: rgba(230, 0, 38, 0.1);
}

.horario-btn.selected {
    border-color: #e60026;
    background: #e60026;
    color: white;
}

.horario-btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    background: #0a0a0a;
}

/* Campos del formulario */
.form-control:focus {
    background-color: #1a1a1a !important;
    color: #ffffff !important;
    border-color: #e60026 !important;
    box-shadow: 0 0 0 0.2rem rgba(230, 0, 38, 0.25) !important;
}

.form-control::placeholder {
    color: #666666 !important;
}

/* Scroll suave */
#calendarioSemana::-webkit-scrollbar {
    height: 6px;
}

#calendarioSemana::-webkit-scrollbar-track {
    background: #1a1a1a;
    border-radius: 10px;
}

#calendarioSemana::-webkit-scrollbar-thumb {
    background: #e60026;
    border-radius: 10px;
}
</style>
