import express from "express"
import { createClient } from '@supabase/supabase-js'
import 'dotenv/config'


const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY)



const adminRouter = express.Router();

adminRouter.post('/login',async(req,res)=>{
    const {email,password} = req.body;

    const{data,error}=await supabase.from('Admin').select('*').eq('email',email).eq('password',password).single()


    if (error || !data){
        return res.status(401).json({error:"Invalid email or password"})
    }

    res.json({
        message:"Admin Login Successfull",
        admin:data
    })

})

adminRouter.post('/signup',async(req,res)=>{
    const {email,password} = req.body;

    const {data,error} = await supabase.from('Admin').insert([{email,password}]).select();

    if (error) {
        return res.status(400).json({ error: error.message });
    }

    res.json({
        message:"Admin Signup Successfull",
        admin:data
    })
})

adminRouter.post('/add_items',async(req,res) => {
    const Data = req.body;

    const { data, error } = await supabase
      .from("Lost_items")
      .insert([{ ...Data }]);

    if (error) {    
      console.error("Error inserting data:", error);
    } else {
      console.log("Data inserted successfully:", data);
    }
})

export default adminRouter;