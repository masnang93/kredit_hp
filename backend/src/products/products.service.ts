import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from './product.entity';

@Injectable()
export class ProductsService {
    constructor(
        @InjectRepository(Product)
        private productsRepo: Repository<Product>,
    ) { }

    findAll(): Promise<Product[]> {
        return this.productsRepo.find({ where: { isActive: true }, order: { name: 'ASC' } });
    }

    findOne(id: string): Promise<Product | null> {
        return this.productsRepo.findOneBy({ id });
    }

    create(product: Partial<Product>): Promise<Product> {
        return this.productsRepo.save(product);
    }
}
