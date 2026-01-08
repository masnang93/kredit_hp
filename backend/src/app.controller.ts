import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
    @Get()
    getHello(): string {
        return '<h1>Fintech Backend Server is Running! 🚀</h1><p>Access <a href="/devices">/devices</a> to see connected devices.</p>';
    }
}
