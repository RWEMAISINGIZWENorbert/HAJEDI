import express from "express";
import authMiddleware from "../middleware/auth_middleware.js";

import {
  createSale,
  getSaleChanges,
  voidSale,
  payCredit,
} from "../controllers/sale_controller.js";

import {
  createPurchase,
  getPurchaseChanges,
  voidPurchase,
} from "../controllers/purchase_controller.js";

import {
  createExpense,
  getExpenseChanges,
  voidExpense,
} from "../controllers/expense_controller.js";

const transactionRouter = express.Router();

transactionRouter.use(authMiddleware);

// Sale routes
transactionRouter.post("/sales", createSale);
transactionRouter.get("/sales/changes", getSaleChanges);
transactionRouter.post("/sales/:clientId/void", voidSale);
transactionRouter.post("/sales/:clientId/pay-credit", payCredit);

// Purchase routes
transactionRouter.post("/purchases", createPurchase);
transactionRouter.get("/purchases/changes", getPurchaseChanges);
transactionRouter.post("/purchases/:clientId/void", voidPurchase);

// Expense routes
transactionRouter.post("/expenses", createExpense);
transactionRouter.get("/expenses/changes", getExpenseChanges);
transactionRouter.post("/expenses/:clientId/void", voidExpense);

export default transactionRouter;