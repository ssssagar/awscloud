import https from 'https';

export const handler = async (event, context, callback) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;
    
    console.log('Event:', JSON.stringify(event, null, 2));
    console.log('Response before head tag replacement:', JSON.stringify(response, null, 2));
    const contentType = response.headers['content-type'] ? response.headers['content-type'][0].value : '';
    if (contentType.includes('text/html')) {
        
        if (!response.body) {
            console.log('Response body is not found. Initializing an empty HTML body.');
            response.body = "<!DOCTYPE html><html><head></head><body></body></html>";
            response.bodyEncoding = "text"; // Ensure the encoding is correct
        }

        let body = response.body;
		const scriptUrl = "//path/to/javascript.min.js";
        const scriptTag = `<script src="${scriptUrl}" async></script>`;
        body = body.replace('<head>', `<head>${scriptTag}`);        
        response.body = body;
    }
    console.log('Response after head tag replacement:', JSON.stringify(response, null, 2));

    callback(null, response);
};