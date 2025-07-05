import AWS from 'aws-sdk';
const dynamoDB = new AWS.DynamoDB.DocumentClient();
const ses = new AWS.SES();
    
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
            createdAt: new Date().toISOString(),
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


        // Prepare email to send to user and business owner using SES
        console.log("Preparing emails to send...");

        // Format inquiryDetails for email
        // Function to format inquiry details for email display
        const formatDetails = (details) => {
            if (typeof details === 'object' && details !== null) {
                // Convert the object to a nicely formatted string
                return Object.entries(details)
                .map(([key, value]) => {
                    // Format the key to be more readable (convert camelCase to Title Case)
                    const formattedKey = key.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase());
                    return `${formattedKey}: ${value}`;
                })
                .join('\n');
            }
            return details || "N/A";
        };

        const sourceEmail = process.env.SES_EMAIL_IDENTITY;

        const userEmailSubject = "Thank You For Your Mortgage Inquiry!";
        const userEmailBody = `
Dear ${body.firstName},

Thank you for your inquiry. We have received your request and will get back to you soon.

Inquiry Details:
${formatDetails(body.inquiryDetails)}

Your Reference ID: ${referenceId}

We appreciate your interest and will contact you within 24-48 hours.

Best regards,
The Premier Mortgage Team
        `;

        const businessEmailSubject = "New Inquiry Received - " + referenceId;
        const businessEmailBody = `
Lead details:

Reference ID: ${referenceId}
Submitted At: ${new Date().toISOString()}

Name: ${body.firstName} ${body.lastName}
Email: ${body.email}
Phone: ${body.phone}

Inquiry Details:
${formatDetails(body.inquiryDetails)}

Communication Preference: 
${formatDetails(body.communicationPreferences)}
        `

        // Sending Emails
        console.log("Sending emails...")

        try {
            const userEmailParams = {
                Source: sourceEmail,
                Destination: {
                    ToAddresses: [sourceEmail], // sending email to myself for testing purposes; change to [body.email] in production
                },
                Message: {
                    Subject: {
                        Data: userEmailSubject,
                        Charset: 'UTF-8',
                    },
                    Body: {
                        Text: {
                            Data: userEmailBody,
                            Charset: 'UTF-8',
                        },
                    },
                },
            };

            console.log("User email sending...");
            await ses.sendEmail(userEmailParams).promise();

            const businessEmailParams = {
                Source: sourceEmail,
                Destination: {
                    ToAddresses: [sourceEmail],
                },
                Message: {
                    Subject: {
                        Data: businessEmailSubject,
                        Charset: 'UTF-8',
                    },
                    Body: {
                        Text: {
                            Data: businessEmailBody,
                            Charset: 'UTF-8',
                        },
                    },
                },
            };

            console.log("Business email sending...");
            await ses.sendEmail(businessEmailParams).promise();

            console.log("Emails Sent!")
        } catch (emailError) {
            console.error("Error sending emails:", emailError);
            // Don't fail the entire request since data is already stored in DynamoDB
        }


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
