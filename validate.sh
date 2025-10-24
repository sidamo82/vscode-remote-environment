#!/bin/bash

set -e

echo "🔍 Validating Coder PHP Multi-Version Template..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "success")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "error")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "info")
            echo -e "ℹ️  $message"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔧 Checking prerequisites..."

if command_exists terraform; then
    print_status "success" "Terraform is installed"
    terraform version | head -1
else
    print_status "error" "Terraform is not installed"
    exit 1
fi

if command_exists docker; then
    print_status "success" "Docker is installed"
    docker --version
else
    print_status "error" "Docker is not installed"
    exit 1
fi

# Check required files
echo ""
echo "📁 Checking required files..."

required_files=(
    "main.tf"
    "README.md"
    "startup.sh"
    "template.yaml"
    ".devcontainer/devcontainer.json"
    ".devcontainer/docker-compose.yml"
    ".devcontainer/Dockerfile"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_status "success" "Found $file"
    else
        print_status "error" "Missing required file: $file"
        exit 1
    fi
done

# Check devcontainer configuration files
echo ""
echo "⚙️  Checking devcontainer configuration..."

config_dirs=(
    ".devcontainer/conf/nginx/conf.d"
    ".devcontainer/conf/php73"
    ".devcontainer/conf/php74"
    ".devcontainer/conf/php80"
    ".devcontainer/conf/php82"
    ".devcontainer/conf/php84"
)

for dir in "${config_dirs[@]}"; do
    if [ -d "$dir" ]; then
        print_status "success" "Found configuration directory: $dir"
    else
        print_status "warning" "Configuration directory not found: $dir"
    fi
done

# Check PHP configuration files
php_configs=(
    ".devcontainer/conf/php73/php.ini"
    ".devcontainer/conf/php74/php.ini"
    ".devcontainer/conf/php80/php.ini"
    ".devcontainer/conf/php82/php.ini"
    ".devcontainer/conf/php84/php.ini"
)

for config in "${php_configs[@]}"; do
    if [ -f "$config" ]; then
        print_status "success" "Found PHP config: $config"
    else
        print_status "warning" "PHP config not found: $config"
    fi
done

# Check Nginx configurations
nginx_configs=(
    ".devcontainer/conf/nginx/conf.d/php73.conf"
    ".devcontainer/conf/nginx/conf.d/php74.conf"
    ".devcontainer/conf/nginx/conf.d/php80.conf"
    ".devcontainer/conf/nginx/conf.d/php82.conf"
    ".devcontainer/conf/nginx/conf.d/php84.conf"
)

for config in "${nginx_configs[@]}"; do
    if [ -f "$config" ]; then
        print_status "success" "Found Nginx config: $config"
    else
        print_status "warning" "Nginx config not found: $config"
    fi
done

# Validate Terraform configuration
echo ""
echo "🏗️  Validating Terraform configuration..."

if terraform init -backend=false >/dev/null 2>&1; then
    print_status "success" "Terraform initialization successful"
else
    print_status "error" "Terraform initialization failed"
    exit 1
fi

if terraform validate >/dev/null 2>&1; then
    print_status "success" "Terraform configuration is valid"
else
    print_status "error" "Terraform configuration validation failed"
    echo "Running terraform validate for details:"
    terraform validate
    exit 1
fi

# Check Terraform formatting
if terraform fmt -check >/dev/null 2>&1; then
    print_status "success" "Terraform configuration is properly formatted"
else
    print_status "warning" "Terraform configuration needs formatting (run 'terraform fmt')"
fi

# Validate JSON files
echo ""
echo "📋 Validating JSON files..."

json_files=(
    ".devcontainer/devcontainer.json"
)

for json_file in "${json_files[@]}"; do
    if [ -f "$json_file" ]; then
        if python3 -m json.tool "$json_file" >/dev/null 2>&1; then
            print_status "success" "Valid JSON: $json_file"
        else
            print_status "error" "Invalid JSON: $json_file"
            exit 1
        fi
    fi
done

# Validate YAML files
echo ""
echo "📄 Validating YAML files..."

yaml_files=(
    "template.yaml"
    ".coder/coder.yaml"
)

for yaml_file in "${yaml_files[@]}"; do
    if [ -f "$yaml_file" ]; then
        if python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" >/dev/null 2>&1; then
            print_status "success" "Valid YAML: $yaml_file"
        else
            print_status "error" "Invalid YAML: $yaml_file"
            exit 1
        fi
    else
        print_status "warning" "YAML file not found: $yaml_file"
    fi
done

# Check Docker Compose configuration
echo ""
echo "🐳 Validating Docker Compose configuration..."

if docker-compose -f .devcontainer/docker-compose.yml config >/dev/null 2>&1; then
    print_status "success" "Docker Compose configuration is valid"
else
    print_status "error" "Docker Compose configuration validation failed"
    echo "Running docker-compose config for details:"
    docker-compose -f .devcontainer/docker-compose.yml config
    exit 1
fi

# Check for hardcoded paths
echo ""
echo "🔍 Checking for hardcoded paths..."

if grep -r "/home/ndamonti" .devcontainer/ >/dev/null 2>&1; then
    print_status "warning" "Found hardcoded paths in devcontainer configuration"
    echo "Files with hardcoded paths:"
    grep -r "/home/ndamonti" .devcontainer/ || true
else
    print_status "success" "No hardcoded paths found"
fi

# Check startup script
echo ""
echo "🚀 Validating startup script..."

if [ -x "startup.sh" ]; then
    print_status "success" "Startup script is executable"
else
    print_status "warning" "Startup script is not executable (will be fixed during deployment)"
fi

# Check for required environment variables in startup script
required_vars=(
    "docker"
    "code-server"
    "curl"
)

for var in "${required_vars[@]}"; do
    if grep -q "$var" startup.sh; then
        print_status "success" "Startup script references: $var"
    else
        print_status "warning" "Startup script may not reference: $var"
    fi
done

# Check template parameters
echo ""
echo "⚙️  Validating template parameters..."

# Check if variables are defined in main.tf
if grep -q "variable \"cpu_cores\"" main.tf; then
    print_status "success" "CPU cores parameter defined"
else
    print_status "error" "CPU cores parameter not defined"
fi

if grep -q "variable \"memory_gb\"" main.tf; then
    print_status "success" "Memory parameter defined"
else
    print_status "error" "Memory parameter not defined"
fi

# Check for required ports
echo ""
echo "🌐 Validating port configuration..."

required_ports=(
    "8073"
    "8074"
    "8080"
    "8082"
    "8084"
    "3306"
    "9003"
    "13337"
)

for port in "${required_ports[@]}"; do
    if grep -q "$port" main.tf; then
        print_status "success" "Port $port configured in Terraform"
    else
        print_status "warning" "Port $port may not be configured"
    fi
done

# Security checks
echo ""
echo "🔒 Security validation..."

# Check for default passwords
if grep -q "Novigo2025!!" .devcontainer/docker-compose.yml; then
    print_status "warning" "Default database passwords found - consider using environment variables for production"
else
    print_status "success" "No default passwords found in docker-compose.yml"
fi

# Check for privileged mode
if grep -q "privileged = true" main.tf; then
    print_status "warning" "Privileged mode enabled - required for docker-in-docker but increases security risk"
else
    print_status "error" "Privileged mode not found - may be required for devcontainer functionality"
fi

# Final summary
echo ""
echo "📊 Validation Summary"
echo "===================="

# Count errors and warnings (simplified)
total_checks=$(grep -c "print_status" "$0")
echo "Total validations performed: ~$total_checks"

print_status "info" "Validation completed!"
print_status "info" "Review any warnings above before deploying to production"

echo ""
echo "🚀 Next steps:"
echo "1. Review any warnings or errors above"
echo "2. Test template deployment: coder templates create php-multi-dev"
echo "3. Create a test workspace: coder create test-workspace --template php-multi-dev"
echo "4. Verify all services are working correctly"
echo ""
echo "📚 See DEPLOYMENT.md for detailed deployment instructions"