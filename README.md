# GCP Terraform Example Project

This repository provides an example Terraform project for setting up and managing infrastructure on Google Cloud Platform (GCP).

## Features

### 1. IAM Configuration
- **Deploy Service Account**: Deploy service account with respective permissions
- **Runtime Service Account**: Runtime service account with respective permissions

### 2. Alert Management
- **Slack Integration**: Set up alerts to notify a Slack channel for monitoring and incident response.

### 3. Artifact Registry
- **Container Repository**: Deploy an Artifact Registry to store and manage container images securely.

### 4. Cloud Run for Compute
- **API Service**: Host a serverless API with cost-efficient, request-based billing.
- **Worker Service**: Implement workers for asynchronous tasks, such as Pub/Sub message processing and scheduled jobs (Cron).
- **Cost Optimization**: Leverage request-based architecture for minimal cost.

### 5. Cloud Pub/Sub for Asynchronous Communcation
- **Topic / Subscription**: define topic and subscriptions in a declarative way
- **Dead lettering**: Every subscription automatically created with dead-letter topic and respective subscription

### 6. Cloud Scheduler
- **Scheduled Jobs**: Configure Cloud Scheduler for cron-like tasks, enabling automated workflows.

### 7. Cloud SQL with PostgreSQL
- **Database Insights**: Enable Query Insights for monitoring and performance analysis.
- **Networking**: Use both private IP and public IP (with SSL and Cloud SQL Proxy) for flexible connectivity.
- **Cloud Storage**: Seamlessly integrate with Cloud Storage for backups or external data sources.
- **Load Balancer**: Set up a load balancer to route traffic efficiently to API services running on Cloud Run.
- **VPC Networking**: Utilize a Virtual Private Cloud (VPC) with static IP egress.

## Benefits
- **Scalability**: Designed for growing workloads with minimal operational overhead.
- **Security**: Adheres to least-privilege access principles and secure networking practices.
- **Cost-Effective**: Utilizes serverless and managed services for optimal cost management.

## License
 This project use MIT license.
