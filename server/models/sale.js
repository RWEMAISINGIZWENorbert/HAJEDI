import mongoose from "mongoose";

const itemSchema = new mongoose.Schema(
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
      min: 1,
    },

    price: {
      type: Number,
      required: true,
      min: 0,
    },

    totalAmount: {
      type: Number,
      required: true,
      min: 0,
    },
  },
  { _id: false },
);

const saleSchema = new mongoose.Schema(
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

    items: {
      type: [itemSchema],
      required: true,
      validate: (items) => items.length > 0,
    },

    totalItems: {
      type: Number,
      required: true,
    },

    totalAmount: {
      type: Number,
      required: true,
      min: 0,
    },

    customerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Customer",
    },

    customerClientId: {
      type: String,
    },

    paymentMethod: {
      type: String,
      enum: ["cash", "mobile", "credit"],
      default: "cash",
    },

    originalPaymentMethod: {
      type: String,
      enum: ["cash", "mobile", "credit"],
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

const Sale = mongoose.model("Sale", saleSchema);
export default Sale;