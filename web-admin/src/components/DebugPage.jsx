import React, { useState, useEffect } from 'react';
import api from '../api';
import { Wifi, WifiOff, RefreshCw, Server, AlertTriangle, CheckCircle } from 'lucide-react';

const DebugPage = () => {
    const [status, setStatus] = useState('idle'); // idle, loading, success, error
    const [testResult, setTestResult] = useState(null);
    const [debugLog, setDebugLog] = useState([]);
    const [customUrl, setCustomUrl] = useState('');

    const addLog = (msg, type = 'info') => {
        const timestamp = new Date().toLocaleTimeString();
        setDebugLog(prev => [`[${timestamp}] ${msg}`, ...prev]);
    };

    const checkConnection = async (urlOverride = null) => {
        setStatus('loading');
        setTestResult(null);
        addLog(`Starting connection check...`);

        // Use custom instance if URL is overridden (for testing different IPs)
        const apiToUse = urlOverride ?
            require('axios').create({ baseURL: urlOverride }) : api;

        const baseUrl = urlOverride || api.defaults.baseURL;
        addLog(`Target URL: ${baseUrl}`);

        try {
            const start = performance.now();
            // Try fetching devices as a test
            const response = await apiToUse.get('/devices');
            const duration = Math.round(performance.now() - start);

            setStatus('success');
            setTestResult({
                status: response.status,
                statusText: response.statusText,
                duration: `${duration}ms`,
                dataLength: response.data ? response.data.length : 0,
                headers: response.headers
            });
            addLog(`Success! Status: ${response.status}. Latency: ${duration}ms`);
        } catch (err) {
            setStatus('error');
            console.error(err);

            const errorInfo = {
                message: err.message,
                code: err.code,
                response: err.response ? {
                    status: err.response.status,
                    statusText: err.response.statusText,
                    data: err.response.data
                } : 'No Response (Network Error?)'
            };

            setTestResult(errorInfo);
            addLog(`Failed: ${err.message}`, 'error');
            if (err.code === 'ERR_NETWORK') {
                addLog('Hint: Check CORS, Firewall, or if Server is running.', 'warn');
            }
        }
    };

    useEffect(() => {
        checkConnection();
    }, []);

    const handleManualTest = (e) => {
        e.preventDefault();
        if (customUrl) {
            checkConnection(customUrl);
        }
    };

    return (
        <div className="p-8 font-outfit text-white">
            <h2 className="text-3xl font-bold mb-6 flex items-center gap-3">
                <Server className="text-blue-400" /> System Debugger
            </h2>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Control Panel */}
                <div className="space-y-6">
                    <div className="glass p-6 rounded-xl border border-white/10">
                        <h3 className="text-xl font-bold mb-4">Connection Test</h3>

                        <div className="mb-6">
                            <label className="block text-sm text-gray-400 mb-2">Current API Base URL</label>
                            <div className="p-3 bg-black/30 rounded-lg font-mono text-green-400 border border-white/5 flex justify-between items-center">
                                {api.defaults.baseURL}
                                <span className="text-xs text-gray-500 bg-white/10 px-2 py-1 rounded">Configured in api.js</span>
                            </div>
                        </div>

                        <form onSubmit={handleManualTest} className="mb-6">
                            <label className="block text-sm text-gray-400 mb-2">Test Custom URL (Optional)</label>
                            <div className="flex gap-2">
                                <input
                                    type="text"
                                    value={customUrl}
                                    onChange={(e) => setCustomUrl(e.target.value)}
                                    placeholder="http://IP_BARU:3000"
                                    className="flex-1 bg-white/5 border border-white/10 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-blue-500"
                                />
                                <button type="submit" className="bg-blue-600 hover:bg-blue-500 px-4 py-2 rounded-lg font-medium">Test</button>
                            </div>
                        </form>

                        <button
                            onClick={() => checkConnection()}
                            disabled={status === 'loading'}
                            className={`w-full py-3 rounded-xl font-bold flex items-center justify-center gap-2 transition-all ${status === 'loading' ? 'bg-gray-600 cursor-not-allowed' :
                                    status === 'success' ? 'bg-green-600 hover:bg-green-500' :
                                        'bg-blue-600 hover:bg-blue-500'
                                }`}
                        >
                            {status === 'loading' ? <RefreshCw className="animate-spin" /> : <Wifi />}
                            {status === 'loading' ? 'Testing Connection...' : 'Run Connection Test'}
                        </button>
                    </div>

                    {/* Result Display */}
                    {testResult && (
                        <div className={`glass p-6 rounded-xl border ${status === 'success' ? 'border-green-500/30 bg-green-500/5' : 'border-red-500/30 bg-red-500/5'}`}>
                            <h3 className={`text-lg font-bold mb-4 flex items-center gap-2 ${status === 'success' ? 'text-green-400' : 'text-red-400'}`}>
                                {status === 'success' ? <CheckCircle /> : <AlertTriangle />}
                                {status === 'success' ? 'Connection Successful' : 'Connection Failed'}
                            </h3>

                            <pre className="bg-black/40 p-4 rounded-lg overflow-x-auto text-xs font-mono text-gray-300">
                                {JSON.stringify(testResult, null, 2)}
                            </pre>
                        </div>
                    )}
                </div>

                {/* Log Panel */}
                <div className="glass p-6 rounded-xl border border-white/10 flex flex-col h-[600px]">
                    <h3 className="text-xl font-bold mb-4 flex justify-between items-center">
                        Live Logs
                        <button onClick={() => setDebugLog([])} className="text-xs text-gray-400 hover:text-white">Clear</button>
                    </h3>
                    <div className="flex-1 bg-black/40 rounded-lg p-4 font-mono text-sm overflow-y-auto space-y-2">
                        {debugLog.length === 0 && <span className="text-gray-600 italic">No logs execution yet...</span>}
                        {debugLog.map((log, i) => (
                            <div key={i} className={`border-b border-white/5 pb-1 ${log.includes('Failed') || log.includes('error') ? 'text-red-400' :
                                    log.includes('Success') ? 'text-green-400' : 'text-gray-300'
                                }`}>
                                {log}
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default DebugPage;
