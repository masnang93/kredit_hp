import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class PaymentConfig {
    @PrimaryGeneratedColumn('increment')
    id: number;

    @Column({ default: 'duitku' })
    provider: string;

    @Column({ nullable: true })
    merchantCode: string;

    @Column({ nullable: true })
    apiKey: string; // Ideally encrypted

    @Column({ default: false })
    isProduction: boolean;
}
