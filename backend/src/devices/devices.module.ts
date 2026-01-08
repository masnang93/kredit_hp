import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DevicesController } from './devices.controller';
import { DevicesService } from './devices.service';
import { Device } from './device.entity';
import { Contact } from './contact.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Device, Contact])],
    controllers: [DevicesController],
    providers: [DevicesService],
})
export class DevicesModule { }
