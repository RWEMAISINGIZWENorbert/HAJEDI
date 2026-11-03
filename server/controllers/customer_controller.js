import Customer from "../models/customer.js";

export const getAllCustomersController = async (req, res) => {
  try {
    const customers = await Customer.find({ deletedAt: null });

    return res.status(200).json({
      message: "All customers fetched successfully",
      data: customers,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to fetch customers",
      error: error.message,
    });
  }
};

export const newCustomerController = async (req, res) => {
  try {
    const { clientId, name, phone_number, address, creditLimit } = req.body;

    if (!clientId || !name || !phone_number) {
      return res.status(400).json({
        message: "ClientId, name, and phone_number are required",
      });
    }

    const existingCustomer = await Customer.findOne({ clientId });

    if (existingCustomer) {
      return res.status(409).json({
        message: "Customer with this clientId already exists",
      });
    }

    const customer = await Customer.create({
      clientId,
      name,
      phone_number,
      address,
      creditLimit,
    });

    return res.status(201).json({
      message: "Customer created successfully",
      customer,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to create customer",
      error: error.message,
    });
  }
};

export const updateCustomerController = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, phone_number, address, creditLimit } = req.body;

    if (!name && !phone_number && !address && req.body.creditLimit === undefined) {
      return res.status(400).json({
        message: "Provide at least one field to update",
      });
    }

    const updateData = {};

    if (name) updateData.name = name;
    if (phone_number) updateData.phone_number = phone_number;
    if (address !== undefined) updateData.address = address;
    if (req.body.creditLimit !== undefined) updateData.creditLimit = creditLimit;

    const customer = await Customer.findByIdAndUpdate(id, updateData, {
      new: true,
    });

    if (!customer) {
      return res.status(404).json({
        message: "Customer not found",
      });
    }

    return res.status(200).json({
      message: "Customer updated successfully",
      customer,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to update customer",
      error: error.message,
    });
  }
};

export const updateCustomerByClientIdController = async (req, res) => {
  try {
    const { clientId } = req.params;
    const { name, phone_number, address, creditLimit } = req.body;

    if (!name && !phone_number && !address && req.body.creditLimit === undefined) {
      return res.status(400).json({
        message: "Provide at least one field to update",
      });
    }

    const updateData = {};

    if (name) updateData.name = name;
    if (phone_number) updateData.phone_number = phone_number;
    if (address !== undefined) updateData.address = address;
    if (req.body.creditLimit !== undefined) updateData.creditLimit = creditLimit;

    const customer = await Customer.findOneAndUpdate(
      { clientId, deletedAt: null },
      updateData,
      {
        new: true,
      }
    );

    if (!customer) {
      return res.status(404).json({
        message: "Customer not found",
      });
    }

    return res.status(200).json({
      message: "Customer updated successfully",
      customer,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to update customer",
      error: error.message,
    });
  }
};

export const removeCustomerController = async (req, res) => {
  try {
    const { id } = req.params;

    const customer = await Customer.findByIdAndUpdate(
      id,
      { deletedAt: new Date() },
      { new: true }
    );

    if (!customer) {
      return res.status(404).json({
        message: "Customer not found",
      });
    }

    return res.status(200).json({
      message: "Customer removed successfully",
      customer,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to remove customer",
      error: error.message,
    });
  }
};

export const removeCustomerByClientIdController = async (req, res) => {
  try {
    const { clientId } = req.params;

    const customer = await Customer.findOneAndUpdate(
      { clientId, deletedAt: null },
      { deletedAt: new Date() },
      { new: true }
    );

    if (!customer) {
      return res.status(404).json({
        message: "Customer not found",
      });
    }

    return res.status(200).json({
      message: "Customer removed successfully",
      customer,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to remove customer",
      error: error.message,
    });
  }
};

export const getCustomerChangesController = async (req, res) => {
  try {
    const { since } = req.query;
    
    const query = { deletedAt: null };
    
    if (since) {
      query.updatedAt = { $gt: new Date(since) };
    }

    const customers = await Customer.find(query).sort({ updatedAt: 1 });

    // Also get deleted customers
    const deletedQuery = { deletedAt: { $ne: null } };
    if (since) {
      deletedQuery.deletedAt = { $gt: new Date(since) };
    }
    
    const deletedCustomers = await Customer.find(deletedQuery).sort({ deletedAt: 1 });

    // Calculate next cursor
    const allCustomers = [...customers, ...deletedCustomers];
    const nextCursor = allCustomers.length > 0 
      ? allCustomers[allCustomers.length - 1].updatedAt.toISOString()
      : null;

    return res.status(200).json({
      message: "Customer changes fetched successfully",
      data: {
        created: customers,
        updated: customers, // For simplicity, treat all as updated
        deleted: deletedCustomers.map(c => ({
          clientId: c.clientId,
          deletedAt: c.deletedAt
        })),
      },
      nextCursor,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to fetch customer changes",
      error: error.message,
    });
  }
};