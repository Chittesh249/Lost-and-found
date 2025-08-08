import express from "express"


const userRouter = express.Router()

userRouter.get('/login',(req,res) => {
    res.send("This is the signin page for user")
})
userRouter.post('/signup',(req,res) => {
    const reponse = req.body;
})

userRouter.get('/me',(req,res) => {
    res.send("This is your profile page")
})

userRouter.get('/items',(req,res) => {
    res.send("This is the place where you can get the list of items lost and found")
})

userRouter.post('/claim',(req,res) =>{
    // get a response code of 200(OK) or 401(unauthorised access)
    const response = req.body;
})


export default userRouter;

