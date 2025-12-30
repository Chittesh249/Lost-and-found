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


import { useRef } from "react";
import { Camera, X } from "lucide-react";

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

  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Webcam refs and state
  const videoRef = useRef<HTMLVideoElement>(null);
  const [isWebcamOpen, setIsWebcamOpen] = useState(false);
  const [stream, setStream] = useState<MediaStream | null>(null);

  const startWebcam = async () => {
    try {
      setIsWebcamOpen(true);
      const mediaStream = await navigator.mediaDevices.getUserMedia({ video: true });
      setStream(mediaStream);
      // Wait for state update and ref to be attached
      setTimeout(() => {
        if (videoRef.current) {
          videoRef.current.srcObject = mediaStream;
        }
      }, 100);
    } catch (err) {
      console.error("Error accessing webcam:", err);
      alert("Could not access webcam. Please check permissions.");
      setIsWebcamOpen(false);
    }
  };

  const stopWebcam = () => {
    if (stream) {
      stream.getTracks().forEach((track) => track.stop());
      setStream(null);
    }
    setIsWebcamOpen(false);
  };

  const captureWebcam = () => {
    if (videoRef.current) {
      const canvas = document.createElement("canvas");
      canvas.width = videoRef.current.videoWidth;
      canvas.height = videoRef.current.videoHeight;
      const ctx = canvas.getContext("2d");
      if (ctx) {
        ctx.drawImage(videoRef.current, 0, 0);
        canvas.toBlob((blob) => {
          if (blob) {
            const file = new File([blob], "webcam-capture.jpg", { type: "image/jpeg" });
            setLostItem((prev) => ({ ...prev, image: file }));
            setImagePreview(URL.createObjectURL(file));
            stopWebcam();
          }
        }, "image/jpeg", 0.8);
      }
    }
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setLostItem((prev) => ({ ...prev, [name]: value }));
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files?.[0]) {
      const file = e.target.files[0];
      setLostItem((prev) => ({ ...prev, image: file }));
      setImagePreview(URL.createObjectURL(file));
      console.log('Mobile/Camera debug:', file.name, file.type, file.size);
    }
  };

  const triggerFileInput = () => {
    fileInputRef.current?.click();
  };

  const removeImage = () => {
    setLostItem((prev) => ({ ...prev, image: null }));
    setImagePreview(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
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
      setImagePreview(null);
      if (fileInputRef.current) fileInputRef.current.value = "";

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

              {/* Hidden Input */}
              <Input
                type="file"
                ref={fileInputRef}
                className="hidden"
                accept="image/*"
                capture="environment"
                onChange={handleFileChange}
              />

              {/* Custom UI */}
              {!imagePreview && (
                <div className="grid grid-cols-2 gap-4">
                  <Button
                    type="button"
                    variant="outline"
                    className="h-32 flex flex-col items-center justify-center border-dashed border-2 hover:bg-muted/50 transition-colors"
                    onClick={triggerFileInput}
                  >
                    <Camera className="h-8 w-8 mb-2 text-muted-foreground" />
                    <span className="text-muted-foreground font-medium">Upload Image</span>
                  </Button>

                  <Button
                    type="button"
                    variant="outline"
                    className="h-32 flex flex-col items-center justify-center border-dashed border-2 hover:bg-muted/50 transition-colors"
                    onClick={startWebcam}
                  >
                    <Camera className="h-8 w-8 mb-2 text-muted-foreground" />
                    <span className="text-muted-foreground font-medium">Use Webcam</span>
                  </Button>
                </div>
              )}

              {imagePreview && (
                <div className="relative w-full h-64 rounded-lg overflow-hidden border">
                  <img
                    src={imagePreview}
                    alt="Preview"
                    className="w-full h-full object-cover"
                  />
                  <Button
                    type="button"
                    variant="destructive"
                    size="icon"
                    className="absolute top-2 right-2 rounded-full shadow-md"
                    onClick={removeImage}
                  >
                    <X className="h-4 w-4" />
                  </Button>
                </div>
              )}
            </div>

            {/* Submit */}
            <Button type="submit" className="w-full text-base">
              Submit Lost Item
            </Button>
          </form>
        </CardContent>
      </Card>

      {/* Webcam Overlay */}
      {isWebcamOpen && (
        <div className="fixed inset-0 z-50 bg-black/80 flex items-center justify-center p-4">
          <div className="bg-background p-4 rounded-lg max-w-2xl w-full flex flex-col items-center gap-4 relative">
            <Button
              type="button"
              variant="ghost"
              size="icon"
              className="absolute top-2 right-2"
              onClick={stopWebcam}
            >
              <X className="h-6 w-6" />
            </Button>

            <h3 className="text-xl font-semibold">Take a Photo</h3>

            <div className="relative w-full aspect-video bg-black rounded overflow-hidden">
              <video
                ref={videoRef}
                autoPlay
                playsInline
                muted
                className="w-full h-full object-cover"
              />
            </div>

            <div className="flex gap-4 w-full">
              <Button type="button" variant="outline" className="flex-1" onClick={stopWebcam}>
                Cancel
              </Button>
              <Button type="button" className="flex-1" onClick={captureWebcam}>
                Capture Photo
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
