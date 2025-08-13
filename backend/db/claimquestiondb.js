import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'


const supabaseUrl = 'https://etdewmgrpvoavevlpibg.supabase.co'
const supabaseKey = process.env.SUPABASE_KEY
const supabase = createClient(supabaseUrl, supabaseKey)


document.getElementById().addEventListener('submit',async(e)=>{
    e.preventDefault()

    const item_id=document.getElementById().ariaValueMax.trim()
    const question=document.getElementById().ariaValueMax.trim()
    const answer=document.getElementById().ariaValueMax.trim()

    const{error:insertError}=await supabase.from('claim_question').insert([{
        item_id:item_id,
        question:question,
        answer:answer
    }]);

    if (insertError){
        console.error(insertError)
        return alert("Error inserting record")
        }


})