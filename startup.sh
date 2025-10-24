#!/bin/bash

set -e

echo "🚀 Starting PHP Multi-Version Development Environment..."

# Function to wait for a service to be ready
wait_for_service() {
    local service_name=$1
    local port=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Waiting for $service_name on port $port..."
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z localhost $port 2>/dev/null; then
            echo "✅ $service_name is ready!"
            return 0
        fi
        
        echo "   Attempt $attempt/$max_attempts - $service_name not ready yet..."
        sleep 2
        ((attempt++))
    done
    
    echo "❌ $service_name failed to start after $max_attempts attempts"
    return 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install netcat if not available (for service health checks)
if ! command_exists nc; then
    echo "📦 Installing netcat for health checks..."
    apt-get update && apt-get install -y netcat-openbsd
fi

# Wait for Docker to be available
echo "⏳ Waiting for Docker to be ready..."
while ! docker info >/dev/null 2>&1; do
    echo "   Docker not ready yet..."
    sleep 2
done
echo "✅ Docker is ready!"

# Check if we're in the workspace directory
if [ ! -f "/workspaces/.devcontainer/docker-compose.yml" ]; then
    echo "⚠️  Devcontainer not found, waiting for git clone to complete..."
    while [ ! -f "/workspaces/.devcontainer/docker-compose.yml" ]; do
        sleep 5
    done
fi

# Change to the workspace directory
cd /workspaces

# Start the devcontainer services
echo "🐳 Starting devcontainer services..."
docker-compose -f .devcontainer/docker-compose.yml up -d

# Wait for core services to be ready
wait_for_service "MariaDB" 3306
wait_for_service "Nginx" 8080

# Check PHP-FPM services
echo "🐘 Checking PHP services..."
for version in 73 74 80 82 84; do
    port="80$version"
    if [ "$version" = "73" ]; then port="8073"; fi
    if [ "$version" = "74" ]; then port="8074"; fi
    
    wait_for_service "PHP $version" $port
done

# Install code-server if not already installed
if ! command_exists code-server; then
    echo "📝 Installing code-server..."
    curl -fsSL https://code-server.dev/install.sh | sh
fi

# Start code-server
echo "🖥️  Starting VS Code Server..."
mkdir -p /tmp/code-server
code-server \
    --auth none \
    --port 13337 \
    --bind-addr 0.0.0.0:13337 \
    --user-data-dir /tmp/code-server \
    --extensions-dir /tmp/code-server/extensions \
    /workspaces \
    >/tmp/code-server.log 2>&1 &

# Wait for code-server to be ready
wait_for_service "VS Code Server" 13337

# Create a simple info page
cat > /workspaces/info.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>PHP Multi-Version Development Environment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .version-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .version-card { background: #007cba; color: white; padding: 20px; border-radius: 5px; text-align: center; text-decoration: none; }
        .version-card:hover { background: #005a87; }
        .info-section { margin: 20px 0; padding: 15px; background: #f8f9fa; border-left: 4px solid #007cba; }
        h1 { color: #333; }
        h2 { color: #007cba; }
        code { background: #f1f1f1; padding: 2px 5px; border-radius: 3px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐘 PHP Multi-Version Development Environment</h1>
        <p>Welcome to your Coder workspace! This environment provides multiple PHP versions with a complete development stack.</p>
        
        <h2>🌐 Available PHP Versions</h2>
        <div class="version-grid">
            <a href="http://localhost:8073" class="version-card" target="_blank">
                <h3>PHP 7.3</h3>
                <p>Port 8073</p>
            </a>
            <a href="http://localhost:8074" class="version-card" target="_blank">
                <h3>PHP 7.4</h3>
                <p>Port 8074</p>
            </a>
            <a href="http://localhost:8080" class="version-card" target="_blank">
                <h3>PHP 8.0</h3>
                <p>Port 8080</p>
            </a>
            <a href="http://localhost:8082" class="version-card" target="_blank">
                <h3>PHP 8.2</h3>
                <p>Port 8082</p>
            </a>
            <a href="http://localhost:8084" class="version-card" target="_blank">
                <h3>PHP 8.4</h3>
                <p>Port 8084</p>
            </a>
        </div>
        
        <div class="info-section">
            <h2>📊 Current PHP Version Info</h2>
            <?php
            echo "<p><strong>PHP Version:</strong> " . phpversion() . "</p>";
            echo "<p><strong>Server:</strong> " . $_SERVER['SERVER_SOFTWARE'] . "</p>";
            echo "<p><strong>Document Root:</strong> " . $_SERVER['DOCUMENT_ROOT'] . "</p>";
            ?>
        </div>
        
        <div class="info-section">
            <h2>🗄️ Database Information</h2>
            <p><strong>Host:</strong> localhost</p>
            <p><strong>Port:</strong> 3306</p>
            <p><strong>Database:</strong> my_database</p>
            <p><strong>Username:</strong> db_user</p>
            <p><strong>Password:</strong> Novigo2025!!</p>
        </div>
        
        <div class="info-section">
            <h2>🔧 Development Tools</h2>
            <p><strong>Xdebug:</strong> Available on port 9003</p>
            <p><strong>VS Code Server:</strong> <a href="http://localhost:13337" target="_blank">http://localhost:13337</a></p>
            <p><strong>IBM DB2:</strong> Client libraries installed at <code>/opt/ibm/clidriver</code></p>
        </div>
        
        <div class="info-section">
            <h2>📁 File Structure</h2>
            <p><strong>Workspace:</strong> <code>/workspaces</code></p>
            <p><strong>Web Root:</strong> <code>/var/www/html</code> (symlinked to workspace)</p>
            <p><strong>Configuration:</strong> <code>/workspaces/.devcontainer/conf/</code></p>
        </div>
    </div>
</body>
</html>
EOF

echo ""
echo "🎉 PHP Multi-Version Development Environment is ready!"
echo ""
echo "📝 Access VS Code: http://localhost:13337"
echo "🌐 Test PHP versions:"
echo "   - PHP 7.3: http://localhost:8073"
echo "   - PHP 7.4: http://localhost:8074"
echo "   - PHP 8.0: http://localhost:8080"
echo "   - PHP 8.2: http://localhost:8082"
echo "   - PHP 8.4: http://localhost:8084"
echo "🗄️  MariaDB: localhost:3306"
echo "🐛 Xdebug: localhost:9003"
echo ""
echo "Happy coding! 🚀"