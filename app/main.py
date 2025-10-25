from fastapi import FastAPI, HTTPException
from datetime import datetime
from pydantic import BaseModel
import boto3
import json
import os

app = FastAPI(
    title="ML Engineering Demo with Claude",
    description="FastAPI application integrated with AWS Bedrock and Claude",
    version="2.0.0"
)

# Initialize Bedrock client
# boto3 automatically uses IAM role from the service account
bedrock = boto3.client(
    service_name='bedrock-runtime',
    region_name=os.getenv('AWS_REGION', 'us-east-1')
)

# Request/Response models for type safety and auto-documentation
class ChatRequest(BaseModel):
    message: str
    max_tokens: int = 1024
    
    class Config:
        json_schema_extra = {
            "example": {
                "message": "Explain machine learning in one sentence",
                "max_tokens": 1024
            }
        }

class ChatResponse(BaseModel):
    response: str
    model: str
    timestamp: str
    input_tokens: int
    output_tokens: int


@app.get("/")
def read_root():
    """Root endpoint with service information"""
    return {
        "message": "ML Engineering Demo with Claude",
        "timestamp": datetime.now().isoformat(),
        "version": "2.0.0",
        "features": ["chat", "health", "models"],
        "endpoints": {
            "chat": "POST /chat - Talk to Claude",
            "health": "GET /health - Health check",
            "models": "GET /models - Available models",
            "docs": "GET /docs - Interactive API docs"
        }
    }

@app.get("/health")
def health_check():
    """Health check endpoint for Kubernetes probes"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat()
    }

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Chat with Claude via AWS Bedrock
    
    This endpoint:
    1. Receives your message
    2. Sends it to Claude via Bedrock
    3. Returns Claude's response
    
    Uses Claude 3 Haiku
    """
    try:
        # Prepare the request body for Claude
        # This follows the Anthropic Messages API format
        body = json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": request.max_tokens,
            "messages": [
                {
                    "role": "user",
                    "content": request.message
                }
            ],
            # Optional: Add system prompt for better responses
            "system": "You are a helpful AI assistant integrated into a production ML engineering platform."
        })
        
        # Call Bedrock
        # The IAM role attached to our service account provides authentication
        response = bedrock.invoke_model(
            modelId="anthropic.claude-3-haiku-20240307-v1:0",
            body=body
        )
        
        # Parse the response
        response_body = json.loads(response['body'].read())
        
        # Extract Claude's text response
        claude_response = response_body['content'][0]['text']
        
        # Get token usage for monitoring
        usage = response_body.get('usage', {})
        
        return ChatResponse(
            response=claude_response,
            model="claude-3-haiku",
            timestamp=datetime.now().isoformat(),
            input_tokens=usage.get('input_tokens', 0),
            output_tokens=usage.get('output_tokens', 0)
        )
        
    except bedrock.exceptions.ValidationException as e:
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid request to Bedrock: {str(e)}"
        )
    except bedrock.exceptions.ModelNotReadyException:
        raise HTTPException(
            status_code=503, 
            detail="Claude model is not ready. Please try again in a moment."
        )
    except bedrock.exceptions.ThrottlingException:
        raise HTTPException(
            status_code=429, 
            detail="Too many requests. Please try again later."
        )
    except Exception as e:
        # Log the error (in production, use proper logging)
        print(f"Error calling Bedrock: {str(e)}")
        raise HTTPException(
            status_code=500, 
            detail=f"Error calling Bedrock: {str(e)}"
        )


@app.get("/models")
def list_models():
    """
    List available Claude models and their characteristics
    """
    return {
        "current_model": "claude-3-haiku",
        "available_models": [
            {
                "name": "claude-3-haiku",
                "id": "anthropic.claude-3-haiku-20240307-v1:0",
                "description": "Fast and cost-effective",
                "use_case": "Quick responses, high volume"
            },
            {
                "name": "claude-3-sonnet",
                "id": "anthropic.claude-3-sonnet-20240229-v1:0",
                "description": "Balanced performance and capability",
                "use_case": "General purpose"
            },
            {
                "name": "claude-3-opus",
                "id": "anthropic.claude-3-opus-20240229-v1:0",
                "description": "Most capable",
                "use_case": "Complex reasoning and analysis"
            }
        ],
        "pricing_note": "Haiku is ~60x cheaper than Opus per token"
    }
