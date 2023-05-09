# AWS Multi Region Aurora with active/active setup

![diagram.png](images%2Fdiagram.png)

## What we are building
1. VPC in us-east-2
2. VPC in eu-west-1
3. Global AWS aurora cluster in us-east-2
4. AWS aurora MySQL cluster in us-east-2
5. AWS aurora MySQL cluster in eu-west-1
6. AWS Secret with username and password in us-east-2
7. Private bastion in us-east-2

## How to build it with Terraform
* Make sure your AWS cli and terraform cli are setup appropriately
* Change variables.tf to desired defaults
* add backend.tf with your desired backend for the state file
```bash
cd terraform
terraform init
terraform plan -out=plan.out
terraform apply
```
111 resources will be created
![resources.png](images%2Fresources.png)

## Retrieve secrets from AWS Secrets
![secrets.jpg](images%2Fsecrets.jpg)

## Connect to bastion
![bastion.jpg](images%2Fbastion.jpg)

## Connect to cluster
Plug the following information in to this command
* Hostname can be found in the RDS portal - connect to the primary writer in us-east-2
* Port for MySQL is 3306
* Username and Password were obtained from AWS Secrets
```bash
mysql -h {hostname} -P {port} -u {username} -p{password}

SHOW DATABASES;
CREATE DATABASE test;
USE test;
```
You should get a response like this
```bash
mysql> USE test;
Database changed
```
Create Tables and records
```bash
CREATE TABLE records (id INT);
INSERT INTO records (id) VALUES (1);
```
You should get a response like this
```bash
mysql> CREATE TABLE records (id INT);
Query OK, 0 rows affected (0.02 sec)

mysql> INSERT INTO records (id) VALUES (1);
Query OK, 1 row affected (0.01 sec)
```
Hop out of the database
```bash
quit;
```

## Check replication
Same steps as above, but with the reader in eu-west-1 

Plug the following information in to this command
* Hostname can be found in the RDS portal - connect to the reader in eu-west-1
* Port for MySQL is 3306
* Username and Password were obtained from AWS Secrets
```bash
mysql -h {hostname} -P {port} -u {username} -p{password}
USE test;
SELECT * FROM records;
```
We will see the replicated record
```bash
mysql> SELECT * FROM records;
+------+
| id   |
+------+
|    1 |
+------+
1 row in set (0.08 sec)
```

## Test failover
![failover.png](images%2Ffailover.png)

![failover_in_progress.png](images%2Ffailover_in_progress.png)

![failover_success.png](images%2Ffailover_success.png)

## Conclusion
With that we've proven replication and failover in a global aurora database. All written with IaC.