import { NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";

export async function POST(req: Request) {
  try {
    // Initialize Supabase Admin Client
    // We try to use the service role key or secret key available in env
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY || process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

    if (!supabaseUrl || !supabaseKey) {
      return NextResponse.json({ error: "Server misconfiguration: Missing Supabase URL or Key" }, { status: 500 });
    }

    const supabase = createClient(supabaseUrl, supabaseKey);

    const formData = await req.formData();
    const image = formData.get("image") as File | null;

    // Required fields
    const description = formData.get("description") as string;
    const location_lost = formData.get("location_lost") as string;
    const date_lost = formData.get("date_lost") as string;
    const reported_by_name = formData.get("reported_by_name") as string;

    if (!description || !location_lost || !date_lost || !reported_by_name) {
      return NextResponse.json({ error: "Missing required fields" }, { status: 400 });
    }

    // Optional fields
    const item_name = formData.get("item_name") as string | null;
    const reported_by_roll = formData.get("reported_by_roll") as string | null;
    const security_question = formData.get("security_question") as string | null;
    const answer = formData.get("answer") as string | null;


    // --- ID Generation Logic Ported from Backend ---
    function generatePrefix(location: string) {
      if (!location) return "XX";
      const words = location.trim().split(/\s+/);
      let prefix = "";
      for (let i = 0; i < Math.min(2, words.length); i++) {
        prefix += words[i][0].toUpperCase();
      }
      const lastWord = words[words.length - 1];
      if (!isNaN(Number(lastWord))) {
        prefix += lastWord;
      }
      return prefix;
    }

    const prefix = generatePrefix(location_lost);

    const { data: lastItem, error: fetchError } = await supabase
      .from("Lost_items")
      .select("item_id")
      .ilike("item_id", `${prefix}%`)
      .order("item_id", { ascending: false })
      .limit(1);

    if (fetchError) {
      console.error("Fetch Error:", fetchError);
      return NextResponse.json({ error: "Error fetching last item: " + fetchError.message }, { status: 400 });
    }

    let newNumber = 1;
    if (lastItem && lastItem.length > 0) {
      const lastId = lastItem[0].item_id;
      // Extract number part: assuming format PREFIX + 000
      const lastNum = parseInt(lastId.substring(prefix.length));
      if (!isNaN(lastNum)) {
        newNumber = lastNum + 1;
      }
    }

    const item_id = `${prefix}${String(newNumber).padStart(3, "0")}`;
    // -----------------------------------------------

    let image_url: string | null = null;

    // ---------- Image Upload ----------
    if (image) {
      const fileExt = image.name.split(".").pop();
      const fileName = `${item_id}.${fileExt}`;
      const filePath = `${fileName}`;

      const buffer = Buffer.from(await image.arrayBuffer());

      const { error: uploadError } = await supabase.storage
        .from("lost-images")
        .upload(filePath, buffer, {
          contentType: image.type,
          upsert: false,
        });

      if (uploadError) {
        console.error("Upload Error:", uploadError);
        return NextResponse.json({ error: "Image upload failed: " + uploadError.message }, { status: 400 });
      }

      const { data } = supabase.storage
        .from("lost-images")
        .getPublicUrl(filePath);

      image_url = data.publicUrl;
    }

    // ---------- Insert ----------
    const { error: dbError } = await supabase
      .from("Lost_items")
      .insert({
        item_id,
        item_name,
        description,
        location_lost,
        date_lost,
        reported_by_name,
        reported_by_roll,
        created_post: new Date().toISOString(),
        image_url,
        security_question: security_question || null,
        answer: answer || null,
      });

    if (dbError) {
      console.error("DB Error:", dbError);
      return NextResponse.json({ error: "Database insert failed: " + dbError.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, item: { item_id } });

  } catch (err: any) {
    console.error("Server Error:", err);
    return NextResponse.json({ error: "Failed to create lost item: " + (err.message || err) }, { status: 500 });
  }
}
