import express from "express"
import sql from "../db/lostItemsdb"
import jwt from "jsonwebtoken"
import dotenv from "dotenv"

const userRouter = express.Router()

userRouter.get('/login',(req,res) => {
    const AccessTocken = jwt.sign(
        {"username" : "User"},
        process.env.ACCESS_TOKEN_SECRET,
        {expiresIn : '600s'}
    )
    const RefreshToken = jwt.sign(
        {"username" : "User"},
        process.env.REFRESH_TOKEN_SECRET,
        {expiresIn : '1d'}
    )
    res.send("This is the signin page for user")
})
userRouter.post('/signup',(req,res) => {
    const reponse = req.body;
})

userRouter.get('/me',(req,res) => {
    // get the email and the password from the current user
})

userRouter.get('/items',(req,res) => {
    res.status(200).send({
        // send the array of list items from the database 
    })
})

userRouter.post('/claim',(req,res) =>{
    // get a response code of 200(OK) or 401(unauthorised access)
    const response = req.body;
    res.status(200).send({
        'Access Token' : 123456
    })
})


export default userRouter;

