# PHP Multi-Version Development Environment

This Coder template creates a comprehensive PHP development environment with multiple PHP versions and supporting services, based on the [vscode-remote-environment](https://github.com/sidamo82/vscode-remote-environment) devcontainer.

## Features

- **Multiple PHP Versions**: 7.3, 7.4, 8.0, 8.2, 8.4 with PHP-FPM
- **Web Server**: Nginx with version-specific virtual hosts
- **Database**: MariaDB with persistent storage
- **Development Tools**: 
  - Xdebug for debugging (port 9003)
  - PHP debugging extensions pre-installed
  - IBM DB2 client libraries and PHP extensions
- **VS Code Integration**: 
  - Web-based VS Code (code-server)
  - Pre-configured with PHP development extensions
  - IntelliSense and debugging support

## Port Configuration

Each PHP version runs on its own dedicated port:

- **8073**: PHP 7.3 Web Server
- **8074**: PHP 7.4 Web Server  
- **8080**: PHP 8.0 Web Server
- **8082**: PHP 8.2 Web Server
- **8084**: PHP 8.4 Web Server
- **3306**: MariaDB Database
- **9003**: Xdebug Port
- **13337**: VS Code Server

## Usage

### Creating a Workspace

1. Create a new workspace using this template
2. Configure CPU cores (1-8) and memory (2-16 GB) as needed
3. Wait for the environment to build (first time may take 5-10 minutes)
4. Access your development environment through the VS Code app

### Accessing Services

- **VS Code**: Use the "VS Code" app in your Coder dashboard
- **PHP Servers**: Use the respective PHP version apps (PHP 7.3, PHP 8.0, etc.)
- **Files**: Your code is persisted in `/workspaces` and available across restarts

### Development Workflow

1. Clone your repositories into `/workspaces`
2. Edit code using the integrated VS Code
3. Test on different PHP versions using the respective server apps
4. Debug using Xdebug on port 9003
5. Access MariaDB on port 3306 for database operations

## Database Configuration

Default MariaDB credentials:
- **Host**: `localhost` (or `mariadb` from within containers)
- **Port**: `3306`
- **Root Password**: `Novigo2025!!`
- **Database**: `my_database`
- **User**: `db_user`
- **Password**: `Novigo2025!!`

## VS Code Extensions Included

The environment comes pre-configured with essential PHP development extensions:

- **PHP Debug** (`felixfbecker.php-debug`) - Xdebug integration
- **PHP Intelephense** (`bmewburn.vscode-intelephense-client`) - IntelliSense and code navigation
- **PHP Tools** (`DEVSENSE.phptools-vscode`) - Advanced PHP development features

## IBM DB2 Support

The environment includes IBM DB2 client libraries and PHP extensions:
- **ibm_db2** PHP extension
- **pdo_ibm** PHP extension
- Client libraries located at `/opt/ibm/clidriver`

## Architecture

This template uses Docker-in-Docker with the following architecture:
- **Main Container**: Runs envbuilder to set up the devcontainer environment
- **Multi-Container Setup**: Nginx + multiple PHP-FPM containers + MariaDB
- **Persistent Storage**: Workspace files and database data persist across restarts
- **Network Isolation**: Each workspace gets its own Docker network

## Resource Requirements

- **Minimum**: 2 CPU cores, 2 GB RAM
- **Recommended**: 4 CPU cores, 4 GB RAM
- **For heavy development**: 6-8 CPU cores, 8-16 GB RAM

## Troubleshooting

### Services Not Starting
If PHP servers aren't accessible:
1. Check the workspace logs in Coder
2. Verify the docker-compose services are running: `docker-compose ps`
3. Restart the workspace if needed

### Database Connection Issues
1. Ensure MariaDB container is running
2. Check network connectivity between containers
3. Verify credentials match the environment variables

### Performance Issues
1. Increase CPU/memory allocation in template parameters
2. Check if all PHP versions are needed (consider commenting out unused ones)
3. Monitor resource usage in Coder dashboard

## Customization

### Adding More PHP Extensions
Edit `.devcontainer/Dockerfile` to add additional PHP extensions:
```dockerfile
RUN apt-get install -y php8.0-your-extension
```

### Modifying PHP Configuration
Edit the respective `php.ini` files in `.devcontainer/conf/phpXX/`

### Nginx Configuration
Modify virtual host configurations in `.devcontainer/conf/nginx/conf.d/`

## Support

This template is based on the open-source [vscode-remote-environment](https://github.com/sidamo82/vscode-remote-environment) repository. For issues specific to the PHP environment setup, refer to that repository's documentation.

For Coder-specific issues, check the Coder documentation or contact your Coder administrator.