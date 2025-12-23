FROM devopsedu/webapp:latest

LABEL maintainer="Your Name <email@example.com>"

# Update and install additional packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    php-mysql \
    php-curl \
    php-json \
    php-mbstring \
    php-xml \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy your PHP application
COPY . /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Create .htaccess for URL rewriting if needed
RUN echo "Options +FollowSymlinks\nRewriteEngine On\nRewriteCond %{REQUEST_FILENAME} !-f\nRewriteCond %{REQUEST_FILENAME} !-d\nRewriteRule ^(.*)$ index.php [L]" > /var/www/html/.htaccess

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
