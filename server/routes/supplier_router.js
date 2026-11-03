import express from "express";
import {
  getAllSuppliersController,
  newSupplierController,
  updateSupplierController,
  updateSupplierByClientIdController,
  removeSupplierController,
  removeSupplierByClientIdController,
  getSupplierChangesController,
} from "../controllers/supplier_controller.js";
import authMiddleware from "../middleware/auth_middleware.js";


const supplierRouter = express.Router();

supplierRouter.use(authMiddleware);

// Standard CRUD routes
supplierRouter.get("/", getAllSuppliersController);
supplierRouter.post("/", newSupplierController);
supplierRouter.put("/:id", updateSupplierController);
supplierRouter.delete("/:id", removeSupplierController);

// Client-based routes for offline-first architecture
supplierRouter.put("/client/:clientId", updateSupplierByClientIdController);
supplierRouter.delete("/client/:clientId", removeSupplierByClientIdController);

// Delta synchronization route
supplierRouter.get("/changes", getSupplierChangesController);

export default supplierRouter;