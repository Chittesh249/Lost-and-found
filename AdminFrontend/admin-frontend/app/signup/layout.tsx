// app/admin/login/layout.tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Admin Signup",
  description: "Signup to access the admin dashboard",
};

export default function SignupLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="bg-gradient-to-br from-purple-100 to-indigo-100 min-h-screen flex items-center justify-center">
      {children}
    </div>
  );
}
