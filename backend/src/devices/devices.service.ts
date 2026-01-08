import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Device } from './device.entity';
import { Contact } from './contact.entity';

@Injectable()
export class DevicesService {
    constructor(
        @InjectRepository(Device)
        private devicesRepository: Repository<Device>,
        @InjectRepository(Contact)
        private contactsRepository: Repository<Contact>,
    ) { }

    findAll(): Promise<Device[]> {
        return this.devicesRepository.find();
    }

    findOne(imei: string): Promise<Device | null> {
        return this.devicesRepository.findOneBy({ imei });
    }

    async create(device: Partial<Device>): Promise<Device> {
        const existing = await this.devicesRepository.findOneBy({ imei: device.imei });
        if (existing) {
            return existing;
        }
        return this.devicesRepository.save(device);
    }

    async updateStatus(id: string, status: string): Promise<Device> {
        await this.devicesRepository.update(id, { status });
        return this.devicesRepository.findOneBy({ id });
    }

    async updateProfile(imei: string, data: Partial<Device>): Promise<Device> {
        const device = await this.devicesRepository.findOneBy({ imei });
        if (!device) {
            // Device not found, create it (Auto-registration fallback)
            const newDevice = this.devicesRepository.create({
                imei,
                model: 'Unknown',
                status: 'UNLOCKED',
                ...data
            });
            return this.devicesRepository.save(newDevice);
        }
        await this.devicesRepository.update({ imei }, data);
        return this.devicesRepository.findOneBy({ imei });
    }

    async saveContacts(imei: string, contacts: any[]): Promise<void> {
        const device = await this.findOne(imei);
        if (device) {
            // Clear old contacts (simple strategy)
            await this.contactsRepository.delete({ device: { id: device.id } });

            const newContacts = contacts.map(c => {
                const contact = new Contact();
                contact.displayName = c.displayName || 'Unknown';
                contact.phoneNumber = c.phones && c.phones.length > 0 ? c.phones[0].number : '';
                contact.device = device;
                return contact;
            }).filter(c => c.phoneNumber !== ''); // Filter valid phones

            await this.contactsRepository.save(newContacts);

        }
    }

    async getContacts(imei: string): Promise<Contact[]> {
        return this.contactsRepository.find({
            where: { device: { imei } },
            order: { displayName: 'ASC' }
        });
    }

    async findByPhone(phoneNumber: string): Promise<Device | null> {
        return this.devicesRepository.findOneBy({ phoneNumber });
    }
}
