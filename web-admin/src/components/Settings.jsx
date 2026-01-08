import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Shield, Bell, Lock, Globe, Save, CreditCard } from 'lucide-react';

const Settings = () => {
    const [paymentConfig, setPaymentConfig] = useState({
        merchantCode: '',
        apiKey: '',
        isProduction: false
    });

    useEffect(() => {
        fetchConfig();
    }, []);

    const fetchConfig = async () => {
        try {
            const res = await axios.get('http://localhost:3000/payments/config');
            if (res.data) setPaymentConfig(res.data);
        } catch (error) {
            console.error('Error fetching config:', error);
        }
    };

    const handleSaveConfig = async () => {
        try {
            await axios.put('http://localhost:3000/payments/config', paymentConfig);
            alert('Konfigurasi Pembayaran Tersimpan!');
        } catch (error) {
            alert('Gagal menyimpan konfigurasi');
        }
    };

    return (
        <div className="p-8 max-w-4xl animate-fade-in">
            <header className="mb-8">
                <h2 className="text-3xl font-bold mb-2">Pengaturan Sistem</h2>
                <p className="text-gray-400">Konfigurasi keamanan dan notifikasi aplikasi.</p>
            </header>

            <div className="space-y-6">
                {/* Payment Gateway Section */}
                <section className="glass rounded-xl p-6">
                    <div className="flex items-center gap-3 mb-6">
                        <div className="p-2 bg-green-500/20 rounded-lg text-green-400">
                            <CreditCard size={24} />
                        </div>
                        <h3 className="text-xl font-bold">Payment Gateway (Duitku)</h3>
                    </div>

                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-400 mb-2">Merchant Code</label>
                            <input
                                type="text"
                                className="w-full bg-black/30 border border-white/10 rounded-lg p-3 text-white focus:outline-none focus:border-green-500"
                                placeholder="D12345"
                                value={paymentConfig.merchantCode || ''}
                                onChange={(e) => setPaymentConfig({ ...paymentConfig, merchantCode: e.target.value })}
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-400 mb-2">API Key</label>
                            <input
                                type="password"
                                className="w-full bg-black/30 border border-white/10 rounded-lg p-3 text-white focus:outline-none focus:border-green-500"
                                placeholder="****************"
                                value={paymentConfig.apiKey || ''}
                                onChange={(e) => setPaymentConfig({ ...paymentConfig, apiKey: e.target.value })}
                            />
                        </div>

                        <div className="flex items-center justify-between p-4 bg-white/5 rounded-lg border border-white/5 cursor-pointer"
                            onClick={() => setPaymentConfig({ ...paymentConfig, isProduction: !paymentConfig.isProduction })}>
                            <div>
                                <h4 className="font-semibold text-white">Mode Production</h4>
                                <p className="text-sm text-gray-400">{paymentConfig.isProduction ? 'Aktif (Transaksi Real)' : 'Non-Aktif (Sandbox / Testing)'}</p>
                            </div>
                            <div className={`w-12 h-6 rounded-full relative transition-colors ${paymentConfig.isProduction ? 'bg-green-600' : 'bg-gray-600'}`}>
                                <div className={`absolute top-1 left-1 bg-white w-4 h-4 rounded-full transition-transform ${paymentConfig.isProduction ? 'translate-x-6' : 'translate-x-0'}`} />
                            </div>
                        </div>

                        <button
                            onClick={handleSaveConfig}
                            className="w-full py-3 bg-green-600 hover:bg-green-700 text-white rounded-xl font-bold transition-all shadow-lg hover:shadow-green-500/25 mt-2">
                            Simpan Konfigurasi Pembayaran
                        </button>
                    </div>
                </section>

                {/* Security Section */}
                <section className="glass rounded-xl p-6">
                    <div className="flex items-center gap-3 mb-6">
                        <div className="p-2 bg-blue-500/20 rounded-lg text-blue-400">
                            <Shield size={24} />
                        </div>
                        <h3 className="text-xl font-bold">Keamanan Perangkat</h3>
                    </div>

                    <div className="space-y-4">
                        <ToggleOption
                            label="Auto-Lock saat Telat Bayar"
                            desc="Otomatis kunci perangkat jika melewati jatuh tempo 1 hari."
                            defaultChecked
                        />
                        <ToggleOption
                            label="Paksa GPS Aktif"
                            desc="Wajibkan pengguna mengaktifkan lokasi saat membuka aplikasi."
                            defaultChecked
                        />
                        <ToggleOption
                            label="Deteksi Root / Jailbreak"
                            desc="Blokir akses jika perangkat terdeteksi sudah di-root."
                        />
                    </div>
                </section>

                {/* Notif Section */}
                <section className="glass rounded-xl p-6">
                    <div className="flex items-center gap-3 mb-6">
                        <div className="p-2 bg-yellow-500/20 rounded-lg text-yellow-400">
                            <Bell size={24} />
                        </div>
                        <h3 className="text-xl font-bold">Notifikasi & Peringatan</h3>
                    </div>

                    <div className="space-y-4">
                        <ToggleOption
                            label="Peringatan H-3 Jatuh Tempo"
                            desc="Kirim notifikasi WA dan Push Notification otomatis."
                            defaultChecked
                        />
                        <div className="p-4 bg-white/5 rounded-lg border border-white/5">
                            <label className="block text-sm font-medium text-gray-400 mb-2">Pesan Layar Kunci (Custom Message)</label>
                            <textarea
                                className="w-full bg-black/30 border border-white/10 rounded-lg p-3 text-white focus:outline-none focus:border-blue-500 transition-colors"
                                rows={3}
                                defaultValue="PERANGKAT TERKUNCI. Mohon segera lakukan pembayaran cicilan Anda untuk membuka akses kembali."
                            />
                        </div>
                    </div>
                </section>

                <div className="flex justify-end pt-4">
                    <button className="flex items-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-500 text-white rounded-xl font-bold transition-all shadow-lg hover:shadow-blue-500/25">
                        <Save size={20} />
                        Simpan Perubahan
                    </button>
                </div>
            </div>
        </div>
    );
};

const ToggleOption = ({ label, desc, defaultChecked = false }) => {
    const [checked, setChecked] = useState(defaultChecked);

    return (
        <div className="flex items-center justify-between p-4 bg-white/5 rounded-lg border border-white/5 hover:bg-white/10 transition-colors cursor-pointer" onClick={() => setChecked(!checked)}>
            <div>
                <h4 className="font-semibold text-white">{label}</h4>
                <p className="text-sm text-gray-400">{desc}</p>
            </div>
            <div className={`w-12 h-6 rounded-full relative transition-colors ${checked ? 'bg-blue-600' : 'bg-gray-600'}`}>
                <div className={`absolute top-1 left-1 bg-white w-4 h-4 rounded-full transition-transform ${checked ? 'translate-x-6' : 'translate-x-0'}`} />
            </div>
        </div>
    );
};

export default Settings;
