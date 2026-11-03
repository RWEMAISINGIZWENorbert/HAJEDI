import mongoose from "mongoose";
import Sale from "../models/sale.js";
import Product from "../models/product.js";
import Customer from "../models/customer.js";

export const createSale = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    const { clientId, customerClientId, paymentMethod, items } = req.body;
    const userId = req.userId;

    if (!clientId || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        message: "clientId and items array are required",
      });
    }

    let createdSale;

    await session.withTransaction(async () => {
      // Check for duplicate sale
      const existingSale = await Sale.findOne({ clientId }).session(session);

      if (existingSale) {
        createdSale = existingSale;
        return;
      }

      // Resolve customer if provided
      let customerId = null;
      if (customerClientId) {
        const customer = await Customer.findOne({
          clientId: customerClientId,
          deletedAt: null,
        }).session(session);

        if (!customer) {
          throw new Error(`Customer not found: ${customerClientId}`);
        }
        customerId = customer._id;
      }

      let totalAmount = 0;
      const saleItems = [];

      for (const item of items) {
        const product = await Product.findOne({
          clientId: item.productClientId,
          deletedAt: null,
        }).session(session);

        if (!product) {
          throw new Error(`Product not found: ${item.productClientId}`);
        }

        const quantity = Number(item.quantity);

        if (!Number.isFinite(quantity) || quantity <= 0) {
          throw new Error("Invalid sale quantity");
        }

        const unitPrice = product.sellingPrice;
        const totalItemAmount = unitPrice * quantity;

        // Atomically decrease stock
        const updatedProduct = await Product.findOneAndUpdate(
          {
            clientId: item.productClientId,
            deletedAt: null,
            quantityInStock: { $gte: quantity },
          },
          {
            $inc: { quantityInStock: -quantity },
          },
          {
            new: true,
            session,
          },
        );

        if (!updatedProduct) {
          throw new Error(`Insufficient stock for ${product.name}`);
        }

        totalAmount += totalItemAmount;

        saleItems.push({
          productId: product._id,
          productClientId: product.clientId,
          quantity,
          price: unitPrice,
          totalAmount: totalItemAmount,
        });
      }

      [createdSale] = await Sale.create(
        [
          {
            clientId,
            userId,
            customerId,
            customerClientId,
            items: saleItems,
            totalItems: saleItems.length,
            totalAmount,
            paymentMethod,
            originalPaymentMethod: paymentMethod,
          },
        ],
        { session },
      );
    });

    return res.status(201).json({
      message: "Sale created successfully",
      data: createdSale,
    });
  } catch (error) {
    console.error("Sale creation error:", error);
    return res.status(400).json({
      message: error.message || "Failed to create sale",
    });
  } finally {
    await session.endSession();
  }
};

export const getSaleChanges = async (req, res) => {
  try {
    const { since } = req.query;
    const query = { deletedAt: null };

    if (since) {
      query.updatedAt = { $gt: new Date(since) };
    }

    const sales = await Sale.find(query)
      .populate("userId", "name clientId")
      .populate("customerId", "name clientId")
      .sort({ updatedAt: 1 });

    const created = [];
    const updated = [];
    const voided = [];

    for (const sale of sales) {
      if (sale.voidedAt) {
        voided.push({
          clientId: sale.clientId,
          voidedAt: sale.voidedAt,
          voidReason: sale.voidReason,
        });
      } else if (since && sale.createdAt >= new Date(since)) {
        created.push(sale);
      } else {
        updated.push(sale);
      }
    }

    const lastSale = sales[sales.length - 1];
    const nextCursor = lastSale ? lastSale.updatedAt.toISOString() : new Date().toISOString();

    return res.status(200).json({
      data: {
        created,
        updated,
        voided,
      },
      nextCursor,
    });
  } catch (error) {
    console.error("Get sale changes error:", error);
    return res.status(500).json({
      message: error.message || "Failed to fetch sale changes",
    });
  }
};

export const voidSale = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    const { clientId } = req.params;
    const { voidReason } = req.body;
    const userId = req.userId;

    await session.withTransaction(async () => {
      const sale = await Sale.findOne({ clientId, deletedAt: null }).session(session);

      if (!sale) {
        throw new Error("Sale not found");
      }

      if (sale.voidedAt) {
        throw new Error("Sale already voided");
      }

      // Restore stock for each item
      for (const item of sale.items) {
        await Product.findOneAndUpdate(
          {
            clientId: item.productClientId,
            deletedAt: null,
          },
          {
            $inc: { quantityInStock: item.quantity },
          },
          { session },
        );
      }

      // Mark sale as voided
      await Sale.findOneAndUpdate(
        { clientId },
        {
          voidedAt: new Date(),
          voidedBy: userId,
          voidReason,
        },
        { session },
      );
    });

    return res.status(200).json({
      message: "Sale voided successfully",
    });
  } catch (error) {
    console.error("Void sale error:", error);
    return res.status(400).json({
      message: error.message || "Failed to void sale",
    });
  } finally {
    await session.endSession();
  }
};

export const payCredit = async (req, res) => {
  try {
    const { clientId } = req.params;
    const { newPaymentMethod } = req.body;

    if (!newPaymentMethod || !["cash", "mobile"].includes(newPaymentMethod)) {
      return res.status(400).json({
        message: "Valid newPaymentMethod (cash or mobile) is required",
      });
    }

    const sale = await Sale.findOneAndUpdate(
      { 
        clientId, 
        deletedAt: null,
        voidedAt: null 
      },
      {
        paymentMethod: newPaymentMethod,
      },
      { new: true }
    );

    if (!sale) {
      return res.status(404).json({
        message: "Sale not found",
      });
    }

    return res.status(200).json({
      message: "Payment method updated successfully",
      data: sale,
    });
  } catch (error) {
    console.error("Pay credit error:", error);
    return res.status(400).json({
      message: error.message || "Failed to update payment method",
    });
  }
};