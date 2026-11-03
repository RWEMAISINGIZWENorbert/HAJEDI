import mongoose from "mongoose";

const customerSchema = new mongoose.Schema(
  {
    clientId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    name: {
      type: String,
      required: true,
    },
    phone_number: {
      type: String,
      required: true,
      trim: true,
    },
    address: {
      type: String,
      default: null,
    },
    creditLimit: {
      type: Number,
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

const Customer = mongoose.model("Customer", customerSchema);

export default Customer;