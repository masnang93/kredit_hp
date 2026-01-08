import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';
import { DevicesModule } from './devices/devices.module';
import { Device } from './devices/device.entity';
import { Contact } from './devices/contact.entity';
import { PaymentConfig } from './payments/payment-config.entity';
import { AppController } from './app.controller';
import { LoansModule } from './loans/loans.module';
import { Loan } from './loans/loan.entity';

import { PaymentsModule } from './payments/payments.module';
import { ProductsModule } from './products/products.module';
import { Product } from './products/product.entity';

@Module({
    imports: [
        TypeOrmModule.forRoot({
            type: 'better-sqlite3',
            database: 'fintech_credit.sqlite',
            entities: [Device, Loan, Contact, PaymentConfig, Product],
            synchronize: true,
        }),
        DevicesModule,
        LoansModule,
        PaymentsModule,
        ProductsModule,
        ScheduleModule.forRoot(),
    ],
    controllers: [AppController],
})
export class AppModule { }
