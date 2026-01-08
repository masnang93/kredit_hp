import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { Device } from './device.entity';

@Entity()
export class Contact {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    displayName: string;

    @Column()
    phoneNumber: string;

    @ManyToOne(() => Device, (device) => device.contacts)
    device: Device;
}
