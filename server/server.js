import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import dbConnect from "./config/db_connect.js";
import authRouter from "./routes/auth_router.js";
import customerRouter from "./routes/customer_router.js";
import supplierRouter from "./routes/supplier_router.js";
import productRouter from "./routes/product_router.js";
import transactionRouter from "./routes/transaction_router.js";

dotenv.config();

const app = express();
app.use(express.json());
app.use(cors());

app.get("/", (req, res) => {
  res.send("API is running...");
});
app.use("/auth", authRouter);
app.use("/customer", customerRouter);
app.use("/supplier", supplierRouter);
app.use("/product", productRouter);
app.use("/transaction", transactionRouter);

const PORT = process.env.PORT || 5000;

dbConnect().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
});

export default app;