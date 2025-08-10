import express from "express"

const adminRouter = express.Router();

adminRouter.get('/login',(req,res) => {
    const AccessTocken = jwt.sign(
        {"username" : "Admin"},
        process.env.ACCESS_TOKEN_SECRET,
        {expiresIn : '600s'}
    )
    const RefreshToken = jwt.sign(
        {"username" : "Admin"},
        process.env.REFRESH_TOKEN_SECRET,
        {expiresIn : '1d'}
    )
    res.send("This is the login page for admin")
})
adminRouter.post('/signup',(req,res) => {
    const data = req.body;
})

adminRouter.post('/items',(req,res) => {
    const data = req.body;
})

export default adminRouter;