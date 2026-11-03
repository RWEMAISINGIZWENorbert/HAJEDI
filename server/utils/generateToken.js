import jwt from "jsonwebtoken";
import User from "../models/user.js";

export const generateRefreshToken = async (userId) => {
       
    if(!process.env.REFRESH_TOKEN_SECRET_KEY){
        throw new Error("Acess Token secret key is not found");
      }
          
         const user = await User.findOne({_id:userId});
       
         if(!user){
             throw new Error("User not found");    
         }

      const token = jwt.sign(
        {id: userId},
        process.env.REFRESH_TOKEN_SECRET_KEY,
        {expiresIn: "1000d"}
      );
      
      return token;
      
}

export const generateAccessToken = async (userId) => {
  if(!process.env.ACCESS_TOKEN_SECRET_KEY){
        throw new Error("Acess Token secret key is not found");
      }
          
         const user = await User.findOne({_id:userId});
       
         if(!user){
             throw new Error("User not found");    
         }

      const token = jwt.sign(
        {id: userId},
        process.env.ACCESS_TOKEN_SECRET_KEY,
        {expiresIn: "1000d"}
      );
      
      return token;
}