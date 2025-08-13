import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'


const supabaseUrl = 'https://etdewmgrpvoavevlpibg.supabase.co'
const supabaseKey = process.env.SUPABASE_KEY
const supabase = createClient(supabaseUrl, supabaseKey)


document.getElementById().addEventListener('submit',async(e)=>{
    e.preventDefault()
    const item_id=document.getElementById().ariaValueMax.trim()
    const location_found=document.getElementById().ariaValueMax.trim()
    const date_found=document.getElementById().ariaValueMax.trim()
    const buyer_rollno=document.getElementById().ariaValueMax.trim()
    const buyer_name=document.getElementById().ariaValueMax.trim()


    const{error:insertError}=await supabase.from('Found_items').insert([{
        item_id:item_id,
        location_found:location_found,
        date_found:date_found,
        buyer_rollno:buyer_rollno,
        buyer_name:buyer_name
    }]);

    if (insertError){
        console.error(insertError)
        return alert("Error inserting records")
    }



})