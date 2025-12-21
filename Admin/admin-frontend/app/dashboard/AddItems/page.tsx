"use client";

import { useState } from "react";
import axios from "axios";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"


interface LostItemForm {
  item_name: string;
  description: string;
  location_lost: string;
  date_lost: string;
  reported_by_name: string;
  reported_by_roll: string;
  security_question: string;
  answer: string;
  created_post: string;
  image: File | null;
}

export default function DashboardPage() {
  const [lostItem, setLostItem] = useState<LostItemForm>({
    item_name: "",
    description: "",
    location_lost: "",
    date_lost: "",
    reported_by_name: "",
    reported_by_roll: "",
    security_question: "",
    answer: "",
    created_post: "",
    image: null,
  });

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setLostItem((prev) => ({ ...prev, [name]: value }));
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files?.[0]) {
      setLostItem((prev) => ({ ...prev, image: e.target.files![0] }));
    }
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!lostItem.description || !lostItem.location_lost || !lostItem.date_lost || !lostItem.reported_by_name) {
      alert("Please fill in all required fields");
      return;
    }
    const formData = new FormData();

    Object.entries(lostItem).forEach(([key, value]) => {
      if (value !== null) {
        formData.append(key, value);
      }
    });
    console.log(formData);
    try {
      await axios.post("/api/admin/items/add", formData);

      alert("Lost item added successfully");

      setLostItem({
        item_name: "",
        description: "",
        location_lost: "",
        date_lost: "",
        reported_by_name: "",
        reported_by_roll: "",
        security_question: "",
        answer: "",
        created_post: "",
        image: null,
      });

    } catch (error: any) {
      console.log(error);
      const msg = error.response?.data?.error || "Failed to add lost item";
      alert(msg);
    }
  };

  const locations = [
    "SECURITY GATE",
    "DHANALAKSHMI BANK",
    "MYTHREYI BHAVAN",
    "AB1 CAR PARKING",
    "AB1",
    "MAIN CANTEEN",
    "AMRITESHWARI HALL",
    "SUDHAMANI HALL",
    "AB1 SBI ATM",
    "MAIN BASKETBALL COURT",
    "MAIN VOLLEYBALL COURT",
    "YAGNAVALKYA BHAVAN",
    "YB MESS HALL",
    "KASHYAPA MESS HALL",
    "MAIN GROUND",
    "AEROSPACE",
    "KASHYAPA BHAVAN",
    "KB GYM",
    "BRIGU BHAVAN",
    "AB4",
    "PANDAL",
    "MBA CANTEEN",
    "ASB BLOCK",
    "CIR BLOCK",
    "KALARI BLOCK",
    "AMENITIES BLOCK",
    "SBI STORE ATM",
    "ANOKHA HUB",
    "BADMINTON COURT",
    "VEHICLE POOL",
    "MECHANICAL SHEDS",
    "ASHRAM",
    "GUEST HOUSE",
    "BUTTERFLY GARDEN",
    "GARGI BHAVAN",
    "AB2",
    "LIBRARY",
    "FSN BLOCK",
    "DEPT OF MATH BUILDING",
    "SWIMMING POOL",
    "KAPILA BHAVAN",
    "ADITHI BHAVANAM",
    "VASISHTA BHAVANAM",
    "VASISHTA GYM",
    "AGASTHYA BHAVANAM",
    "GAUTHAMA BHAVANAM",
    "VASISHTA GROUND",
    "VASISHTA BADMINTON COURT",
    "VASISHTA NIGHT CANTEEN",
    "MILLET CAFE",
    "SOPANAM IT CANTEEN",
    "GREEN BRIDGE",
    "PROJECT OFFICE",
    "AB3",
  ].sort();

  return (
    <div className="flex justify-center px-4 py-10">
      <Card className="w-full max-w-2xl shadow-lg rounded-2xl">
        <CardHeader>
          <CardTitle className="text-3xl font-bold">
            Report a Lost Item
          </CardTitle>
          <CardDescription>
            Enter accurate details to help recover the lost item.
          </CardDescription>
        </CardHeader>

        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Item Name */}
            <div className="space-y-2">
              <Label htmlFor="item_name">Item Name</Label>
              <Input
                id="item_name"
                name="item_name"
                placeholder="e.g. Wallet, ID Card"
                value={lostItem.item_name}
                onChange={handleChange}
                required
              />
            </div>

            {/* Description */}
            <div className="space-y-2">
              <Label htmlFor="description">Description</Label>
              <Textarea
                id="description"
                name="description"
                placeholder="Color, brand, identifying marks..."
                value={lostItem.description}
                onChange={handleChange}
                required
              />
            </div>

            {/* Dates */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="date_lost">Date Lost</Label>
                <Input
                  type="date"
                  id="date_lost"
                  name="date_lost"
                  value={lostItem.date_lost}
                  onChange={handleChange}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="created_post">Post Created On</Label>
                <Input
                  type="datetime-local"
                  id="created_post"
                  name="created_post"
                  value={lostItem.created_post}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>

            {/* Location */}
            <div className="space-y-2">
              <Label>Location Lost</Label>
              <Select
                value={lostItem.location_lost}
                onValueChange={(value) =>
                  handleChange({
                    target: { name: "location_lost", value } as any,
                  } as any)
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select location" />
                </SelectTrigger>
                <SelectContent>
                  {locations.map((location) => (
                    <SelectItem key={location} value={location}>
                      {location}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Reporter Info */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="reported_by_name">Reported By</Label>
                <Input
                  id="reported_by_name"
                  name="reported_by_name"
                  placeholder="Full Name"
                  value={lostItem.reported_by_name}
                  onChange={handleChange}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="reported_by_roll">Roll Number</Label>
                <Input
                  id="reported_by_roll"
                  name="reported_by_roll"
                  placeholder="Optional"
                  value={lostItem.reported_by_roll}
                  onChange={handleChange}
                />
              </div>
            </div>

            {/* Security Question */}
            <div className="space-y-2">
              <Label htmlFor="security_question">Security Question</Label>
              <Input
                id="security_question"
                name="security_question"
                placeholder="A question only the owner can answer"
                value={lostItem.security_question}
                onChange={handleChange}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="answer">Answer</Label>
              <Input
                id="answer"
                name="answer"
                placeholder="Answer to the security question"
                value={lostItem.answer}
                onChange={handleChange}
              />
            </div>

            {/* Image Upload */}
            <div className="space-y-2">
              <Label>Item Image</Label>
              <Input
                type="file"
                accept="image/*"
                onChange={handleFileChange}
              />
            </div>

            {/* Submit */}
            <Button type="submit" className="w-full text-base">
              Submit Lost Item
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
