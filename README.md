# tf-aws-ansible-nginx

Repository to create AWS EC2 Instanse with Nginx and Telegraf installed and dockerized

Tools: **Telegraf** **Nginx** **Terraform** **Ansible** **Docker**

## Required

1. Install web server of your choice in docker image and run it on that instance.
   > Webserver should serve “hello world” web page on port 8080.
2. Second item 
3. Change default webserver log directory using chef
4. Hook up grafana or other monitoring tool to monitor the webserver.
5. Automate provisioning and installation using terraform and chef.

* Bonus:
    configure your webserver to send logs to cloud logging (AWS CloudWatch, OCI Logging etc…)
    Please put your solution ideally to github and send me the link.

## Done

1. Builded CI/CD pipeline based on Github Actions
2. All cloud insfrastructure build/configured using Terraform
3. Configuration management done using Ansible and
4. Services delivered by Docker containers
5. All sensitive data locked in Github Actions  Secret Menegenment service
6. Logs from Nginx assigned to CloudWatch and also availbae in Grafana

Github Secrets Required:

```yaml
    AWS_ACCESS_KEY_ID: standard environment variable for AWS auth
    AWS_SECRET_ACCESS_KEY: standard environment variable for AWS auth
    EC2_KEY_PEM_64: encrypted base64 pem key for EC2 instance access
    EC2_KEY_PUB_64: encrypted base64 pub key for EC2 instance access
    INFLUXDB_USER_PASSWORD: Telegraf user password
```

For key encription use command:

```bash
cat ~/.ssh/ec2_key_pair.pem | openssl base64 | tr -d '\n'
```

Before run the workflow, [Monitoring instanse](https://github.com/lobykin/terraform-docker-aws-grafana) should be deployed🟢 and Grafana Dashboard configured
