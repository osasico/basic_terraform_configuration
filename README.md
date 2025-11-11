# terraform basics



#  Basic Terraform AWS EC2 Environment Setup

Project Background: This terraform configuration provisions a simple AWS infrastructure stack in the **eu-west-3 (Paris)** region. It includes:

- A custom VPC and subnet
- An internet gateway and route table
- A security group for SSH and HTTP
- A key pair for SSH access
- A public EC2 instance (Amazon Linux 2 AMI)

---

##  Project Structure

```
.
├── main.tf            # Main Terraform configuration
├── variables.tf       # Input variable definitions
├── outputs.tf         # Output values
└── README.md          # Project documentation
```

---

##  Requirements

- [Terraform]
- [AWS CLI]

