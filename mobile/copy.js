const fs = require('fs');
try {
    fs.copyFileSync('C:\\Users\\JURAGAN 147\\.gemini\\antigravity\\brain\\043740e1-ca20-4db6-bde1-3464be67e659\\uploaded_image_1767794792322.jpg', 'assets/logo.jpg');
    console.log('Copied');
} catch (e) {
    console.error(e);
}
