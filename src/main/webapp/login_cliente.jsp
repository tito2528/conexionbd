<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión - Peluquería Josephlo</title>
    
    <!-- Favicon -->
    <link href="favicon.png" rel="icon">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- SweetAlert2 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">

    <style>
        :root {
            --color-primary: #e60026;
            --color-primary-dark: #cc001f;
            --color-black: #000000;
            --color-dark: #1a1a1a;
            --color-gray-dark: #2a2a2a;
            --color-gray: #444444;
            --color-white: #ffffff;
            --color-white-50: rgba(255, 255, 255, 0.5);
            --color-white-70: rgba(255, 255, 255, 0.7);
            --font-family: 'Poppins', sans-serif;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: var(--font-family);
            background: linear-gradient(135deg, var(--color-black) 0%, var(--color-dark) 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--color-white);
        }

        .login-container {
            width: 100%;
            max-width: 450px;
            padding: 20px;
        }

        .login-card {
            background: var(--color-gray-dark);
            border: 1px solid var(--color-gray);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 15px 50px rgba(230, 0, 38, 0.3);
            animation: fadeInUp 0.6s;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .login-header img {
            height: 60px;
            margin-bottom: 20px;
            filter: brightness(0) invert(1);
        }

        .login-header h2 {
            color: var(--color-white);
            font-weight: 700;
            font-size: 1.8rem;
            margin-bottom: 10px;
        }

        .login-header p {
            color: var(--color-white-70);
            font-size: 0.95rem;
        }

        .form-label {
            color: var(--color-white);
            font-weight: 500;
            margin-bottom: 8px;
        }

        .form-control {
            background-color: var(--color-dark) !important;
            border: 1px solid var(--color-gray) !important;
            color: var(--color-white) !important;
            border-radius: 10px;
            padding: 12px 15px;
            font-size: 0.95rem;
        }

        .form-control:focus {
            background-color: var(--color-dark) !important;
            border-color: var(--color-primary) !important;
            box-shadow: 0 0 0 0.2rem rgba(230, 0, 38, 0.25) !important;
            color: var(--color-white) !important;
        }

        .form-control::placeholder {
            color: var(--color-white-50) !important;
        }

        .input-group-text {
            background-color: var(--color-dark);
            border: 1px solid var(--color-gray);
            border-right: none;
            color: var(--color-white-70);
            border-radius: 10px 0 0 10px;
        }

        .input-group .form-control {
            border-left: none;
            border-radius: 0 10px 10px 0;
        }

        .btn-login {
            background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
            border: none;
            color: var(--color-white);
            padding: 12px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 1rem;
            width: 100%;
            margin-top: 10px;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(230, 0, 38, 0.3);
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(230, 0, 38, 0.5);
            background: linear-gradient(135deg, var(--color-primary-dark) 0%, var(--color-primary) 100%);
        }

        .divider {
            text-align: center;
            margin: 25px 0;
            position: relative;
        }

        .divider::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            width: 45%;
            height: 1px;
            background: var(--color-gray);
        }

        .divider::after {
            content: '';
            position: absolute;
            right: 0;
            top: 50%;
            width: 45%;
            height: 1px;
            background: var(--color-gray);
        }

        .divider span {
            color: var(--color-white-70);
            font-size: 0.9rem;
        }

        .btn-register {
            background-color: transparent;
            border: 2px solid var(--color-white);
            color: var(--color-white);
            padding: 12px;
            border-radius: 10px;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s;
        }

        .btn-register:hover {
            background-color: var(--color-white);
            color: var(--color-black);
            transform: translateY(-2px);
        }

        .back-link {
            text-align: center;
            margin-top: 20px;
        }

        .back-link a {
            color: var(--color-white-70);
            text-decoration: none;
            font-size: 0.9rem;
            transition: color 0.3s;
        }

        .back-link a:hover {
            color: var(--color-primary);
        }

        .password-toggle {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: var(--color-white-70);
            z-index: 10;
        }

        .password-toggle:hover {
            color: var(--color-primary);
        }

        @media (max-width: 576px) {
            .login-card {
                padding: 30px 20px;
            }
            
            .login-header h2 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>

<body>
    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <img src="img/logo-white.png" alt="Josephlo Logo">
                <h2>Iniciar Sesión</h2>
                <p>Accede a tu cuenta para reservar</p>
            </div>

            <form id="formLogin" method="POST" action="Cabecera-detalle/Controlador_cliente.jsp">
                <input type="hidden" name="accion" value="login">
                
                <div class="mb-3">
                    <label class="form-label">
                        <i class="fas fa-envelope text-danger"></i> Usuario
                    </label>
                    <div class="input-group">
                        <span class="input-group-text">
                            <i class="fas fa-user"></i>
                        </span>
                        <input type="text" class="form-control" name="usuario" id="usuario" 
                               placeholder="tu_usuario" required>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">
                        <i class="fas fa-lock text-danger"></i> Contraseña
                    </label>
                    <div class="input-group position-relative">
                        <span class="input-group-text">
                            <i class="fas fa-key"></i>
                        </span>
                        <input type="password" class="form-control" name="password" id="password" 
                               placeholder="••••••••" required>
                        <i class="fas fa-eye password-toggle" id="togglePassword"></i>
                    </div>
                </div>

                <button type="submit" class="btn btn-login">
                    <i class="fas fa-sign-in-alt"></i> Iniciar Sesión
                </button>
            </form>

            <div class="divider">
                <span>o</span>
            </div>

            <a href="registro_cliente.jsp" class="btn btn-register">
                <i class="fas fa-user-plus"></i> Crear una cuenta
            </a>

            <div class="back-link">
                <a href="index_publico.jsp">
                    <i class="fas fa-arrow-left"></i> Volver al inicio
                </a>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
        // Toggle password visibility
        document.getElementById('togglePassword').addEventListener('click', function() {
            const password = document.getElementById('password');
            const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
            password.setAttribute('type', type);
            
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
        });

        // Form submission
        $('#formLogin').on('submit', function(e) {
            e.preventDefault();
            
            const usuario = $('#usuario').val().trim();
            const password = $('#password').val().trim();
            
            if (!usuario || !password) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Campos vacíos',
                    text: 'Por favor completa todos los campos',
                    confirmButtonColor: '#e60026'
                });
                return;
            }
            
            $.ajax({
                url: 'Cabecera-detalle/Controlador_cliente.jsp',
                type: 'POST',
                data: {
                    accion: 'login',
                    usuario: usuario,
                    password: password
                },
                success: function(response) {
                    console.log("Respuesta:", response);
                    response = response.trim();
                    
                    if (response.indexOf('exitoso') !== -1 || response.indexOf('✅') !== -1) {
                        Swal.fire({
                            icon: 'success',
                            title: '¡Bienvenido!',
                            text: 'Inicio de sesión exitoso',
                            confirmButtonColor: '#e60026',
                            timer: 1500,
                            showConfirmButton: false
                        }).then(() => {
                            window.location.href = 'index_publico.jsp';
                        });
                    } else if (response.indexOf('bloqueada') !== -1 || response.indexOf('🔒') !== -1) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Cuenta bloqueada',
                            html: response,
                            confirmButtonColor: '#e60026'
                        });
                    } else if (response.indexOf('incorrectos') !== -1 || response.indexOf('❌') !== -1) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Credenciales incorrectas',
                            html: response,
                            confirmButtonColor: '#e60026'
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: 'Ocurrió un error. Intenta nuevamente',
                            confirmButtonColor: '#e60026'
                        });
                    }
                },
                error: function() {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error de conexión',
                        text: 'No se pudo conectar con el servidor',
                        confirmButtonColor: '#e60026'
                    });
                }
            });
        });
    </script>
</body>
</html>
