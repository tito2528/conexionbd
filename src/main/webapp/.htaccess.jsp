<IfModule mod_rewrite.c>
RewriteEngine On

# Ignora archivos y directorios reales
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d

# Redirige a tu error 404
RewriteRule ^ /projectobd/pages/ERROR_404.html [L]
</IfModule>