import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'


const supabaseUrl = 'https://etdewmgrpvoavevlpibg.supabase.co'
const supabaseKey = process.env.SUPABASE_KEY
const supabase = createClient(supabaseUrl, supabaseKey)


document.getElementById().addEventListener('submit',async(e)=>{
    e.preventDefault()
    const user_name=document.getElementById().value.trim()
    const user_password=document.getElementById().value.trim()


    const{error:insertError}=await supabase.from('Users').insert([{username:user_name,password:user_password}]);


    if (insertError){
        console.error(insertError)
        return alert("Error inserting records")
    }

})

