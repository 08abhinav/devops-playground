terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
    }

    backend "s3" {
        bucket  = "terraform-backend-17-03-2026"
        key     = "terrform-aws-project-statefile/project1.tfstate"
        region  = "us-east-1"
        encrypt = true
    }
}

provider "aws"{
    region = "us-east-1"
}