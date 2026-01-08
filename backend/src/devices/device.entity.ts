import { Entity, Column, PrimaryGeneratedColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { Contact } from './contact.entity';
import { Loan } from '../loans/loan.entity';

@Entity()
export class Device {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true })
    imei: string;

    @Column({ nullable: true })
    brand: string;

    @Column({ default: 'remi_note_12', nullable: true })
    model: string;

    @Column({ nullable: true })
    ownerName: string;

    @Column({ nullable: true })
    nik: string;

    @Column({ nullable: true })
    phoneNumber: string;

    @Column({ nullable: true })
    email: string;

    @Column({ nullable: true })
    address: string;

    @Column({ nullable: true })
    emergencyContact: string; // Phone number or name | phone

    @Column('decimal', { default: 10000000, precision: 15, scale: 2 })
    creditLimit: number;

    @Column('decimal', { nullable: true })
    latitude: number;

    @Column('decimal', { nullable: true })
    longitude: number;

    @Column({ default: 'UNLOCKED' }) // LOCKED, UNLOCKED
    status: string;

    @UpdateDateColumn()
    lastHeartbeat: Date;

    @OneToMany(() => Contact, (contact) => contact.device)
    contacts: Contact[];

    @OneToMany(() => Loan, (loan) => loan.device)
    loans: Loan[];
}
