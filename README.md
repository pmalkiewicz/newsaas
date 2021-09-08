# Newsaas
News as a Service is a tool, which uses GCP free tier to automate creation and delivery of ebook magazines based on new articles downloaded from your favourite website with Calibre recipes. 
Together with Kindle feature of ebook delivery via email it allows for an effortless subscription-like experience.

Calibre built-in recipes for fetching articles from popular websites: https://github.com/kovidgoyal/calibre/tree/master/recipes

Documentation of this Calibre feature: https://manual.calibre-ebook.com/news.html

Documentation of Amazon Send to Kindle feature: https://www.amazon.com/gp/help/customer/display.html/ref=hp_left_v4_sib?ie=UTF8&nodeId=G7NECT4B4ZWHQ8WV

**GCP free tier limits:**
- Cloud Run (Only North American regions have free egress quota!) - https://cloud.google.com/free/docs/gcp-free-tier/#cloud-run
- Cloud Scheduler - https://cloud.google.com/scheduler/pricing

**The project consists of:**
- `container` folder with code for creation of a Docker image, which contains Calibre and wraps its headless version into Flask based REST API allowing GCP Cloud Run deployment. 
The Docker image is built and published to ghcr.io (https://github.com/pmalkiewicz/newsaas/pkgs/container/newsaas) using Github actions, so there is no need to build it on your own, unless custom modifications are required.
- `terraform` folder with IaaC code for GCP deployment of Cloud Run instance together with Cloud Scheduler to trigger news fetching and delivery. 
Dummy and empty App Engine app is also created as it is a Cloud Scheduler dependency (https://cloud.google.com/scheduler/docs#supported_regions)

## Security

⚠ The docker container itself is not designed to be exposed publicly to the Internet on its own! ⚠ 

It does not contain any authentication or authorization logic, the authentication to its REST API is protected via Cloud Run requiring GCP IAM Cloud Run Invoker permissions.

## Usage
**Prerequisites:**
- GCP account and GCP project
- Email account credentials with SMTP access added to "Approved Personal Document Email List" on Amazon website. Gmail might not be the best choice given security features blocking suspicious log-ins triggering on GCP ephemeral IPs.
- Terraform (https://www.terraform.io/downloads.html), gcloud SDK (https://cloud.google.com/sdk/docs/install) and Docker (https://docs.docker.com/engine/install/) installed

**Deployment:**
1. Clone this project `git clone https://github.com/pmalkiewicz/newsaas.git`
2. Given the lack of Cloud Run support for external container registries (https://cloud.google.com/run/docs/deploying#images) the ghcr.io URL cannot be passed to Cloud Run. GCP Container Registry or Artifact Registry needs to be used. Artifact Registry has only 500MB of free storage, which is unsufficient for calibre image (over 1.5GB). Container Registry (GCR) uses Cloud Storage, which offers 5GB of free storage. The image needs to be downloaded from ghcr.io and uploaded to GCR:
- authenticate to GCP with gcloud SDK `gcloud auth login`
- enable GCR API `gcloud services enable containerregistry.googleapis.com`
- configure Docker command line tool authentication to GCR `gcloud auth configure-docker`
- pull image from ghcr.io `docker image pull ghcr.io/pmalkiewicz/newsaas:main`
- tag it with your GCR url `docker image tag ghcr.io/pmalkiewicz/newsaas:main gcr.io/GCP_PROJECT_NAME/newsaas`
- push it to GCR `docker image push gcr.io/GCP_PROJECT_NAME/newsaas` and note the tag, it will be neeeded for `image` variable in terraform
2. Enter `terraform` directory and run `terraform init`
3. Log into GCP with `gcloud auth application-default login`
4. Run `terraform apply` and input the variables when prompted.
