<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="conexion.jsp" %>
<%@ include file="header.jsp" %>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    Date fechaActual = new Date();
    SimpleDateFormat formateadorFecha = new SimpleDateFormat("yyyy-MM-dd");
    String fechaFormateada = formateadorFecha.format(fechaActual);
%>
<div class="content-wrapper">
    <section class="content">
        <h3 class="text-white fw-bold">Registro de Agendamiento</h3>
        <div class="row">
            <!-- Columna izquierda - Datos de la cita -->
            <div class="col-lg-4">
                <div class="card" style="padding: 20px; margin-bottom: 20px;">
                    <h4>Datos de la Cita</h4>
                    <form id="formAgendamiento" autocomplete="off">
                        <div class="form-group">
                            <label>Cliente</label>
                            <div class="input-group">
                                <select class="form-control" id="id_cliente" name="id_cliente" required>
                                    <option value="">Seleccione...</option>
                                </select>
                                <span class="input-group-btn">
                                    <button class="btn btn-info" type="button" id="btnBuscarCliente" title="Buscar cliente">
                                        <span class="fa fa-search"></span>
                                    </button>
                                </span>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Fecha</label>
                            <input type="date" class="form-control" name="age_fecha" id="age_fecha" 
                                   value="<%=fechaFormateada%>" min="<%=fechaFormateada%>" required>
                        </div>

                        <div class="form-group">
                            <label>Horario</label>
                            <select class="form-control" name="id_horario" id="id_horario" required>
                                <option value="">Seleccione...</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Sucursal</label>
                            <input type="text" class="form-control" id="sucursal_nombre" readonly>
                            <input type="hidden" id="id_sucursal" name="id_sucursal">
                        </div>

                        <div class="form-group">
                            <label>Estado</label>
                            <select class="form-control" name="estado" id="estado" required>
                                <option value="pendiente">Pendiente</option>
                                <option value="confirmado">Confirmado</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Observaciones</label>
                            <textarea class="form-control" name="observaciones" id="observaciones" 
                                     placeholder="Opcional - Escriba observaciones sobre la cita" 
                                     rows="3"></textarea>
                            <small class="text-muted">Dejar vacío si no hay observaciones</small>
                        </div>

                        <div id="respuesta" style="margin-bottom: 10px;"></div>

                        <div class="form-group" style="text-align: center;">
                            <button type="button" id="btnRegistrarCita" class="btn btn-success btn-lg">
                                <span class="fa fa-save"></span> Guardar Cita
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Columna derecha - Detalle de servicios -->
            <div class="col-lg-8">
                <div class="panel panel-border panel-primary">
                    <div class="panel-heading">
                        <h4><i class="fa fa-list"></i> <strong>Detalle de Servicios</strong></h4>
                    </div>
                    <div class="panel-body">
                        <!-- Formulario para agregar servicios -->
                        <div class="row" style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 15px;">
                            <div class="col-md-5">
                                <div class="form-group">
                                    <label>Servicio</label>
                                    <select class="form-control" id="id_servicio">
                                        <option value="">Seleccione...</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <label>Precio</label>
                                    <input type="text" class="form-control" id="precio_servicio" readonly>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Profesional</label>
                                    <select class="form-control" id="id_profesional">
                                        <option value="">Seleccione servicio primero</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-12">
                                <button type="button" id="btnAgregarServicio" class="btn btn-primary">
                                    <span class="fa fa-plus"></span> Agregar Servicio
                                </button>
                            </div>
                        </div>

                        <!-- Tabla de servicios agregados -->
                        <div class="table-responsive">
                            <table class="table table-striped table-bordered">
                                <thead>
                                    <tr>
                                        <th>Acción</th>
                                        <th>Servicio</th>
                                        <th>Precio</th>
                                        <th>Profesional</th>
                                        <th>Horario</th>
                                    </tr>
                                </thead>
                                <tbody id="detalle-servicios">
                                    <tr id="sin-servicios">
                                        <td colspan="5" class="text-center text-muted">No hay servicios agregados</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>

<!-- Modal de búsqueda de cliente -->
<div class="modal fade" id="modalBuscarCliente" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">Buscar Cliente</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <input type="text" id="busqueda_cliente" class="form-control" placeholder="Nombre, apellido o CI">
                </div>
                <div id="resultados_clientes" style="max-height:300px; overflow:auto; border: 1px solid #ddd; padding: 10px; border-radius: 4px;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="script/registro_agendamiento.js"></script>
<%@ include file="footer.jsp" %>