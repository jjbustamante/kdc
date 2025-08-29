#!/bin/bash
set -e

# Demo script for Buildpacks build
# Shows the simplicity of building with Cloud Native Buildpacks

echo "📦 BUILDPACKS BUILD DEMO"
echo "========================"
echo

# Colors for better presentation
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="kdc-buildpacks-demo"
CONTAINER_NAME="kdc-buildpacks-test"
PORT=5002

echo -e "${BLUE}📋 Buildpacks Configuration:${NC}"
echo -e "   • Builder: heroku/builder:24"
echo -e "   • Image: ${IMAGE_NAME}"
echo -e "   • Auto-detected: Python + bcrypt"
echo -e "   • Port: ${PORT}"
echo

# Cleanup function
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up...${NC}"
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
}

# Set trap for cleanup
trap cleanup EXIT

echo -e "${PURPLE}🚀 Step 1: Building with Cloud Native Buildpacks${NC}"
echo -e "${GREEN}✨ Note: Watch the automatic detection and simplicity!${NC}"
echo

# Show the simplicity - no Dockerfile needed!
echo -e "${CYAN}📄 Required files for Buildpacks:${NC}"
echo -e "   • requirements.txt (Python dependencies)"
echo -e "   • Procfile (process definition)"  
echo -e "   • app.py (application code)"
echo -e "${GREEN}   Total complexity: 3 simple files vs 50+ line Dockerfile!${NC}"
echo

# Show Procfile content
echo -e "${CYAN}📋 Procfile (1 line):${NC}"
cat Procfile
echo

# Build with pack
echo -e "${PURPLE}⏳ Building with pack CLI...${NC}"
echo -e "${YELLOW}   Command: pack build ${IMAGE_NAME} --builder heroku/builder:24${NC}"
echo

# Run pack build with some formatting
pack build ${IMAGE_NAME} --builder heroku/builder:24

echo -e "${GREEN}🎉 Buildpacks build complete!${NC}"
echo -e "${CYAN}✅ Auto-detected: Python application${NC}"
echo -e "${CYAN}✅ Auto-installed: bcrypt native compilation${NC}"
echo -e "${CYAN}✅ Auto-configured: Web process from Procfile${NC}"
echo

echo -e "${PURPLE}🧪 Step 2: Testing the Buildpacks image${NC}"

# Run the container
echo -e "${BLUE}🚀 Starting container...${NC}"
docker run -d --name ${CONTAINER_NAME} -p ${PORT}:5000 ${IMAGE_NAME}

# Wait for container to be ready
echo -e "${YELLOW}⏳ Waiting for application to start...${NC}"
sleep 3

# Test the endpoints
echo -e "${CYAN}🔍 Testing application endpoints:${NC}"
echo

# Test root endpoint
echo -e "${BLUE}📡 GET / (System info):${NC}"
response=$(curl -s http://localhost:${PORT}/ || echo "FAILED")
echo "$response" | jq . 2>/dev/null || echo "$response"
echo

# Extract architecture for validation
arch=$(echo "$response" | jq -r '.architecture' 2>/dev/null || echo "unknown")
echo -e "${GREEN}   Architecture detected: ${arch}${NC}"
echo

# Test bcrypt hashing
echo -e "${BLUE}🔐 POST /hash (bcrypt test):${NC}"
hash_response=$(curl -s -X POST http://localhost:${PORT}/hash \
  -H "Content-Type: application/json" \
  -d '{"password": "demo_password_buildpacks"}' || echo "FAILED")

echo "$hash_response" | jq . 2>/dev/null || echo "$hash_response"
echo

# Extract hash for verification
hash_value=$(echo "$hash_response" | jq -r '.hash' 2>/dev/null)

if [[ "$hash_value" != "null" && "$hash_value" != "" ]]; then
    echo -e "${GREEN}✅ bcrypt working perfectly in Buildpacks container${NC}"
    
    # Test verification
    echo -e "${BLUE}🔍 POST /verify (password verification):${NC}"
    verify_response=$(curl -s -X POST http://localhost:${PORT}/verify \
      -H "Content-Type: application/json" \
      -d "{\"password\": \"demo_password_buildpacks\", \"hash\": \"$hash_value\"}" || echo "FAILED")
    
    echo "$verify_response" | jq . 2>/dev/null || echo "$verify_response"
    
    is_valid=$(echo "$verify_response" | jq -r '.valid' 2>/dev/null)
    if [[ "$is_valid" == "true" ]]; then
        echo -e "${GREEN}✅ Password verification successful${NC}"
    else
        echo -e "${RED}❌ Password verification failed${NC}"
    fi
else
    echo -e "${RED}❌ bcrypt hash generation failed${NC}"
fi

echo
echo -e "${BLUE}🏥 GET /health (Health check):${NC}"
health_response=$(curl -s http://localhost:${PORT}/health || echo "FAILED")
echo "$health_response" | jq . 2>/dev/null || echo "$health_response"
echo

# Image comparison
echo -e "${PURPLE}📊 BUILDPACKS DEMO SUMMARY${NC}"
echo "=================================="
echo -e "${GREEN}✅ Simplicity: 1 command (pack build)${NC}"
echo -e "${GREEN}✅ Architecture handling: Automatic${NC}"
echo -e "${GREEN}✅ Native deps: Auto-detected and compiled${NC}"
echo -e "${GREEN}✅ Maintenance: Buildpack provider updates${NC}"
echo -e "${GREEN}✅ Result: Same working application${NC}"
echo

# Show image sizes for comparison
echo -e "${CYAN}📦 Image Comparison:${NC}"
docker_size=$(docker images kdc-docker-demo --format "table {{.Size}}" 2>/dev/null | tail -1 || echo "N/A")
buildpacks_size=$(docker images ${IMAGE_NAME} --format "table {{.Size}}" 2>/dev/null | tail -1 || echo "Unknown")

echo -e "   • Docker image: ${docker_size}"
echo -e "   • Buildpacks image: ${buildpacks_size}"
echo

# Final comparison
echo -e "${PURPLE}🆚 DOCKER vs BUILDPACKS COMPARISON${NC}"
echo "====================================="
echo
echo -e "${RED}🐳 DOCKER APPROACH:${NC}"
echo -e "   ❌ 50+ line Dockerfile"
echo -e "   ❌ Manual architecture conditionals" 
echo -e "   ❌ Complex native dependency setup"
echo -e "   ❌ Requires Docker expertise"
echo -e "   ❌ Manual maintenance and updates"
echo
echo -e "${GREEN}📦 BUILDPACKS APPROACH:${NC}"
echo -e "   ✅ 1 command: pack build"
echo -e "   ✅ Automatic architecture detection"
echo -e "   ✅ Auto-handles native dependencies"
echo -e "   ✅ No Docker knowledge required"
echo -e "   ✅ Automatic updates via buildpack provider"
echo

# Container info
echo -e "${CYAN}📦 Container Information:${NC}"
echo -e "   • Container: ${CONTAINER_NAME}"
echo -e "   • Image: ${IMAGE_NAME}"
echo -e "   • Port: http://localhost:${PORT}"
echo -e "   • Architecture: ${arch}"
echo

echo -e "${YELLOW}🎯 Key Takeaway: Buildpacks eliminates complexity while delivering the same result!${NC}"
echo
echo -e "${BLUE}🌐 Production images available at: https://hub.docker.com/r/jjbustamante/kdc${NC}"
echo -e "${BLUE}🚀 GitHub Actions workflow: Multi-arch builds automatically${NC}"
echo