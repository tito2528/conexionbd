<%@page import="java.sql.*"%>

<%
// Conexión a la base de datos
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

if (request.getParameter("btnLogin") != null) {
    String user = request.getParameter("usuario");
    String password = request.getParameter("pswrd");
    HttpSession sesion = request.getSession();

    try {
        // 1. Conectar a PostgreSQL
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/proyecto_2025", 
            "postgres", 
            "admin"
        );

        // 2. 🛡️ PROTECCIÓN ANTI-FUERZA BRUTA SIMPLE (usando sesión)
        Integer intentosFallidos = (Integer) session.getAttribute("intentos_fallidos_" + user);
        Long tiempoBloqueo = (Long) session.getAttribute("tiempo_bloqueo_" + user);
        
        if (intentosFallidos == null) intentosFallidos = 0;
        
        // Verificar si está bloqueado
        if (tiempoBloqueo != null && System.currentTimeMillis() < tiempoBloqueo) {
            long minutosRestantes = (tiempoBloqueo - System.currentTimeMillis()) / 60000;
            out.println("<div class='alert alert-danger'>" +
                       "<i class='fas fa-lock'></i> <strong>Cuenta bloqueada temporalmente</strong><br>" +
                       "Tiempo restante: <strong>" + minutosRestantes + " minutos</strong></div>");
            return;
        }
        
        // Si ya pasó el tiempo de bloqueo, resetear
        if (tiempoBloqueo != null && System.currentTimeMillis() >= tiempoBloqueo) {
            session.removeAttribute("intentos_fallidos_" + user);
            session.removeAttribute("tiempo_bloqueo_" + user);
            intentosFallidos = 0;
        }

        // 3. 🔒 CIFRADO DE DATOS (bcrypt) + 🛡️ ANTI SQL INJECTION (PreparedStatement)
        String sql = "SELECT id_usuario, usu_usuario, usu_nombre, usu_apellido FROM public.usuario " +
            "WHERE usu_usuario = ? " +
            "AND password = crypt(?, password) " +
            "AND estado = 'ACTIVO' " +
            "AND id_rol IN (SELECT id_rol FROM rol WHERE rol_nombre IN ('Administrador', 'Recepcion', 'Profesional'))";
        ps = conn.prepareStatement(sql);
        ps.setString(1, user);
        ps.setString(2, password);
        rs = ps.executeQuery();

        // 4. Si encuentra coincidencia - LOGIN EXITOSO
        if (rs.next()) {
            // Limpiar intentos fallidos
            session.removeAttribute("intentos_fallidos_" + user);
            session.removeAttribute("tiempo_bloqueo_" + user);
            
            // Crear sesión
            sesion.setAttribute("logueado", "1");
            sesion.setAttribute("user", rs.getString("usu_usuario"));
            sesion.setAttribute("id", rs.getString("id_usuario"));
            
            response.sendRedirect("index.jsp");
            return;
            
        } else {
            // 5. LOGIN FALLIDO - Incrementar intentos
            intentosFallidos++;
            session.setAttribute("intentos_fallidos_" + user, intentosFallidos);
            
            // Si supera 5 intentos, bloquear por 15 minutos
            if (intentosFallidos >= 5) {
                long tiempoBloqueoFuturo = System.currentTimeMillis() + (15 * 60 * 1000); // 15 minutos
                session.setAttribute("tiempo_bloqueo_" + user, tiempoBloqueoFuturo);
                
                out.println("<div class='alert alert-danger'>" +
                           "<i class='fas fa-exclamation-triangle'></i> <strong>¡Cuenta bloqueada!</strong><br>" +
                           "Has excedido el límite de intentos fallidos.<br>" +
                           "Tu cuenta ha sido bloqueada por <strong>15 minutos</strong>.</div>");
            } else {
                int intentosRestantes = 5 - intentosFallidos;
                out.println("<div class='alert alert-danger'>" +
                           "<i class='fas fa-times-circle'></i> Usuario o contrase�a incorrectos<br>" +
                           "Intentos restantes: <strong>" + intentosRestantes + "</strong></div>");
            }
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body, html {
            height: 100%;
            overflow: hidden;
        }

        .background-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
        }

        .background-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center;
        }

        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
            z-index: 0;
        }

        .login-container {
            position: relative;
            z-index: 1;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .login-box {
            background: rgba(255, 255, 255, 0.95);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            width: 100%;
            max-width: 420px;
            backdrop-filter: blur(10px);
        }

        .login-box h2 {
            color: #333;
            margin-bottom: 30px;
            text-align: center;
            font-weight: 600;
        }

        .form-control {
            padding: 12px;
            border-radius: 8px;
            border: 1px solid #ddd;
            transition: all 0.3s;
        }

        .form-control:focus {
            border-color: #0d6efd;
            box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25);
        }

        .btn-primary {
            padding: 12px;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(13, 110, 253, 0.4);
        }

        .alert {
            border-radius: 8px;
            margin-bottom: 20px;
        }

        @media (max-width: 576px) {
            .login-box {
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <div class="background-container">
        <img src="imagenes/image.jpg" alt="Background" class="background-image">
    </div>

    <div class="overlay"></div>

    <div class="login-container">
        <div class="login-box">
            <h2>Sistema Peluclik</h2>
            <h5 class="text-center">Iniciar Sesi�n</h5>
            
            <form method="POST">
                <div class="mb-3">
                    <label for="usuario" class="form-label">Usuario</label>
                    <input type="text" name="usuario" id="usuario" class="form-control" 
                           placeholder="Ingresa tu usuario" required>
                </div>
                
                <div class="mb-3">
                    <label for="pswrd" class="form-label">Contrase�a</label>
                    <input type="password" name="pswrd" id="pswrd" class="form-control" 
                           placeholder="Ingresa tu contrase�a" required>
                </div>
                
                <button type="submit" name="btnLogin" class="btn btn-primary w-100">Ingresar</button>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
