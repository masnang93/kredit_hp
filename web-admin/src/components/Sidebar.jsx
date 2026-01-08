import React from 'react';
import { LayoutDashboard, Settings, Smartphone, LogOut, CreditCard } from 'lucide-react';

const Sidebar = ({ activeTab, setActiveTab, onLogout }) => {
    const menuItems = [
        { id: 'dashboard', label: 'Dashboard', icon: <LayoutDashboard size={20} /> },
        { id: 'loans', label: 'Kelola Tagihan', icon: <CreditCard size={20} /> },
        { id: 'transactions', label: 'Riwayat Transaksi', icon: <CreditCard size={20} /> },
        { id: 'settings', label: 'Settings', icon: <Settings size={20} /> },
        { id: 'debug', label: 'Debug System', icon: <Smartphone size={20} /> },
    ];

    return (
        <div className="w-64 glass h-screen fixed left-0 top-0 p-6 flex flex-col justify-between z-50">
            <div>
                <div className="flex items-center gap-3 mb-10 px-2">
                    <div className="p-2 bg-blue-600 rounded-lg">
                        <Smartphone size={24} className="text-white" />
                    </div>
                    <h1 className="text-xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-cyan-400">
                        Fintech Admin
                    </h1>
                </div>

                <nav className="space-y-2">
                    {menuItems.map((item) => (
                        <button
                            key={item.id}
                            onClick={() => setActiveTab(item.id)}
                            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-300 ${activeTab === item.id
                                ? 'bg-blue-600/20 text-blue-400 border border-blue-500/30'
                                : 'text-gray-400 hover:bg-white/5 hover:text-white'
                                }`}
                        >
                            {item.icon}
                            <span className="font-medium">{item.label}</span>
                        </button>
                    ))}
                </nav>
            </div>

            <button onClick={onLogout} className="flex items-center gap-3 px-4 py-3 text-red-400 hover:bg-red-500/10 rounded-xl transition-colors">
                <LogOut size={20} />
                <span className="font-medium">Logout</span>
            </button>
        </div>
    );
};

export default Sidebar;
