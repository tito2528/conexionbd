<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="conexion.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Horarios</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <h2>Prueba de Carga de Horarios</h2>
    
    <div>
        <label>Profesional:</label>
        <select id="test_profesional">
            <option value="">Cargando...</option>
        </select>
    </div>
    
    <div>
        <label>Fecha:</label>
        <input type="date" id="test_fecha" value="2025-11-03">
    </div>
    
    <div>
        <label>Servicio:</label>
        <input type="text" id="test_servicio" value="1">
    </div>
    
    <button onclick="probarHorarios()">CARGAR HORARIOS</button>
    
    <div>
        <label>Horarios:</label>
        <select id="test_horario">
            <option value="">Esperando...</option>
        </select>
    </div>
    
    <div id="resultado" style="margin-top:20px; padding:10px; border:1px solid #ccc;">
        <h3>Resultado:</h3>
        <pre id="resultado_texto">Pendiente...</pre>
    </div>

    <script>
        // Cargar profesionales al inicio
        $(document).ready(function() {
            $.ajax({
                url: 'Cabecera-detalle/profesional_horario.jsp',
                type: 'POST',
                data: {accion: 'listarProfesionales'},
                success: function(response) {
                    console.log("Profesionales:", response);
                    $("#test_profesional").html(response);
                },
                error: function(xhr, status, error) {
                    console.error("Error profesionales:", error);
                    $("#test_profesional").html("<option>ERROR: " + error + "</option>");
                }
            });
        });
        
        function probarHorarios() {
            var profesional = $("#test_profesional").val();
            var fecha = $("#test_fecha").val();
            var servicio = $("#test_servicio").val();
            
            console.log("=== PROBANDO HORARIOS ===");
            console.log("Profesional:", profesional);
            console.log("Fecha:", fecha);
            console.log("Servicio:", servicio);
            
            if (!profesional || !fecha || !servicio) {
                alert("Complete todos los campos");
                return;
            }
            
            $("#resultado_texto").text("Enviando petición...");
            $("#test_horario").html("<option>Cargando...</option>");
            
            $.ajax({
                url: 'Cabecera-detalle/profesional_horario.jsp',
                type: 'POST',
                data: {
                    accion: 'horariosDisponibles',
                    id_profesional: profesional,
                    id_servicio: servicio,
                    fecha: fecha
                },
                success: function(response) {
                    console.log("Respuesta:", response);
                    $("#test_horario").html(response);
                    $("#resultado_texto").text("✅ SUCCESS:\n\n" + response);
                },
                error: function(xhr, status, error) {
                    console.error("Error:", error);
                    console.error("Response:", xhr.responseText);
                    $("#resultado_texto").text("❌ ERROR:\n\nStatus: " + status + "\nError: " + error + "\n\nResponse:\n" + xhr.responseText);
                }
            });
        }
    </script>
</body>
</html>