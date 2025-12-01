<%@include file="header.jsp" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Obtener la fecha actual
    Date fechaActual = new Date();

    // Crear un formateador de fecha
    SimpleDateFormat formateadorFecha = new SimpleDateFormat("dd-MM-yyyy");

    // Formatear la fecha
    String fechaFormateada = formateadorFecha.format(fechaActual);
%>
<div class="content-wrapper">
    <section class="content">
        <form action="#" id="form" enctype="multipart/form-data" method="POST" role="form" class="form-horizontal form-groups-bordered">
            <input type="hidden" id="listar" name="listar" value="cargar"/>
            <h3><i></i>Compras de Articulos</h3><br>


            <div class="row">
                <div class="col-lg-3 ds">
                    <!--COMPLETED ACTIONS DONUTS CHART-->
                    <h5>DATOS DEL PROVEEDOR

                    </h5>

                    <!-- First Action -->


                    <!-- First Action -->


                    <!-- First Action -->


                    <!-- Second Action -->

                    <div class="form-group">
                        <label for="field-12" class="control-label">Proveedor</label>

                        <select class="form-control" name="idproveedor" id="idproveedor" onchange="dividirproveedor(this.value)">

                        </select>
                    </div>

                    <div class="form-group">
                        <label for="field-12" class="control-label">Documento</label>
                        <input type="hidden" id="codproveedor" name="codproveedor">
                        <input class="form-control" type="text" value="" name="ruc" id="ruc" onKeyUp="this.value = this.value.toUpperCase();" autocomplete="off" placeholder="Cedula" readonly="readonly" required><small><span class="symbol required"></span> </small>
                    </div>

                    <div class="form-group">
                        <label for="field-12" class="control-label">Fecha de Venta</label>
                        <input class="form-control" type="text" name="fecharegistro" id="fecharegistro" onKeyUp="" autocomplete="off" placeholder="Ingrese Fecha" value="<%= fechaFormateada%>" readonly>

                    </div>

                    <hr>
                    <br>

                </div><!-- /col-lg-3 -->

                <div class="col-lg-9">

                    <div class="row">
                        <!-- TWITTER PANEL -->

                        <div class="col-lg-12">
                            <div class="panel panel-border panel-warning widget-s-1">
                                <div class="panel-heading">
                                    <h4 class="mb"><i class="fa fa-archive"></i> <strong>Detalle De La Compra</strong> </h4>
                                </div>
                                <div class="panel-body">

                                    <div id="error">
                                        <!-- error will be shown here ! -->
                                    </div>
                                    <div class="row">


                                        <div class="col-md-5">
                                            <div class="form-group">
                                                <label for="field-5" class="control-label">Búsqueda de Articulo: <span class="symbol required"></span></label>
                                                <input type="hidden" id="codproducto" name="codproducto">
                                                <select class="form-control" name="idproducto" id="idproducto" onchange="dividirproducto(this.value)">

                                                </select>
                                            </div>
                                        </div>

                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label for="field-3" class="control-label">Precio Venta: <span class="symbol required"></span></label>
                                                <input class="form-control" type="text" name="precio" id="precio" autocomplete="off" placeholder="precio" required onkeyup="puntitos(this, this.value.charAt(this.value.length - 1))" readonly="readonly">
                                            </div>
                                        </div>


                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label for="field-2" class="control-label">Cantidad: <span class="symbol required"></span></label>
                                                <input class="form-control number" value="1" type="text" name="cantidad" id="cantidad" onKeyUp="this.value = this.value.toUpperCase();" autocomplete="off" placeholder="Cantidad">
                                            </div>
                                        </div>

                                    </div>



                                    <div align="right">
                                        <button type="button" name="agregar" value="agregar" id="AgregaProductoCompra" class="btn btn-primary" onclick=""><span class="fa fa-shopping"></span> Agregar</button>
                                        <div id="respuesta"></div>
                                    </div>
                                    <hr>



                                    <div class="row">
                                        <div class="col-md-12">
                                            <div class="table-responsive">
                                                <table class="table table-striped table-bordered dt-responsive nowrap" id="carrito">
                                                    <thead>
                                                        <tr>
                                                            <th>
                                                                <div align="center">Acción</div>
                                                            </th>
                                                            <th>
                                                                <div align="center">Articulo</div>
                                                            </th>
                                                            <th>
                                                                <div align="center">Precio</div>
                                                            </th>
                                                            <th>
                                                                <div align="center">Cantidad</div>
                                                            </th>
                                                            <th>
                                                                <div align="center">Total</div>
                                                            </th>

                                                        </tr>
                                                    </thead>

                                                    <tbody id="resultados">



                                                    </tbody>

                                                </table>
                                                <table width="302" id="carritototal">

                                                    <tr>
                                                        <td><span class="Estilo9"><label>Total:</label></span></td>
                                                        <td>
                                                            <div align="right" class="Estilo9"><label id="lbltotal" name="lbltotal"></label><input type="hidden" name="txtTotal" id="txtTotal" value="0.00" />
                                                                <input type="" name="txtTotalCompra" id="txtTotalCompra" value="" />
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </div>
                                    </div>





                                    <div class="modal-footer">
                                        <button class="btn btn-danger" type="reset" onclick="#"><span class="fa fa-times"></span> Cancelar</button>
                                        <button type="button" name="btn-submit" id="btn-submit" class="btn btn-primary" onclick="#"><span class="fa fa-save"></span> Registrar</button>
                                    </div>



                                </div>
                            </div>
                        </div>



                    </div><!-- /row -->
                </div><!-- /col-lg-9 END SECTION MIDDLE -->

            </div>
            <!-- **********************************************************************************************************************************************************
          RIGHT SIDEBAR CONTENT
          *********************************************************************************************************************************************************** -->
        </form>
    </section>
</div>

</div>
<script>
    $(document).ready(function () {
        buscarproveedor();
        buscararticulo();
    });
    function buscarproveedor() {
        $.ajax({
            data: {listar: 'buscarproveedor'},
            url: 'jsp/buscar.jsp',
            type: 'post',
            beforeSend: function () {
                //$("#resultado").html("Procesando, espere por favor...");
            },
            success: function (response) {
                $("#idproveedor").html(response);
            }
        });
    }

    function buscararticulo() {
        $.ajax({
            data: {listar: 'buscararticulo'},
            url: 'jsp/buscar.jsp',
            type: 'post',
            beforeSend: function () {
                //$("#resultado").html("Procesando, espere por favor...");
            },
            success: function (response) {
                $("#idproducto").html(response);
            }
        });
    }

    function dividirproveedor(a) {
        //alert(a)
        datos = a.split(',');
        //alert(datos[0]);
       // alert(datos[1]);
        $("#codproveedor").val(datos[0]);
        $("#ruc").val(datos[1]);
    }
    
    function dividirproducto(a) {
        //alert(a)
        datos = a.split(',');
        //alert(datos[0]);
       // alert(datos[1]);
        $("#codproducto").val(datos[0]);
        $("#precio").val(datos[1]);
    }
    
    $("#AgregaProductoCompra").click(function(){
        datosform = $("#form").serialize();
        $.ajax({
            data: datosform,
            url: 'jsp/compras.jsp',
            type: 'post',
            beforeSend: function () {
                //$("#resultado").html("Procesando, espere por favor...");
            },
            success: function (response) {
                $("#respuesta").html(response);
                cargardetalle();
            }
        });
    });
    
    function cargardetalle(){
           $.ajax({
            data: {listar:'listar'},
            url: 'jsp/compras.jsp',
            type: 'post',
            beforeSend: function () {
                //$("#resultado").html("Procesando, espere por favor...");
            },
            success: function (response) {
                $("#resultados").html(response);
                
            }
        });
    }
    
</script>
<%@include file="footer.jsp" %>