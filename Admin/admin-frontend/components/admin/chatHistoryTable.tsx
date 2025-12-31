import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableFooter,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"

const messages = [
  {
    date:"",
    message :""
  }
]

export function TableDemo() {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead className="w-full p-4">Date</TableHead>
          <TableHead className="text-right p-4">Message</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {messages.map((message) => (
          message.date ?
          <TableRow key={message.date}>
            <TableCell className="font-medium">{message.date}</TableCell>
            <TableCell className="text-right">{message.message}</TableCell>
          </TableRow>
          : <span className="flex items-center justify-center">No messages to display</span>
        ))}
      </TableBody>
    </Table>
  )
}
export default TableDemo;