import User  from "../models/user.js";
import {
  generateAccessToken,
  generateRefreshToken,
} from "../utils/generateToken.js";


export const getAllUsers = async (req, res) => {
     
    try{

      //  const users = await User.find({}, { password: 0 }); // Exclude password field
       const users = await User.find({}, { password: 0 });

       return res.status(200).json({
          message: "Users fetched successfully",
          data: users,
       });

    }catch(error){
       return res.status(500).json({
         message: "Failed to fetch users",
         error: error.message,
       });
    }

}

export const register = async (req, res) => {
  try {
    const { clientId, name, role, password } = req.body;

   if (!clientId || !name || !password) {
    return res.status(400).json({
      message: "clientId, name and password are required",
    });
   }

    const existingUser = await User.findOne({
      $or: [
        { clientId },
        { name },
      ],
    });

    if (existingUser) {
      return res.status(409).json({
        message: "User already exists",
      });
    }

    // const hashedPassword = await bcrypt.hash(password, 10);
    const hashedPassword = password; // Store password as plain text for now (not recommended for production)

    const newUser = await User.create({
      clientId,
      name,
      role: role || "employee",
      password: hashedPassword,
    });

    return res.status(201).json({
      message: "User registered successfully",
      user: {
        id: newUser._id,
        clientId: newUser.clientId,
        name: newUser.name,
        role: newUser.role,
        createdAt: newUser.createdAt,
        updatedAt: newUser.updatedAt,
      },
    });
  } catch (error) {
    return res.status(500).json({
      message: "Registration failed",
      error: error.message,
    });
  }
};

export const login = async (req, res) => {
  try {
    const { name, password } = req.body;

    if (!name || !password) {
      return res.status(400).json({
        message: "Name and password are required",
      });
    }

    const user = await User.findOne({ name, deletedAt: null });

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    // const isMatch = await bcrypt.compare(password, user.password);
    const isMatch = password === user.password;

    if (!isMatch) {
      return res.status(401).json({
        message: "Invalid credentials",
      });
    }

    const accessToken = await generateAccessToken(user._id);
    const refreshToken = await generateRefreshToken(user._id);

    return res.status(200).json({
      message: "Login successful",
      user: {
        id: user._id,
        name: user.name,
        role: user.role,
      },
      tokens: {
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    return res.status(500).json({
      message: "Login failed",
      error: error.message,
    });
  }
};

export const removeUser = async (req, res) => {
  try {
    const { id } = req.params;
    let clientId = id;
    const deletedUser = await User.findOneAndUpdate(
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

    if (!deletedUser) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    return res.status(200).json({
      message: "User removed successfully",
      clientId: deletedUser.clientId,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to remove user",
      error: error.message,
    });
  }
};

export const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, role, password } = req.body;

    const updateData = {};

    if (name) updateData.name = name;
    if (role) updateData.role = role;

    if (password) {
      // updateData.password = await bcrypt.hash(password, 10);
      updateData.password = password; // Store password as plain text for now (not recommended for production)
    }

    const updatedUser = await User.findOneAndUpdate(
      {
        clientId: id,
        deletedAt: null
      },
      updateData,
      { new: true, runValidators: true }
    );

    if (!updatedUser) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    return res.status(200).json({
      message: "User updated successfully",
      user: {
        id: updatedUser._id,
        clientId: updatedUser.clientId,
        name: updatedUser.name,
        role: updatedUser.role,
        password: updatedUser.password, // Include password in the response (not recommended for production)
        updatedAt: updatedUser.updatedAt,
        createdAt: updatedUser.createdAt,
      },
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to update user",
      error: error.message,
    });
  }
};


export const getUserChanges = async (req, res) => {
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

    const users = await User.find(filter)
      .sort({ updatedAt: 1 })
      .lean();

    const created = [];
    const updated = [];
    const deleted = [];

    for (const user of users) {
      const userData = {
        id: user._id.toString(),
        clientId: user.clientId,
        name: user.name,
        role: user.role,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      };

   if (user.deletedAt) {
     deleted.push({
       clientId: user.clientId,
       deletedAt: user.deletedAt,
    });
  } else if (
    user.createdAt.getTime() === user.updatedAt.getTime()
  ) {
    created.push(userData);
  } else {
    updated.push(userData);
  }
 }

    const latestUser = users[users.length - 1];

    const nextCursor = latestUser
      ? latestUser.updatedAt.toISOString()
      : since || new Date(0).toISOString();

    return res.status(200).json({
      data: {
        created,
        updated,
        deleted,
      },
      nextCursor,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Failed to fetch user changes",
      error: error.message,
    });
  }
};