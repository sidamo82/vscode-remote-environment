# Coder Template Deployment Guide

This guide will help you deploy the PHP Multi-Version Development Environment template to your Coder instance.

## Prerequisites

- Coder server running and accessible
- Docker provider configured in Coder
- Sufficient resources on Coder nodes (Docker hosts)
- Access to push templates to your Coder instance

## Files Structure

Your template should contain these files:

```
├── main.tf                 # Main Terraform configuration
├── startup.sh             # Enhanced startup script
├── template.yaml          # Template metadata
├── README.md              # User documentation
├── DEPLOYMENT.md          # This deployment guide
├── .coder/
│   └── coder.yaml         # Coder-specific configuration
└── .devcontainer/         # Original devcontainer configuration
    ├── Dockerfile
    ├── devcontainer.json
    ├── docker-compose.yml
    ├── conf/              # PHP and Nginx configurations
    └── ibmodbcdriver/     # IBM DB2 drivers
```

## Step 1: Validate Template

Before deploying, validate your Terraform configuration:

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Check formatting
terraform fmt -check
```

## Step 2: Create Template in Coder

### Option A: Using Coder CLI

```bash
# Create template from current directory
coder templates create php-multi-dev

# Or create from Git repository
coder templates create php-multi-dev \
  --git-url https://github.com/your-org/your-coder-template-repo.git
```

### Option B: Using Coder Web UI

1. Navigate to your Coder dashboard
2. Go to "Templates" section
3. Click "Create Template"
4. Upload the template files or connect to Git repository
5. Configure template settings:
   - **Name**: `php-multi-dev`
   - **Display Name**: `PHP Multi-Version Development`
   - **Description**: `Complete PHP development environment with multiple PHP versions`

## Step 3: Configure Template Parameters

The template includes these configurable parameters:

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| `cpu_cores` | 2 | 1-8 | Number of CPU cores |
| `memory_gb` | 4 | 2-16 | Memory allocation in GB |

## Step 4: Test Deployment

Create a test workspace to verify everything works:

```bash
# Create a test workspace
coder create test-php-workspace --template php-multi-dev

# Check workspace status
coder list

# Connect to workspace (optional)
coder ssh test-php-workspace
```

## Step 5: Verify Services

Once the workspace is running, verify all services:

### Check Container Status
```bash
# SSH into workspace
coder ssh your-workspace-name

# Check running containers
docker ps

# Check docker-compose services
cd /workspaces
docker-compose -f .devcontainer/docker-compose.yml ps
```

### Test Web Services
Access these URLs through the Coder dashboard apps:

- **VS Code**: Port 13337
- **PHP 7.3**: Port 8073
- **PHP 7.4**: Port 8074
- **PHP 8.0**: Port 8080
- **PHP 8.2**: Port 8082
- **PHP 8.4**: Port 8084

### Test Database Connection
```bash
# Connect to MariaDB
mysql -h localhost -u db_user -p'Novigo2025!!' my_database

# Or from within workspace
docker exec -it mariadb mysql -u root -p'Novigo2025!!'
```

## Troubleshooting

### Common Issues

#### 1. Services not starting
```bash
# Check container logs
docker logs nginx
docker logs mariadb
docker logs php-fpm-80

# Check docker-compose logs
docker-compose -f .devcontainer/docker-compose.yml logs
```

#### 2. Port conflicts
If you get port binding errors, check if ports are already in use:
```bash
# Check port usage
netstat -tulpn | grep :8080
ss -tulpn | grep :8080
```

#### 3. Permission issues
```bash
# Fix workspace permissions
chown -R $(whoami):$(whoami) /workspaces
chmod -R 755 /workspaces
```

#### 4. Memory/CPU issues
- Increase template parameters if services are slow
- Monitor resource usage in Coder dashboard
- Consider reducing number of PHP versions if needed

### Debug Mode

Enable debug logging by modifying the startup script:

```bash
# Add debug flag to startup.sh
set -ex  # Instead of set -e

# Check startup logs
tail -f /tmp/code-server.log
journalctl -u docker  # If using systemd
```

## Performance Optimization

### Resource Allocation

For different use cases:

| Use Case | CPU Cores | Memory | Notes |
|----------|-----------|--------|-------|
| Light development | 2 | 4 GB | Single PHP version testing |
| Multi-version testing | 4 | 8 GB | All PHP versions active |
| Heavy development | 6-8 | 12-16 GB | Multiple projects, debugging |

### Service Optimization

Consider disabling unused PHP versions by commenting them out in `docker-compose.yml`:

```yaml
# Comment out unused versions
# php73:
#   image: novigoconsulting/php73
#   ...
```

## Monitoring

### Health Checks

The template includes health checks for:
- VS Code Server (`/healthz` endpoint)
- All PHP services (port connectivity)
- MariaDB (port 3306)

### Metrics

Monitor through Coder dashboard:
- CPU usage
- Memory usage  
- Disk usage
- Network traffic

## Security Considerations

### Default Passwords

**⚠️ Important**: Change default database passwords in production:

1. Update `.devcontainer/docker-compose.yml`
2. Modify environment variables:
   ```yaml
   environment:
     MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD:-YOUR_SECURE_PASSWORD}
     MYSQL_PASSWORD: ${DB_PASSWORD:-YOUR_SECURE_PASSWORD}
   ```

### Network Security

- All services run in isolated Docker networks per workspace
- No external access unless explicitly configured
- VS Code Server runs without authentication (local access only)

## Maintenance

### Updating Template

To update the template:

```bash
# Update template
coder templates push php-multi-dev

# Or create new version
coder templates create php-multi-dev-v2
```

### Workspace Updates

Users can update their workspaces:

```bash
# Update workspace to latest template
coder update your-workspace-name
```

## Support

### Logs Location

Important log files:
- `/tmp/code-server.log` - VS Code Server logs
- `/var/log/nginx/` - Nginx logs
- `/var/log/mysql/` - MariaDB logs
- Docker container logs via `docker logs <container>`

### Getting Help

1. Check Coder documentation: https://coder.com/docs
2. Review template logs in Coder dashboard
3. SSH into workspace for direct debugging
4. Contact your Coder administrator

## Next Steps

After successful deployment:

1. **Create user documentation** for your team
2. **Set up monitoring** and alerting
3. **Configure backups** for persistent volumes
4. **Establish update procedures** for template maintenance
5. **Train users** on the development environment features