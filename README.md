# Newsaas
News as a Service is a tool, which uses GCP free tier to automate creation and delivery of ebook magazines based on new articles downloaded from your favourite website with Calibre recipes. 
Together with Kindle feature of ebook delivery via email it allows for an effortless subscription-like experience.

Calibre built-in recipes for fetching articles from popular websites: https://github.com/kovidgoyal/calibre/tree/master/recipes

Documentation of this Calibre feature: https://manual.calibre-ebook.com/news.html

Documentation of Amazon Send to Kindle feature: https://www.amazon.com/gp/help/customer/display.html/ref=hp_left_v4_sib?ie=UTF8&nodeId=G7NECT4B4ZWHQ8WV

**GCP free tier limits:**
- Cloud Run - https://cloud.google.com/free/docs/gcp-free-tier/#cloud-run
- Cloud Scheduler - https://cloud.google.com/scheduler/pricing

**The project consists of:**
- `container` folder with code for creation of a Docker image, which contains Calibre and wraps its headless version into Flask based REST API allowing GCP Cloud Run deployment. 
The Docker image is built and published to ghcr.io (https://github.com/pmalkiewicz/newsaas/pkgs/container/newsaas) using Github actions, so there is no need to build it on your own, unless custom modifications are required.
- `terraform` folder with IaaC code for GCP deployment of Cloud Run instance together with Cloud Scheduler to trigger news fetching and delivery

## Security

⚠ The docker container itself is not designed to be exposed publicly to the Internet on its own! ⚠ 

It does not contain any authentication or authorization logic, the authentication to its REST API is protected via Cloud Run requiring GCP IAM Cloud Run Invoker permissions.

## Usage
**Prerequisites:**
- GCP account
- Email account credentials with SMTP access added to "Approved Personal Document Email List" on Amazon website. Gmail might not be the best choice given security features blocking suspicious log-ins triggering on GCP ephemeral IPs.

**Deployment:**
1. Install Terraform (https://www.terraform.io/downloads.html) and Gcloud SDK (https://cloud.google.com/sdk/docs/install) 
2. Clone this project
3. Enter `terraform` directory and run `terraform init`
4. Log into GCP with `gcloud auth application-default login`
5. Run `terraform apply` and input the variables when prompted.
