<%@ include file="conexion.jsp" %>
<%@ include file="header.jsp" %>
<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h3 class="text-white fw-bold">HORARIOS DE PROFESIONALES</h3>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active text-white fw-bold">Horarios de Profesionales</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>

    <div class="content">
        <div class="container-fluid">
            <div class="card">
                <div class="card-header">
                    <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#modalAgregarHorario">
                        Agregar Horario a Profesional
                    </button>
                </div>
                <div class="card-body">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Profesional</th>
                                <th>Dia</th>
                                <th>Horario</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tablaHorariosProfesionales">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalAgregarHorario">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Agregar Horario a Profesional</h5>
                <button type="button" class="close" data-dismiss="modal">x</button>
            </div>
            <div class="modal-body">
                <form id="formHorarioProfesional">
                    <div class="form-group">
                        <label>Profesional</label>
                        <select class="form-control" id="selectProfesional" name="id_profesional" required>
                            <option value="">Seleccione...</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Dia de la semana</label>
                        <select class="form-control" id="selectDia" name="dia_semana" required>
                            <option value="">Seleccione...</option>
                            <option value="2">Lunes</option>
                            <option value="3">Martes</option>
                            <option value="4">Miercoles</option>
                            <option value="5">Jueves</option>
                            <option value="6">Viernes</option>
                            <option value="7">Sabado</option>
                            <option value="1">Domingo</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Horario</label>
                        <select class="form-control" id="selectHorario" name="id_horario" required>
                            <option value="">Seleccione...</option>
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="button" class="btn btn-primary" id="btnGuardarHorario">Guardar</button>
            </div>
        </div>
    </div>
</div>

<!-- INCLUIR EL SCRIPT SEPARADO -->
<script src="script/horarios_profesionales.js"></script>

<%@ include file="footer.jsp" %>