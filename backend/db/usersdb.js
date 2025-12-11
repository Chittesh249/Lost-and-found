import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://etdewmgrpvoavevlpibg.supabase.co'

const supabaseKey = process.env.SUPABASE_KEY

const supabase = createClient(supabaseUrl, supabaseKey)


document.getElementById().addEventListener('submit',async(e)=>{
    e.preventDefault()
    const roll_no=document.getElementById().value.trim()
    const name=document.getElementById().value.trim()
    const email=document.getElementById().value.trim()
    const password=document.getElementById().value.trim()


    const{error:insertError}=await supabase.from('Users').insert([{
        rollno:roll_no,
        name:name,
        email:email,
        password:password
    }]);
    
    if (insertError){
        console.error(insertError)
        return alert("Error inserting record")
    }
})