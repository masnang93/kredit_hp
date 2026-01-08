import React, { useState } from 'react';
import { Lock, User, ArrowRight } from 'lucide-react';

const Login = ({ onLogin }) => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        // Simple Hardcoded Auth
        if (username === 'admin' && password === 'admin123') {
            onLogin();
        } else {
            setError('Username atau Password salah!');
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-[#0f1014] p-4 font-outfit text-white">
            {/* Background Effects */}
            <div className="fixed top-0 left-0 w-[500px] h-[500px] bg-blue-600/20 rounded-full blur-[128px] pointer-events-none" />
            <div className="fixed bottom-0 right-0 w-[500px] h-[500px] bg-purple-600/20 rounded-full blur-[128px] pointer-events-none" />

            <div className="w-full max-w-md glass p-8 rounded-2xl relative z-10 border border-white/10 shadow-2xl">
                <div className="text-center mb-8">
                    <div className="inline-flex p-3 bg-blue-600/20 rounded-xl mb-4 text-blue-400">
                        <Lock size={32} />
                    </div>
                    <h1 className="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-purple-400">
                        Fintech Admin
                    </h1>
                    <p className="text-gray-400 text-sm mt-2">Masuk untuk mengelola sistem.</p>
                </div>

                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label className="text-sm font-medium text-gray-400 mb-1 block">Username</label>
                        <div className="relative">
                            <User className="absolute left-3 top-3 text-gray-500" size={18} />
                            <input
                                type="text"
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                                className="w-full bg-black/30 border border-white/10 rounded-lg py-2.5 pl-10 pr-4 focus:outline-none focus:border-blue-500 transition-colors"
                                placeholder="admin"
                            />
                        </div>
                    </div>
                    <div>
                        <label className="text-sm font-medium text-gray-400 mb-1 block">Password</label>
                        <div className="relative">
                            <Lock className="absolute left-3 top-3 text-gray-500" size={18} />
                            <input
                                type="password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                className="w-full bg-black/30 border border-white/10 rounded-lg py-2.5 pl-10 pr-4 focus:outline-none focus:border-blue-500 transition-colors"
                                placeholder="••••••••"
                            />
                        </div>
                    </div>

                    {error && (
                        <div className="text-red-400 text-xs text-center font-medium bg-red-500/10 py-2 rounded-lg">
                            {error}
                        </div>
                    )}

                    <button
                        type="submit"
                        className="w-full bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-500 hover:to-purple-500 text-white font-bold py-3 rounded-lg transition-all flex items-center justify-center gap-2 group"
                    >
                        Masuk Dashboard <ArrowRight size={18} className="group-hover:translate-x-1 transition-transform" />
                    </button>
                </form>
            </div>
        </div>
    );
};

export default Login;
