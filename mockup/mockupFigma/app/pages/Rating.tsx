import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import { Star, ThumbsUp, CheckCircle2, Send } from "lucide-react";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

const professionalData = {
  id: 1,
  name: "Dra. Ana María García",
  specialty: "Enfermería General",
  image: "https://images.unsplash.com/photo-1562673462-877b3612cbea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxudXJzZSUyMHByb2Zlc3Npb25hbCUyMGhlYWx0aGNhcmV8ZW58MXx8fHwxNzc0MjIxOTI5fDA&ixlib=rb-4.1.0&q=80&w=1080"
};

const quickComments = [
  "Excelente profesional",
  "Muy puntual",
  "Trato amable",
  "Muy profesional",
  "Servicio de calidad",
  "Lo recomiendo"
];

export function Rating() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [rating, setRating] = useState(0);
  const [hoveredRating, setHoveredRating] = useState(0);
  const [selectedComments, setSelectedComments] = useState<string[]>([]);
  const [customComment, setCustomComment] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);

  const toggleComment = (comment: string) => {
    setSelectedComments(prev => 
      prev.includes(comment)
        ? prev.filter(c => c !== comment)
        : [...prev, comment]
    );
  };

  const handleSubmit = () => {
    if (rating === 0) return;

    setIsSubmitting(true);
    
    // Simular envío
    setTimeout(() => {
      setIsSubmitting(false);
      setIsSubmitted(true);
      
      // Redirigir al historial después de 2 segundos
      setTimeout(() => {
        navigate("/history");
      }, 2000);
    }, 1000);
  };

  if (isSubmitted) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="text-center max-w-md">
          <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle2 className="w-10 h-10 text-green-600" />
          </div>
          <h1 className="text-xl mb-3 text-gray-900">¡Gracias por tu opinión!</h1>
          <p className="text-sm text-gray-600 mb-6">
            Tu calificación nos ayuda a mejorar nuestros servicios y a mantener la calidad de nuestros profesionales.
          </p>
          <div className="bg-white rounded-2xl p-4 border border-gray-200">
            <div className="flex items-center gap-3">
              <ImageWithFallback 
                src={professionalData.image}
                alt={professionalData.name}
                className="w-12 h-12 rounded-xl object-cover"
              />
              <div className="text-left flex-1">
                <p className="text-sm text-gray-900">{professionalData.name}</p>
                <div className="flex items-center gap-1 mt-1">
                  {[...Array(5)].map((_, i) => (
                    <Star 
                      key={i}
                      className={`w-4 h-4 ${
                        i < rating 
                          ? 'fill-yellow-400 text-yellow-400' 
                          : 'text-gray-300'
                      }`}
                    />
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-md mx-auto space-y-6 py-6">
        {/* Header */}
        <div className="text-center">
          <h1 className="text-xl mb-2 text-gray-900">¿Cómo estuvo tu experiencia?</h1>
          <p className="text-sm text-gray-600">
            Califica el servicio recibido
          </p>
        </div>

        {/* Professional Card */}
        <div className="bg-white rounded-2xl p-4 border border-gray-200">
          <div className="flex items-center gap-3">
            <ImageWithFallback 
              src={professionalData.image}
              alt={professionalData.name}
              className="w-16 h-16 rounded-xl object-cover"
            />
            <div>
              <h2 className="text-base text-gray-900">{professionalData.name}</h2>
              <p className="text-sm text-gray-600">{professionalData.specialty}</p>
            </div>
          </div>
        </div>

        {/* Star Rating */}
        <div className="bg-white rounded-2xl p-6 border border-gray-200">
          <p className="text-sm text-gray-700 mb-4 text-center">
            Toca las estrellas para calificar
          </p>
          <div className="flex justify-center gap-2">
            {[1, 2, 3, 4, 5].map((star) => (
              <button
                key={star}
                onClick={() => setRating(star)}
                onMouseEnter={() => setHoveredRating(star)}
                onMouseLeave={() => setHoveredRating(0)}
                className="transition-transform hover:scale-110 active:scale-95"
              >
                <Star 
                  className={`w-12 h-12 transition-colors ${
                    star <= (hoveredRating || rating)
                      ? 'fill-yellow-400 text-yellow-400' 
                      : 'text-gray-300'
                  }`}
                />
              </button>
            ))}
          </div>
          {rating > 0 && (
            <p className="text-center mt-4 text-sm text-gray-600">
              {rating === 1 && "Necesita mejorar"}
              {rating === 2 && "Puede mejorar"}
              {rating === 3 && "Aceptable"}
              {rating === 4 && "Muy bueno"}
              {rating === 5 && "¡Excelente!"}
            </p>
          )}
        </div>

        {/* Quick Comments */}
        {rating > 0 && (
          <div className="bg-white rounded-2xl p-4 border border-gray-200">
            <h3 className="text-sm text-gray-900 mb-3">¿Qué te gustó? (opcional)</h3>
            <div className="flex flex-wrap gap-2">
              {quickComments.map((comment) => (
                <button
                  key={comment}
                  onClick={() => toggleComment(comment)}
                  className={`px-3 py-2 rounded-lg text-sm border-2 transition-colors ${
                    selectedComments.includes(comment)
                      ? 'border-violet-600 bg-violet-50 text-violet-700'
                      : 'border-gray-200 text-gray-700 hover:border-violet-300'
                  }`}
                >
                  <div className="flex items-center gap-1">
                    {selectedComments.includes(comment) && (
                      <ThumbsUp className="w-3.5 h-3.5" />
                    )}
                    {comment}
                  </div>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Custom Comment */}
        {rating > 0 && (
          <div className="bg-white rounded-2xl p-4 border border-gray-200">
            <h3 className="text-sm text-gray-900 mb-3">Comentario adicional (opcional)</h3>
            <textarea
              value={customComment}
              onChange={(e) => setCustomComment(e.target.value)}
              placeholder="Cuéntanos más sobre tu experiencia..."
              rows={4}
              className="w-full py-2 px-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-500 resize-none text-sm"
              maxLength={500}
            />
            <div className="flex justify-end mt-1">
              <span className="text-xs text-gray-500">
                {customComment.length}/500
              </span>
            </div>
          </div>
        )}

        {/* Recommendations */}
        {rating >= 4 && (
          <div className="bg-gradient-to-br from-violet-50 to-purple-50 rounded-2xl p-4 border border-violet-100">
            <h3 className="text-sm text-gray-900 mb-2">¿Recomendarías este profesional?</h3>
            <p className="text-xs text-gray-600 mb-3">
              Tu recomendación ayuda a otros usuarios a encontrar profesionales de confianza
            </p>
            <div className="flex items-center gap-2">
              <ThumbsUp className="w-4 h-4 text-violet-600" />
              <span className="text-sm text-gray-700">
                ¡Gracias! Agregaremos tu recomendación
              </span>
            </div>
          </div>
        )}

        {/* Submit Button */}
        <button
          onClick={handleSubmit}
          disabled={rating === 0 || isSubmitting}
          className={`w-full py-3 rounded-xl text-white flex items-center justify-center gap-2 transition-all ${
            rating === 0 || isSubmitting
              ? 'bg-gray-300 cursor-not-allowed'
              : 'bg-violet-600 hover:bg-violet-700 active:scale-95'
          }`}
        >
          {isSubmitting ? (
            <>
              <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              Enviando...
            </>
          ) : (
            <>
              <Send className="w-5 h-5" />
              Enviar calificación
            </>
          )}
        </button>

        {/* Skip */}
        <button
          onClick={() => navigate("/history")}
          className="w-full py-3 text-sm text-gray-600 hover:text-gray-900"
        >
          Calificar más tarde
        </button>
      </div>
    </div>
  );
}
