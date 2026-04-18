# Cloud Run Deployment Script for ClipWise
# Target Project: fasionwood

$PROJECT_ID="fasionwood"
$REGION="us-central1"
$REPO_NAME="clipwise-repo"
$IMAGE_NAME="ffmpeg-server"
$SERVICE_NAME="clipwise-server"

echo "=== 1. Setting Project ==="
gcloud config set project $PROJECT_ID

echo "=== 2. Enabling Required APIs ==="
gcloud services enable artifactregistry.googleapis.com run.googleapis.com

echo "=== 3. Creating Artifact Registry (if needed) ==="
gcloud artifacts repositories create $REPO_NAME `
    --repository-format=docker `
    --location=$REGION `
    --description="Docker repository for ClipWise" `
    --quiet

echo "=== 4. Authenticating Docker ==="
gcloud auth configure-docker "$REGION-docker.pkg.dev" --quiet

echo "=== 5. Building and Pushing Image (Under 500MB) ==="
$FULL_IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:latest"
docker build -t $FULL_IMAGE_NAME .
docker push $FULL_IMAGE_NAME

echo "=== 6. Deploying to Cloud Run ==="
# Note: We are using 4GB RAM to ensure Remotion has enough overhead for rendering
gcloud run deploy $SERVICE_NAME `
    --image=$FULL_IMAGE_NAME `
    --region=$REGION `
    --memory=4Gi `
    --cpu=2 `
    --allow-unauthenticated `
    --set-env-vars="NODE_ENV=production,TEMP_DIR=/tmp/hyperedit" `
    --update-secrets="GEMINI_API_KEY=GEMINI_API_KEY:latest,OPENAI_API_KEY=OPENAI_API_KEY:latest,NVIDIA_API_KEY=NVIDIA_API_KEY:latest,FAL_API_KEY=FAL_API_KEY:latest,GIPHY_API_KEY=GIPHY_API_KEY:latest"

echo "=== DEPLOYMENT COMPLETE ==="
gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)'
