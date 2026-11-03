import Expense from "../models/expense.js";

export const createExpense = async (req, res) => {
  try {
    const { clientId, description, amount, category, paymentMethod } = req.body;
    const userId = req.userId;

    if (!clientId || !description || !amount || !category) {
      return res.status(400).json({
        message: "clientId, description, amount, and category are required",
      });
    }

    // Check for duplicate expense
    const existingExpense = await Expense.findOne({ clientId });

    if (existingExpense) {
      return res.status(200).json({
        message: "Expense already exists",
        data: existingExpense,
      });
    }

    const expense = await Expense.create({
      clientId,
      userId,
      description,
      amount: Number(amount),
      category,
      paymentMethod: paymentMethod || "cash",
    });

    return res.status(201).json({
      message: "Expense created successfully",
      data: expense,
    });
  } catch (error) {
    console.error("Expense creation error:", error);
    return res.status(400).json({
      message: error.message || "Failed to create expense",
    });
  }
};

export const getExpenseChanges = async (req, res) => {
  try {
    const { since } = req.query;
    const query = { deletedAt: null };

    if (since) {
      query.updatedAt = { $gt: new Date(since) };
    }

    const expenses = await Expense.find(query)
      .populate("userId", "name clientId")
      .sort({ updatedAt: 1 });

    const created = [];
    const updated = [];
    const voided = [];

    for (const expense of expenses) {
      if (expense.voidedAt) {
        voided.push({
          clientId: expense.clientId,
          voidedAt: expense.voidedAt,
          voidReason: expense.voidReason,
        });
      } else if (since && expense.createdAt >= new Date(since)) {
        created.push(expense);
      } else {
        updated.push(expense);
      }
    }

    const lastExpense = expenses[expenses.length - 1];
    const nextCursor = lastExpense ? lastExpense.updatedAt.toISOString() : new Date().toISOString();

    return res.status(200).json({
      data: {
        created,
        updated,
        voided,
      },
      nextCursor,
    });
  } catch (error) {
    console.error("Get expense changes error:", error);
    return res.status(500).json({
      message: error.message || "Failed to fetch expense changes",
    });
  }
};

export const voidExpense = async (req, res) => {
  try {
    const { clientId } = req.params;
    const { voidReason } = req.body;
    const userId = req.userId;

    const expense = await Expense.findOne({ clientId, deletedAt: null });

    if (!expense) {
      return res.status(404).json({
        message: "Expense not found",
      });
    }

    if (expense.voidedAt) {
      return res.status(400).json({
        message: "Expense already voided",
      });
    }

    expense.voidedAt = new Date();
    expense.voidedBy = userId;
    expense.voidReason = voidReason;

    await expense.save();

    return res.status(200).json({
      message: "Expense voided successfully",
    });
  } catch (error) {
    console.error("Void expense error:", error);
    return res.status(400).json({
      message: error.message || "Failed to void expense",
    });
  }
};