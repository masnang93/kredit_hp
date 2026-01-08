import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Loan } from './loan.entity';
import { Device } from '../devices/device.entity';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class LoansService {
    constructor(
        @InjectRepository(Loan)
        private loansRepository: Repository<Loan>,
        @InjectRepository(Device)
        private devicesRepository: Repository<Device>,
    ) { }

    findAll(): Promise<Loan[]> {
        return this.loansRepository.find({ relations: ['device'] });
    }

    async findByImei(imei: string): Promise<Loan[]> {
        return this.loansRepository.find({
            where: { device: { imei } },
            order: { createdAt: 'DESC' }
        });
    }

    async create(imei: string, data: any): Promise<Loan[]> {
        const device = await this.devicesRepository.findOneBy({ imei });
        if (!device) {
            throw new Error('Device not found');
        }

        const tenor = data.tenor || 1;
        const totalPrincipal = data.amount;
        const totalInterest = data.interest;
        const totalBill = data.totalAmount;

        const monthlyPrincipal = totalPrincipal / tenor;
        const monthlyInterest = totalInterest / tenor;
        const monthlyTotal = totalBill / tenor;

        const createdLoans: Loan[] = [];

        for (let i = 0; i < tenor; i++) {
            const dueDate = new Date(data.dueDate);
            dueDate.setMonth(dueDate.getMonth() + i);

            const loan = this.loansRepository.create({
                amount: monthlyPrincipal,
                interest: monthlyInterest,
                totalAmount: monthlyTotal,
                dueDate: dueDate,
                status: 'PENDING',
                title: tenor > 1 ? `Cicilan ${i + 1}/${tenor}` : `Tagihan Tunai`,
                device: device
            });
            createdLoans.push(await this.loansRepository.save(loan));
        }

        return createdLoans;
    }

    async payLoan(id: string): Promise<Loan> {
        await this.loansRepository.update(id, { status: 'PAID' });
        return this.loansRepository.findOneBy({ id });
    }

    async getFinancialStats() {
        const totalDisbursed = await this.loansRepository
            .createQueryBuilder('loan')
            .select('SUM(loan.amount)', 'sum')
            .getRawOne();

        const outstanding = await this.loansRepository
            .createQueryBuilder('loan')
            .select('SUM(loan.totalAmount)', 'sum')
            .where('loan.status = :status', { status: 'PENDING' })
            .getRawOne();

        const collected = await this.loansRepository
            .createQueryBuilder('loan')
            .select('SUM(loan.totalAmount)', 'total')
            .addSelect('SUM(loan.interest)', 'interest')
            .where('loan.status = :status', { status: 'PAID' })
            .getRawOne();

        return {
            totalDisbursed: parseFloat(totalDisbursed.sum || 0),
            outstandingAmount: parseFloat(outstanding.sum || 0),
            totalCollected: parseFloat(collected.total || 0),
            totalProfit: parseFloat(collected.interest || 0)
        };
    }

    async getSummary(imei: string) {
        const device = await this.devicesRepository.findOneBy({ imei });
        if (!device) return { totalLimit: 0, availableLimit: 0, currency: 'IDR' };

        const activeLoans = await this.loansRepository.find({
            where: { device: { imei }, status: 'PENDING' }
        });

        const usedAmount = activeLoans.reduce((sum, loan) => sum + Number(loan.totalAmount), 0);
        const creditLimit = Number(device.creditLimit) || 10000000;

        return {
            totalLimit: creditLimit,
            availableLimit: creditLimit - usedAmount,
            currency: 'IDR'
        };
    }

    @Cron(CronExpression.EVERY_MINUTE)
    async checkOverdueLoans() {
        // console.log('Checking for overdue loans...'); // Debug log
        try {
            const now = new Date();
            const overdueLoans = await this.loansRepository
                .createQueryBuilder('loan')
                .leftJoinAndSelect('loan.device', 'device')
                .where('loan.status = :status', { status: 'PENDING' })
                .andWhere('loan.dueDate < :now', { now })
                .getMany();

            if (overdueLoans.length > 0) {
                console.log(`Found ${overdueLoans.length} overdue loans. Locking devices...`);
                for (const loan of overdueLoans) {
                    if (loan.device && loan.device.status !== 'LOCKED') {
                        console.log(`Locking device ${loan.device.imei} due to overdue loan #${loan.id}`);
                        // Update device status to LOCKED
                        // We inject DevicesRepository directly or use DevicesService via forwardRef if needed
                        // For simplicity since we have Repository<Device> injected:
                        loan.device.status = 'LOCKED';
                        await this.devicesRepository.save(loan.device);
                    }
                }
            }
        } catch (e) {
            console.error('Error checking overdue loans:', e);
        }
    }
}
