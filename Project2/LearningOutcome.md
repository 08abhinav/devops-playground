# Project 2: Learning Outcomes

While working on this project, the steps looked simple on the surface, but the real learning came from debugging and understanding how Nginx actually behaves under the hood. I had worked with Nginx before this, but mostly in a basic or monolithic setup. In those cases, I never really dealt with proper architecture breakdown, virtual hosts, or real production-style debugging.

In this project, Nginx stopped being just a server and started behaving like a structured system with clear internal layers.

---

## 1. Nginx Architecture
Nginx is a web server that also works as a reverse proxy and load balancer.

It mainly operates in three roles:
- Web Server: serves static files (HTML, CSS, JS)
- Reverse Proxy: forwards requests to backend services
- Load Balancer: distributes traffic across multiple servers

But the most important concept is its **event-driven architecture**.

### Master–Worker Model

Nginx runs using a master process and multiple worker processes:

**Master Process**
- Reads configuration (`nginx.conf`)
- Manages worker processes
- Handles reloads and restarts

**Worker Processes**
- Handle actual client requests
- Read files from disk
- Process connections asynchronously

If a worker crashes, the master process can restart it.

### Why Nginx is fast

Nginx does not create a thread per request. Instead, it uses an event-driven model where a single worker can handle thousands of connections using non-blocking I/O.

---

## 2. Request Lifecycle
When you visit a domain like `blog.example.com`, the following happens:

### Step 1: DNS Resolution

The domain is translated into an IP address.

### Step 2: Request reaches Nginx

Nginx receives the HTTP request from the browser.

### Step 3: Server Block Matching
Nginx checks the `server_name` inside configuration files:
/etc/nginx/sites-available/<your-server>

It matches the incoming Host header with the correct server block.

### Step 4: Root Resolution
Nginx maps the request to a filesystem path:
root /var/www/server1;

So a request to `/` becomes:
/var/www/server1/index.html

### Step 5: Response

Nginx returns:
- HTML
- CSS
- JS

Or forwards the request to a backend if configured as reverse proxy.

---

## 3. Nginx Configuration Flow (Actual Internal Flow)
When Nginx starts, everything begins from:
/etc/nginx/nginx.conf

This file acts as the main entry point.

### Event Block

events {
    worker_connections 768;
}
This defines how many simultaneous connections a worker can handle.

http {
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    include /etc/nginx/sites-enabled/*;
}

This is where all web-related configuration lives.
Key Insight
nginx.conf does NOT define individual websites. It only loads them using the include directive.

## 4. sites-available vs sites-enabled

Inside /etc/nginx/ there are two important directories:

### sites-available
- Contains all website configurations
- These configs are inactive unless enabled

### sites-enabled
- Contains active websites
- These are symlinks to sites-available

This separation allows enabling/disabling websites without deleting configuration files.

## 5. Linking sites-available to sites-enabled

We use symbolic links:
```bash
sudo ln -s /etc/nginx/sites-available/server1 /etc/nginx/sites-enabled/server1
```

To verify
```bash
ls -lt /etc/nginx/sites-enabled/
```

Ouptut
```bash
server1 -> /etc/nginx/sites-available/server1
```
This means server1 is now active.

## 6. Server Block Configuration

Each file inside sites-available defines a virtual host:

```nginx
server {
    listen 80;
    server_name server1.abhinavnegi.site;

    root /var/www/server1;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Important parts:
- server_name → domain matching
- root → maps domain to filesystem
- location → request routing rules

## 7. Directory Structure Mapping
A clean mapping looks like:

```nginx
/var/www/server1  → server1.example.com
/var/www/server2  → server2.example.com
```

Each domain has its own isolated directory.

## 8. Debugging Strategies

This project taught me that debugging is more important than configuration.

1. Check service status
```bash
sudo systemctl status nginx
```

2. Validate configuration
```bash
sudo nginx -t
```

This is the most important debugging command. It catches:

- syntax errors
- missing files
- broken symlinks

3. Check logs
```bash
sudo cat /var/log/nginx/error.log
```

Common error patterns:

- open() → file/path issue
- bind() → port already in use
- permission denied → access issue

## 9. Key Learning
- Nginx is not just a server, it is a structured system
- Virtual hosting is based on domain-to-directory mapping
- Symlinks are critical in production setups
- Small mistakes in paths can break the entire service
- Debugging is a layered process, not guesswork
- Understanding logs is more important than memorizing config
