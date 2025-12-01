<%@page import="java.util.Date"%>
<%
// 1. Obtener la sesión sin crear una nueva si no existe
HttpSession sesion = request.getSession(false);

// 2. Verificar si el usuario NO está logueado
if (sesion == null || sesion.getAttribute("logueado") == null || !sesion.getAttribute("logueado").equals("1")) {
    response.sendRedirect(request.getContextPath() + "/ERROR_404.html");
    return;
}

// 3. Configuración de tiempo de inactividad (5 minutos)
final long TIEMPO_INACTIVIDAD = 5 * 60 * 1000; // 5 minutos (solo para prueba)
long tiempoActual = System.currentTimeMillis();

// 4. Obtener último acceso (con verificación de null)
Object ultimoAccesoObj = sesion.getAttribute("ultimoAcceso");
Long tiempoUltimoAcceso = (ultimoAccesoObj != null) ? (Long) ultimoAccesoObj : null;

// 5. Validar inactividad
if (tiempoUltimoAcceso != null && (tiempoActual - tiempoUltimoAcceso) > TIEMPO_INACTIVIDAD) {
    sesion.invalidate(); // Destruir sesión
    response.sendRedirect(request.getContextPath() + "/ERROR_404.html");
    return;
}

// 6. Actualizar tiempo de último acceso
sesion.setAttribute("ultimoAcceso", tiempoActual);
%>