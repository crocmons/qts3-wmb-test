FROM python:3.12
LABEL maintainer="Miguel Galves <mgalves@gmail.com>"

# Install sudo, nginx, and emacs in one command, and clean up the apt cache to reduce image size
RUN apt-get update && apt-get -y install sudo nginx emacs && \
    rm -rf /var/lib/apt/lists/*

# Creating local user and group, and adding to the appropriate groups
RUN groupadd nginx && \
    adduser --disabled-password --home /home/wmb --shell /bin/bash wmb && \
    adduser wmb sudo && \
    adduser wmb nginx && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# NGINX configuration
COPY etc/nginx.conf /etc/nginx/sites-enabled/default

# Switch to our local user 'wmb' to run subsequent commands
USER wmb

# Create necessary directories with correct permissions
RUN mkdir -p /home/wmb/logs/nginx /home/wmb/www/src && \
    chmod 777 /home/wmb/logs /home/wmb/logs/nginx && \
    chown wmb:nginx /home/wmb/logs /home/wmb/logs/nginx && \
    chmod o+x /home/wmb /home/wmb/www

# Copy scripts and files, set ownership and permissions in one step
COPY --chown=wmb:wmb bin/cmd_run.sh /home/wmb/www/
COPY --chown=wmb:wmb requirements.txt /home/wmb/www/

# Set the working directory
WORKDIR /home/wmb/www/

# Install Python requirements
RUN pip install --no-cache-dir -r requirements.txt

# Set the PATH environment variable
ENV PATH="${PATH}:/home/wmb/.local/bin"

# Expose the necessary ports
EXPOSE 8000 80
