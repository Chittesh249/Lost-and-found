import express from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { supabase } from "../db/supabaseClient.js";

const userRouter = express.Router();

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*]).{8,}$/;

userRouter.post("/signup", async (req, res) => {
  const { email, password } = req.body;

  if (!emailRegex.test(email))
    return res.status(400).json({ error: "Invalid email format" });
  if (!passwordRegex.test(password))
    return res.status(400).json({
      error:
        "Password must be ≥8 chars and include a number and a special character"
    });

  try {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const { error } = await supabase
      .from("Users")
      .insert([{ email, password: hashedPassword }]);

    if (error) return res.status(400).json({ error: error.message });
    res.status(201).json({ message: "User created successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

userRouter.post("/login", async (req, res) => {
  const { email, password } = req.body;

  if (!emailRegex.test(email))
    return res.status(400).json({ error: "Invalid email format" });

  try {
    const { data: user, error } = await supabase
      .from("Users")
      .select("*")
      .eq("email", email)
      .single();

    if (error || !user)
      return res.status(401).json({ error: "Invalid email or password" });
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch)
      return res.status(401).json({ error: "Invalid email or password" });
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || "1h" }
    );

    res.json({ message: "Login successful", token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

userRouter.get("/get_items", verifyToken, async (req, res) => {
  try {
    const { data, error } = await supabase.from("Lost_items").select("*");
    if (error) return res.status(400).json({ error: error.message });
    res.json(data);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

function verifyToken(req, res, next) {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (!token) return res.status(401).json({ error: "Token missing" });

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ error: "Invalid or expired token" });
    req.user = decoded;
    next();
  });
}

export default userRouter;
