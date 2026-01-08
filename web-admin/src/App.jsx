import React, { useState } from 'react';
import Sidebar from './components/Sidebar';
import Dashboard from './components/Dashboard';
import Settings from './components/Settings';
import LoanManager from './components/LoanManager';
import Transactions from './components/Transactions';
import DebugPage from './components/DebugPage';
import Login from './components/Login';

function App() {
    const [activeTab, setActiveTab] = useState('dashboard');
    // Check localStorage for persisted session
    const [isAuthenticated, setIsAuthenticated] = useState(() => {
        return localStorage.getItem('isAdminLoggedIn') === 'true';
    });

    const handleLogin = () => {
        localStorage.setItem('isAdminLoggedIn', 'true');
        setIsAuthenticated(true);
    };

    const handleLogout = () => {
        localStorage.removeItem('isAdminLoggedIn');
        setIsAuthenticated(false);
    };

    if (!isAuthenticated) {
        return <Login onLogin={handleLogin} />;
    }

    return (
        <div className="flex min-h-screen bg-transparent font-outfit text-white">
            {/* Sidebar */}
            <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} onLogout={handleLogout} />

            {/* Main Content */}
            <main className="flex-1 ml-64 min-h-screen relative z-0">
                {/* Background Gradients for Premium Feel */}
                <div className="fixed top-[-10%] right-[-5%] w-[500px] h-[500px] bg-blue-600/20 rounded-full blur-[128px] pointer-events-none" />
                <div className="fixed bottom-[-10%] left-[20%] w-[400px] h-[400px] bg-purple-600/20 rounded-full blur-[128px] pointer-events-none" />

                <div className="relative z-10 animate-fade-in">
                    {activeTab === 'dashboard' && <Dashboard />}
                    {activeTab === 'loans' && <LoanManager />}
                    {activeTab === 'transactions' && <Transactions />}
                    {activeTab === 'settings' && <Settings />}
                    {activeTab === 'debug' && <DebugPage />}
                </div>
            </main>
        </div>
    );
}

export default App;
