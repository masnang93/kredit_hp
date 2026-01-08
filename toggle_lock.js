const http = require('http');

const deviceId = 'test-device-id-001';
const action = process.argv[2]; // 'lock' or 'unlock'

if (!action || (action !== 'lock' && action !== 'unlock')) {
    console.log('Usage: node toggle_lock.js <lock|unlock>');
    process.exit(1);
}

const options = {
    hostname: 'localhost',
    port: 3000,
    path: `/devices/${deviceId}/${action}`,
    method: 'PUT',
};

const req = http.request(options, (res) => {
    console.log(`Initial Status Code: ${res.statusCode}`);
    
    res.on('data', (d) => {
        process.stdout.write(d);
        console.log('\n\n--- SUCCESS ---');
        console.log(`Device ${deviceId} is now ${action.toUpperCase()}ED`);
    });
});

req.on('error', (e) => {
    console.error(`Problem with request: ${e.message}`);
    console.log('Make sure the backend server is running on port 3000!');
});

req.end();
