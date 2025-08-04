FROM grafana/grafana:latest

# Switch to root to install plugins and copy files
USER root

# Create provisioning directories
RUN mkdir -p /etc/grafana/provisioning/datasources
RUN mkdir -p /etc/grafana/provisioning/dashboards

# Copy datasource configuration
COPY --chown=472:472 datasources.yml /etc/grafana/provisioning/datasources/

# Switch back to grafana user (UID 472)
USER 472

# Expose the default Grafana port
EXPOSE 3000