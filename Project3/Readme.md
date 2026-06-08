# Project 3: Setup Load Balancing for Static Website Using Nignx

In this project, we will deploy three AWS servers and configure Nginx as a Layer 7 Load Balancer.  
Two servers will host static websites, while the third server will distribute incoming traffic between them using Nginx load balancing.

## Project Tasks
1. Deploy three servers
2. Set up static websites on two servers using Nginx. Make a small change in the index.html file of one of the websites to differentiate between two servers.
3. Set up Nginx on the third server. It will act as a load balancer.
4. Configure Nginx to load and balance traffic between two static websites.
5. Add the Nginx Load balancer IP to the DNS A record.
6. Try accessing the website. Every time you reload the website you should see a different index.html.
7. Try different Nginx load-balancing algorithms and options.
8. Understand L7 load balancing.

### Step1: Deploy three servers
To provision the infrastructure, I used the IaC (Infrastructure as Code) tool Terraform.  
Using Terraform, I created three AWS EC2 instances.

Navigate to the `awsInfra` directory and review the Terraform configuration files carefully.

Run the following commands:

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

After the infrastructure is created, Terraform will display the public IP addresses of all three servers.

Now connect to the servers using SSH:

```bash
ssh -i <your-pem-file> ubuntu@<your-server-public-ip>
```

Once connected, verify whether Nginx is installed and running:

```bash
sudo systemctl status nginx
```

You should see the service in an active/running state because Nginx installation was automated using a User Data bash script during server provisioning.

Repeat the same verification process for the other two servers.

---

### Step2: Set up static websites on two servers using Nginx. Make a small change in the index.html file of one of the websites to differentiate between two servers.

In this step, we will configure static websites on `server1` and `server2`.

Create two different `index.html` files or download static website templates from the internet.  
Make a small visual/text change in one website so that traffic switching can be identified easily during load balancing.

## Method 1: Create the File Directly on the Server

SSH into `server1` and navigate to the default Nginx web root directory:

```bash
cd /var/www/html
```

Create the `index.html` file:

```bash
sudo vim index.html
```

Paste your HTML code and save the file.

Repeat the same process for `server2`.

---

## Method 2: Copy the File from Your Local Machine
If you already have an `index.html` file on your local system, transfer it using SCP:

```bash
scp -i <your-pem-file> index.html ubuntu@<your-server-ip>:/home/ubuntu
```

After the file is copied, SSH into the server and move it to the Nginx web directory:

```bash
sudo mv /home/ubuntu/index.html /var/www/html/
```

Repeat the same process for `server2`.

---

# Step 3: Configure the Third Server as an Nginx Load Balancer

Now SSH into `server3`, which will act as the Load Balancer.

Navigate to the Nginx configuration directory:

```bash
cd /etc/nginx
```

Remove the default Nginx configuration files:

```bash
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
```

Now move into the `sites-available` directory:

```bash
cd /etc/nginx/sites-available
```

Create a new configuration file:

```bash
sudo vim loadbalancer
```

---

# Step 4: Configure Load Balancing Between Backend Servers
Inside the `loadbalancer` file, add the following configuration:

```nginx
upstream backend {
    server <server1-private-ip>;
    server <server2-private-ip>;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;
    }
}
```

Explanation:
- `upstream backend` defines a pool of backend servers
- `proxy_pass` forwards incoming client requests to the backend pool
- Nginx will distribute traffic between both servers automatically

Save and exit Vim:

```bash
:wq
```

Now create a symbolic link:

```bash
sudo ln -s /etc/nginx/sites-available/loadbalancer /etc/nginx/sites-enabled/
```

Test the Nginx configuration:

```bash
sudo nginx -t
```

Restart Nginx:

```bash
sudo systemctl restart nginx
```

---

# Step 5: Add the Load Balancer IP to the DNS A Record

Now configure DNS for your Load Balancer.

Go to your domain registrar or DNS provider and create a new A record.

Example:

| Type | Name | Value |
|------|------|------|
| A | loadbalancer | <server3-public-ip> |

This maps your subdomain to the Nginx Load Balancer server.

---

# Step 6: Verify Load Balancing
Now access your configured domain/subdomain in the browser:

```text
http://loadbalancer.yourdomain.com
```

Refresh the page multiple times.

You should notice different versions of the website being served alternately.  
This confirms that Nginx is successfully distributing traffic between both backend servers.

---
# Step 7: Explore Different Nginx Load-Balancing Algorithms

By default, Nginx uses the **Round Robin** algorithm.

In Round Robin:
- Requests are distributed sequentially
- Each backend server gets requests one after another
- Traffic distribution is time/order based

Example:

```nginx
upstream backend {
    server <server1-private-ip>;
    server <server2-private-ip>;
}
```

---

## 1. Least Connections

This method sends traffic to the server with the fewest active connections.

Useful when:
- Requests take different amounts of time
- One server may become overloaded

Configuration:

```nginx
upstream backend {
    least_conn;

    server <server1-private-ip>;
    server <server2-private-ip>;
}
```

---

## 2. IP Hash

This method routes requests based on the client IP address.

Useful for:
- Session persistence
- Keeping users connected to the same backend server

Configuration:

```nginx
upstream backend {
    ip_hash;

    server <server1-private-ip>;
    server <server2-private-ip>;
}
```

---

# Step 8: Understanding Layer 7 (L7) Load Balancing
Nginx acts as a **Layer 7 Load Balancer** because it operates at the **Application Layer** of the OSI model.

Unlike Layer 4 load balancing, which works only with IP addresses and ports, Layer 7 load balancing understands:
- URLs
- HTTP headers
- Cookies
- Request paths
- Hostnames

This allows intelligent traffic routing.

---

## Example Use Cases of L7 Load Balancing
### Route Traffic Based on URL Path

```nginx
location /api {
    proxy_pass http://backend_api;
}

location /images {
    proxy_pass http://backend_images;
}
```

---

### Route Traffic Based on Domain Name

```nginx
server_name api.example.com;
```

---

### SSL Termination

Nginx can handle HTTPS encryption and forward plain HTTP traffic internally to backend servers.

Benefits:
- Reduced backend server load
- Centralized SSL management
- Better performance

---

## Why L7 Load Balancing is Important
Advantages:
- Better traffic control
- Session persistence support
- Smarter routing decisions
- SSL termination support
- Improved scalability
- Better fault tolerance
- Easier microservices routing

---

# Conclusion
In this project, we:
- Provisioned infrastructure using Terraform
- Hosted static websites using Nginx
- Configured Nginx as a reverse proxy and load balancer
- Implemented DNS mapping
- Explored multiple load-balancing algorithms
- Understood Layer 7 load balancing concepts
