# 概要
AWS Fargateを使用したWebアプリケーションを構築するためのリポジトリ。
当リポジトリにインフラからアプリケーションプログラムまで、全てのファイルを一つにまとめる。

# 環境構築
## インフラリソースの作成・更新
インフラリソースの作成・更新は、CloudFormationで作成されるCodePipelineから実行する。初回実行時のみ、以下手順を踏んでCodePipelineリソースを作成する。

### インフラリソースの作成・更新手順
1. environment/terraform_pipeline.yamlからTerraformパイプライン用のスタックを作成する。
2. 以下コマンド入力でS3バケットにtfvarsファイルをアップロードする。

    ```
    aws s3 cp ./terraform.tfvars s3://{ServiceName}-{EnvironmentIdentifier}-tf-pipeline-tfvars/{ServiceName}/{EnvironmentIdentifier}/terraform.tfvars
    ```
    - ServiceName: terraform_pipeline.yamlから作成したスタックのParameters「ServiceName」の値
    - EnvironmentIdentifier: terraform_pipeline.yamlから作成したスタックのParameters「EnvironmentIdentifier」の値
3. スタックから作成されたCodePipelineリソース、{ServiceName}-{EnvironmentIdentifier}-pipeline-tfの変更をリリースする。

※ 上記手順でインフラ更新のパイプラインを作成後は、パイプラインの変更をリリースすることで、インフラ更新を行う。

## アプリケーションプログラムの作成・更新
アプリケーションプログラムを作成、更新する場合は、以下CodePipelineの変更をリリースする。

■CodePipelineリソース

- ${service_name}-{environment_identifier}-pipeline-program
# ディレクトリ構成
ディレクトリ構成は以下の通り。
```
.
├── README.md
├── environment
│   └── terraform_pipeline.yaml
├── infrastructure
│   ├── main.tf
│   ├── modules
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── terraform_backend
│   └── variables.tf
└── program
    ├── backend
    ├── fluentbit
    ├── frontend
    └── functions
```

## environmentディレクトリ

環境構築を行うためのリソースを配置するディレクトリ。
例えば、インフラリソースを作成するためのパイプラインなどを配置する。
## infrastructureディレクトリ
インフラリソースを作成するTerraform関連のファイルを配置するディレクトリ。modulesディレクトリに各AWSリソースを作成するためのtfファイルを配置する。

※ terraform.tfvarsは、{ServiceName}-{EnvironmentIdentifier}-pipeline-tfパイプラインのビルド時にS3バケットから取得する。
## programディレクトリ
インフラ以外のアプリケーションプログラムを配置するディレクトリ。
バックエンドアプリケーションやフロントエンドアプリケーション、Lambdaで使用する関数などを配置する。
