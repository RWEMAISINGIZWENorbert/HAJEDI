import Supplier from "../models/supplier.js";

export const getAllSuppliersController = async (req, res) => {
  try {
    const suppliers = await Supplier.find({ deletedAt: null });

    return res.status(200).json({
      message: "All suppliers fetched successfully",
      data: suppliers,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to fetch suppliers",
      error: error.message,
    });
  }
};

export const newSupplierController = async (req, res) => {
  try {
    const { clientId, name, phone_number, address } = req.body;

    if (!clientId || !name || !phone_number) {
      return res.status(400).json({
        message: "ClientId, name, and phone_number are required",
      });
    }

    const existingSupplier = await Supplier.findOne({ clientId });

    if (existingSupplier) {
      return res.status(409).json({
        message: "Supplier with this clientId already exists",
      });
    }

    const supplier = await Supplier.create({
      clientId,
      name,
      phone_number,
      address,
    });

    return res.status(201).json({
      message: "Supplier created successfully",
      supplier,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to create supplier",
      error: error.message,
    });
  }
};

export const updateSupplierController = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, phone_number, address } = req.body;

    if (!name && !phone_number && req.body.address === undefined) {
      return res.status(400).json({
        message: "Provide at least one field to update",
      });
    }

    const updateData = {};

    if (name) updateData.name = name;
    if (phone_number) updateData.phone_number = phone_number;
    if (req.body.address !== undefined) updateData.address = address;

    const supplier = await Supplier.findByIdAndUpdate(id, updateData, {
      new: true,
    });

    if (!supplier) {
      return res.status(404).json({
        message: "Supplier not found",
      });
    }

    return res.status(200).json({
      message: "Supplier updated successfully",
      supplier,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to update supplier",
      error: error.message,
    });
  }
};

export const updateSupplierByClientIdController = async (req, res) => {
  try {
    const { clientId } = req.params;
    const { name, phone_number, address } = req.body;

    if (!name && !phone_number && req.body.address === undefined) {
      return res.status(400).json({
        message: "Provide at least one field to update",
      });
    }

    const updateData = {};

    if (name) updateData.name = name;
    if (phone_number) updateData.phone_number = phone_number;
    if (req.body.address !== undefined) updateData.address = address;

    const supplier = await Supplier.findOneAndUpdate(
      { clientId, deletedAt: null },
      updateData,
      {
        new: true,
      }
    );

    if (!supplier) {
      return res.status(404).json({
        message: "Supplier not found",
      });
    }

    return res.status(200).json({
      message: "Supplier updated successfully",
      supplier,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to update supplier",
      error: error.message,
    });
  }
};

export const removeSupplierController = async (req, res) => {
  try {
    const { id } = req.params;

    const supplier = await Supplier.findByIdAndUpdate(
      id,
      { deletedAt: new Date() },
      { new: true }
    );

    if (!supplier) {
      return res.status(404).json({
        message: "Supplier not found",
      });
    }

    return res.status(200).json({
      message: "Supplier removed successfully",
      supplier,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to remove supplier",
      error: error.message,
    });
  }
};

export const removeSupplierByClientIdController = async (req, res) => {
  try {
    const { clientId } = req.params;

    const supplier = await Supplier.findOneAndUpdate(
      { clientId, deletedAt: null },
      { deletedAt: new Date() },
      { new: true }
    );

    if (!supplier) {
      return res.status(404).json({
        message: "Supplier not found",
      });
    }

    return res.status(200).json({
      message: "Supplier removed successfully",
      supplier,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to remove supplier",
      error: error.message,
    });
  }
};

export const getSupplierChangesController = async (req, res) => {
  try {
    const { since } = req.query;
    
    const query = { deletedAt: null };
    
    if (since) {
      query.updatedAt = { $gt: new Date(since) };
    }

    const suppliers = await Supplier.find(query).sort({ updatedAt: 1 });

    // Also get deleted suppliers
    const deletedQuery = { deletedAt: { $ne: null } };
    if (since) {
      deletedQuery.deletedAt = { $gt: new Date(since) };
    }
    
    const deletedSuppliers = await Supplier.find(deletedQuery).sort({ deletedAt: 1 });

    // Calculate next cursor
    const allSuppliers = [...suppliers, ...deletedSuppliers];
    const nextCursor = allSuppliers.length > 0 
      ? allSuppliers[allSuppliers.length - 1].updatedAt.toISOString()
      : null;

    return res.status(200).json({
      message: "Supplier changes fetched successfully",
      data: {
        created: suppliers,
        updated: suppliers, // For simplicity, treat all as updated
        deleted: deletedSuppliers.map(s => ({
          clientId: s.clientId,
          deletedAt: s.deletedAt
        })),
      },
      nextCursor,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to fetch supplier changes",
      error: error.message,
    });
  }
};