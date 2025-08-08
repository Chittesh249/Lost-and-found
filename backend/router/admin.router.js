import express from "express"

const adminRouter = express.Router();

adminRouter.get('/login',(req,res) => {
    res.send("This is the login page for admin")
})
adminRouter.post('/signup',(req,res) => {
    const data = req.body;
})

adminRouter.post('/items',(req,res) => {
    const data = req.body;
})

export default adminRouter;