locals {
  ecs_cluster_name = element(split("/", var.ecs_cluster_arn), 1)
}

resource "aws_codepipeline" "program_pipeline" {
  name = "${var.service_name}-${var.environment_identifier}-pipeline-program"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifact_bucket_id
    type     = "S3"

    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.repository_name
        BranchName       = "release/${var.environment_identifier}"
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildFluentBit"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_fluentbit_output"]
      version          = "1"
      run_order        = 1

      configuration = {
        ProjectName = var.code_build_fluentbit_arn
      }
    }

    action {
      name             = "BuildApi"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_api_output"]
      version          = "1"
      run_order        = 2

      configuration = {
        ProjectName = var.code_build_api_arn
      }
    }

    action {
      name             = "BuildFrontend"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_frontend_output"]
      version          = "1"
      run_order        = 2

      configuration = {
        ProjectName = var.code_build_frontend_arn
      }
    }
  }

  stage {
    name = "Approve"

    action {
      name     = "Approve"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployApi"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_api_output"]
      version         = "1"
      run_order        = 1

      configuration = {
        ClusterName = local.ecs_cluster_name
        ServiceName = var.api_service_name
        FileName = "imagedefinitions.json"
      }
    }

    action {
      name            = "DeployFrontend"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_frontend_output"]
      version         = "1"
      run_order        = 1

      configuration = {
        ClusterName = local.ecs_cluster_name
        ServiceName =var.frontend_service_name
        FileName = "imagedefinitions.json"
      }
    }
  }
}
