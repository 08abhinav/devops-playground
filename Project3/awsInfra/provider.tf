terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
    }

    backend "s3" {
        bucket  = "terraform-backend-17-03-2026"
        key     = "terraform-aws-project-statefile/project3.tfstate"
        region  = "us-east-1"
        encrypt = true
    }
}

provider "aws"{
    region = "us-east-1"
}