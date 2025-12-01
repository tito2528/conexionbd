<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
// Invalidar la sesión completamente
if (session != null) {
    session.invalidate();
}

// Redirigir a la página web pública
response.sendRedirect(request.getContextPath() + "/index_publico.jsp");
%>