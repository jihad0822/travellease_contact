import AWS from 'aws-sdk';
const dynamoDB = new AWS.DynamoDB.DocumentClient();
    
// CORS headers
const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'OPTIONS, POST',
    'Content-Type': 'application/json'
};

export const handler = async (event) => {

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

            // Validate required fields
            if (!body.firstName || !body.lastName || !body.email || !body.phone) {
                console.log("Missing required fields");
                return {
                    statusCode: 400,
                    headers: corsHeaders,
                    body: JSON.stringify({
                        message: "Bad Request: Missing required fields",
                        required: ["firstName", "lastName", "email", "phone"],
                        received: Object.keys(body)
                    }),
                };
            }

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

        // Log successful validation
        console.log("Validation passed for:", {
            firstName: body.firstName,
            lastName: body.lastName,
            email: body.email,
            phone: body.phone
        });


        // Generate Unique, Non-Reusable Reference ID
        // Format: inquiry-<random-uuid>
        console.log("Generating unique reference ID...");
        const referenceId = `inquiry-${AWS.util.uuid.v4()}`;
        
        // Validate referenceId
        if (!referenceId) {
            console.error("Failed to generate reference ID");
            return {
                statusCode: 500,
                headers: corsHeaders,
                body: JSON.stringify({
                    message: "Internal Server Error: Failed to generate reference ID",
                }),
            };
        }

        // Log the generated reference ID
        console.log("Generated reference ID:", referenceId);


        // Prepare data to be stored in DynamoDB
        console.log("Preparing data for DynamoDB...");
        const item = {
            referenceId: referenceId,
            firstName: body.firstName,
            lastName: body.lastName,
            email: body.email,
            phone: body.phone,
            inquiryDetails: body.inquiryDetails,
            communicationPreferences: body.communicationPreferences || "email", // Default to email if not provided
            metadata: body.metadata,
        }
        // Log the prepared item
        console.log("Prepared item for DynamoDB:", JSON.stringify(item, null, 2));

        // Store data in DynamoDB
        console.log("Storing data in DynamoDB...");
        const params = {
            TableName: process.env.DYNAMODB_TABLE_NAME,
            Item: item,
        };
        await dynamoDB.put(params).promise();   
        console.log("Data successfully stored in DynamoDB");


        /* Prepare email to send to user using SES
        console.log("Preparing email for user...");
        const ses = new AWS.SES();
        const emailParams = {
            Source: process.env.SES_SOURCE_EMAIL, // Ensure this environment variable is set
            Destination: {
                ToAddresses: [body.email],
            },
            Message: {
                Subject: {
                    Data: "Thank you for your inquiry!",
                    Charset: "UTF-8",   
                },
                Body: {
                    Text: {
                        Data: `Hello ${body.firstName},\n\nThank you for reaching out to us! We have received your inquiry and will get back to you shortly.\n\nYour Reference ID: ${referenceId}\n\nBest regards,\nThe Premier Mortgage Team`,
                        Charset: "UTF-8",
                    },
                },
            },
        };
        */
        

        // Return success response
        console.log("Process completed successfully!");
        return {
            statusCode: 200,
            headers: corsHeaders,   
            body: JSON.stringify({
                message: "Inquiry submitted successfully",
                referenceId: referenceId,
            }),
        };

    } catch (error) {
        console.error("Unexpected error:", error);

        // Return Error
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
