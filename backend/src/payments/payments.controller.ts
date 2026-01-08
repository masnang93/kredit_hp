import { Controller, Post, Get, Put, Body, Param, Req, Res } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { Request, Response } from 'express';

@Controller('payments')
export class PaymentsController {
    constructor(private readonly paymentsService: PaymentsService) { }

    @Get('config')
    async getConfig() {
        return this.paymentsService.getConfig();
    }

    @Put('config')
    async updateConfig(@Body() body: any) {
        return this.paymentsService.updateConfig(body);
    }

    @Post('invoice')
    async createInvoice(@Body() body: { loanId: string; amount: number; userId: string }, @Req() req: Request) {
        const result = await this.paymentsService.createInvoice(body.loanId, body.amount, body.userId);
        // Prepend Host for Simulation
        if (result.mode === 'SIMULATION') {
            const host = req.get('host'); // e.g., localhost:3000
            const protocol = req.protocol;
            result.paymentUrl = `${protocol}://${host}${result.paymentUrl}`;
        }
        return result;
    }

    @Get('pay/:loanId')
    async getPaymentPage(@Param('loanId') loanId: string, @Res() res: Response) {
        const html = await this.paymentsService.getPaymentPage(loanId);
        res.send(html);
    }

    @Post('pay/:loanId')
    async confirmPayment(@Param('loanId') loanId: string, @Res() res: Response) {
        const success = await this.paymentsService.processPaymentSimulation(loanId);
        if (success) {
            res.send('<h1>Payment Successful! Device Unlocked.</h1><p>You can close this window.</p>');
        } else {
            res.send('<h1>Payment Failed</h1>');
        }
    }

    @Post('callback')
    async callback(@Body() body: any) {
        return this.paymentsService.handleCallback(body);
    }
}
