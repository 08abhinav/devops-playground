# Project 1: Setup Static Website using Nginx
This project aims to help you understand how to host a static website using Nginx and configure DNS to make the website publicly accessible over the internet.

## Project Tasks

1. Buy a domain name from a domain registrar.
2. Spin up an Ubuntu server.
3. SSH into the server and install Nginx.
4. Download or create HTML website files.
5. Use SCP to copy files to the Nginx directory.
6. Validate the website using the server IP address.
7. Create an A record in DNS and point it to an Elastic IP.
8. Use `dig` to check DNS records.
9. Verify the website using the domain.
10. Create a Let's Encrypt certificate and configure Nginx.
11. Validate SSL using OpenSSL.

These are the tasks we will perform to achieve our final goal.
Instead of provisioning infrastructure manually using the AWS Console, we will automate the process using an Infrastructure as Code (IaC) tool called Terraform.

---

## Step 1: Buy a Domain
Go to a domain registrar such as GoDaddy and purchase a domain name.
This project will cover tasks **2, 3, 4, 5, 6, 7, 8, and 9** from the task list above.

---

## Step 2: Provision AWS Infrastructure using Terraform

Create an `awsInfra` directory. Inside this directory, create the following files and folders:

```txt
awsInfra/
│── network/
│   ├── main.tf
│   └── variables.tf
│
│── provider.tf
│── main.tf
│── variables.tf
```

### Directory Structure Explanation

#### `network/`
This is a Terraform module that helps us follow IaC best practices and create reusable infrastructure components.

Inside this module:

- `main.tf` → Contains networking resources such as VPC, subnets, route tables, security groups, etc.
- `variables.tf` → Contains variables used inside the networking module.

#### `provider.tf`
This file contains information about the cloud provider (AWS) and Terraform backend configuration used to manage state files.

#### `main.tf`
This file contains the main infrastructure resources such as the EC2 instance.

#### `variables.tf`
This file is used to manage variables used across the Terraform configuration.
Go through the `awsInfra` directory and try to understand what each file is doing.

If you want to learn about Terraform: [Click Here](https://medium.com/@abhinavnegi101/provisioning-aws-infrastructure-using-terraform-beginner-friendly-guide-182262f6cac5)
---

### Run Terraform Commands
After writing the Terraform configuration, run the following commands:

```bash
terraform init
terraform validate
terraform plan
terraform apply
``` 

Once Terraform completes successfully, your AWS infrastructure will be provisioned.

---

## Step 3: SSH into EC2 Instance

After provisioning, Terraform will display the public IP of your EC2 instance.
SSH into the instance using:

```bash
ssh -i <your-keypair-file-location> ubuntu@<your-instance-public-ip>
```

You are now connected to your server.

---

## Step 4: Install Nginx

Update packages and install Nginx:

```bash
sudo apt-get update -y
sudo apt install nginx -y
```

Check Nginx status:

```bash
sudo systemctl status nginx
```

If everything is working correctly, Nginx should be running.

---

## Step 5: Copy HTML Files to EC2 using SCP

Create a simple HTML page or download one from the internet.
Now copy the file from your local machine to EC2:

```bash
scp -i <your-keypair-file> <your-html-file> ubuntu@<your-instance-public-ip>:/home/ubuntu
```

This command copies your HTML file into the `/home/ubuntu` directory.

---

## Step 6: Move HTML File to Nginx Directory

After logging into the EC2 instance, move the HTML file to Nginx's root directory:

```bash
sudo mv index.html /var/www/html/
```

Now visit:

```txt
http://<your-instance-public-ip>
```

You should see your website content.

---

## Step 7: Configure Elastic IP

Go to the AWS Console.
Navigate to:

```txt
EC2 → Elastic IPs
```

Allocate a new Elastic IP and associate it with your `nginx-server` instance.
Using an Elastic IP ensures your public IP remains static even after instance restarts.

---

## Step 8: Configure DNS Record

Go to your domain registrar dashboard.
Create an **A Record** and point it to your Elastic IP.

Example:

```txt
Type: A
Host: @
Value: <your-elastic-ip>
TTL: 300
```

Optionally, add a `www` record:

```txt
Type: A
Host: www
Value: <your-elastic-ip>
TTL: 300
```

---

## Step 9: Validate DNS

Run:

```bash
dig <your-domain> +short
```

If DNS propagation is successful, it should return your Elastic IP.

Example:

```txt
3.108.xx.xx
```

Now open:

```txt
http://<your-domain>
```

You should see your website.

### Note

If your domain redirects to `/lander`, follow these steps:
Open the Nginx default configuration file:

```bash
sudo nano /etc/nginx/sites-available/default
```

Find:

```nginx
server_name _;
```

Replace it with:

```nginx
server_name yourdomain.com www.yourdomain.com;
```

Save the file and restart Nginx:

```bash
sudo systemctl restart nginx
```

Now try accessing your domain again.

---

## Step 10: Configure SSL using Let's Encrypt

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

## Step 11: Validate SSL Certificate

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

## Final Outcome

At this point, you have successfully:

- Provisioned infrastructure using Terraform
- Deployed an EC2 instance
- Installed and configured Nginx
- Hosted a static website
- Configured DNS records
- Associated an Elastic IP
- Enabled HTTPS using Let's Encrypt
- Validated SSL configuration

## Note
Destroy the aws infrastructure provisioned using Terraform

```bash
terraform destroy -auto-approve
```

Also manually release the Elastic Ip to save AWS cost.
