import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Smartphone, Lock, Unlock, RefreshCw, AlertCircle, MapPin, User, X, Phone, CreditCard, Edit2, Save } from 'lucide-react';

const Dashboard = () => {
    const [devices, setDevices] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const [finStats, setFinStats] = useState({ totalDisbursed: 0, outstandingAmount: 0, totalCollected: 0, totalProfit: 0 });

    // Detail Modal State
    const [selectedDetailDevice, setSelectedDetailDevice] = useState(null);
    const [detailContacts, setDetailContacts] = useState([]);
    const [loadingContacts, setLoadingContacts] = useState(false);
    const [isEditingDetail, setIsEditingDetail] = useState(false);

    // Edit Form State
    const [editFormData, setEditFormData] = useState({});

    const fetchDevices = async () => {
        try {
            setLoading(true);
            const response = await api.get('/devices');
            setDevices(response.data);

            // Fetch Financial Stats
            const stats = await api.get('/loans/stats');
            setFinStats(stats.data);

            setError(null);
        } catch (err) {
            console.error(err);
            setError(`Gagal mengambil data perangkat. Error: ${err.message || err.toString()}`);
            // Mock data for demo if backend fails
            setDevices([
                { id: '1', imei: 'test-device-id-001', model: 'Flutter Emulator', status: 'UNLOCKED' },
                { id: '2', imei: 'demo-device-002', model: 'Samsung Galaxy A54', status: 'LOCKED' },
            ]);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchDevices();
    }, []);

    const toggleLock = async (id, currentStatus) => {
        const newStatus = currentStatus === 'LOCKED' ? 'unlock' : 'lock';
        try {
            await api.put(`/devices/${id}/${newStatus}`);
            fetchDevices(); // Refresh data
        } catch (err) {
            alert('Gagal mengubah status: ' + err.message);
        }
    };

    const openDetailModal = async (device) => {
        setSelectedDetailDevice(device);
        setEditFormData({ ...device }); // Init edit form
        setIsEditingDetail(false);
        setDetailContacts([]);
        setLoadingContacts(true);
        try {
            const res = await api.get(`/devices/${device.imei}/contacts`);
            setDetailContacts(res.data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoadingContacts(false);
        }
    };

    const handleEditChange = (e) => {
        setEditFormData({
            ...editFormData,
            [e.target.name]: e.target.value
        });
    };

    const saveDetail = async () => {
        try {
            await api.put(`/devices/${selectedDetailDevice.imei}`, editFormData);
            alert('Data Pelanggan Berhasil Disimpan!');
            setIsEditingDetail(false);
            setSelectedDetailDevice({ ...editFormData }); // Update local view
            fetchDevices(); // Refresh lists
        } catch (err) {
            alert('Gagal menyimpan: ' + err.message);
        }
    };

    const updateLimit = async (imei, newLimit) => {
        try {
            await api.put(`/devices/${imei}`, {
                creditLimit: newLimit
            });
            alert('Limit berhasil diperbarui!');
            fetchDevices();
            setSelectedDetailDevice(prev => ({ ...prev, creditLimit: newLimit }));
        } catch (err) {
            alert('Gagal update limit: ' + err.message);
        }
    };

    const closeDetailModal = () => {
        setSelectedDetailDevice(null);
    };

    return (
        <div className="p-8">
            <header className="flex justify-between items-center mb-8">
                <div>
                    <h2 className="text-3xl font-bold mb-2">Dashboard</h2>
                    <p className="text-gray-400">Pantau dan kelola perangkat terdaftar.</p>
                </div>
                <button
                    onClick={fetchDevices}
                    className="flex items-center gap-2 px-4 py-2 bg-white/5 hover:bg-white/10 rounded-lg transition-colors border border-white/10"
                >
                    <RefreshCw size={18} />
                    Refresh
                </button>
            </header>

            {/* Financial Stats */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                <div className="glass-card bg-blue-500/10 border-blue-500/20">
                    <h3 className="text-blue-300 mb-1 text-sm font-medium">Total Pembiayaan</h3>
                    <p className="text-2xl font-bold text-white">
                        {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(finStats.totalDisbursed)}
                    </p>
                </div>
                <div className="glass-card bg-yellow-500/10 border-yellow-500/20">
                    <h3 className="text-yellow-300 mb-1 text-sm font-medium">Sisa Piutang (Outstanding)</h3>
                    <p className="text-2xl font-bold text-white">
                        {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(finStats.outstandingAmount)}
                    </p>
                </div>
                <div className="glass-card bg-green-500/10 border-green-500/20">
                    <h3 className="text-green-300 mb-1 text-sm font-medium">Total Terkumpul</h3>
                    <p className="text-2xl font-bold text-white">
                        {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(finStats.totalCollected)}
                    </p>
                </div>
                <div className="glass-card bg-purple-500/10 border-purple-500/20">
                    <h3 className="text-purple-300 mb-1 text-sm font-medium">Keuntungan (Bunga)</h3>
                    <p className="text-2xl font-bold text-white">
                        {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(finStats.totalProfit)}
                    </p>
                </div>
            </div>

            {/* Device Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div className="glass-card">
                    <h3 className="text-gray-400 mb-1">Total Perangkat</h3>
                    <p className="text-4xl font-bold text-white">{devices.length}</p>
                </div>
                <div className="glass-card relative overflow-hidden group">
                    <div className="absolute top-0 right-0 p-4 bg-green-500/10 rounded-bl-2xl">
                        <Unlock className="text-green-400" size={24} />
                    </div>
                    <h3 className="text-gray-400 mb-1">Status Aman</h3>
                    <p className="text-4xl font-bold text-green-400">
                        {devices.filter(d => d.status === 'UNLOCKED').length}
                    </p>
                </div>
                <div className="glass-card relative overflow-hidden group">
                    <div className="absolute top-0 right-0 p-4 bg-red-500/10 rounded-bl-2xl">
                        <Lock className="text-red-400" size={24} />
                    </div>
                    <h3 className="text-gray-400 mb-1">Terkunci</h3>
                    <p className="text-4xl font-bold text-red-500">
                        {devices.filter(d => d.status === 'LOCKED').length}
                    </p>
                </div>
            </div>

            {/* Device List */}
            <div className="glass rounded-xl overflow-hidden">
                <div className="p-6 border-b border-white/10">
                    <h3 className="text-xl font-bold">Daftar Perangkat</h3>
                </div>

                {loading ? (
                    <div className="p-8 text-center text-gray-400">Loading data...</div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-white/5 text-gray-400 text-sm">
                                    <th className="p-4 font-normal">ID / IMEI</th>
                                    <th className="p-4 font-normal">Model</th>
                                    <th className="p-4 font-normal">Lokasi</th>
                                    <th className="p-4 font-normal">Status</th>
                                    <th className="p-4 font-normal text-right">Aksi</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-white/5">
                                {devices.map((device) => (
                                    <tr key={device.id} className="hover:bg-white/5 transition-colors">
                                        <td className="p-4 flex items-center gap-3">
                                            <div className="p-2 bg-gray-700/50 rounded-lg">
                                                <Smartphone size={18} className="text-blue-400" />
                                            </div>
                                            <div>
                                                <div className="font-mono text-sm">{device.imei}</div>
                                                <div className="text-xs text-gray-500">{device.ownerName || 'No Name'}</div>
                                                <button
                                                    onClick={() => openDetailModal(device)}
                                                    className="text-xs text-blue-400 hover:text-blue-300 hover:underline mt-1 flex items-center gap-1"
                                                >
                                                    <User size={10} /> Lihat Detail
                                                </button>
                                            </div>
                                        </td>
                                        <td className="p-4 text-gray-300">{device.model || 'Unknown'}</td>
                                        <td className="p-4">
                                            {device.latitude && device.longitude ? (
                                                <a
                                                    href={`https://www.google.com/maps/search/?api=1&query=${device.latitude},${device.longitude}`}
                                                    target="_blank"
                                                    rel="noreferrer"
                                                    className="inline-flex items-center gap-1 text-blue-400 hover:text-blue-300 hover:underline text-sm"
                                                >
                                                    <MapPin size={14} />
                                                    Lihat Peta
                                                </a>
                                            ) : (
                                                <span className="text-gray-600 text-sm italic">Belum ada lokasi</span>
                                            )}
                                        </td>
                                        <td className="p-4">
                                            <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium border ${device.status === 'LOCKED'
                                                ? 'bg-red-500/10 text-red-400 border-red-500/20'
                                                : 'bg-green-500/10 text-green-400 border-green-500/20'
                                                }`}>
                                                {device.status === 'LOCKED' ? 'LOCKED' : 'ACTIVE'}
                                            </span>
                                        </td>
                                        <td className="p-4 text-right">
                                            <button
                                                onClick={() => toggleLock(device.id, device.status)}
                                                className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm font-medium transition-all ${device.status === 'LOCKED'
                                                    ? 'bg-green-500/20 text-green-400 hover:bg-green-500/30'
                                                    : 'bg-red-500/20 text-red-400 hover:bg-red-500/30'
                                                    }`}
                                            >
                                                {device.status === 'LOCKED' ? <Unlock size={14} /> : <Lock size={14} />}
                                                {device.status === 'LOCKED' ? 'Buka Kunci' : 'Kunci Perangkat'}
                                            </button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>

            {error && (
                <div className="mt-8 p-4 glass border-l-4 border-yellow-500 flex items-start gap-3">
                    <AlertCircle className="text-yellow-500 mt-0.5" size={20} />
                    <div>
                        <h4 className="font-bold text-yellow-500">Koneksi Backend Bermasalah</h4>
                        <p className="text-sm text-gray-400">{error} (Menampilkan data dummy)</p>
                    </div>
                </div>
            )}

            {/* Detail Modal */}
            {selectedDetailDevice && (
                <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-[#1a1b23] border border-white/10 rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden flex flex-col shadow-2xl">
                        {/* Modal Header */}
                        <div className="p-6 border-b border-white/10 flex justify-between items-center bg-white/5">
                            <h3 className="text-xl font-bold flex items-center gap-3">
                                <User className="text-blue-400" />
                                {isEditingDetail ? 'Edit Pelanggan' : 'Detail Pelanggan'}
                            </h3>
                            <div className="flex gap-2">
                                <button
                                    onClick={() => {
                                        if (isEditingDetail) {
                                            saveDetail();
                                        } else {
                                            setIsEditingDetail(true);
                                        }
                                    }}
                                    className={`p-2 rounded-lg transition-colors flex items-center gap-2 ${isEditingDetail
                                        ? 'bg-green-500/20 text-green-400 hover:bg-green-500/30'
                                        : 'bg-white/5 hover:bg-white/10 text-white'}`}
                                >
                                    {isEditingDetail ? <Save size={20} /> : <Edit2 size={20} />}
                                    {isEditingDetail ? 'Simpan' : 'Edit'}
                                </button>
                                <button onClick={closeDetailModal} className="p-2 hover:bg-white/10 rounded-lg text-gray-400 hover:text-white transition-colors">
                                    <X size={24} />
                                </button>
                            </div>
                        </div>

                        {/* Modal Content */}
                        <div className="p-6 overflow-y-auto space-y-8">

                            {/* Biodata Section */}
                            <section>
                                <h4 className="text-sm font-bold text-gray-400 uppercase tracking-wider mb-4 border-b border-white/5 pb-2">Informasi Pribadi</h4>
                                <div className="grid grid-cols-2 gap-4">
                                    <div className="p-4 bg-white/5 rounded-xl border border-white/5 col-span-2">
                                        <div className="text-xs text-gray-500 mb-1">IMEI (Serial Number)</div>
                                        <div className="font-mono text-lg text-gray-400">{selectedDetailDevice.imei}</div>
                                    </div>

                                    {/* Brand (Merk) Field */}
                                    <div className="p-4 bg-white/5 rounded-xl border border-white/5">
                                        <div className="text-xs text-gray-500 mb-1">Merk HP</div>
                                        {isEditingDetail ? (
                                            <input name="brand" className="w-full bg-black/20 border border-white/10 rounded px-2 py-1 text-white" value={editFormData.brand || ''} onChange={handleEditChange} placeholder="Contoh: Samsung" />
                                        ) : (
                                            <div className="font-bold text-lg">{selectedDetailDevice.brand || '-'}</div>
                                        )}
                                    </div>

                                    {/* Model (Tipe) Field */}
                                    <div className="p-4 bg-white/5 rounded-xl border border-white/5">
                                        <div className="text-xs text-gray-500 mb-1">Tipe HP</div>
                                        {isEditingDetail ? (
                                            <input name="model" className="w-full bg-black/20 border border-white/10 rounded px-2 py-1 text-white" value={editFormData.model || ''} onChange={handleEditChange} placeholder="Contoh: Galaxy A54" />
                                        ) : (
                                            <div className="font-bold text-lg">{selectedDetailDevice.model || '-'}</div>
                                        )}
                                    </div>

                                    {/* Name Field */}
                                    <div className="p-4 bg-white/5 rounded-xl border border-white/5">
                                        <div className="text-xs text-gray-500 mb-1">Nama Lengkap</div>
                                        {isEditingDetail ? (
                                            <input name="ownerName" className="w-full bg-black/20 border border-white/10 rounded px-2 py-1 text-white" value={editFormData.ownerName || ''} onChange={handleEditChange} />
                                        ) : (
                                            <div className="font-bold text-lg">{selectedDetailDevice.ownerName || '-'}</div>
                                        )}
                                    </div>

                                    {/* NIK Field */}
                                    <div className="p-4 bg-white/5 rounded-xl border border-white/5">
                                        <div className="text-xs text-gray-500 mb-1">NIK</div>
                                        {isEditingDetail ? (
                                            <input name="nik" className="w-full bg-black/20 border border-white/10 rounded px-2 py-1 text-white" value={editFormData.nik || ''} onChange={handleEditChange} />
                                        ) : (
                                            <div className="font-mono text-lg">{selectedDetailDevice.nik || '-'}</div>
                                        )}
                                    </div>

                                    {/* Phone Field */}
                                    <div className="p-4 bg-white/5 rounded-xl border border-white/5">
                                        <div className="text-xs text-gray-500 mb-1">Nomor HP</div>
                                        {isEditingDetail ? (
                                            <input name="phoneNumber" className="w-full bg-black/20 border border-white/10 rounded px-2 py-1 text-white" value={editFormData.phoneNumber || ''} onChange={handleEditChange} />
                                        ) : (
                                            <div className="font-mono text-lg flex items-center gap-2">
                                                <Phone size={16} className="text-green-400" />
                                                {selectedDetailDevice.phoneNumber || '-'}
                                            </div>
                                        )}
                                    </div>

                                    {/* Email Field (NEW) */}
                                    <div className="p-4 bg-white/5 rounded-xl border border-white/5">
                                        <div className="text-xs text-gray-500 mb-1">Email</div>
                                        {isEditingDetail ? (
                                            <input name="email" className="w-full bg-black/20 border border-white/10 rounded px-2 py-1 text-white" value={editFormData.email || ''} onChange={handleEditChange} />
                                        ) : (
                                            <div className="font-mono text-lg">{selectedDetailDevice.email || '-'}</div>
                                        )}
                                    </div>

                                    {/* Emergency Field */}
                                    <div className="p-4 bg-white/5 rounded-xl border border-white/5 col-span-2">
                                        <div className="text-xs text-gray-500 mb-1">Kontak Darurat</div>
                                        {isEditingDetail ? (
                                            <input name="emergencyContact" className="w-full bg-black/20 border border-white/10 rounded px-2 py-1 text-white" value={editFormData.emergencyContact || ''} onChange={handleEditChange} />
                                        ) : (
                                            <div className="font-mono text-lg flex items-center gap-2">
                                                <AlertCircle size={16} className="text-orange-400" />
                                                {selectedDetailDevice.emergencyContact || '-'}
                                            </div>
                                        )}
                                    </div>

                                    {/* Address Field */}
                                    <div className="p-4 bg-white/5 rounded-xl border border-white/5 col-span-2">
                                        <div className="text-xs text-gray-500 mb-1">Alamat Lengkap</div>
                                        {isEditingDetail ? (
                                            <textarea name="address" className="w-full bg-black/20 border border-white/10 rounded px-2 py-1 text-white" rows="2" value={editFormData.address || ''} onChange={handleEditChange} />
                                        ) : (
                                            <div className="text-sm">{selectedDetailDevice.address || '-'}</div>
                                        )}
                                    </div>

                                    <div className="p-4 bg-white/5 rounded-xl border border-white/5">
                                        <div className="text-xs text-gray-500 mb-1">Status Perangkat</div>
                                        <div className={`font-bold ${selectedDetailDevice.status === 'LOCKED' ? 'text-red-400' : 'text-green-400'}`}>
                                            {selectedDetailDevice.status}
                                        </div>
                                    </div>
                                    <div className="p-4 bg-blue-500/10 rounded-xl border border-blue-500/20 col-span-2">
                                        <div className="text-xs text-blue-300 mb-2">Limit Kredit (Plafon)</div>
                                        <div className="flex gap-2">
                                            <input
                                                type="number"
                                                className="bg-black/20 border border-white/10 rounded px-3 py-2 text-white w-full"
                                                defaultValue={selectedDetailDevice.creditLimit || 10000000}
                                                id="limitInput"
                                            />
                                            <button
                                                onClick={() => {
                                                    const val = document.getElementById('limitInput').value;
                                                    updateLimit(selectedDetailDevice.imei, val);
                                                }}
                                                className="bg-blue-600 hover:bg-blue-500 text-white px-4 py-2 rounded font-medium"
                                            >
                                                Update
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </section>

                            {/* Synced Contacts Section */}
                            <section>
                                <div className="flex justify-between items-center mb-4 border-b border-white/5 pb-2">
                                    <h4 className="text-sm font-bold text-gray-400 uppercase tracking-wider">Kontak Tersinkronisasi</h4>
                                    <span className="text-xs bg-white/10 px-2 py-1 rounded-full text-gray-300">
                                        {detailContacts.length} Kontak
                                    </span>
                                </div>

                                <div className="bg-black/20 rounded-xl border border-white/5 h-[250px] overflow-y-auto p-2">
                                    {loadingContacts ? (
                                        <div className="flex items-center justify-center h-full text-gray-500">
                                            <RefreshCw size={20} className="animate-spin mr-2" />
                                            Mengambil data kontak...
                                        </div>
                                    ) : detailContacts.length === 0 ? (
                                        <div className="flex items-center justify-center h-full text-gray-500 italic">
                                            Tidak ada kontak tersinkronisasi.
                                        </div>
                                    ) : (
                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                                            {detailContacts.map((contact, idx) => (
                                                <div key={idx} className="flex items-center gap-3 p-2 hover:bg-white/5 rounded-lg transition-colors">
                                                    <div className="w-8 h-8 rounded-full bg-blue-500/20 flex items-center justify-center text-blue-400 font-bold text-xs">
                                                        {contact.displayName.charAt(0).toUpperCase()}
                                                    </div>
                                                    <div className="overflow-hidden">
                                                        <div className="text-sm font-medium truncate">{contact.displayName}</div>
                                                        <div className="text-xs text-gray-500 font-mono">{contact.phoneNumber}</div>
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                </div>
                            </section>

                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Dashboard;
