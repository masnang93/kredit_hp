import { Controller, Get, Post, Body, Param, Put } from '@nestjs/common';
import { LoansService } from './loans.service';
import { Loan } from './loan.entity';

@Controller('loans')
export class LoansController {
    constructor(private readonly loansService: LoansService) { }

    @Get()
    findAll(): Promise<Loan[]> {
        return this.loansService.findAll();
    }

    @Get('stats')
    getStats() {
        return this.loansService.getFinancialStats();
    }

    @Get('device/:imei')
    findByImei(@Param('imei') imei: string): Promise<Loan[]> {
        return this.loansService.findByImei(imei);
    }

    @Get('summary/:imei')
    getSummary(@Param('imei') imei: string) {
        return this.loansService.getSummary(imei);
    }

    @Post()
    create(@Body() body: { imei: string, loan: any }): Promise<Loan[]> {
        return this.loansService.create(body.imei, body.loan);
    }

    @Put(':id/pay')
    payLoan(@Param('id') id: string): Promise<Loan> {
        return this.loansService.payLoan(id);
    }
}
