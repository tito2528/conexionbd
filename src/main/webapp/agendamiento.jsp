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
        <h3>Agendamiento de Citas</h3>
        <div class="row">
            <!-- Sección de registro de cita -->
            <div class="col-md-5">
                <form id="formAgendamiento" class="form-horizontal" autocomplete="off">
                    <input type="hidden" name="accion" value="registrarCita">
                    <div class="card" style="padding: 20px; margin-bottom: 20px;">
                        <h4>Datos de la Cita</h4>
                        <div class="form-group">
                            <label>Cliente</label>
                            <div class="input-group">
                                <select class="form-control" id="id_cliente" name="id_cliente" style="width:85%" required>
                                    <option value="">Seleccione...</option>
                                </select>
                                <span class="input-group-btn" style="width:15%">
                                    <button class="btn btn-info" type="button" id="btnBuscarCliente" title="Buscar cliente">
                                        <span class="fa fa-search"></span>
                                    </button>
                                </span>
                            </div>
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
                                <div id="resultados_clientes" style="margin-top:10px; max-height:300px; overflow:auto; border: 1px solid #ddd; padding: 10px; border-radius: 4px;"></div>
                              </div>
                              <div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
                              </div>
                            </div>
                          </div>
                        </div>
                        <div class="form-group">
                            <label>Servicio</label>
                            <select class="form-control" name="id_servicio" id="id_servicio" required>
                                <option value="">Seleccione...</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Profesional</label>
                            <select class="form-control" name="id_profesional" id="id_profesional" required>
                                <option value="">Seleccione un servicio primero</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Sucursal</label>
                            <input type="text" class="form-control" id="sucursal_nombre" readonly>
                            <input type="hidden" id="id_sucursal" name="id_sucursal">
                        </div>
                        <div class="form-group">
                            <label>Fecha</label>
                            <input type="date" class="form-control" name="age_fecha" id="age_fecha" value="<%=fechaFormateada%>" min="<%=fechaFormateada%>" required>
                        </div>
                        <div class="form-group">
                            <label>Horario</label>
                            <select class="form-control" name="id_horario" id="id_horario" required>
                                <option value="">Seleccione...</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Estado</label>
                            <select class="form-control" name="estado" id="estado" required>
                                <option value="pendiente">Pendiente</option>
                                <option value="confirmado">Confirmado</option>
                                <option value="cancelado">Cancelado</option>
                            </select>
                        </div>
                        <div id="respuesta" style="margin-bottom: 10px;"></div>
                        <div class="form-group" style="text-align: right;">
                            <button type="button" id="btnRegistrar" class="btn btn-success">
                                <span class="fa fa-save"></span> Registrar Cita
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            <!-- Sección de listado de citas -->
            <div class="col-md-7">
                <div class="card" style="padding: 20px;">
                    <h4>Citas</h4>
                    <div class="form-group row">
                        <div class="col-md-5">
                            <label>Desde</label>
                            <input type="date" class="form-control" id="filtro_desde" value="<%=fechaFormateada%>" min="<%=fechaFormateada%>">
                        </div>
                        <div class="col-md-5">
                            <label>Hasta</label>
                            <input type="date" class="form-control" id="filtro_hasta" value="<%=fechaFormateada%>" min="<%=fechaFormateada%>" style="width: 100%">
                        </div>
                        <div class="col-md-2" style="padding-top: 25px;">
                            <button class="btn btn-info" id="btnFiltrar"><span class="fa fa-search"></span> Filtrar</button>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped" id="tablaCitas">
                            <thead>
                                <tr>
                                    <th>Cliente</th>
                                    <th>Profesional</th>
                                    <th>Servicio</th>
                                    <th>Sucursal</th>
                                    <th>Fecha y Hora</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody id="tbodyCitas"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="script/agendamiento.js"></script>
<%@ include file="footer.jsp" %>