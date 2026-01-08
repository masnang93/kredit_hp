import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PaymentsService } from './payments.service';
import { PaymentsController } from './payments.controller';
import { PaymentConfig } from './payment-config.entity';

import { Loan } from '../loans/loan.entity';
import { Device } from '../devices/device.entity';

@Module({
    imports: [TypeOrmModule.forFeature([PaymentConfig, Loan, Device])],
    providers: [PaymentsService],
    controllers: [PaymentsController],
})
export class PaymentsModule { }
