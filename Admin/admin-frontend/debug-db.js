const { createClient } = require('@supabase/supabase-js');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables from .env
dotenv.config({ path: path.resolve(process.cwd(), '.env') });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL;
// Try to grab the service role key specifically
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY;

console.log('URL:', supabaseUrl);
console.log('Key exists:', !!supabaseKey);

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing credentials');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkData() {
  console.log('Checking Users table...');
  const { data: users, error: userError } = await supabase
    .from('Users')
    .select('*');
  
  if (userError) console.error('Users Error:', userError);
  else console.log('Users found:', users?.length, users);

  console.log('Checking Lost_items table...');
  const { data: items, error: itemError } = await supabase
    .from('Lost_items')
    .select('*');

  if (itemError) console.error('Items Error:', itemError);
  else console.log('Items found:', items?.length);
}

checkData();
