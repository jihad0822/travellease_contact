export const handler = async (event) => {
    // CORS headers - must be included in ALL responses
    const corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token',
        'Access-Control-Allow-Methods': 'OPTIONS, POST',
        'Content-Type': 'application/json'
    };

    try {
        // Log the entire event for debugging
        console.log("Received event:", JSON.stringify(event, null, 2));
        
        // Handle OPTIONS request (preflight)
        if (event.httpMethod === 'OPTIONS') {
            return {
                statusCode: 200,
                headers: corsHeaders,
                body: JSON.stringify({ message: 'CORS preflight response' })
            };
        }

        // Check if body exists
        if (!event.body) {
            console.log("No body in request");
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({
                    message: "Bad Request: Empty request body",
                }),
            };
        }

        // Parse the incoming event body with error handling
        let body;
        try {
            body = JSON.parse(event.body);
            console.log("Parsed body:", body);
        } catch (parseError) {
            console.error("JSON parse error:", parseError);
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({
                    message: "Bad Request: Invalid JSON in request body",
                }),
            };
        }

        // Validate required fields
        if (!body.fullName || !body.email || !body.phone) {
            console.log("Missing required fields");
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({
                    message: "Bad Request: Missing required fields",
                    required: ["fullName", "email", "phone"],
                    received: Object.keys(body)
                }),
            };
        }

        // Log successful validation
        console.log("Validation passed for:", {
            fullName: body.fullName,
            email: body.email,
            phone: body.phone
        });

        // Return test response with CORS headers
        return {
            statusCode: 200,
            headers: corsHeaders,
            body: JSON.stringify({
                message: "Test response from Lambda",
                success: true,
                data: {
                    fullName: body.fullName,
                    email: body.email,
                    phone: body.phone,
                    timestamp: new Date().toISOString()
                }
            })
        };

    } catch (error) {
        console.error("Unexpected error:", error);

        // Always return CORS headers, even in error cases
        return {
            statusCode: 500,
            headers: corsHeaders,
            body: JSON.stringify({
                message: "Internal Server Error",
                error: error.message,
            }),
        };
    }
};
