"use client"

import React, { useEffect, useRef, useState } from "react"
import { io, type Socket } from "socket.io-client"
import LostItems from "@/components/admin/LostItems"
import TableDemo from "@/components/admin/chatHistoryTable"

type Claim = { id: string; user: string; message: string; createdAt?: string }
type Broadcast = { message: string; createdAt?: string }

export default function UserPage() {
  const [claims, setClaims] = useState<Claim[]>([])
  const [logs, setLogs] = useState<string[]>([])
  const [broadcastMsg, setBroadcastMsg] = useState("")
  const socketRef = useRef<Socket | null>(null)

  // useEffect(() => {
  //   // Connect to the Socket.IO server mounted at the API route path.
  //   const socket = io(undefined, { path: "/api/admin/chats" })
  //   socketRef.current = socket

  //   socket.on("connect", () => {
  //     setLogs((l) => [...l, `connected: ${socket.id}`])
  //   })

  //   socket.on("disconnect", (reason) => {
  //     setLogs((l) => [...l, `disconnected: ${String(reason)}`])
  //   })

  //   // When the backend emits a new claim request
  //   socket.on("claim-request", (claim: Claim) => {
  //     setClaims((c) => [claim, ...c])
  //     setLogs((l) => [...l, `new claim: ${claim.id} from ${claim.user}`])
  //   })

  //   // When a lost item is added the backend may emit this
  //   socket.on("lost-item-added", (item: any) => {
  //     setLogs((l) => [...l, `lost item added: ${item?.id ?? JSON.stringify(item)}`])
  //   })

  //   // Optional: receive broadcasts
  //   socket.on("admin-broadcast", (b: Broadcast) => {
  //     setLogs((l) => [...l, `broadcast: ${b.message}`])
  //   })

  //   return () => {
  //     socket.disconnect()
  //     socketRef.current = null
  //   }
  // }, [])

  // const sendBroadcast = () => {
  //   const msg = broadcastMsg.trim()
  //   if (!msg || !socketRef.current) return
  //   socketRef.current.emit("admin-broadcast", { message: msg })
  //   setLogs((l) => [...l, `broadcast sent: ${msg}`])
  //   setBroadcastMsg("")
  // }
  useEffect(() => {
    // Placeholder for any initialization logic if needed in the future
  }, [])

  return (
    <div className="space-y-6 overflow-y-scroll p-4">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold">Live Claim Requests</h2>
      </div>

      <div className="mb-4">
        <div className="flex gap-2">
          <input
            value={broadcastMsg}
            onChange={(e) => setBroadcastMsg(e.target.value)}
            placeholder="Broadcast message to users"
            className="flex-1 rounded border px-2 py-2 text-md"
          />
          <button onClick={() => {
            console.log("message sent")
          }} className="ml-2 rounded bg-blue-600 px-3 py-1 text-white">
            Broadcast
          </button>
        </div>
      </div>

      <div>
        {claims.length === 0 ? (
          <p className="text-sm text-muted-foreground">No claims yet.</p>
        ) : (
          <ul className="space-y-2">
            {claims.map((c) => (
              <li key={c.id} className="rounded border p-3">
                <div className="text-sm text-muted-foreground">
                  {c.user} • {c.createdAt ?? "-"}
                </div>
                <div className="mt-1">{c.message}</div>
              </li>
            ))}
          </ul>
        )}
      </div>

      <div className="mt-4">
        <h3 className="text-sm font-medium">Event Log</h3>
        <div className="mt-2 max-h-48 overflow-auto rounded border-2 text-xs">
              <TableDemo />
        </div>
      </div>
    </div>
  )
}
