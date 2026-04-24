import { useState } from "react";
import { useNavigate } from "react-router";
import { 
  ArrowLeft, 
  Search, 
  Filter, 
  Clock, 
  CheckCircle2, 
  XCircle, 
  FileText,
  Eye,
  Download,
  MessageSquare,
  MoreVertical,
  User,
  Shield,
  Calendar,
  MapPin,
  ChevronRight,
  AlertTriangle,
  Check,
  X
} from "lucide-react";

type ValidationStatus = "pending" | "in_review" | "approved" | "rejected";

interface ProfessionalRequest {
  id: string;
  name: string;
  email: string;
  phone: string;
  specialty: string;
  licenseNumber: string;
  yearsExperience: number;
  submittedAt: string;
  status: ValidationStatus;
  documents: {
    id: string;
    type: string;
    name: string;
    status: "pending" | "verified" | "rejected";
    url?: string;
  }[];
  photo?: string;
}

const mockRequests: ProfessionalRequest[] = [
  {
    id: "1",
    name: "Maria Garcia Lopez",
    email: "maria.garcia@email.com",
    phone: "+57 300 123 4567",
    specialty: "Enfermeria General",
    licenseNumber: "ENF-2024-12345",
    yearsExperience: 8,
    submittedAt: "2026-04-20T10:30:00",
    status: "pending",
    documents: [
      { id: "d1", type: "id", name: "Cedula de ciudadania", status: "verified" },
      { id: "d2", type: "degree", name: "Titulo profesional", status: "pending" },
      { id: "d3", type: "license", name: "Tarjeta profesional", status: "pending" },
      { id: "d4", type: "background", name: "Antecedentes judiciales", status: "verified" },
    ]
  },
  {
    id: "2",
    name: "Carlos Rodriguez Perez",
    email: "carlos.rodriguez@email.com",
    phone: "+57 310 987 6543",
    specialty: "Fisioterapia",
    licenseNumber: "FIS-2024-67890",
    yearsExperience: 5,
    submittedAt: "2026-04-19T14:15:00",
    status: "in_review",
    documents: [
      { id: "d1", type: "id", name: "Cedula de ciudadania", status: "verified" },
      { id: "d2", type: "degree", name: "Titulo profesional", status: "verified" },
      { id: "d3", type: "license", name: "Tarjeta profesional", status: "pending" },
      { id: "d4", type: "background", name: "Antecedentes judiciales", status: "verified" },
    ]
  },
  {
    id: "3",
    name: "Ana Martinez Ruiz",
    email: "ana.martinez@email.com",
    phone: "+57 320 456 7890",
    specialty: "Cuidado de Adultos Mayores",
    licenseNumber: "CAM-2024-11111",
    yearsExperience: 12,
    submittedAt: "2026-04-18T09:00:00",
    status: "approved",
    documents: [
      { id: "d1", type: "id", name: "Cedula de ciudadania", status: "verified" },
      { id: "d2", type: "degree", name: "Titulo profesional", status: "verified" },
      { id: "d3", type: "license", name: "Tarjeta profesional", status: "verified" },
      { id: "d4", type: "background", name: "Antecedentes judiciales", status: "verified" },
    ]
  },
  {
    id: "4",
    name: "Pedro Sanchez Gomez",
    email: "pedro.sanchez@email.com",
    phone: "+57 315 222 3333",
    specialty: "Pediatria",
    licenseNumber: "PED-2024-22222",
    yearsExperience: 3,
    submittedAt: "2026-04-17T16:45:00",
    status: "rejected",
    documents: [
      { id: "d1", type: "id", name: "Cedula de ciudadania", status: "verified" },
      { id: "d2", type: "degree", name: "Titulo profesional", status: "rejected" },
      { id: "d3", type: "license", name: "Tarjeta profesional", status: "rejected" },
      { id: "d4", type: "background", name: "Antecedentes judiciales", status: "verified" },
    ]
  },
];

const statusConfig = {
  pending: { label: "Pendiente", color: "bg-amber-100 text-amber-700", icon: Clock },
  in_review: { label: "En revision", color: "bg-blue-100 text-blue-700", icon: Eye },
  approved: { label: "Aprobado", color: "bg-green-100 text-green-700", icon: CheckCircle2 },
  rejected: { label: "Rechazado", color: "bg-red-100 text-red-700", icon: XCircle },
};

export function AdminValidation() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<"all" | ValidationStatus>("all");
  const [selectedRequest, setSelectedRequest] = useState<ProfessionalRequest | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [showRejectModal, setShowRejectModal] = useState(false);
  const [rejectReason, setRejectReason] = useState("");

  const filteredRequests = mockRequests.filter(req => {
    const matchesTab = activeTab === "all" || req.status === activeTab;
    const matchesSearch = req.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          req.specialty.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesTab && matchesSearch;
  });

  const stats = {
    pending: mockRequests.filter(r => r.status === "pending").length,
    inReview: mockRequests.filter(r => r.status === "in_review").length,
    approved: mockRequests.filter(r => r.status === "approved").length,
    rejected: mockRequests.filter(r => r.status === "rejected").length,
  };

  const handleApprove = (requestId: string) => {
    // Mock approval action
    console.log("Approved:", requestId);
    setSelectedRequest(null);
  };

  const handleReject = (requestId: string) => {
    // Mock rejection action
    console.log("Rejected:", requestId, "Reason:", rejectReason);
    setShowRejectModal(false);
    setRejectReason("");
    setSelectedRequest(null);
  };

  if (selectedRequest) {
    return (
      <RequestDetail 
        request={selectedRequest} 
        onBack={() => setSelectedRequest(null)}
        onApprove={handleApprove}
        onReject={() => setShowRejectModal(true)}
      />
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 p-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate("/")} className="p-2 hover:bg-gray-100 rounded-full">
            <ArrowLeft className="w-5 h-5 text-gray-600" />
          </button>
          <div>
            <h1 className="text-xl font-semibold text-gray-900">Panel de Validacion</h1>
            <p className="text-sm text-gray-500">Gestion de solicitudes de profesionales</p>
          </div>
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Buscar por nombre o especialidad..."
            className="w-full pl-10 pr-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none"
          />
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-2 p-4">
        <div className="bg-amber-50 rounded-xl p-3 text-center">
          <p className="text-2xl font-bold text-amber-600">{stats.pending}</p>
          <p className="text-xs text-amber-700">Pendientes</p>
        </div>
        <div className="bg-blue-50 rounded-xl p-3 text-center">
          <p className="text-2xl font-bold text-blue-600">{stats.inReview}</p>
          <p className="text-xs text-blue-700">En revision</p>
        </div>
        <div className="bg-green-50 rounded-xl p-3 text-center">
          <p className="text-2xl font-bold text-green-600">{stats.approved}</p>
          <p className="text-xs text-green-700">Aprobados</p>
        </div>
        <div className="bg-red-50 rounded-xl p-3 text-center">
          <p className="text-2xl font-bold text-red-600">{stats.rejected}</p>
          <p className="text-xs text-red-700">Rechazados</p>
        </div>
      </div>

      {/* Tabs */}
      <div className="px-4 mb-4">
        <div className="flex gap-2 overflow-x-auto pb-2">
          {["all", "pending", "in_review", "approved", "rejected"].map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab as typeof activeTab)}
              className={`px-4 py-2 rounded-full text-sm whitespace-nowrap transition-colors ${
                activeTab === tab
                  ? "bg-violet-600 text-white"
                  : "bg-white text-gray-600 border border-gray-200"
              }`}
            >
              {tab === "all" ? "Todas" : statusConfig[tab as ValidationStatus].label}
            </button>
          ))}
        </div>
      </div>

      {/* Request List */}
      <div className="px-4 space-y-3 pb-6">
        {filteredRequests.map((request) => (
          <div
            key={request.id}
            onClick={() => setSelectedRequest(request)}
            className="bg-white rounded-xl p-4 shadow-sm border border-gray-100 cursor-pointer hover:border-violet-200 transition-colors"
          >
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-violet-100 rounded-full flex items-center justify-center">
                  <User className="w-6 h-6 text-violet-600" />
                </div>
                <div>
                  <h3 className="font-medium text-gray-900">{request.name}</h3>
                  <p className="text-sm text-gray-500">{request.specialty}</p>
                </div>
              </div>
              <span className={`text-xs px-2 py-1 rounded-full ${statusConfig[request.status].color}`}>
                {statusConfig[request.status].label}
              </span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-4 text-gray-500">
                <span className="flex items-center gap-1">
                  <Calendar className="w-4 h-4" />
                  {new Date(request.submittedAt).toLocaleDateString()}
                </span>
                <span className="flex items-center gap-1">
                  <FileText className="w-4 h-4" />
                  {request.documents.filter(d => d.status === "verified").length}/{request.documents.length} docs
                </span>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </div>
          </div>
        ))}

        {filteredRequests.length === 0 && (
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <FileText className="w-8 h-8 text-gray-400" />
            </div>
            <p className="text-gray-500">No hay solicitudes en esta categoria</p>
          </div>
        )}
      </div>

      {/* Reject Modal */}
      {showRejectModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 w-full max-w-md">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center">
                <AlertTriangle className="w-6 h-6 text-red-600" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">Rechazar solicitud</h3>
                <p className="text-sm text-gray-500">Indica el motivo del rechazo</p>
              </div>
            </div>
            <textarea
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="Escribe el motivo del rechazo..."
              rows={4}
              className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none resize-none mb-4"
            />
            <div className="flex gap-3">
              <button
                onClick={() => setShowRejectModal(false)}
                className="flex-1 py-3 border border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50"
              >
                Cancelar
              </button>
              <button
                onClick={() => handleReject(selectedRequest?.id || "")}
                className="flex-1 py-3 bg-red-600 text-white rounded-xl hover:bg-red-700"
              >
                Confirmar rechazo
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// Request Detail View
function RequestDetail({ 
  request, 
  onBack, 
  onApprove, 
  onReject 
}: { 
  request: ProfessionalRequest; 
  onBack: () => void;
  onApprove: (id: string) => void;
  onReject: () => void;
}) {
  const [activeDocTab, setActiveDocTab] = useState(0);

  const documentStatusConfig = {
    pending: { label: "Pendiente", color: "bg-amber-100 text-amber-700" },
    verified: { label: "Verificado", color: "bg-green-100 text-green-700" },
    rejected: { label: "Rechazado", color: "bg-red-100 text-red-700" },
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <button onClick={onBack} className="p-2 hover:bg-gray-100 rounded-full">
              <ArrowLeft className="w-5 h-5 text-gray-600" />
            </button>
            <span className="font-medium text-gray-900">Detalle de solicitud</span>
          </div>
          <span className={`text-xs px-2 py-1 rounded-full ${statusConfig[request.status].color}`}>
            {statusConfig[request.status].label}
          </span>
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* Profile Card */}
        <div className="bg-white rounded-xl p-4 shadow-sm">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-16 h-16 bg-violet-100 rounded-full flex items-center justify-center">
              <User className="w-8 h-8 text-violet-600" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-gray-900">{request.name}</h2>
              <p className="text-sm text-gray-500">{request.specialty}</p>
              <div className="flex items-center gap-2 mt-1">
                <Shield className="w-4 h-4 text-violet-600" />
                <span className="text-xs text-violet-600">{request.licenseNumber}</span>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4 pt-4 border-t border-gray-100">
            <div>
              <p className="text-xs text-gray-500">Correo electronico</p>
              <p className="text-sm text-gray-900">{request.email}</p>
            </div>
            <div>
              <p className="text-xs text-gray-500">Telefono</p>
              <p className="text-sm text-gray-900">{request.phone}</p>
            </div>
            <div>
              <p className="text-xs text-gray-500">Experiencia</p>
              <p className="text-sm text-gray-900">{request.yearsExperience} anos</p>
            </div>
            <div>
              <p className="text-xs text-gray-500">Fecha de solicitud</p>
              <p className="text-sm text-gray-900">{new Date(request.submittedAt).toLocaleDateString()}</p>
            </div>
          </div>
        </div>

        {/* Documents */}
        <div className="bg-white rounded-xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-4">Documentos subidos</h3>
          <div className="space-y-3">
            {request.documents.map((doc, index) => (
              <div key={doc.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
                <div className="flex items-center gap-3">
                  <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                    doc.status === "verified" ? "bg-green-100" : 
                    doc.status === "rejected" ? "bg-red-100" : "bg-amber-100"
                  }`}>
                    <FileText className={`w-5 h-5 ${
                      doc.status === "verified" ? "text-green-600" : 
                      doc.status === "rejected" ? "text-red-600" : "text-amber-600"
                    }`} />
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">{doc.name}</p>
                    <span className={`text-xs px-2 py-0.5 rounded-full ${documentStatusConfig[doc.status].color}`}>
                      {documentStatusConfig[doc.status].label}
                    </span>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <button className="p-2 hover:bg-gray-200 rounded-lg">
                    <Eye className="w-4 h-4 text-gray-500" />
                  </button>
                  <button className="p-2 hover:bg-gray-200 rounded-lg">
                    <Download className="w-4 h-4 text-gray-500" />
                  </button>
                </div>
              </div>
            ))}
          </div>

          {/* Document Actions */}
          {request.status === "pending" || request.status === "in_review" ? (
            <div className="mt-4 pt-4 border-t border-gray-100">
              <p className="text-sm text-gray-500 mb-3">Acciones de documentos</p>
              <div className="flex gap-2">
                <button className="flex-1 py-2 bg-green-100 text-green-700 rounded-lg text-sm hover:bg-green-200 flex items-center justify-center gap-2">
                  <Check className="w-4 h-4" />
                  Verificar todos
                </button>
                <button className="flex-1 py-2 bg-red-100 text-red-700 rounded-lg text-sm hover:bg-red-200 flex items-center justify-center gap-2">
                  <X className="w-4 h-4" />
                  Marcar invalidos
                </button>
              </div>
            </div>
          ) : null}
        </div>

        {/* Notes/Comments */}
        <div className="bg-white rounded-xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-900 mb-3">Notas internas</h3>
          <textarea
            placeholder="Agregar nota sobre esta solicitud..."
            rows={3}
            className="w-full px-4 py-3 bg-gray-50 rounded-xl border border-gray-200 focus:border-violet-500 focus:bg-white transition-colors outline-none resize-none"
          />
          <button className="mt-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg text-sm hover:bg-gray-200">
            Guardar nota
          </button>
        </div>

        {/* Action Buttons */}
        {(request.status === "pending" || request.status === "in_review") && (
          <div className="flex gap-3 pt-4">
            <button
              onClick={onReject}
              className="flex-1 py-3.5 border-2 border-red-200 bg-red-50 text-red-600 rounded-xl hover:bg-red-100 transition-colors flex items-center justify-center gap-2"
            >
              <XCircle className="w-5 h-5" />
              Rechazar
            </button>
            <button
              onClick={() => onApprove(request.id)}
              className="flex-1 py-3.5 bg-gradient-to-r from-green-500 to-emerald-500 text-white rounded-xl hover:from-green-600 hover:to-emerald-600 transition-all shadow-lg shadow-green-500/30 flex items-center justify-center gap-2"
            >
              <CheckCircle2 className="w-5 h-5" />
              Aprobar
            </button>
          </div>
        )}

        {/* Contact Professional */}
        <button className="w-full py-3 bg-white border border-gray-200 rounded-xl text-gray-700 hover:bg-gray-50 flex items-center justify-center gap-2">
          <MessageSquare className="w-5 h-5" />
          Contactar profesional
        </button>
      </div>
    </div>
  );
}
