import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity()
export class Product {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    name: string;

    @Column()
    brand: string; // Samsung, Apple, Xiaomi

    @Column('decimal', { precision: 12, scale: 2 })
    price: number;

    // Store as JSON Array e.g. [3, 6, 12, 24]
    @Column('simple-json', { nullable: true })
    tenorOptions: number[];

    @Column({ nullable: true })
    imageUrl: string; // URL to photo

    @Column({ nullable: true })
    description: string;

    @Column({ default: true })
    isActive: boolean;

    @CreateDateColumn()
    createdAt: Date;
}
