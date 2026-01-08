import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn } from 'typeorm';
import { Device } from '../devices/device.entity';

@Entity()
export class Loan {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column('decimal', { default: 0 })
    amount: number;

    @Column('decimal', { default: 0 })
    interest: number;

    @Column('decimal', { default: 0 })
    totalAmount: number;

    @Column()
    dueDate: Date;

    @Column({ default: 'PENDING' }) // PENDING, PAID, OVERDUE
    status: string;

    @CreateDateColumn()
    createdAt: Date;

    @Column({ nullable: true })
    title: string;

    @ManyToOne(() => Device, (device) => device.loans)
    device: Device;
}
