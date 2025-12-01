<%@ include file="conexion.jsp" %>
<%@page import="java.sql.*"%>
<%@ include file="header.jsp" %>
<div class="content-wrapper">
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="text-white fw-bold">LISTADO DE USUARIOS</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="index.jsp">Inicio</a></li>
                        <li class="breadcrumb-item active text-white fw-bold">Usuarios</li>
                    </ol>
                </div>
            </div>
        </div>
    </div>
    <div class="content">
        <div class="container-fluid">
            <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal" id="btnNuevo">
                <i class="fas fa-plus"></i> Agregar Usuario
            </button>
            <button type="button" class="btn btn-secondary" onclick="imprimirReporte('reporteUsuario.jasper')">
                <i class="fas fa-print"></i> Imprimir Reporte
            </button>
            <table class="table">
                <thead class="thead-light">
                    <tr>
                        <th>#</th>
                        <th>Usuario</th>
                        <th>Nombre</th>
                        <th>Apellido</th>
                        <th>Rol</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="listadoUsuarios">
                    <!-- Aquí se cargan los usuarios por AJAX -->
                </tbody>
            </table>

            <!-- Modal para ABM -->
            <div class="modal fade" id="exampleModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="modalTitle">Nuevo usuario</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <form id="form" name="form" autocomplete="off">
                                <input type="hidden" name="campo" id="campo" value="guardar">
                                <input type="hidden" name="pk" id="pk" value="">

                                <div class="form-group">
                                    <label>Usuario *</label>
                                    <input type="text" class="form-control" name="usu_usuario" placeholder="Nombre de usuario" required>
                                </div>
                                <div class="form-group">
                                    <label>Contraseña *</label>
                                    <input type="password" class="form-control" name="password" placeholder="Contraseña" required>
                                </div>
                                <div class="form-group">
                                    <label>Nombre</label>
                                    <input type="text" class="form-control" name="usu_nombre" placeholder="Nombre">
                                </div>
                                <div class="form-group">
                                    <label>Apellido</label>
                                    <input type="text" class="form-control" name="usu_apellido" placeholder="Apellido">
                                </div>
                                <div class="form-group">
                                    <label>Rol *</label>
                                    <select class="form-control" name="id_rol" id="id_rol" required>
                                        <option value="">Seleccione rol...</option>
                                        <%
                                        try (Statement st = conn.createStatement();
                                             ResultSet rs = st.executeQuery("SELECT id_rol, rol_nombre FROM rol ORDER BY rol_nombre")) {
                                            while (rs.next()) {
                                        %>
                                        <option value="<%= rs.getInt("id_rol") %>"><%= rs.getString("rol_nombre") %></option>
                                        <%
                                            }
                                        } catch (Exception e) { out.print("<option>Error cargando roles</option>"); }
                                        %>
                                    </select>
                                </div>
                                <div class="form-group" id="estadoContainer">
                                    <label>Estado</label>
                                    <select class="form-control" name="estado">
                                        <option value="ACTIVO">Activo</option>
                                        <option value="INACTIVO">Inactivo</option>
                                    </select>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                    <button type="button" class="btn btn-primary" id="guardarRegistro">Guardar</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <script src="script/usuario.js"></script>
            <script>
                  function imprimirReporte(reporteUsuario, parametros = {}) {
                      let url = 'reporteGenerico.jsp?reporte=' + encodeURIComponent(reporteUsuario);

                      for (let key in parametros) {
                          url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(parametros[key]);
                      }

                      window.open(url, '_blank');
                  }
// FUNCIÓN ESPECÍFICA PARA REPORTE INDIVIDUAL DE USUARIO
function imprimirUsuarioIndividual(idUsuario, nombreUsuario) {
    if (!idUsuario) {
        alert('Error: No se puede generar el reporte - ID no válido');
        return;
    }
    
    if (confirm('¿Generar reporte individual del usuario: ' + (nombreUsuario || '') + '?')) {
        // Llama directamente a Listadousuario.jsp con el parámetro del ID
        let url = 'reporte/Listadousuario.jsp?llamausuario=' + encodeURIComponent(idUsuario);
        
        window.open(url, '_blank');
    }
}
            </script>
        </div>
    </div>
</div>
<%@ include file="footer.jsp" %>