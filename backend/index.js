import express from "express"
import cors from "cors"
import dotenv from "dotenv"
import userRouter from "./router/user.router.js"
import adminRouter from "./router/admin.router.js"

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

// routing logic
app.use("/api/user",userRouter);
app.use("/api/admin",adminRouter);

app.get("/",(req,res) => {
  res.send("API is running....");
})
// server instance
app.listen(process.env.PORT || 3000,() => {
    console.log("Listening on http://localhost:3000")
}).on("error", (err) => {
  console.error("Failed to start server:", err);
});