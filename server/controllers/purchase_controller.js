import mongoose from "mongoose";
import Purchase from "../models/purchase.js";
import Product from "../models/product.js";
import Supplier from "../models/supplier.js";

export const createPurchase = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    const { clientId, supplierClientId, paymentMethod, items } = req.body;
    const userId = req.userId;

    if (!clientId || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        message: "clientId and items array are required",
      });
    }

    let createdPurchase;

    await session.withTransaction(async () => {
      // Check for duplicate purchase
      const existingPurchase = await Purchase.findOne({ clientId }).session(session);

      if (existingPurchase) {
        createdPurchase = existingPurchase;
        return;
      }

      // Resolve supplier if provided
      let supplierId = null;
      if (supplierClientId) {
        const supplier = await Supplier.findOne({
          clientId: supplierClientId,
          deletedAt: null,
        }).session(session);

        if (!supplier) {
          throw new Error(`Supplier not found: ${supplierClientId}`);
        }
        supplierId = supplier._id;
      }

      let totalCost = 0;
      const purchaseItems = [];

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
          throw new Error("Invalid purchase quantity");
        }

        const purchaseCost = Number(item.purchaseCost) || product.purchaseCost;
        const totalItemCost = purchaseCost * quantity;

         // Calculate actual stock increment based on purchase method
        let stockIncrement = quantity;
        if (product.purchaseMethod === "packet" || product.purchaseMethod === "crate" || product.purchaseMethod === "sack") {
          stockIncrement = quantity * product.unitsPerPackage;
        }

        // Atomically increase stock
        await Product.findOneAndUpdate(
          {
            clientId: item.productClientId,
            deletedAt: null,
          },
          {
            $inc: { quantityInStock: stockIncrement  },
          },
          { session },
        );

        totalCost += totalItemCost;

        purchaseItems.push({
          productId: product._id,
          productClientId: product.clientId,
          quantity,
          purchaseCost,
          totalCost: totalItemCost,
        });
      }

      [createdPurchase] = await Purchase.create(
        [
          {
            clientId,
            userId,
            supplierId,
            supplierClientId,
            items: purchaseItems,
            totalItems: purchaseItems.length,
            totalCost,
            paymentMethod,
          },
        ],
        { session },
      );
    });

    return res.status(201).json({
      message: "Purchase created successfully",
      data: createdPurchase,
    });
  } catch (error) {
    console.error("Purchase creation error:", error);
    return res.status(400).json({
      message: error.message || "Failed to create purchase",
    });
  } finally {
    await session.endSession();
  }
};

export const getPurchaseChanges = async (req, res) => {
  try {
    const { since } = req.query;
    const query = { deletedAt: null };

    if (since) {
      query.updatedAt = { $gt: new Date(since) };
    }

    const purchases = await Purchase.find(query)
      .populate("userId", "name clientId")
      .populate("supplierId", "name clientId")
      .sort({ updatedAt: 1 });

    const created = [];
    const updated = [];
    const voided = [];

    for (const purchase of purchases) {
      if (purchase.voidedAt) {
        voided.push({
          clientId: purchase.clientId,
          voidedAt: purchase.voidedAt,
          voidReason: purchase.voidReason,
        });
      } else if (since && purchase.createdAt >= new Date(since)) {
        created.push(purchase);
      } else {
        updated.push(purchase);
      }
    }

    const lastPurchase = purchases[purchases.length - 1];
    const nextCursor = lastPurchase ? lastPurchase.updatedAt.toISOString() : new Date().toISOString();

    return res.status(200).json({
      data: {
        created,
        updated,
        voided,
      },
      nextCursor,
    });
  } catch (error) {
    console.error("Get purchase changes error:", error);
    return res.status(500).json({
      message: error.message || "Failed to fetch purchase changes",
    });
  }
};

export const voidPurchase = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    const { clientId } = req.params;
    const { voidReason } = req.body;
    const userId = req.userId;

    await session.withTransaction(async () => {
      const purchase = await Purchase.findOne({ clientId, deletedAt: null }).session(session);

      if (!purchase) {
        throw new Error("Purchase not found");
      }

      if (purchase.voidedAt) {
        throw new Error("Purchase already voided");
      }

      // Decrease stock for each item
      for (const item of purchase.items) {
        await Product.findOneAndUpdate(
          {
            clientId: item.productClientId,
            deletedAt: null,
            quantityInStock: { $gte: item.quantity },
          },
          {
            $inc: { quantityInStock: -item.quantity },
          },
          { session },
        );
      }

      // Mark purchase as voided
      await Purchase.findOneAndUpdate(
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
      message: "Purchase voided successfully",
    });
  } catch (error) {
    console.error("Void purchase error:", error);
    return res.status(400).json({
      message: error.message || "Failed to void purchase",
    });
  } finally {
    await session.endSession();
  }
};