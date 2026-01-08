import axios from 'axios';

// Ganti URL ini dengan IP VPS Anda saat deploy
// Contoh: 'http://72.61.113.95'
// Untuk development lokal: 'http://localhost:3000'

const API_BASE_URL = 'http://72.61.113.95:3000';

const api = axios.create({
    baseURL: API_BASE_URL,
});

export default api;
