import express from "express";

import {
  getAllProductsController,
  getProductByIdController,
  getProductChangesController,
  newProductController,
  updateProductController,
  removeProductController,
} from "../controllers/product_controller.js";

import authMiddleware from "../middleware/auth_middleware.js";

const productRouter = express.Router();

productRouter.use(authMiddleware);

productRouter.get("/", getAllProductsController);
productRouter.get("/changes", getProductChangesController);
productRouter.get("/client/:clientId", getProductByIdController);

productRouter.post("/", newProductController);
productRouter.put("/client/:clientId", updateProductController);
productRouter.delete("/client/:clientId", removeProductController);

export default productRouter;