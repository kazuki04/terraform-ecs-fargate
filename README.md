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

# アーキテクチャ図
## システム全体図
![fargate_architecture](https://user-images.githubusercontent.com/63912049/201950118-49e39101-59dd-4561-90ef-30dc30c16601.png)



### CloudFront
CloudFrontでカスタムヘッダーを付与する。CloudFrontからALBへの通信に対して、AWS WAFでCloudFrontからのカスタムヘッダーが付与されているか否かをチェックする。

### Application Load Balancer
パスベースでAWS Fargateへのリクエストの振り分けを行なう。パスが「/api/*」のリクエストはバックエンド用のECS Service、それ以外のリクエストはフロントエンド用のECS Serviceへ振り分ける。

### AWS Fargate
リソースはプライベートサブネットに配置する。構成はバックエンド用、フロントエンド用のECSサービスとで分ける。

### VPC endpoint
インターフェイスエンドポイントはプライベートサブネットに配置する。AWS Fargateのサブネットに組み込むのではなく、egress用のサブネットとして別途管理する。

### AWS CodeBuild
AWS CodeBuildでプログラムのビルド、またはtrivyによるDockerイメージの脆弱性スキャンを行なう。パッケージのダウンロードなどを行なうため、パブリックサブネットに配置されているNAT Gatewayを通してインターネットアクセスを行なう。

## Terrafrom CI/CD Pipeline
![terraform_pipeline](https://user-images.githubusercontent.com/63912049/201527685-c89fa47a-dc46-4280-9281-d527210bf0d6.png)

以下の理由から、Terraformで作成されるインフラリソースに関しては、CodePipelineからなるCI/CDパイプラインで作成・更新を行なう。

■**理由**
- インフラリソースの作成・更新をするにあたって、ユーザーに強い権限を与えたくない。(代わりに、CodeBuildプロジェクトに強い権限を与える)
- インフラリソースの脆弱性チェックを確実に組み込みたい
- インフラリソースの作成・更新フローに再現性をもたせ、自動化させたい

TerraformでCI/CDパイプラインを作成すると、Terraformのbackend管理を行なうためのS3やDynamoDBリソースが必要になる。そのため、CI/CDパイプラインに関するリソースはCloudFormationで作成する。

■**CI/CDフロー**
1. CodeCommitからリソースの取得
2. tfsecによるインフラリソースのセキュリティチェック
3. terraform planによる実行プランの作成
4. Approveフェーズ。terraform planにより作成された実行プランの確認
5. terraform applyによってインフラリソースの作成・更新

tfvarsファイルに関しては、CodeBuildのbuildspecにおいてS3から取得する。

## ロギングアーキテクチャ
![logging architecture](https://user-images.githubusercontent.com/63912049/201527539-6bf0d5c3-f5ea-494d-8db8-c1e694c076c9.png)

ログ管理に関しては、fluentbitを使ったサイドカー構成とする。fluentbitを使ってアクセスログはS3バケット、エラーログはCloudWatchへ転送する。サービスがスケールしてCloudWatch Logsのログアーカイブコストが膨らむことを避けるためにS3バケットとCloudWatchへのログ振り分けを行なう。

エラーログの振り分けは、ログレベルごとに異なるログストリームに転送する。
バックエンドアプリケーションに関しては、以下のログレベルでログストリームを分類する。

■**ログレベル**
- FATAL
- ERROR

## メトリクス監視アーキテクチャ
![monitoring_architecture](https://user-images.githubusercontent.com/63912049/201527600-27733fdc-f31a-41a3-96c1-490cfddc939c.png)

Aurora、ECSに関してはメトリクスの監視を行なう。CloudWatch Alarmでアラートの管理を行なう。特定のメトリクスがアラートに状態になった場合、Amazon SNSを通してAWS LambdaでWebhookを利用してSlackへ通知を行なう。アラート状態が正常になった際も、同じく通知を行なう。

■**メトリクス監視項目(閾値)**

||CPU | Memory|
|---|---|---|
| Aurora | 80% | 95% |
| ECS | 80% | 80% |


Auroraは一時的に高負荷になる状況が十分に考えられるため、Memoryの閾値は95%とする。

また、以下ログレベルのログに関しては、メトリクスフィルターを作成する。

■**アラート通知対象のメトリクスフィルター**
- ECS バックエンドアプリケーション
  - FATAL
  - ERROR
- PostgreSQL
  - FATAL
  - ERROR

上記のメトリクスフィルターのメトリクス値が1を超えた場合もエラー通知を行う。
