# DevOps on AWS Real Project - All In One

## Setup CI/CD

### Setup KUBECONFIG secret
```sh
aws eks update-kubeconfig --region  us-east-1 --name devops-on-aws-all-in-one-prod-eks-01
cat ~/.kube/config
```

### Setup Secrets on Github


### CI

```sh
name: CI

on:
  push:
    branches: [main]
  pull_request:

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: prod/devops-on-aws-all-in-one

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [productpage, reviews, ratings, details]

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials from GitHub Secrets
        if: github.event_name == 'push'
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        if: github.event_name == 'push'
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build only for PR
        if: github.event_name == 'pull_request'
        uses: docker/build-push-action@v6
        with:
          context: ./${{ matrix.service }}
          push: false
          tags: local/${{ matrix.service }}:test

      - name: Build and Push
        if: github.event_name == 'push'
        uses: docker/build-push-action@v6
        with:
          context: ./${{ matrix.service }}
          push: true
          tags: |
            ${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:${{ matrix.service }}-${{ github.sha }}
            ${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:${{ matrix.service }}-latest
```

### CD

```sh
name: CD

on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: prod/devops-on-aws-all-in-one
  NAMESPACE: bookinfo

jobs:
  deploy:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [productpage, reviews, ratings, details]

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Install kubectl
        uses: azure/setup-kubectl@v4

      - name: Set kubeconfig
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBECONFIG }}" > ~/.kube/config

      - name: Update deployment image
        run: |
          kubectl set image deployment/${{ matrix.service }} \
            ${{ matrix.service }}=736059458620.dkr.ecr.${{ env.AWS_REGION }}.amazonaws.com/${{ env.ECR_REPOSITORY }}:${{ matrix.service }}-${{ github.event.workflow_run.head_sha }} \
            -n ${{ env.NAMESPACE }}

      - name: Check rollout status
        run: |
          kubectl rollout status deployment/${{ matrix.service }} -n ${{ env.NAMESPACE }} --timeout=180s

```