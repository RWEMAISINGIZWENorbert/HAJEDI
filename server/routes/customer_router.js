
import express from "express";
import {
  getAllCustomersController,
  newCustomerController,
  updateCustomerController,
  updateCustomerByClientIdController,
  removeCustomerController,
  removeCustomerByClientIdController,
  getCustomerChangesController,
} from "../controllers/customer_controller.js";
import authMiddleware from "../middleware/auth_middleware.js";

const customerRouter = express.Router();
customerRouter.use(authMiddleware);

// Standard CRUD routes
customerRouter.get("/", getAllCustomersController);
customerRouter.post("/", newCustomerController);
customerRouter.put("/:id", updateCustomerController);
customerRouter.delete("/:id", removeCustomerController);

// Client-based routes for offline-first architecture
customerRouter.put("/client/:clientId", updateCustomerByClientIdController);
customerRouter.delete("/client/:clientId", removeCustomerByClientIdController);

// Delta synchronization route
customerRouter.get("/changes", getCustomerChangesController);

export default customerRouter;