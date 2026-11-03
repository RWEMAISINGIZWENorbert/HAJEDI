import mongoose from "mongoose";

const purchaseItemSchema = new mongoose.Schema(
  {
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },

    productClientId: {
      type: String,
      required: true,
    },

    quantity: {
      type: Number,
      required: true,
      min: 0.5,
    },

    purchaseCost: {
      type: Number,
      required: true,
      min: 0,
    },

    totalCost: {
      type: Number,
      required: true,
      min: 0,
    },
  },
  { _id: false },
);

const purchaseSchema = new mongoose.Schema(
  {
    clientId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },

    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    supplierId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Supplier",
    },

    supplierClientId: {
      type: String,
    },

    items: {
      type: [purchaseItemSchema],
      required: true,
      validate: (items) => items.length > 0,
    },

    totalItems: {
      type: Number,
      required: true,
    },

    totalCost: {
      type: Number,
      required: true,
      min: 0,
    },

    paymentMethod: {
      type: String,
      enum: ["cash", "mobile", "credit"],
      default: "cash",
    },

    voidedAt: {
      type: Date,
      default: null,
      index: true,
    },

    voidedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    voidReason: {
      type: String,
    },

    deletedAt: {
      type: Date,
      default: null,
      index: true,
    },
  },
  {
    timestamps: true,
  },
);

const purchaseModel = mongoose.model("Purchase", purchaseSchema);
export default purchaseModel;