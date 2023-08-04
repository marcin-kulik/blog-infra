Create the new infrastructure to host the blog.

Requirements for the deployment:

 - 2 virtual machines hosted in Google Cloud Europe West 2 region
 - The virtual machines must be labelled with `environment: techBlog`
 - Each virtual machine must have 1 data drive
 - IAC must be reusable to allow deployments to other regions
 - RDP access from the office IP 80.193.23.74/32
 - Port 443 must be open to the internet
 - Configuration to ensure the infrastructure is highly available within the single region 
 - Deploy the infrastructure to the us-west1 region 
 - Add data drive for logs to the existing deployment