import Product from "../models/product.js";

const productFields = [
  "name",
  "productType",
  "purchaseMethod",
  "saleMethod",
  "purchaseCost",
  "sellingPrice",
  "unitsPerPackage",
  "quantityInStock",
];

const createProductUpdateData = (body) => {
  const updateData = {};

  for (const field of productFields) {
    if (body[field] !== undefined) {
      updateData[field] = body[field];
    }
  }

  return updateData;
};

const validateProductData = (data, requireAllFields = true) => {
  const requiredFields = [
    "name",
    "productType",
    "purchaseMethod",
    "saleMethod",
    "purchaseCost",
    "sellingPrice",
    "unitsPerPackage",
    "quantityInStock",
  ];

  if (requireAllFields) {
    const missingFields = requiredFields.filter(
      (field) =>
        data[field] === undefined ||
        data[field] === null ||
        data[field] === ""
    );

    if (missingFields.length > 0) {
      return `Missing required fields: ${missingFields.join(", ")}`;
    }
  }

  if (data.name !== undefined && String(data.name).trim() === "") {
    return "Product name cannot be empty";
  }

  const numericFields = [
    "purchaseCost",
    "sellingPrice",
    "unitsPerPackage",
    "quantityInStock",
  ];

  for (const field of numericFields) {
    if (data[field] !== undefined) {
      const value = Number(data[field]);

      if (!Number.isFinite(value) || value < 0) {
        return `${field} must be a valid positive number`;
      }

      if (
        ["unitsPerPackage", "quantityInStock"].includes(field) &&
        value % 1 !== 0
      ) {
        return `${field} must be a whole number`;
      }
    }
  }

  return null;
};

const serializeProduct = (product) => ({
  id: product._id.toString(),
  clientId: product.clientId,
  name: product.name,
  productType: product.productType,
  purchaseMethod: product.purchaseMethod,
  saleMethod: product.saleMethod,
  purchaseCost: product.purchaseCost,
  sellingPrice: product.sellingPrice,
  unitsPerPackage: product.unitsPerPackage,
  quantityInStock: product.quantityInStock,
  createdAt: product.createdAt,
  updatedAt: product.updatedAt,
  deletedAt: product.deletedAt,
});

export const getAllProductsController = async (req, res) => {
  try {
    const products = await Product.find({
      deletedAt: null,
    }).sort({ createdAt: -1 });

    return res.status(200).json({
      message: "All products fetched successfully",
      data: products.map(serializeProduct),
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to fetch products",
      error: error.message,
    });
  }
};

export const getProductByIdController = async (req, res) => {
  try {
    const { clientId } = req.params;

    const product = await Product.findOne({
      clientId,
      deletedAt: null,
    });

    if (!product) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    return res.status(200).json({
      message: "Product fetched successfully",
      data: serializeProduct(product),
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to fetch product",
      error: error.message,
    });
  }
};

export const newProductController = async (req, res) => {
  try {
    const { clientId } = req.body;

    if (!clientId) {
      return res.status(400).json({
        message: "clientId is required",
      });
    }

    const validationError = validateProductData(req.body, true);

    if (validationError) {
      return res.status(400).json({
        message: validationError,
      });
    }

    const existingProduct = await Product.findOne({ clientId });

    if (existingProduct) {
      if (existingProduct.deletedAt) {
        return res.status(409).json({
          message: "A deleted product already uses this clientId",
        });
      }

      return res.status(409).json({
        message: "Product already exists",
      });
    }

    const product = await Product.create({
      clientId,
      name: req.body.name,
      productType: req.body.productType,
      purchaseMethod: req.body.purchaseMethod,
      saleMethod: req.body.saleMethod,
      purchaseCost: req.body.purchaseCost,
      sellingPrice: req.body.sellingPrice,
      unitsPerPackage: req.body.unitsPerPackage,
      quantityInStock: req.body.quantityInStock,
    });

    return res.status(201).json({
      message: "Product created successfully",
      data: serializeProduct(product),
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({
        message: "A product with this clientId already exists",
      });
    }

    return res.status(500).json({
      message: "Failed to create product",
      error: error.message,
    });
  }
};

export const updateProductController = async (req, res) => {
  try {
    const { clientId } = req.params;
    const updateData = createProductUpdateData(req.body);

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({
        message: "At least one field is required to update",
      });
    }

    const validationError = validateProductData(updateData, false);

    if (validationError) {
      return res.status(400).json({
        message: validationError,
      });
    }

    const product = await Product.findOneAndUpdate(
      {
        clientId,
        deletedAt: null,
      },
      updateData,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!product) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    return res.status(200).json({
      message: "Product updated successfully",
      data: serializeProduct(product),
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to update product",
      error: error.message,
    });
  }
};

export const removeProductController = async (req, res) => {
  try {
    const { clientId } = req.params;

    const product = await Product.findOneAndUpdate(
      {
        clientId,
        deletedAt: null,
      },
      {
        deletedAt: new Date(),
      },
      {
        new: true,
      }
    );

    if (!product) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    return res.status(200).json({
      message: "Product removed successfully",
      data: {
        clientId: product.clientId,
        deletedAt: product.deletedAt,
      },
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to remove product",
      error: error.message,
    });
  }
};

export const getProductChangesController = async (req, res) => {
  try {
    const { since } = req.query;

    const filter = {};

    if (since) {
      const sinceDate = new Date(since);

      if (Number.isNaN(sinceDate.getTime())) {
        return res.status(400).json({
          message: "Invalid synchronization cursor",
        });
      }

      filter.updatedAt = {
        $gt: sinceDate,
      };
    }

    const products = await Product.find(filter)
      .sort({ updatedAt: 1 })
      .lean();

    const created = [];
    const updated = [];
    const deleted = [];

    for (const product of products) {
      const serializedProduct = serializeProduct(product);

      if (product.deletedAt) {
        deleted.push({
          clientId: product.clientId,
          deletedAt: product.deletedAt,
        });
      } else if (
        product.createdAt.getTime() === product.updatedAt.getTime()
      ) {
        created.push(serializedProduct);
      } else {
        updated.push(serializedProduct);
      }
    }

    const latestProduct = products[products.length - 1];

    const nextCursor = latestProduct
      ? latestProduct.updatedAt.toISOString()
      : since || new Date(0).toISOString();

    return res.status(200).json({
      message: "Product changes fetched successfully",
      data: {
        created,
        updated,
        deleted,
      },
      nextCursor,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to fetch product changes",
      error: error.message,
    });
  }
};