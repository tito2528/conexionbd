// ===================== CONFIGURACIÓN =====================
// Cambia las URLs según tus controladores JSP
const URL_SERVICIOS = 'Controlador_servicio.jsp?accion=listarActivos';
const URL_PROFESIONALES = 'Controlador_profesional.jsp?accion=listarPorServicio';
const URL_HORARIOS = 'Controlador_horario.jsp?accion=listarDisponibles';
const URL_REGISTRO = 'Controlador_cliente.jsp?accion=registrar';
const URL_LOGIN = 'Controlador_usuario.jsp?accion=loginCliente';
const URL_AGENDAR = 'Controlador_agendamiento.jsp?accion=agendarCliente';

// ===================== UTILIDADES =====================
function mostrarMensaje(mensaje, tipo = 'success') {
    const alert = document.createElement('div');
    alert.className = `alert alert-${tipo} alert-dismissible fade show position-fixed top-0 end-0 m-3`;
    alert.style.zIndex = 9999;
    alert.innerHTML = `
        ${mensaje}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    document.body.appendChild(alert);
    setTimeout(() => alert.remove(), 4000);
}

function setSesionCliente(cliente) {
    localStorage.setItem('cliente', JSON.stringify(cliente));
    document.getElementById('logoutBtn').classList.remove('d-none');
    document.getElementById('agendamientoSection').classList.remove('d-none');
    document.querySelectorAll('[data-bs-target="#loginModal"], [data-bs-target="#registerModal"]').forEach(btn => btn.classList.add('d-none'));
}

function limpiarSesionCliente() {
    localStorage.removeItem('cliente');
    document.getElementById('logoutBtn').classList.add('d-none');
    document.getElementById('agendamientoSection').classList.add('d-none');
    document.querySelectorAll('[data-bs-target="#loginModal"], [data-bs-target="#registerModal"]').forEach(btn => btn.classList.remove('d-none'));
}

// ===================== CARGA DE SERVICIOS =====================
function cargarServicios() {
    fetch(URL_SERVICIOS)
        .then(res => res.json())
        .then(servicios => {
            const cont = document.getElementById('serviciosContainer');
            const select = document.getElementById('servicioSelect');
            cont.innerHTML = '';
            select.innerHTML = '<option value="">Seleccione un servicio</option>';
            servicios.forEach(servicio => {
                // Tarjeta visual
                cont.innerHTML += `
                    <div class="col-md-4 mb-4">
                        <div class="card service-card h-100">
                            <img src="${servicio.imagen || 'https://placehold.co/300x200'}" class="card-img-top" alt="${servicio.ser_nombre}">
                            <div class="card-body">
                                <h5 class="card-title">${servicio.ser_nombre}</h5>
                                <p class="card-text">${servicio.descripcion || ''}</p>
                                <p class="fw-bold text-primary">Gs. ${servicio.ser_precio}</p>
                                <button class="btn btn-outline-primary btn-sm" onclick="seleccionarServicio('${servicio.id_servicio}')">Agendar</button>
                            </div>
                        </div>
                    </div>
                `;
                // Opción en el select
                select.innerHTML += `<option value="${servicio.id_servicio}">${servicio.ser_nombre}</option>`;
            });
        })
        .catch(() => mostrarMensaje('Error al cargar servicios', 'danger'));
}

// ===================== SELECCIÓN DE SERVICIO =====================
window.seleccionarServicio = function(idServicio) {
    document.getElementById('servicioSelect').value = idServicio;
    document.getElementById('agendamientoSection').scrollIntoView({ behavior: 'smooth' });
    cargarProfesionales(idServicio);
};

// ===================== CARGA DE PROFESIONALES =====================
function cargarProfesionales(idServicio) {
    fetch(`${URL_PROFESIONALES}&id_servicio=${idServicio}`)
        .then(res => res.json())
        .then(profesionales => {
            const select = document.getElementById('profesionalSelect');
            select.innerHTML = '<option value="">Seleccione un profesional</option>';
            profesionales.forEach(prof => {
                select.innerHTML += `<option value="${prof.id_profesional}">${prof.prof_nombre} ${prof.prof_apellido}</option>`;
            });
        })
        .catch(() => mostrarMensaje('Error al cargar profesionales', 'danger'));
}

// ===================== CARGA DE HORARIOS =====================
function cargarHorarios() {
    const idProfesional = document.getElementById('profesionalSelect').value;
    const fecha = document.getElementById('fechaInput').value;
    if (!idProfesional || !fecha) return;
    fetch(`${URL_HORARIOS}&id_profesional=${idProfesional}&fecha=${fecha}`)
        .then(res => res.json())
        .then(horarios => {
            const select = document.getElementById('horarioSelect');
            select.innerHTML = '<option value="">Seleccione un horario</option>';
            horarios.forEach(hor => {
                select.innerHTML += `<option value="${hor.id_horario}">${hor.hora_inicio} - ${hor.hora_fin}</option>`;
            });
        })
        .catch(() => mostrarMensaje('Error al cargar horarios', 'danger'));
}

// ===================== REGISTRO DE CLIENTE =====================
document.getElementById('registerForm').addEventListener('submit', function(e) {
    e.preventDefault();
    const data = {
        cli_nombre: document.getElementById('regNombre').value,
        cli_apellido: document.getElementById('regApellido').value,
        cli_email: document.getElementById('regEmail').value,
        cli_telefono: document.getElementById('regTelefono').value,
        password: document.getElementById('regPassword').value
    };
    fetch(URL_REGISTRO, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(resp => {
        if (resp.exito) {
            mostrarMensaje('¡Registro exitoso! Ahora puedes iniciar sesión.');
            bootstrap.Modal.getOrCreateInstance(document.getElementById('registerModal')).hide();
        } else {
            mostrarMensaje(resp.mensaje || 'Error en el registro', 'danger');
        }
    })
    .catch(() => mostrarMensaje('Error en el registro', 'danger'));
});

// ===================== LOGIN DE CLIENTE =====================
document.getElementById('loginForm').addEventListener('submit', function(e) {
    e.preventDefault();
    const data = {
        email: document.getElementById('loginEmail').value,
        password: document.getElementById('loginPassword').value
    };
    fetch(URL_LOGIN, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(resp => {
        if (resp.exito && resp.cliente) {
            setSesionCliente(resp.cliente);
            mostrarMensaje('¡Bienvenido!');
            bootstrap.Modal.getOrCreateInstance(document.getElementById('loginModal')).hide();
        } else {
            mostrarMensaje(resp.mensaje || 'Credenciales incorrectas', 'danger');
        }
    })
    .catch(() => mostrarMensaje('Error al iniciar sesión', 'danger'));
});

// ===================== LOGOUT =====================
document.getElementById('logoutBtn').addEventListener('click', function() {
    limpiarSesionCliente();
    mostrarMensaje('Sesión cerrada');
});

// ===================== AGENDAMIENTO DE CITA =====================
document.getElementById('agendarForm').addEventListener('submit', function(e) {
    e.preventDefault();
    const cliente = JSON.parse(localStorage.getItem('cliente'));
    if (!cliente) {
        mostrarMensaje('Debes iniciar sesión para agendar', 'danger');
        return;
    }
    const data = {
        id_cliente: cliente.id_cliente,
        id_servicio: document.getElementById('servicioSelect').value,
        id_profesional: document.getElementById('profesionalSelect').value,
        fecha: document.getElementById('fechaInput').value,
        id_horario: document.getElementById('horarioSelect').value,
        observaciones: document.getElementById('observacionesInput').value
    };
    fetch(URL_AGENDAR, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(resp => {
        if (resp.exito) {
            mostrarMensaje('¡Cita agendada con éxito!');
            document.getElementById('agendarForm').reset();
        } else {
            mostrarMensaje(resp.mensaje || 'No se pudo agendar la cita', 'danger');
        }
    })
    .catch(() => mostrarMensaje('Error al agendar la cita', 'danger'));
});

// ===================== EVENTOS DE SELECTS =====================
document.getElementById('servicioSelect').addEventListener('change', function() {
    cargarProfesionales(this.value);
});
document.getElementById('profesionalSelect').addEventListener('change', cargarHorarios);
document.getElementById('fechaInput').addEventListener('change', cargarHorarios);

// ===================== INICIALIZACIÓN =====================
window.addEventListener('DOMContentLoaded', function() {
    cargarServicios();
    // Si hay sesión, mostrar agendamiento
    if (localStorage.getItem('cliente')) {
        setSesionCliente(JSON.parse(localStorage.getItem('cliente')));
    } else {
        limpiarSesionCliente();
    }
});