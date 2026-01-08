import React, { useEffect, useState } from 'react';
import api from '../api';
import { CreditCard, CheckCircle, Search, RefreshCw, Calendar, Smartphone } from 'lucide-react';

const Transactions = () => {
    const [transactions, setTransactions] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchTransactions();
    }, []);

    const fetchTransactions = async () => {
        setLoading(true);
        try {
            // Fetch all loans and filter manually for PAID status
            // Ideal: Backend endpoint /loans?status=PAID
            const res = await api.get('/loans');
            const paidLoans = res.data.filter(loan => loan.status === 'PAID').sort((a, b) => new Date(b.dueDate) - new Date(a.dueDate));
            setTransactions(paidLoans);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const filteredTransactions = transactions.filter(t =>
        t.device?.ownerName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        t.id.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="p-8">
            <h2 className="text-3xl font-bold mb-6">Riwayat Transaksi</h2>

            <div className="glass rounded-xl overflow-hidden">
                <div className="p-6 border-b border-white/10 flex flex-col md:flex-row justify-between gap-4">
                    <div className="relative">
                        <Search className="absolute left-3 top-3 text-gray-500" size={18} />
                        <input
                            type="text"
                            placeholder="Cari nama atau ID..."
                            value={searchTerm}
                            onChange={e => setSearchTerm(e.target.value)}
                            className="bg-black/20 border border-white/10 rounded-lg py-2 pl-10 pr-4 focus:outline-none focus:border-blue-500 w-full md:w-64"
                        />
                    </div>
                    <button
                        onClick={fetchTransactions}
                        className="flex items-center gap-2 px-4 py-2 bg-white/5 hover:bg-white/10 rounded-lg transition-colors border border-white/10"
                    >
                        <RefreshCw size={18} /> Refresh
                    </button>
                </div>

                <div className="max-h-[600px] overflow-y-auto">
                    {loading ? (
                        <div className="p-12 text-center text-gray-500">Loading data...</div>
                    ) : filteredTransactions.length === 0 ? (
                        <div className="p-12 text-center text-gray-500 flex flex-col items-center">
                            <CreditCard size={48} className="mb-4 opacity-20" />
                            Belum ada riwayat transaksi lunas.
                        </div>
                    ) : (
                        <table className="w-full text-left">
                            <thead className="bg-white/5 text-xs text-gray-400 uppercase sticky top-0 bg-[#15161b] z-10">
                                <tr>
                                    <th className="p-4">ID Transaksi</th>
                                    <th className="p-4">Pelanggan</th>
                                    <th className="p-4">Tanggal Pembayaran</th>
                                    <th className="p-4">Metode</th>
                                    <th className="p-4 text-right">Jumlah</th>
                                    <th className="p-4 text-center">Status</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-white/5">
                                {filteredTransactions.map(t => (
                                    <tr key={t.id} className="hover:bg-white/5 transition-colors">
                                        <td className="p-4 font-mono text-sm opacity-70">
                                            #{t.id.substring(0, 8)}
                                            <div className="text-xs text-blue-300 font-sans mt-1">{t.title || 'Tagihan'}</div>
                                        </td>
                                        <td className="p-4">
                                            <div className="font-bold">{t.device?.ownerName || 'Unknown'}</div>
                                            <div className="text-xs text-gray-500 flex items-center gap-1">
                                                <Smartphone size={10} /> {t.device?.imei}
                                            </div>
                                        </td>
                                        <td className="p-4 text-sm text-gray-300">
                                            <div className="flex items-center gap-2">
                                                <Calendar size={14} className="text-gray-500" />
                                                {/* Assuming Payment Date is roughly Due Date for now, or just show Due Date if no PayDate stored yet */}
                                                {new Date(t.dueDate).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })}
                                            </div>
                                        </td>
                                        <td className="p-4 text-sm">
                                            <span className="px-2 py-1 rounded bg-blue-500/10 text-blue-400 border border-blue-500/20 text-xs">
                                                Online Transfer
                                            </span>
                                        </td>
                                        <td className="p-4 text-right font-bold text-green-400">
                                            {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(t.totalAmount)}
                                        </td>
                                        <td className="p-4 text-center">
                                            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-green-500/10 text-green-400 border border-green-500/20">
                                                <CheckCircle size={12} /> LUNAS
                                            </span>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </div>
            </div>
        </div>
    );
};

export default Transactions;
