import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LoansService } from './loans.service';
import { LoansController } from './loans.controller';
import { Loan } from './loan.entity';
import { Device } from '../devices/device.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Loan, Device])],
    providers: [LoansService],
    controllers: [LoansController],
})
export class LoansModule { }
