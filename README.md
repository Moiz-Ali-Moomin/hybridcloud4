# Hybrid Cloud AWS Infrastructure (WordPress + MySQL + Bastion + NAT)

This Terraform project creates a **hybrid AWS infrastructure** using VPC, subnets (public & private), security groups, EC2 instances, Bastion host, NAT Gateway and routing — designed to host a **WordPress server with a MySQL backend** securely.

---

## 🧠 Project Summary

This repo defines infrastructure as code (IaC) using **Terraform** to provision:

✔ Virtual Private Cloud (VPC)  
✔ Public & private subnets  
✔ Internet Gateway & NAT Gateway  
✔ Security groups for web, database & bastion hosts  
✔ EC2 instances for:
- **WordPress web server**
- **MySQL database server**
- **Bastion host** for secure SSH access  
✔ Networking & routing between components (public → private)

---

## 📁 Repo Structure

hybridcloud4/
├── main.tf # Main Terraform config file (all AWS resources)
├── README.md # This documentation

yaml
Copy code

The entire infra is defined in **main.tf** for simplicity.

---

## 🚀 What This Code Builds

### 🔹 Networking
- **VPC** with CIDR `192.168.0.0/16`
- **Public Subnet (ap-south-1a)** – Internet-facing
- **Private Subnet (ap-south-1b)** – Backend services
- **Internet Gateway** – Public internet access
- **NAT Gateway** – Outbound access from private subnet

---

### 🔹 Security Groups
Each component gets network rules:

| SG | Purpose |
|----|---------|
| webserver_sg | Allow HTTP (80) + SSH (22) |
| database_sg | Allow MySQL (3306) from web |
| allow_bastion_sg | Allow SSH from anywhere |
| bastion_sg | SSH access for admin |

---

### 🔹 Compute Instances
| Instance | Purpose | Subnet | SG |
|----------|---------|--------|----|
| `aws_instance.wordpress` | WordPress Server | Public | webserver_sg |
| `aws_instance.mysql` | MySQL Database | Private | database_sg, allow_bastion_sg |
| `aws_instance.bastion` | Bastion Host | Public | bastion_sg |

---

### 🔹 Routing
- **Public subnet** routes via Internet Gateway
- **Private subnet** routes via NAT Gateway for outbound

---

## 🧩 How It Works

1. **Terraform Provider:** Configures AWS region & profile  
2. **VPC + Subnets:** Creates network segments  
3. **Security Groups:** Controls traffic access  
4. **EC2 Instances:** Deploys WordPress + Database + Bastion server  
5. **NAT Gateway:** Enables private instances to reach internet securely

---

## 📦 Prerequisites

Before you run this, ensure:

✔ AWS CLI installed & configured  
✔ AWS credentials/profile present (`~/.aws/credentials`)  
✔ Terraform installed (>= 1.x)

Example credentials file:

[Moiz]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

yaml
Copy code

---

## 🛠️ Quick Setup

1. **Initialize Terraform**

```bash
terraform init
Validate configuration

bash
Copy code
terraform validate
Review what will be created

bash
Copy code
terraform plan
Apply provision

bash
Copy code
terraform apply
📍 After Deployment
✔ WordPress instance will be accessible via public IP
✔ MySQL in private subnet (secured)
✔ Bastion host can SSH into private resources
✔ You can extend this to add an ALB/ELB, auto-scaling, S3 backups, RDS, etc.

📌 Notes
⭐ Uses real AWS resources — charges may apply
⭐ Instance type: t2.micro (eligible for Free Tier)
⭐ Customize AMIs, CIDRs and regions as needed

🚀 Next Steps
You can enhance this infra by:

Making WordPress autoscale behind load balancer

Using RDS instead of EC2 MySQL

Adding Terraform modules for reusability

Integrating CI/CD (GitHub Actions / Terraform Cloud)

📄 License
This project is open-source and available to use & extend.

yaml
Copy code

---

If you want, I can also ✔ generate a **Terraform variables file + outputs file**, ✔ split into reusable modules, or ✔ add **architecture diagram + live demo screenshot** to make the README even more 🔥 for recruiters. Just ask!
::contentReference[oaicite:0]{index=0}
