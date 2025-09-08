import express from "express";
import dotenv from "dotenv";
import { createClient } from "@supabase/supabase-js";

dotenv.config();

const userRouter = express.Router();

// Use Supabase service role key to initialize admin client
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

userRouter.post("/signup", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email and password are required." });
  }

  try {
    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true, 
    });

    if (error) {
      console.error("Signup error:", error);
      return res.status(400).json({ error: error.message });
    }

    res.status(201).json({ message: "User created successfully", user: data.user });
  } catch (err) {
    console.error("Server error:", err.message);
    res.status(500).json({ error: "Internal server error" });
  }
});

userRouter.get("/get_items", async (req, res) => {
  try {
    const { data, error } = await supabaseAdmin.from("Lost_items").select("*");

    if (error) {
      return res.status(400).json({ error: error.message });
    }
    res.json(data);
  } catch (err) {
    console.error("Server error:", err.message);
    res.status(500).json({ error: "Internal server error" });
  }
});

export default userRouter;
