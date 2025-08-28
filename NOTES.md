Microservices CI/CD on AWS with Jenkins — Key Notes

Architecture
- Two Node.js services: `users` and `orders`
- Containerized with Docker; images stored in Amazon ECR
- Deployed to Amazon EKS (Kubernetes) using Deployments + Services
- CI/CD orchestrated by Jenkins using a declarative `Jenkinsfile`
- Infrastructure provisioned with Terraform: VPC, subnets, EKS, ECR

Flow
1) Developer pushes to main branch
2) Jenkins checks out code and builds Docker images
3) Jenkins logs in to ECR and pushes `users` and `orders` images
4) Jenkins updates EKS using `kubectl apply` with image URI substitution
5) Kubernetes rolls out changes with zero-downtime deployments

Why these choices
- Docker: consistency across dev/stage/prod
- ECR: regional, IAM-integrated container registry
- EKS: managed Kubernetes control plane, autoscaling worker nodes
- Jenkins: mature, extensible CI/CD with Pipeline-as-Code
- Terraform: declarative, idempotent infrastructure as code

Security & IAM
- Least-privilege IAM role for Jenkins with ECR and EKS permissions
- ECR image scanning on push (enabled in Terraform)
- kubectl access via `aws eks update-kubeconfig` and AWS auth

Reliability
- Readiness/liveness probes in Deployments
- Two replicas per service by default
- Rolling updates; quick rollback using `kubectl rollout undo`

Scalability
- Horizontal scaling by adjusting `replicas` or using HPA
- Separate services enable independent scaling and deployments

Cost Controls
- Small instance types for node group (`t3.small`)
- Destroy infra with `terraform destroy` when not needed

Observability (starter)
- `kubectl get pods -n microapps`, `kubectl logs`
- Add CloudWatch Container Insights or Prometheus/Grafana later

Local Dev
- `npm start` from `services/*`; test with `/health`, `/users`, `/orders`

Jenkins Parameters
- `AWS_REGION`, `ECR_ACCOUNT_ID`, `CLUSTER_NAME`, `ECR_URI_BASE`

Commands to demo
- Build images locally: `docker build -t users:dev services/users`
- Apply manifests: `kubectl apply -f k8s/namespace.yaml`
- Rollout status: `kubectl -n microapps rollout status deploy/users-deployment`
- View services: `kubectl -n microapps get svc,pods`

Trade-offs
- Minimal services; focus on CI/CD path
- Manual image URI substitution via `sed` for simplicity; could use Helm
- Single EKS node group; can expand to multiple instance types and AZs

Next Improvements
- Helm charts and values per environment
- Ingress (ALB) and external DNS
- GitOps with Argo CD or Flux
- Automated tests and code coverage in Jenkins
- CI for PRs; CD to staging/prod with approvals

What we implemented
- Bootstrapped two Node.js microservices (`services/users`, `services/orders`)
- Containerized both services with minimal production Dockerfiles
- Auth probes and Deployments/Services for each service under namespace `microapps`
- Jenkins declarative pipeline to build, push to ECR, and deploy to EKS
- Terraform provisioning for VPC, subnets, EKS cluster, and ECR repositories
- Helper scripts for ECR repo creation and EKS kubeconfig setup
- README with setup steps; NOTES for presentation

Mentor Q&A practice (10)
1) What problem does Terraform solve here?
- Declarative, versioned infra creation (VPC, EKS, ECR) with idempotent plans.

2) Why EKS over ECS/Fargate?
- Kubernetes portability, ecosystem, and fine-grained deployment controls (probes/rollouts).

3) How does the pipeline update images without editing YAML in git?
- It pipes manifests through a substitution of `REPLACE_ECR_URI` at deploy time.

4) How do you achieve zero-downtime deploys?
- Kubernetes Deployments with rolling update strategy + readiness probes.

5) Where are images stored and how is access controlled?
- Amazon ECR; Jenkins authenticates via AWS CLI; IAM governs push/pull.

6) How would you roll back a bad release?
- `kubectl -n microapps rollout undo deploy/<deploy-name>` or redeploy previous tag.

7) How do you scale the services?
- Increase `replicas` or add an HPA based on CPU/memory or custom metrics.

8) What security measures are in place?
- Least-privilege IAM, ECR image scanning, cluster access via AWS IAM authenticator.

9) How would you expose these services outside the cluster?
- Add an Ingress with AWS Load Balancer Controller (ALB) and external DNS.

10) What would you improve next for production?
- Helm charts, multi-env CI/CD, GitOps, secrets management (AWS Secrets Manager), observability stack.
