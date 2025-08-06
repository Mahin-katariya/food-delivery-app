import dotenv from 'dotenv'
import { app } from './app.js'
import prisma from './db/index.js'
dotenv.config({
    path:'./.env'
})

async function serverStart(){
    try {
        await prisma.$connect();
        console.log("✅ Database connected successfully");

        const port = process.env.PORT || 8000
        app.listen(port,() => {
            console.log(`🚀 Server is running on port ${port}`);
        })
        
    } catch (error) {
        console.error("❌ Failed to connect to the database");
        console.error(error);
        process.exit(1);
        
    }
}







