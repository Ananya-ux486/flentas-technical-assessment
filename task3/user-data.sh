#!/bin/bash
# User data script for Auto Scaling Group instances

# Update system
sudo yum update -y

# Install Nginx
sudo yum install nginx -y

# Download resume from S3
sudo curl -o /usr/share/nginx/html/resume.pdf "${resume_url}"

# Create HTML page
sudo cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ananya Dixit - Resume (High Availability)</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        header {
            text-align: center;
            padding-bottom: 20px;
            border-bottom: 3px solid #667eea;
            margin-bottom: 20px;
        }
        h1 { color: #667eea; font-size: 2.5em; margin-bottom: 10px; }
        .subtitle { color: #666; font-size: 1.2em; }
        .ha-badge {
            display: inline-block;
            background: #28a745;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            margin-top: 10px;
        }
        .buttons {
            text-align: center;
            margin: 20px 0;
        }
        .btn {
            display: inline-block;
            padding: 12px 30px;
            background: #667eea;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 0 10px;
            font-weight: bold;
            transition: background 0.3s;
        }
        .btn:hover { background: #764ba2; }
        .pdf-container {
            width: 100%;
            height: 800px;
            border: 2px solid #ddd;
            border-radius: 5px;
            margin-top: 20px;
        }
        footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #eee;
            color: #888;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Ananya Dixit</h1>
            <p class="subtitle">Resume</p>
            <span class="ha-badge">✓ High Availability Enabled</span>
        </header>

        <div class="buttons">
            <a href="resume.pdf" class="btn" download>Download Resume (PDF)</a>
            <a href="resume.pdf" class="btn" target="_blank">Open in New Tab</a>
        </div>

        <div class="pdf-container">
            <embed src="resume.pdf" type="application/pdf" width="100%" height="100%">
        </div>

        <footer>
            <p>Hosted on AWS with High Availability Architecture</p>
            <p>ALB → Auto Scaling Group → EC2 Instances (Private Subnets)</p>
            <p>GitHub: <a href="https://github.com/Ananya-ux486/flentas-technical-assessment" style="color: #667eea;">github.com/Ananya-ux486/flentas-technical-assessment</a></p>
        </footer>
    </div>
</body>
</html>
EOF

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Disable firewall
sudo systemctl stop firewalld 2>/dev/null || true
sudo systemctl disable firewalld 2>/dev/null || true

echo "Setup complete! Instance ready for ALB."
