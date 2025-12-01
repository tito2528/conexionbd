<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="conexion.jsp" %>
<%@ include file="header.jsp" %>
<%@page import="java.sql.*"%>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Date fechaActual = new Date();
    SimpleDateFormat formateadorFecha = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    String fechaFormateada = formateadorFecha.format(fechaActual);
%>
<%
    // Obtener observaciones de la cita si viene desde listado_citas
    String observaciones = "";
    String idAgendamientoParam = request.getParameter("id_agendamiento");
    
    if (idAgendamientoParam != null && !idAgendamientoParam.isEmpty()) {
        try {
            PreparedStatement psObs = conn.prepareStatement(
                "SELECT observaciones FROM agendamiento WHERE id_agendamiento = ?"
            );
            psObs.setInt(1, Integer.parseInt(idAgendamientoParam));
            ResultSet rsObs = psObs.executeQuery();
            
            if (rsObs.next()) {
                observaciones = rsObs.getString("observaciones");
                if (observaciones == null) observaciones = "";
            }
            
            rsObs.close();
            psObs.close();
        } catch (Exception e) {
            observaciones = "";
        }
    }
%>
<style>
/* Estilos simples para facturación - Igual que agendamiento */
.ds {
    background: rgba(255, 255, 255, 0.95);
    padding: 20px;
    border-radius: 5px;
    margin-bottom: 20px;
}

.panel {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 5px;
}

.panel-heading {
    background-color: #f8f9fa;
    padding: 15px;
    border-bottom: 1px solid #dee2e6;
}

.panel-body {
    background: rgba(255, 255, 255, 0.95);
    padding: 20px;
}

label {
    font-weight: 500;
    color: #333;
    margin-bottom: 5px;
}

.form-control {
    background: #fff;
    border: 1px solid #ced4da;
    color: #495057;
}

.form-control:focus {
    border-color: #80bdff;
    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.form-control[readonly] {
    background-color: #e9ecef;
}

.table {
    background: rgba(255, 255, 255, 0.95);
}

.table thead th {
    background-color: #f8f9fa;
    color: #495057;
    font-weight: 600;
    border-bottom: 2px solid #dee2e6;
}

.table tbody td {
    background: #fff;
    color: #495057;
}

#carritototal {
    background: rgba(255, 255, 255, 0.95);
    padding: 15px;
    margin-top: 15px;
}

#txtTotalFactura {
    font-size: 16px;
    font-weight: bold;
    text-align: right;
}
</style>
<div class="content-wrapper">
    <section class="content">
        <form action="#" id="form" enctype="multipart/form-data" method="POST" class="form-horizontal form-groups-bordered">
            <input type="hidden" id="listar" name="listar" value="cargar"/>
            <h3 class="text-white fw-bold">Facturación de Servicios</h3><br>
            <div class="row">
                <div class="col-lg-3 ds">
                    <h5>DATOS DE LA FACTURA</h5>
                    <div class="form-group">
                        <label>Número de Factura</label>
                        <input type="text" id="numero_factura" name="numero_factura" class="form-control" readonly />
                    </div>
                    <div class="form-group">
                        <label>Cliente</label>
                        <select class="form-control" name="id_cliente" id="id_cliente" required></select>
                    </div>
                    <div class="form-group">
                        <label>Cédula/RUC</label>
                        <input class="form-control" type="text" name="ci_cliente" id="ci_cliente" readonly>
                    </div>
                    <div class="form-group">
                        <label>Sucursal del Cliente</label>
                        <input class="form-control" type="text" name="sucursal_cliente" id="sucursal_cliente" readonly>
                    </div>
                    <div class="form-group">
                        <label>Fecha de Factura</label>
                        <input class="form-control" type="text" name="fact_fecha" id="fact_fecha" value="<%= fechaFormateada %>" readonly>
                    </div>
                    
                    <!-- MÉTODOS DE PAGO DIVIDIDOS -->
                    <div class="form-group">
                        <label>💳 Método de Pago 1</label>
                        <select class="form-control" name="id_metodo_pago" id="id_metodo_pago" required>
                            <option value="">Cargando...</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>💰 Monto Pago 1</label>
                        <input type="number" class="form-control" id="monto_pago_1" name="monto_pago_1" 
                               placeholder="0" min="0" step="1000" value="0">
                        <small class="text-muted">Dejar en 0 si paga todo con método 1</small>
                    </div>
                    
                    <div class="form-group">
                        <label>💳 Método de Pago 2 (Opcional)</label>
                        <select class="form-control" name="id_metodo_pago_2" id="id_metodo_pago_2">
                            <option value="">No usar segundo método</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>💰 Monto Pago 2</label>
                        <input type="number" class="form-control" id="monto_pago_2" name="monto_pago_2" 
                               placeholder="0" min="0" step="1000" value="0">
                        <small class="text-muted">Solo si usa 2 métodos de pago</small>
                    </div>
                    
                    <div class="form-group">
                        <label>Usuario</label>
                        <select class="form-control" name="id_usuario" id="id_usuario" required>
                            <option value="">Cargando...</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Sucursal</label>
                        <select class="form-control" name="id_sucursal" id="id_sucursal" required>
                            <option value="">Cargando...</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>📝 Observaciones de la Cita</label>
                        <textarea class="form-control" readonly 
                                  style="background-color: #f8f9fa; resize: none; min-height: 60px;"><%=observaciones%></textarea>
                        <small class="text-muted">Notas registradas al crear la cita</small>
                    </div>
                </div>
                <div class="col-lg-9">
                    <div class="panel panel-border panel-warning widget-s-1">
                        <div class="panel-heading">
                            <h4><i class="fa fa-archive"></i> <strong>Detalle De La Factura</strong></h4>
                        </div>
                        <div class="panel-body">
                            <div id="error"></div>
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>Servicio</label>
                                        <select class="form-control" name="id_servicio" id="id_servicio" required>
                                            <option value="">Cargando...</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="form-group">
                                        <label>Precio Unitario</label>
                                        <input class="form-control" type="text" name="precio_unitario" id="precio_unitario" readonly>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="form-group">
                                        <label>Cantidad</label>
                                        <input class="form-control number" value="1" type="number" name="cantidad" id="cantidad" min="1" max="100" required>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="form-group">
                                        <label>Profesional</label>
                                        <select class="form-control" name="id_profesional" id="id_profesional" required>
                                            <option value="">Cargando...</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-1">
                                    <div class="form-group">
                                        <label>&nbsp;</label>
                                        <button type="button" name="agregar" value="agregar" id="AgregaServicioFactura" class="btn btn-primary form-control">
                                            <span class="fa fa-plus"></span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div id="respuesta"></div>
                            <hr>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="table-responsive">
                                        <table class="table table-striped table-bordered dt-responsive nowrap" id="carrito">
                                            <thead>
                                                <tr>
                                                    <th>Acción</th>
                                                    <th>Servicio</th>
                                                    <th>Precio</th>
                                                    <th>Cantidad</th>
                                                    <th>Profesional</th>
                                                    <th>Subtotal</th>
                                                </tr>
                                            </thead>
                                            <tbody id="resultados"></tbody>
                                        </table>
                                        <table width="302" id="carritototal">
                                            <tr>
                                                <td><label>Total:</label></td>
                                                <td>
                                                    <div align="right">
                                                        <input type="hidden" name="txtTotal" id="txtTotal" value="0" />
                                                        <input type="text" name="txtTotalFactura" id="txtTotalFactura" value="" readonly class="form-control"/>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" id="btn-cancelar" class="btn btn-danger"><span class="fa fa-times"></span> Cancelar Factura</button>
                                <button type="button" name="btn-submit" id="btn-submit" class="btn btn-primary"><span class="fa fa-save"></span> Registrar Factura</button>
                                <button type="button" id="btn-ver-movimientos" class="btn btn-info">
                                    <span class="fa fa-file-pdf-o"></span> Ver Movimientos
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </section>
</div>

<!-- SweetAlert2 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    var usuarioLogueadoId = <%= session.getAttribute("id") %>;
</script>
<script src="script/facturacion.js"></script>
<script>
// Script de inicialización para facturación
$(document).ready(function() {
    console.log("🟢 vistafacturacion.jsp inicializada");
    
    // Forzar la carga de datos después de un breve delay
    setTimeout(function() {
        if (typeof cargardetalle === 'function') {
            console.log("🔄 Forzando carga de detalle...");
            cargardetalle();
        }
        
        // Actualizar sucursal desde parámetros URL
        var urlParams = new URLSearchParams(window.location.search);
        var sucursal = urlParams.get('sucursal_nombre');
        if (sucursal) {
            $("#sucursal_cliente").val(sucursal);
            console.log("✅ Sucursal establecida:", sucursal);
        }
    }, 800);
});
</script>
<%@ include file="footer.jsp" %>