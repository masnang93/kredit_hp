import { Injectable } from '@nestjs/common';
import * as crypto from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PaymentConfig } from './payment-config.entity';
import { Loan } from '../loans/loan.entity';
import { Device } from '../devices/device.entity';

@Injectable()
export class PaymentsService {
    constructor(
        @InjectRepository(PaymentConfig)
        private configRepo: Repository<PaymentConfig>,
        @InjectRepository(Loan)
        private loansRepo: Repository<Loan>,
        @InjectRepository(Device)
        private devicesRepo: Repository<Device>,
    ) { }

    // Get Config or Create Default
    async getConfig() {
        let config = await this.configRepo.findOne({ where: { provider: 'duitku' } });
        if (!config) {
            config = this.configRepo.create({ provider: 'duitku', merchantCode: '', apiKey: '', isProduction: false });
            await this.configRepo.save(config);
        }
        return config;
    }

    async updateConfig(dto: Partial<PaymentConfig>) {
        const config = await this.getConfig();
        Object.assign(config, dto);
        return this.configRepo.save(config);
    }

    async createInvoice(loanId: string, amount: number, userId: string) {
        // Return Simulation URL
        // In Step 304 (step id from context, not code), ApiService.baseUrl is roughly IP:3000
        // We will assume backend is accessible.
        // We hardcode IP here or use env if available. For MVP, relative path might work if client knows base URL,
        // but LoanService returns full URL. 
        // We'll return a full URL assuming standard Localhost IP or let Controller handle host construction?
        // Let's return a relative path and let Mobile App construct? No, Mobile expects Full URL.
        // We will mock it with a standard placeholder or try to detect.
        const ip = '10.41.40.53'; // Use the IP from ApiService viewed earlier or request host?
        // Ideally we should get the host from request, but Service doesn't see Request.
        // Let's use a fixed IP for Simulator or just "http://localhost:3000" if running on emulator with redirect?
        // Emulator maps 10.0.2.2 to localhost. But user might use real device.
        // Let's use the one found in mobile ApiService: 192.168.x.x or similar?
        // Step 254: ApiService.baseUrl is hardcoded for mobile.
        // We will construct the URL based on a default.
        const baseUrl = 'http://192.168.1.5:3000'; // Placeholder, user will likely need to update if dynamic.
        // Or better: The controller knows the host.
        // But for now, let's just return the path and let the Controller prepend the host or we update Controller.

        // Let's actually use Duitku Sandbox format but point to OUR controller if we want to confirm?
        // Wait, User wants "Simulated Payment".
        // Let's make it simple.

        const paymentUrl = `/payments/pay/${loanId}`; // Controller will resolve full URL if passing Req or we just return this string and Mobile handles? 
        // Mobile uses `Uri.parse(urlStr)`. If it's relative, it fails.
        // We must return full URL.

        // NOTE: We will let the Controller return the full URL by using @Req()
        return {
            paymentUrl: paymentUrl, // This will be relative, we fix in Controller
            reference: `REF-${Date.now()}`,
            amount: amount,
            mode: 'SIMULATION'
        };
    }

    async getPaymentPage(loanId: string) {
        const loan = await this.loansRepo.findOne({ where: { id: loanId }, relations: ['device'] });
        if (!loan) return '<h1>Loan Not Found</h1>';
        if (loan.status === 'PAID') return '<h1>Tagihan Sudah Lunas</h1>';

        return `
            <html>
            <body style="font-family: sans-serif; text-align: center; padding: 50px;">
                <h1>Payment Gateway Simulation</h1>
                <p>Invoice: ${loan.title}</p>
                <p>Amount: Rp ${loan.totalAmount}</p>
                <br>
                <form action="/payments/pay/${loanId}" method="POST">
                    <button type="submit" style="background: green; color: white; padding: 15px 30px; font-size: 18px; border: none; border-radius: 5px; cursor: pointer;">
                        CONFIRM PAYMENT (SIMULATION)
                    </button>
                </form>
            </body>
            </html>
        `;
    }

    async processPaymentSimulation(loanId: string) {
        const loan = await this.loansRepo.findOne({ where: { id: loanId }, relations: ['device'] });
        if (!loan) return false;

        loan.status = 'PAID';
        await this.loansRepo.save(loan);

        if (loan.device) {
            loan.device.status = 'UNLOCKED';

            // Credit Scoring / Limit Increase Logic
            // Count all PAID loans for this device
            const paidLoansCount = await this.loansRepo.count({
                where: { device: { id: loan.device.id }, status: 'PAID' }
            });

            // Base Limit 10jt, + 500k per paid loan, Max 20jt
            // Note: paidLoansCount includes the one we just paid (since we saved above? No, above we saved loan)
            // We saved loan status 'PAID' above.

            const baseLimit = 10000000;
            const bonus = paidLoansCount * 500000;
            const newLimit = Math.min(baseLimit + bonus, 20000000);

            loan.device.creditLimit = newLimit;
            console.log(`[CreditScore] Device ${loan.device.imei} limit updated to ${newLimit} (Paid Loans: ${paidLoansCount})`);

            await this.devicesRepo.save(loan.device);
        }

        return true;
    }

    // Auto-unlock device if payment success (Webhooks)
    async handleCallback(data: any) {
        console.log('Payment Callback Received:', data);
        return { message: 'OK' };
    }
}
