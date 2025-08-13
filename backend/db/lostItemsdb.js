import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'


const supabaseUrl = 'https://etdewmgrpvoavevlpibg.supabase.co'
const supabaseKey = process.env.SUPABASE_KEY
const supabase = createClient(supabaseUrl, supabaseKey)

document.getElementById().addEventListener('Submit',async(e)=>{
    e.preventDefault()
    
    const item_id=document.getElementById().value.trim()
    const item_name =document.getElementById().value.trim()
    const description =document.getElementById().value.trim()
    const location_lost=document.getElementById().value.trim()
    const date_lost=document.getElementById().value.trim()
    const reported_by_name=document.getElementById().value.trim()
    const reported_by_roll=document.getElementById().value.trim()
    const created_post=document.getElementById().value.trim()
    
    const file=document.getElementById('image').files[0]
    
    if (!file){
        return alert("Please select a file")
    }
    const fileName = `${itemid}`

    const { data: storageData, error: storageError } = await supabase.storage.from('lost-images').upload(fileName, file)

    if (storageError) {
        console.error(storageError)
        return alert("Error uploading image")
    }

    const { data:publicUrlData}=supabase.storage.from('lost-images').getPublicUrl(fileName)

    const imageUrl=publicUrlData.publicUrl

    const { error:insertError }=await supabase.from('Lost_items').insert([{
        item_id: item_id,
        item_name:item_name,
        description:description,
        location_lost:location_lost,
        date_lost:date_lost, 
        reported_by_name:reported_by_name,
        reported_by_roll:reported_by_roll,
        created_post:created_post,
        image_url:imageUrl
    }]);

    if (insertError){
        console.error(insertError)
        return alert("Error inserting record")
    }



})
