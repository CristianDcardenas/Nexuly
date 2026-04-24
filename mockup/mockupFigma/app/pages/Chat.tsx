import { useState } from "react";
import { useParams } from "react-router";
import { Send, Phone, Video, MoreVertical, Image, Paperclip } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const professionalData = {
  id: 1,
  name: "Dra. Ana María García",
  specialty: "Enfermería General",
  image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080",
  online: true
};

const initialMessages = [
  {
    id: 1,
    sender: "professional",
    text: "¡Hola! Soy la Dra. García. ¿En qué puedo ayudarte hoy?",
    time: "10:30 AM",
    read: true
  },
  {
    id: 2,
    sender: "user",
    text: "Buenos días doctora. Necesito una aplicación de vitamina B12 para mi madre.",
    time: "10:32 AM",
    read: true
  },
  {
    id: 3,
    sender: "professional",
    text: "Perfecto. ¿Tiene alguna prescripción médica? ¿Cuál sería la fecha y hora que prefieren?",
    time: "10:33 AM",
    read: true
  },
  {
    id: 4,
    sender: "user",
    text: "Sí, tengo la receta médica. ¿Podría ser mañana a las 10 AM?",
    time: "10:35 AM",
    read: true
  },
  {
    id: 5,
    sender: "professional",
    text: "Excelente. Mañana a las 10 AM tengo disponibilidad. ¿Cuál es la dirección?",
    time: "10:36 AM",
    read: false
  }
];

export function Chat() {
  const { id } = useParams();
  const [messages, setMessages] = useState(initialMessages);
  const [newMessage, setNewMessage] = useState("");

  const handleSendMessage = () => {
    if (newMessage.trim()) {
      const message = {
        id: messages.length + 1,
        sender: "user" as const,
        text: newMessage,
        time: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
        read: false
      };
      setMessages([...messages, message]);
      setNewMessage("");

      // Simulate professional response
      setTimeout(() => {
        const response = {
          id: messages.length + 2,
          sender: "professional" as const,
          text: "Perfecto, he recibido tu mensaje. Te confirmo la cita.",
          time: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
          read: false
        };
        setMessages(prev => [...prev, response]);
      }, 2000);
    }
  };

  return (
    <div className="flex flex-col h-[calc(100vh-120px)]">
      {/* Chat Header */}
      <div className="bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <button 
            onClick={() => window.history.back()}
            className="p-1"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          
          <div className="relative">
            <ImageWithFallback 
              src={professionalData.image}
              alt={professionalData.name}
              className="w-10 h-10 rounded-full object-cover"
            />
            {professionalData.online && (
              <div className="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full" />
            )}
          </div>

          <div>
            <h2 className="text-sm text-gray-900">{professionalData.name}</h2>
            <p className="text-xs text-green-600">En línea</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button className="p-2 rounded-full hover:bg-gray-100">
            <Phone className="w-5 h-5 text-gray-600" />
          </button>
          <button className="p-2 rounded-full hover:bg-gray-100">
            <Video className="w-5 h-5 text-gray-600" />
          </button>
          <button className="p-2 rounded-full hover:bg-gray-100">
            <MoreVertical className="w-5 h-5 text-gray-600" />
          </button>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50">
        {/* Date Separator */}
        <div className="flex items-center justify-center">
          <span className="px-3 py-1 rounded-full bg-gray-200 text-xs text-gray-600">
            Hoy
          </span>
        </div>

        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex ${message.sender === "user" ? "justify-end" : "justify-start"}`}
          >
            <div className={`max-w-[75%] ${message.sender === "user" ? "order-2" : "order-1"}`}>
              <div
                className={`rounded-2xl px-4 py-2 ${
                  message.sender === "user"
                    ? "bg-violet-600 text-white rounded-br-sm"
                    : "bg-white text-gray-900 rounded-bl-sm"
                }`}
              >
                <p className="text-sm">{message.text}</p>
              </div>
              <div className={`flex items-center gap-1 mt-1 ${message.sender === "user" ? "justify-end" : "justify-start"}`}>
                <span className="text-xs text-gray-500">{message.time}</span>
                {message.sender === "user" && (
                  <svg
                    className={`w-4 h-4 ${message.read ? "text-violet-600" : "text-gray-400"}`}
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Input Area */}
      <div className="bg-white border-t border-gray-200 p-4">
        <div className="flex items-end gap-2">
          <button className="p-2 rounded-full hover:bg-gray-100 text-gray-600">
            <Image className="w-5 h-5" />
          </button>
          <button className="p-2 rounded-full hover:bg-gray-100 text-gray-600">
            <Paperclip className="w-5 h-5" />
          </button>
          
          <div className="flex-1 bg-gray-100 rounded-2xl px-4 py-2 flex items-center">
            <input
              type="text"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
              placeholder="Escribe un mensaje..."
              className="flex-1 bg-transparent focus:outline-none text-sm"
            />
          </div>

          <button
            onClick={handleSendMessage}
            disabled={!newMessage.trim()}
            className={`p-3 rounded-full ${
              newMessage.trim()
                ? "bg-violet-600 text-white"
                : "bg-gray-200 text-gray-400"
            }`}
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}