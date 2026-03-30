# Student Registration Portal on AWS

A full-stack **Student Registration Portal** built with **Next.js**, **Prisma**, and **PostgreSQL**, then deployed on **AWS** using a secure private-subnet architecture.

This project allows students to register, log in, and access a portal backed by a PostgreSQL database. The application was packaged, uploaded to S3, pulled onto a private EC2 instance during bootstrap, migrated automatically with Prisma, and exposed securely over HTTPS through an Application Load Balancer.

## Project Overview

The goal of this project was to build and deploy a production-style student portal that demonstrates both application development and cloud infrastructure skills.

The application includes:

- student registration
- student login
- protected dashboard access
- PostgreSQL-backed persistence
- Prisma schema migration on deployment
- secure HTTPS access
- monitoring and alerting with CloudWatch and SNS

## Architecture

The solution was deployed using the following architecture:

- **Cloudflare** for DNS management
- **AWS Certificate Manager (ACM)** for SSL/TLS certificate
- **Application Load Balancer (ALB)** in public subnets
- **Ubuntu EC2 instance** in a private subnet hosting the Next.js app
- **Amazon RDS PostgreSQL** in private DB subnets
- **Amazon S3** for storing the application bundle
- **CloudWatch + SNS** for monitoring and notifications
- **Bastion Host** for secure SSH access to the private EC2 instance

## Architecture Diagram

Add your diagram here:


Architecture Diagram: See evidence folder


## Tech Stack

### Application
- Next.js
- React
- Prisma ORM
- PostgreSQL
- Node.js

### AWS / Infrastructure
- VPC
- Public and Private Subnets
- Internet Gateway
- NAT Gateway
- EC2
- RDS PostgreSQL
- Application Load Balancer
- ACM
- S3
- CloudWatch
- SNS
- Security Groups

## Key Features

- Full-stack Next.js application
- Student registration workflow
- Login and protected portal access
- PostgreSQL database integration
- Prisma migrations during deployment
- Private EC2 deployment model
- HTTPS-enabled public access
- Monitoring and alert notifications

## Deployment Workflow

1. Build or package the application source
2. Upload the application zip to Amazon S3
3. Launch a private Ubuntu EC2 instance
4. Use EC2 user data to:
   - install dependencies
   - install AWS CLI v2
   - download the zip from S3
   - extract the application
   - set environment variables
   - connect to PostgreSQL
   - run Prisma generate
   - run Prisma migrations
   - build the application
   - start the service with systemd
5. Route public traffic through the ALB
6. Secure the application with ACM and Cloudflare DNS
7. Monitor the RDS instance with CloudWatch alarms and SNS notifications

## Networking Design

- **Public subnets**
  - ALB
  - Bastion host
  - NAT Gateway

- **Private subnet**
  - Application EC2 instance

- **Private DB subnet group**
  - RDS PostgreSQL instance

### Traffic Flow

User → Cloudflare → ALB → Private EC2 (Next.js app) → RDS PostgreSQL

## Security Design

- RDS deployed with **no public access**
- EC2 application server deployed in a **private subnet**
- SSH access handled through a **bastion host**
- Security groups restricted traffic between tiers
- HTTPS termination handled by **ALB + ACM**
- Cloudflare used for domain routing and TLS support

## Bootstrap / User Data Highlights

The EC2 bootstrap script performs the following:

- installs system packages
- installs AWS CLI v2 from the official zip installer
- installs Node.js
- downloads the application zip from S3
- handles the top-level folder structure in the uploaded zip
- exports `DATABASE_URL`
- verifies PostgreSQL connectivity
- runs `npx prisma generate`
- runs `npx prisma migrate deploy`
- builds the Next.js app
- deploys the standalone build output
- starts the app as a `systemd` service

## Problems Encountered and Fixes

This project included several real-world troubleshooting moments:

### 1. AWS CLI v2 installation
Installing AWS CLI with `apt` was not reliable for this workflow.

**Fix:** Installed AWS CLI v2 using the official zip installer.

### 2. Uploaded zip structure
The uploaded application zip contained a top-level `student-registration-portal` folder, which caused path issues during bootstrap.

**Fix:** Updated the script to detect and `cd` into the correct folder after unzip.

### 3. Prisma version mismatch
Prisma 7 introduced issues with the existing application setup.

**Fix:** Pinned `prisma` and `@prisma/client` to `6.19.0`.

### 4. `npm ci` failure
`package-lock.json` had not been updated after dependency version changes.

**Fix:** Switched from `npm ci` to `npm install`.

### 5. Environment variable handling
Prisma commands failed until the database connection string was available in the environment.

**Fix:** Exported `DATABASE_URL` before running Prisma commands.

### 6. unzip exit code warning
`unzip` returned exit code `1`, which was non-fatal, but cloud-init treated it as failure.

**Fix:** Updated the bootstrap logic to tolerate the warning.

### 7. systemd startup
The app did not initially start correctly using the expected runtime path.

**Fix:** Updated the service to use the **Next.js standalone output**.

### 8. ALB 504 Gateway Timeout
The ALB was reachable but unable to communicate with the target.

**Fix:** Adjusted ALB security group outbound rules so traffic could reach the EC2 target on port `3000`.

## Validation Evidence

The following checks were completed successfully:

- application health endpoint returned:
  ```json
  {"status":"ok","database":"connected"}
  
- student-portal service started successfully on port 3000
- Prisma migration completed successfully
- local EC2 health checks worked
- ALB successfully routed traffic to the private EC2 instance
- HTTPS was enabled successfully
- RDS connectivity from EC2 was confirmed
- CloudWatch alarm for RDS CPU utilization was configured
- Example Commands Used
- Health Check
- curl http://localhost:3000/api/health
- Service Status
- sudo systemctl status student-portal
- Check Listening Port
- sudo ss -tulpn | grep 3000
- Test PostgreSQL Connectivity
- PGPASSWORD='your-password' psql "host=YOUR_RDS_ENDPOINT port=5432 dbname=student_portal user=postgres sslmode=require" -c 'SELECT 1;'

Repository Structure
.
├── app/
├── prisma/
├── public/
├── infra/
│   ├── user-data.sh
│   └── create-rds-cpu-alarm.sh
├── package.json
├── next.config.js
└── README.md

Future Improvements
### use Secrets Manager for database credentials
### add CI/CD with GitHub Actions
### deploy with Auto Scaling Group instead of single EC2 instance
### introduce WAF for extra protection
### add password reset and role-based access control
### containerize the application with Docker
### deploy to ECS or EKS for orchestration

Lessons Learned
This project reinforced the importance of:

- understanding networking and security groups
- planning private/public subnet architecture properly
- handling app packaging carefully during bootstrap
- validating runtime paths in production deployments
- treating troubleshooting as a core DevOps skill, not a side task

Author
Chukwuka Agupugo

LinkedIn: www.linkedin.com/in/donchucky21
Medium:  https://medium.com/@donchucky21

License

This project is for educational and portfolio purposes.
  
