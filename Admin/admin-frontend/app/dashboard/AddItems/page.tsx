"use client";
import { useState } from "react";
import axios from "axios";
import { v4 as uuidv4 } from "uuid";

interface LostItem {
  item_id: string;
  item_name: string;
  description: string;
  location_lost: string;
  date_lost: Date | null | string;
  reported_by_name: string;
  securityQuestion: string;
  reported_by_roll: string;
  created_post: Date | null | string;
  answer: string;
  image?: File | null;
}

export default function DashboardPage() {
  const [lostItem, setLostItem] = useState<LostItem>({
    item_id: uuidv4(),
    item_name: "",
    description: "",
    date_lost: new Date(),
    location_lost: "",
    reported_by_name: "",
    securityQuestion: "",
    reported_by_roll: "",
    created_post: new Date(),
    answer: "",
    image: null,
  });

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setLostItem({ ...lostItem, [name]: value });
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setLostItem({ ...lostItem, image: e.target.files[0] });
    }
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    const formData = new FormData();
    formData.append("item_id", lostItem.item_id);
    formData.append("item_name", lostItem.item_name);
    formData.append("description", lostItem.description);
    formData.append("date_lost", String(lostItem.date_lost));
    formData.append("location_lost", lostItem.location_lost);
    formData.append("reported_by_name", lostItem.reported_by_name);
    formData.append("reported_by_roll", lostItem.reported_by_roll);
    formData.append("securityQuestion", lostItem.securityQuestion);
    formData.append("answer", lostItem.answer);
    formData.append("created_post", String(lostItem.created_post));
    if (lostItem.image) {
      formData.append("image", lostItem.image);
    }

    try {
      const { data } = await axios.post(
        "https://lost-and-found-es98.onrender.com/api/admin/add_items",
        formData,
      );
      console.log("Item added successfully:", data);

      setLostItem({
        item_id: "",
        item_name: "",
        description: "",
        date_lost: new Date(),
        location_lost: "",
        reported_by_name: "",
        reported_by_roll: "",
        securityQuestion: "",
        answer: "",
        created_post: new Date(),
        image: null,
      });
    } catch (error) {
      console.error("Error uploading:", error);
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
    <div className="space-y-6 flex flex-col items-center">
      <h1 className="font-extrabold text-4xl">
        Enter the details of the newly lost item
      </h1>
      <section className="flex gap-4 lg:grid-cols-3 w-full ">
        <form
          onSubmit={handleSubmit}
          className="space-y-4 flex flex-col justify-center w-full"
        >
          <div>
            <label className="block text-sm font-medium">Item Name</label>
            <input
              type="text"
              name="item_name"
              value={lostItem.item_name}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>

          <div>
            <label className="block text-sm font-medium">Description</label>
            <input
              type="text"
              name="description"
              value={lostItem.description}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>

          <div>
            <label className="block text-sm font-medium">Date Lost</label>
            <input
              type="date"
              name="date_lost"
              value={lostItem.date_lost as string}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>

          <div>
            <label className="block text-sm font-medium">Created Post</label>
            <input
              type="datetime-local"
              name="created_post"
              value={lostItem.created_post as string}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>

          <div>
            <label className="block text-sm font-medium">Location Lost</label>
            <select
              name="location_lost"
              value={lostItem.location_lost}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            >
              <option value="">Select a location</option>
              {locations.map((loc) => (
                <option key={loc} value={loc}>
                  {loc}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium">Reported By Name</label>
            <input
              type="text"
              name="reported_by_name"
              value={lostItem.reported_by_name}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>

          <div>
            <label className="block text-sm font-medium">Reported By Roll</label>
            <input
              type="text"
              name="reported_by_roll"
              value={lostItem.reported_by_roll}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>

          <div>
            <label className="block text-sm font-medium">
              Security Question
            </label>
            <input
              type="text"
              name="securityQuestion"
              value={lostItem.securityQuestion}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>

          <div>
            <label className="block text-sm font-medium">Answer</label>
            <input
              type="text"
              name="answer"
              value={lostItem.answer}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>

          <div>
            <label className="block text-sm font-medium">
              Upload the image of the lost item
            </label>
            <input
              type="file"
              accept="image/*"
              onChange={handleFileChange}
              className="border-1 border-black p-3 rounded-2xl"
            />
          </div>

          <button
            type="submit"
            className="mt-4 bg-blue-500 text-white rounded-md p-2"
          >
            Submit
          </button>
        </form>
      </section>
    </div>
  );
}
