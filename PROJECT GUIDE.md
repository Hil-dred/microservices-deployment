### PROJECT GUIDE

- SERVICES DEPLOYED (DEPLOYMENTS)
1. carts
2. carts-db (mongo)
3. catalogue
4. catalogue-db (MYSQL)
5. front-end
6. orders
7. orders-db (mongo)
8. payment
9. queue-master
10. rabbitmq
11. session-db (redis)
12. shipping
13. user
14. user-db (mongo)


- SERVICES
1. carts
2. carts-db
3. catalogue
4. catalogue-db
5. front-end
6. orders
7. orders-db
8. payment
9. queue-master
10. rabbitmq
11. session-db
12. shipping
13. user
14. user-db


- VOLUMES
1. carts
2. carts-db
3. orders
4. orderd-db
5. shipping
6. user-db


- WHAT AWS SERVICES DO YOU NEED?
AWS Region: us-east-2 (Ohio)

ESTIMATED UNIT COST
1. 1 MySQL RDS Instance: 
        - 0.034 USD hourly
2. EKS Cluster : 2 T3 Medium Nodes
        - 0.10 USD hourly (cluster)
        - $0.0832 USD per hour (EC2 instances)
3. Redis
        - 0.068 USD hourly
4. Elastic FIle System (cost is estimated per GB of data/month)
        - 0.30 USD per month

Service Uptime Duration:
    1 week 

ESTIMATED WEEKLY COST
1. 1 MySQL RDS Instance: 
        - 5.712 USD/week
2. EKS Cluster : 2 T3 Medium Nodes
        - 16.8 USD/week (cluster)
        - 14 USD/week (EC2 instances)
3. Redis
        - 11.424 USD/week
4. Elastic FIle System 
        - 0.30 USD per month



## CLUSTER SETUP ORDER
0-provider.tf
1-vpv-module.tf
2-blueprints.tf
3-kubernetes-addons.tf

Then,
4-efs.tf



## COMMANDS

#CONNECT TO CLUSTER
aws eks update-kubeconfig --name microservices-demo --region us-east-2
aws eks update-kubeconfig --name microservices-demo --region us-east-2 --profile developer


# Create Kubernetes Secret
kubectl create secret generic rds-secret \
  --from-literal=MYSQL_ROOT_PASSWORD="default_password" \
  --from-literal=MYSQL_HOST=tf-20241009114516074300000003.c4rola1vcvvx.us-east-2ku.rds.amazonaws.com \
  --from-literal=MYSQL_USER=catalogue_user

# Apply manifests
kubectl apply -f complete-demo.yaml
kubectl apply -f ingress.yaml

#
kubectl config set-context --current --namespace=sock-shop
#
kubectl port-forward service/front-end -n sock-shop 8080:80
kubectl get ingress sock-shop-ingress -n sock-shop
kubectl logs front-end -n sock-shop

# Create Kubernetes Secret
kubectl create secret generic rds-secret \
  --from-literal=MYSQL_ROOT_PASSWORD=<your_master_password> \
  --from-literal=MYSQL_HOST=<aurora-endpoint> \
  --from-literal=MYSQL_USER=demouser


kubectl create namespace  sock-shop 

kubectl create secret generic rds-secret \
  --from-literal=MYSQL_ROOT_PASSWORD='4K7Ae6~Vbmli5!NuPMeqV-Eh>E1r' \
  --from-literal=MYSQL_HOST='tf-20241016130246263700000003.c4rola1vcvvx.us-east-2.rds.amazonaws.com'\
  --from-literal=MYSQL_USER=demouser




### DUMP DB DATA

# How I dumped db information
Instance- i-030bdca76340d5acb

docker cp d1b0266d1dfa:/docker-entrypoint-initdb.d/dump.sql /Users/oluwatobilobaadebayo/Desktop/Learning/PIP/dump.sql

# How to restore dump

1. Add S3 full access role to node instance profile

2. Copy dump from s3 bucket
aws s3 cp s3://microservices-demo-terraform-state/copy-dump/dump.sql /home/ec2-user/dump.sql



*1. Connect instance to RDS

*2. Add inbound access on port 3306 for RDS SG on EKS nodes security group : microservices-demo-node-20240930142021031300000004

3. Install mysql client on node instance connected to RDS
        sudo yum update
        sudo yum install mysql -y

4. Create DB
mysql -h tf-20241016130246263700000003.c4rola1vcvvx.us-east-2.rds.amazonaws.com -u demouser -p --ssl-mode=DISABLED
OR
mysql -h tf-20241016130246263700000003.c4rola1vcvvx.us-east-2.rds.amazonaws.com -u demouser -p --skip-ssl

mysql -h tf-20241016130246263700000003.c4rola1vcvvx.us-east-2.rds.amazonaws.com -u catalogue_user -p --skip-ssl

default_password

CREATE DATABASE socksdb;

5. Restore dump into DB

mysql -h tf-20241016130246263700000003.c4rola1vcvvx.us-east-2.rds.amazonaws.com -u demouser -p socksdb < /home/ec2-user/dump.sql

PSWD: .TT*THbYe:c*~wR4<KOyZrvZ~lU8

6. Verify data

mysql -h tf-20241016130246263700000003.c4rola1vcvvx.us-east-2.rds.amazonaws.com -P 3306 -u demouser -p
USE socksdb;
SHOW TABLES;
SELECT * FROM sock_tag;
quit;

6. Verify Users

SELECT 
    user, 
    host, 
    db, 
    select_priv, 
    insert_priv, 
    update_priv, 
    delete_priv 
FROM 
    mysql.db 
WHERE 
    db = 'socksdb';


7. 

######
# From within the pod
1. kubectl exec -it catalogue-db-d764d45d6-qq7dv -- /bin/bash


#### Docker

docker stop catalogue-db
docker rm catalogue-db

docker run -d --name catalogue-db \
  -e MYSQL_ROOT_PASSWORD=fake_password \
  -e MYSQL_DATABASE=socksdb \
  -p 3306:3306 \
  weaveworksdemos/catalogue-db:0.3.0

docker exec -it catalogue-db /bin/bash


### TROUBLESHOOT RBAC
aws eks update-kubeconfig --name microservices-demo --region us-east-2 --profile developer
kubectl auth can-i "*" "*"
kubectl get clusterrolebinding reader -o yaml 

kubectl get clusterrolebinding -o yaml | grep -A 10 'developer'
kubectl get rolebinding -A -o yaml | grep -A 10 'developer'

kubectl get clusterrole reader -o yaml

