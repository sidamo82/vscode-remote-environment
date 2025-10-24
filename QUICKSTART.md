# Quick Start Guide

Get up and running with the PHP Multi-Version Development Environment in minutes!

## 🚀 Create Your Workspace

1. **Go to your Coder dashboard**
2. **Click "Create Workspace"**
3. **Select "PHP Multi-Version Development" template**
4. **Configure resources:**
   - CPU Cores: 2-4 (recommended: 4)
   - Memory: 4-8 GB (recommended: 6GB)
5. **Click "Create Workspace"**

⏳ **Wait 5-10 minutes** for the environment to build (first time only)

## 🎯 Access Your Environment

Once your workspace is ready, you'll see these apps in your dashboard:

### 🖥️ Development Environment
- **VS Code** - Your main development interface
- Click to open VS Code in your browser

### 🐘 PHP Test Servers
- **PHP 7.3 Server** (Port 8073)
- **PHP 7.4 Server** (Port 8074) 
- **PHP 8.0 Server** (Port 8080)
- **PHP 8.2 Server** (Port 8082)
- **PHP 8.4 Server** (Port 8084)

## 🏃‍♂️ Your First Steps

### 1. Open VS Code
Click the "VS Code" app from your workspace dashboard.

### 2. Create a Test File
Create a new file: `/workspaces/test.php`

```php
<?php
echo "<h1>Hello from PHP " . phpversion() . "!</h1>";
echo "<p>Server: " . $_SERVER['SERVER_SOFTWARE'] . "</p>";
echo "<p>Current time: " . date('Y-m-d H:i:s') . "</p>";

// Test database connection
try {
    $pdo = new PDO('mysql:host=localhost;dbname=my_database', 'db_user', 'Novigo2025!!');
    echo "<p>✅ Database connection successful!</p>";
} catch(PDOException $e) {
    echo "<p>❌ Database connection failed: " . $e->getMessage() . "</p>";
}
?>
```

### 3. Test Different PHP Versions
- Open each PHP server app (PHP 7.3, 8.0, etc.)
- Navigate to your `test.php` file
- See how your code runs on different PHP versions!

## 🗄️ Database Access

### Connection Details
- **Host:** `localhost`
- **Port:** `3306`
- **Database:** `my_database`
- **Username:** `db_user`
- **Password:** `Novigo2025!!`

### Quick Database Test
```php
<?php
// Create connection
$mysqli = new mysqli("localhost", "db_user", "Novigo2025!!", "my_database");

// Check connection
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}

echo "Connected successfully to MariaDB!";

// Create a test table
$sql = "CREATE TABLE IF NOT EXISTS users (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(30) NOT NULL,
    lastname VARCHAR(30) NOT NULL,
    email VARCHAR(50),
    reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)";

if ($mysqli->query($sql) === TRUE) {
    echo "<br>Table 'users' created successfully";
} else {
    echo "<br>Error creating table: " . $mysqli->error;
}

$mysqli->close();
?>
```

## 🐛 Debug with Xdebug

Xdebug is pre-configured and ready to use!

### VS Code Debug Setup
1. Open VS Code
2. Go to Run and Debug (Ctrl+Shift+D)
3. Create a `launch.json` configuration:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "/workspaces"
            }
        }
    ]
}
```

4. Set breakpoints in your PHP code
5. Start debugging session
6. Load your PHP page in browser

## 📁 File Organization

Your workspace directory structure:
```
/workspaces/
├── your-project-files/     # Your PHP projects go here
├── test.php               # Test files
├── .devcontainer/         # Environment configuration
└── startup.sh            # Startup script
```

## 🎨 Customize Your Environment

### Install Additional PHP Extensions
```bash
# SSH into your workspace
coder ssh your-workspace-name

# Enter the devcontainer
docker exec -it devcontainer bash

# Install extensions (example)
apt-get update
apt-get install php8.0-redis php8.0-mongodb
```

### Add VS Code Extensions
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search and install extensions like:
   - PHP DocBlocker
   - PHP Namespace Resolver
   - Laravel Extension Pack
   - Twig Language 2

## 🔧 Troubleshooting

### Services Not Loading?
1. Wait a few more minutes (initial setup takes time)
2. Check workspace logs in Coder dashboard
3. Restart workspace if needed

### Can't Connect to Database?
1. Verify you're using correct credentials
2. Make sure you're connecting to `localhost:3306`
3. Check if MariaDB container is running:
   ```bash
   docker ps | grep mariadb
   ```

### PHP Version Not Working?
1. Check if the specific PHP-FPM container is running:
   ```bash
   docker ps | grep php-fpm
   ```
2. Restart docker-compose services:
   ```bash
   cd /workspaces
   docker-compose -f .devcontainer/docker-compose.yml restart
   ```

## 📚 Next Steps

1. **Clone your projects** into `/workspaces/`
2. **Set up Git** with your credentials
3. **Install Composer** dependencies
4. **Configure your preferred VS Code settings**
5. **Start developing!** 🎉

## 💡 Pro Tips

- **Use workspaces efficiently**: Keep your projects organized in subdirectories
- **Multiple PHP versions**: Test compatibility by switching between server apps
- **Database management**: Use the built-in MariaDB for local development
- **Persistent storage**: Your files in `/workspaces/` persist between sessions
- **Resource monitoring**: Check CPU/Memory usage in Coder dashboard

## 🆘 Need Help?

1. Check the detailed [README.md](README.md)
2. Review [DEPLOYMENT.md](DEPLOYMENT.md) for advanced configuration
3. Contact your Coder administrator
4. Check Coder documentation: https://coder.com/docs

---

**Happy Coding! 🚀**