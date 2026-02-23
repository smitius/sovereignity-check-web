# Viewfinder Sovereign Check - Self-Contained Build
# Based on Red Hat UBI9 PHP 8.3

FROM registry.access.redhat.com/ubi9/php-83:latest

LABEL maintainer="Miro <miro@smitka.gleeze.com>"
LABEL description="Digital Sovereignty Readiness Assessment Tool"
LABEL version="1.0.0"

# Switch to root for setup
USER root

# Install required PHP extensions
RUN dnf install -y --setopt=tsflags=nodocs \
    php-gd \
    php-mbstring \
    php-xml \
    php-json \
    php-zip \
    fontconfig \
    && dnf clean all

# Create app directory
RUN mkdir -p /opt/app-root/src && chown -R 1001:0 /opt/app-root/src

# Copy application files (vendor/ included for self-standing build)
COPY --chown=1001:0 . /opt/app-root/src/

# Set permissions
RUN chmod -R g+w /opt/app-root/src

# Switch to non-root user
USER 1001

# Working directory
WORKDIR /opt/app-root/src

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start PHP built-in server
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/opt/app-root/src"]
