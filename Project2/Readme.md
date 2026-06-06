# Project 2: Setup Multiple Static Websites on a Single Server Using Nginx Virtual Hosts


## Project Tasks

1. Create two subdomains
2. Install and configure Nignx on a server
3. Create two website directories with two different website templates.
4. Configure the Virtual host to point two subdomains to two different website directories.
5. Add the IP of the server as A record to the two subdomains.
6. Validate the setup accessing the subdomains.
7. Create a wildcard Letsencrypt SSL certificate for the root Domain.
8. Configure wildcard SSL on Nginx for two websites.
9. Validate the subdomain websites' SSL using OpenSSL utility.

### Step1: Create two subdomains
Go to your DNS registrar, navigate to your domain and create two subdomains.
While creating the subdomains, you can also complete Step 5 by adding an A record that points both subdomains to your server's public IP address.

Example:
Type	Name	    Value
A	   server1 	    YOUR_SERVER_IP
A	   server2	    YOUR_SERVER_IP

After DNS propagation, both subdomains should resolve to your server.


### Step2: Install and configure Nignx on a server

Using the same infrastructure which was used in [Project1](https://github.com/08abhinav/devops-playground/tree/master/Project1/awsInfra)

1. Install Nginx

```bash
sudo apt update -y
sudo apt install nginx -y
```

2. Enbale and start nginx and verify its status

```bash
sudo systemctl enbale nginx
sudo systemctl start nginx

sudo systemctl status nginx
```

### Step3: Create two website directories with two different website templates.
Navigate to /var/www/html/ and create two directory as server1 and server2. I am using directory name as server1 and server2 is becuase my subdomains have same name so for sake of simplicity I am using these names.

After creating the directory, create separate html files for both the directory.

Heirarchy inside /var/www/ should look like:

```text
www/
|  ├── html/
|  |    └── index.html
|  |
|  ├── Server1/
|  |   └── index.html
|  |  
|  └── Server2/
|      └── index.html
```

Now navigate to /etc/nginx/sites-available and inside this create a file using

```bash
sudo vim server1
```

Configure the below server

```text
server{
    listen 80;
    server_name server1.example.com/<replace-with-your-subdomain>;

    root /var/www/server1
    index index.html

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Now after configuring the server1 do the same thing for server2 as done for server.
Now link your virtual host so that it could server actual traffic.

```bash
sudo ln -s /etc/nginx/sites-available/server1 /etc/nginx/sites-enabled/server1
sudo ln -s /etc/nginx/sites-available/server2 /etc/nginx/sites-enabled/server2
```

After successfully linking your servers, test your configuration

```bash
sudo nginx -t
```
If everything is configured correctly, you should see:

```text
syntax is ok
test is successful
```

Restart nginx service

```bash
sudo systemctl restart nginx
```

### Step 5: Configure DNS A Records

This step can be completed together with Step 1 while creating the subdomains.

### Step 6: Validate the Setup

Open both subdomains in your browser:

- http://server1.example.com
- http://server2.example.com

Both websites should load independently from their respective directories.
You can also validate using curl:

```bash
curl http://server1.example.com
curl http://server2.example.com
```

## Step 7: Configure SSL using Let's Encrypt
To make your website accessible over HTTPS, install a free SSL certificate using Let's Encrypt.
Install Certbot and the Nginx plugin:

```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
```

Now generate and configure the SSL certificate:

```bash
sudo certbot --nginx
```

During setup:

- Enter your email address.
- Accept the terms and conditions.
- Select your domain name.
- Choose the option to redirect HTTP traffic to HTTPS.

After successful configuration, try opening:

```txt
https://<your-domain>
```

You should now see your website over HTTPS.

---

## Step 8: Validate SSL Certificate

To verify the SSL certificate, run:

```bash
openssl s_client -connect <your-domain>:443
```

If everything is configured correctly, you should see output similar to:

```txt
Verify return code: 0 (ok)
```

You can also validate your SSL configuration online using SSL Labs.
If the certificate is valid, your website is now securely accessible over HTTPS.

---

## Note
Destroy the aws infrastructure provisioned using Terraform

```bash
terraform destroy -auto-approve
```

Also manually release the Elastic Ip to save AWS cost.
