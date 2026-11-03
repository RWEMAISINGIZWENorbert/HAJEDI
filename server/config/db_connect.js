import mongoose from "mongoose";
import dotenv from "dotenv";

dotenv.config();

const dbConnect = async () => {
  try {
    const dbUrl = process.env.DATABASE_URL;

    if (!dbUrl) {
      throw new Error("DATABASE_URL is not defined in .env");
    }

    await mongoose.connect(dbUrl);
    console.log("MongoDB connected successfully");
  } catch (error) {
    console.error("MongoDB connection failed:", error.message);
    process.exit(1);
  }
};

export default dbConnect;