import jwt from "jsonwebtoken";
import User from "../models/user.js";

const authMiddleware = async (req, res, next) => {
  try {
    const authorization = req.headers.authorization;

    let token = req.cookies?.accessToken;

    if (!token && authorization?.startsWith("Bearer ")) {
      token = authorization.substring("Bearer ".length);
    }

    if (!token) {
      return res.status(401).json({
        message: "Access token is required",
        error: true,
      });
    }

    if (!process.env.ACCESS_TOKEN_SECRET_KEY) {
      return res.status(500).json({
        message: "Access token secret key was not configured",
        error: true,
      });
    }

    const decoded = jwt.verify(
      token,
      process.env.ACCESS_TOKEN_SECRET_KEY
    );

    const user = await User.findById(decoded.id);

    if (!user || user.deletedAt) {
      return res.status(401).json({
        message: "User is not authorized",
        error: true,
      });
    }

    req.userId = user._id;
    req.user = user;

    next();
  } catch (error) {
    return res.status(401).json({
      message: "Invalid or expired access token",
      error: true,
    });
  }
};

export default authMiddleware;