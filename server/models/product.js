import mongoose from "mongoose";

const productSchema = new mongoose.Schema(
  {
    clientId: {
      type: String,
      required: true,
      unique: true,
      index: true,
      trim: true,
    },

    name: {
      type: String,
      required: true,
      trim: true,
    },

    productType: {
      type: String,
      enum: ["item", "kg"],
      required: true,
    },

    purchaseMethod: {
      type: String,
      enum: ["packet", "crate", "unit", "kg", "sack"],
      required: true,
    },

    saleMethod: {
      type: String,
      enum: ["unit", "kg", "gram", "bottles"],
      required: true,
    },

    purchaseCost: {
      type: Number,
      required: true,
      min: 0,
    },

    sellingPrice: {
      type: Number,
      required: true,
      min: 0,
    },

    unitsPerPackage: {
      type: Number,
      required: true,
      min: 1,
    },

    quantityInStock: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },

    deletedAt: {
      type: Date,
      default: null,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

const Product = mongoose.model("Product", productSchema);

export default Product;