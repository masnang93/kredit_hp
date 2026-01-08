import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Smartphone, Plus, Calendar, DollarSign, CheckCircle, XCircle } from 'lucide-react';

const LoanManager = () => {
    const [devices, setDevices] = useState([]);
    const [selectedDevice, setSelectedDevice] = useState(null);
    const [loans, setLoans] = useState([]);
    const [loading, setLoading] = useState(false);

    // Form State
    const [amount, setAmount] = useState('');
    const [interestRate, setInterestRate] = useState('');
    const [interest, setInterest] = useState('');
    const [tenor, setTenor] = useState(1);
    const [dueDate, setDueDate] = useState('');

    // Auto calculate interest when Rate changes
    const handleRateChange = (val) => {
        setInterestRate(val);
        if (amount && val) {
            const calculatedInterest = (parseFloat(amount) * parseFloat(val)) / 100;
            setInterest(calculatedInterest);
        }
    };

    // Auto calculate interest when Amount changes
    const handleAmountChange = (val) => {
        setAmount(val);
        if (interestRate && val) {
            const calculatedInterest = (parseFloat(val) * parseFloat(interestRate)) / 100;
            setInterest(calculatedInterest);
        }
    };

    useEffect(() => {
        fetchDevices();
    }, []);

    useEffect(() => {
        if (selectedDevice) {
            fetchLoans(selectedDevice.imei);
        } else {
            setLoans([]);
        }
    }, [selectedDevice]);

    const fetchDevices = async () => {
        try {
            const res = await axios.get('http://localhost:3000/devices');
            setDevices(res.data);
        } catch (err) {
            console.error(err);
        }
    };

    const fetchLoans = async (imei) => {
        setLoading(true);
        try {
            const res = await axios.get(`http://localhost:3000/loans/device/${imei}`);
            setLoans(res.data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleCreateLoan = async (e) => {
        e.preventDefault();
        if (!selectedDevice) return;

        try {
            const total = parseFloat(amount) + parseFloat(interest || 0);
            await axios.post('http://localhost:3000/loans', {
                imei: selectedDevice.imei,
                loan: {
                    amount: parseFloat(amount), // Total Principal
                    interest: parseFloat(interest || 0), // Total Interest
                    totalAmount: total, // Total Bill
                    dueDate: new Date(dueDate),
                    status: 'PENDING',
                    tenor: parseInt(tenor) // Send Tenor
                }
            });
            alert('Tagihan berhasil dibuat!');
            setAmount('');
            setInterestRate('');
            setInterest('');
            setDueDate('');
            setTenor(1);
            fetchLoans(selectedDevice.imei);
        } catch (err) {
            alert('Gagal membuat tagihan: ' + err.message);
        }
    };

    return (
        <div className="p-8">
            <h2 className="text-3xl font-bold mb-6">Kelola Tagihan</h2>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {/* Device List */}
                <div className="glass p-4 rounded-xl h-[600px] overflow-y-auto">
                    <h3 className="font-bold mb-4 sticky top-0 bg-[#0f1014] p-2 z-10">Pilih Perangkat</h3>
                    <div className="space-y-2">
                        {devices.map(d => (
                            <div
                                key={d.id}
                                onClick={() => setSelectedDevice(d)}
                                className={`p-3 rounded-lg cursor-pointer transition-colors flex items-center gap-3 ${selectedDevice?.id === d.id ? 'bg-blue-500/20 border border-blue-500/50' : 'bg-white/5 hover:bg-white/10'}`}
                            >
                                <Smartphone size={20} className={selectedDevice?.id === d.id ? 'text-blue-400' : 'text-gray-400'} />
                                <div>
                                    <div className="font-mono text-sm">{d.imei}</div>
                                    <div className="text-xs text-gray-500">{d.ownerName || 'No Name'}</div>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Main Content */}
                <div className="md:col-span-2 space-y-6">
                    {selectedDevice ? (
                        <>
                            {/* Create Loan Form */}
                            <div className="glass p-6 rounded-xl">
                                <h3 className="text-xl font-bold mb-4 flex items-center gap-2">
                                    <Plus size={20} /> Buat Tagihan Baru
                                </h3>
                                <form onSubmit={handleCreateLoan} className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                    <div>
                                        <label className="text-sm text-gray-400">Total Pinjaman (Rp)</label>
                                        <div className="relative mt-1">
                                            <DollarSign size={16} className="absolute left-3 top-3 text-gray-500" />
                                            <input
                                                type="number"
                                                value={amount}
                                                onChange={e => handleAmountChange(e.target.value)}
                                                className="w-full bg-black/20 border border-white/10 rounded-lg py-2 pl-9 pr-4 focus:outline-none focus:border-blue-500"
                                                placeholder="1000000"
                                                required
                                            />
                                        </div>
                                    </div>
                                    <div>
                                        <label className="text-sm text-gray-400">Bunga (%)</label>
                                        <input
                                            type="number"
                                            value={interestRate}
                                            onChange={e => handleRateChange(e.target.value)}
                                            className="w-full mt-1 bg-black/20 border border-white/10 rounded-lg py-2 px-4 focus:outline-none focus:border-blue-500"
                                            placeholder="5"
                                        />
                                    </div>
                                    <div>
                                        <label className="text-sm text-gray-400">Bunga Nominal (Rp)</label>
                                        <input
                                            type="number"
                                            value={interest}
                                            onChange={e => setInterest(e.target.value)}
                                            className="w-full mt-1 bg-black/20 border border-white/10 rounded-lg py-2 px-4 focus:outline-none focus:border-blue-500"
                                            placeholder="50000"
                                        />
                                    </div>
                                    <div>
                                        <label className="text-sm text-gray-400">Tenor (Cicilan)</label>
                                        <select
                                            value={tenor}
                                            onChange={e => setTenor(parseInt(e.target.value))}
                                            className="w-full mt-1 bg-black/20 border border-white/10 rounded-lg py-2 px-4 focus:outline-none focus:border-blue-500 text-white"
                                        >
                                            <option value={1}>1x (Tunai / Bulan Ini)</option>
                                            <option value={3}>3x Bulan</option>
                                            <option value={6}>6x Bulan</option>
                                            <option value={12}>12x Bulan</option>
                                            <option value={24}>24x Bulan</option>
                                        </select>
                                    </div>
                                    <div className="md:col-span-3">
                                        <label className="text-sm text-gray-400">Jatuh Tempo</label>
                                        <input
                                            type="date"
                                            value={dueDate}
                                            onChange={e => setDueDate(e.target.value)}
                                            className="w-full mt-1 bg-black/20 border border-white/10 rounded-lg py-2 px-4 focus:outline-none focus:border-blue-500"
                                            required
                                        />
                                    </div>
                                    <div className="md:col-span-3">
                                        <button type="submit" className="w-full bg-blue-600 hover:bg-blue-500 text-white font-bold py-2 px-4 rounded-lg transition-colors">
                                            Buat Tagihan
                                        </button>
                                    </div>
                                </form>
                            </div>

                            {/* Active Loans List */}
                            <div className="glass rounded-xl overflow-hidden">
                                <div className="p-4 border-b border-white/10">
                                    <h3 className="font-bold">Riwayat Tagihan</h3>
                                </div>
                                <div className="max-h-[400px] overflow-y-auto">
                                    {loading ? (
                                        <div className="p-8 text-center text-gray-500">Loading...</div>
                                    ) : loans.length === 0 ? (
                                        <div className="p-8 text-center text-gray-500">Belum ada tagihan.</div>
                                    ) : (
                                        <table className="w-full text-left">
                                            <thead className="bg-white/5 text-xs text-gray-400 uppercase">
                                                <tr>
                                                    <th className="p-3">ID / Keterangan</th>
                                                    <th className="p-3">Total</th>
                                                    <th className="p-3">Jatuh Tempo</th>
                                                    <th className="p-3">Status</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-white/5">
                                                {loans.map(loan => (
                                                    <tr key={loan.id} className="hover:bg-white/5">
                                                        <td className="p-3">
                                                            <div className="font-mono text-sm opacity-70">#{loan.id.substring(0, 8)}</div>
                                                            <div className="text-xs font-bold text-blue-300">{loan.title || 'Tagihan Tunai'}</div>
                                                        </td>
                                                        <td className="p-3 font-bold">Rp {parseInt(loan.totalAmount).toLocaleString()}</td>
                                                        <td className="p-3 text-sm">{new Date(loan.dueDate).toLocaleDateString()}</td>
                                                        <td className="p-3">
                                                            <span className={`inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-bold ${loan.status === 'PAID' ? 'text-green-400 bg-green-400/10' : 'text-yellow-400 bg-yellow-400/10'}`}>
                                                                {loan.status === 'PAID' ? <CheckCircle size={12} /> : <XCircle size={12} />}
                                                                {loan.status}
                                                            </span>
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    )}
                                </div>
                            </div>
                        </>
                    ) : (
                        <div className="glass p-12 rounded-xl flex flex-col items-center justify-center text-gray-500">
                            <Smartphone size={48} className="mb-4 opacity-50" />
                            <p>Pilih perangkat di sebelah kiri untuk melihat tagihan.</p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

export default LoanManager;
