import { NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";
import * as bcrypt from "bcryptjs";

export async function POST(req: Request) {
    try {
        // Initialize Supabase Admin Client
        const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL;
        const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY || process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

        if (!supabaseUrl || !supabaseKey) {
            return NextResponse.json({ error: "Server misconfiguration: Missing Supabase URL or Key" }, { status: 500 });
        }

        const supabase = createClient(supabaseUrl, supabaseKey);

        const body = await req.json();
        const { email, password } = body;

        // Basic Validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*]).{8,}$/;

        if (!email || !emailRegex.test(email)) {
            return NextResponse.json({ error: "Invalid email format" }, { status: 400 });
        }
        if (!password || !passwordRegex.test(password)) {
            return NextResponse.json({
                error: "Password must be ≥8 chars and include a number and a special character"
            }, { status: 400 });
        }

        // Check if user already exists
        const { data: existingUser } = await supabase
            .from("Users")
            .select("email")
            .eq("email", email)
            .single();

        if (existingUser) {
            return NextResponse.json({ error: "User already exists" }, { status: 400 });
        }

        // Hash Password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Insert User
        const { error: insertError } = await supabase
            .from("Users")
            .insert([{ email, password: hashedPassword }]);

        if (insertError) {
            console.error("Insert Error:", insertError);
            return NextResponse.json({ error: insertError.message }, { status: 400 });
        }

        return NextResponse.json({ message: "User created successfully" }, { status: 201 });

    } catch (err: any) {
        console.error("Signup Error:", err);
        return NextResponse.json({ error: "Server error: " + (err.message || err) }, { status: 500 });
    }
}
