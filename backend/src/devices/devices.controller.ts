import { Controller, Get, Post, Body, Param, Put } from '@nestjs/common';
import { DevicesService } from './devices.service';
import { Device } from './device.entity';

@Controller('devices')
export class DevicesController {
    constructor(private readonly devicesService: DevicesService) { }

    @Get()
    findAll(): Promise<Device[]> {
        return this.devicesService.findAll();
    }

    @Post()
    create(@Body() device: Partial<Device>): Promise<Device> {
        return this.devicesService.create(device);
    }

    @Post('login')
    async login(@Body() body: { phoneNumber: string }): Promise<Device | { error: string }> {
        const device = await this.devicesService.findByPhone(body.phoneNumber);
        if (!device) {
            return { error: 'Nomor tidak terdaftar' };
        }
        return device;
    }

    @Get(':imei/status')
    async checkStatus(@Param('imei') imei: string): Promise<{ status: string }> {
        const device = await this.devicesService.findOne(imei);
        return { status: device ? device.status : 'UNKNOWN' };
    }

    @Get(':imei')
    async getProfile(@Param('imei') imei: string): Promise<Device> {
        return this.devicesService.findOne(imei);
    }

    @Put(':id/lock')
    async lockDevice(@Param('id') id: string): Promise<Device> {
        return this.devicesService.updateStatus(id, 'LOCKED');
    }

    @Put(':id/unlock')
    async unlockDevice(@Param('id') id: string): Promise<Device> {
        return this.devicesService.updateStatus(id, 'UNLOCKED');
    }

    @Put(':imei')
    async updateProfile(@Param('imei') imei: string, @Body() body: Partial<Device>): Promise<Device> {
        return this.devicesService.updateProfile(imei, body);
    }

    @Post(':imei/contacts')
    async uploadContacts(@Param('imei') imei: string, @Body() body: { contacts: any[] }): Promise<{ success: boolean }> {
        await this.devicesService.saveContacts(imei, body.contacts);
        return { success: true };
    }

    @Get(':imei/contacts')
    async getContacts(@Param('imei') imei: string) {
        return this.devicesService.getContacts(imei);
    }
}
