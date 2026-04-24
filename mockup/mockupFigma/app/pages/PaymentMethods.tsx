import { useState } from "react";
import { Link } from "react-router";
import { ArrowLeft, Plus, CreditCard, Trash2, Check, Building2 } from "lucide-react";

interface PaymentMethod {
  id: string;
  type: "card" | "bank";
  last4: string;
  brand?: string;
  bankName?: string;
  expiryDate?: string;
  isDefault: boolean;
}

export function PaymentMethods() {
  const [showAddForm, setShowAddForm] = useState(false);
  const [paymentType, setPaymentType] = useState<"card" | "bank">("card");

  const [methods] = useState<PaymentMethod[]>([
    {
      id: "1",
      type: "card",
      last4: "4242",
      brand: "Visa",
      expiryDate: "12/26",
      isDefault: true,
    },
    {
      id: "2",
      type: "card",
      last4: "5555",
      brand: "Mastercard",
      expiryDate: "08/25",
      isDefault: false,
    },
    {
      id: "3",
      type: "bank",
      last4: "7890",
      bankName: "BBVA",
      isDefault: false,
    },
  ]);

  const getCardIcon = (brand?: string) => {
    return (
      <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
        brand === "Visa" ? "bg-blue-100" : brand === "Mastercard" ? "bg-orange-100" : "bg-gray-100"
      }`}>
        <CreditCard className={`w-5 h-5 ${
          brand === "Visa" ? "text-blue-600" : brand === "Mastercard" ? "text-orange-600" : "text-gray-600"
        }`} />
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white px-4 py-4 border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Link to="/user-profile" className="p-2 -ml-2 rounded-full hover:bg-gray-100">
              <ArrowLeft className="w-5 h-5" />
            </Link>
            <h1 className="text-lg font-medium">Metodos de pago</h1>
          </div>
          <button
            onClick={() => setShowAddForm(true)}
            className="p-2 rounded-full hover:bg-gray-100 text-violet-600"
          >
            <Plus className="w-5 h-5" />
          </button>
        </div>
      </div>

      <div className="p-4">
        <p className="text-sm text-gray-600 mb-4">
          Administra tus metodos de pago para realizar pagos rapidos y seguros.
        </p>

        {/* Payment Methods List */}
        <div className="space-y-3">
          {methods.map((method) => (
            <div key={method.id} className="bg-white rounded-xl p-4 border border-gray-200">
              <div className="flex items-center gap-3">
                {method.type === "card" ? (
                  getCardIcon(method.brand)
                ) : (
                  <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                    <Building2 className="w-5 h-5 text-green-600" />
                  </div>
                )}

                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <span className="font-medium text-gray-900">
                      {method.type === "card" ? method.brand : method.bankName}
                    </span>
                    {method.isDefault && (
                      <span className="text-xs bg-violet-100 text-violet-700 px-2 py-0.5 rounded-full">
                        Predeterminado
                      </span>
                    )}
                  </div>
                  <p className="text-sm text-gray-500">
                    {method.type === "card" 
                      ? `**** **** **** ${method.last4} - Exp: ${method.expiryDate}`
                      : `Cuenta terminada en ${method.last4}`
                    }
                  </p>
                </div>

                <div className="flex gap-1">
                  {!method.isDefault && (
                    <button className="p-2 text-gray-400 hover:text-green-600 hover:bg-green-50 rounded-lg">
                      <Check className="w-4 h-4" />
                    </button>
                  )}
                  <button className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {methods.length === 0 && (
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <CreditCard className="w-8 h-8 text-gray-400" />
            </div>
            <h3 className="font-medium text-gray-900 mb-2">No hay metodos de pago</h3>
            <p className="text-sm text-gray-500 mb-4">
              Agrega una tarjeta o cuenta bancaria para pagar tus servicios
            </p>
            <button
              onClick={() => setShowAddForm(true)}
              className="inline-flex items-center gap-2 px-4 py-2 bg-violet-600 text-white rounded-full text-sm hover:bg-violet-700"
            >
              <Plus className="w-4 h-4" />
              Agregar metodo
            </button>
          </div>
        )}

        {/* Security Info */}
        <div className="mt-6 bg-green-50 rounded-xl p-4 border border-green-100">
          <div className="flex items-start gap-3">
            <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0">
              <Check className="w-4 h-4 text-green-600" />
            </div>
            <div>
              <h4 className="font-medium text-green-800 mb-1">Pagos seguros</h4>
              <p className="text-sm text-green-700">
                Tus datos de pago estan protegidos con encriptacion de grado bancario. Nunca almacenamos tu numero de tarjeta completo.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Add Payment Method Modal */}
      {showAddForm && (
        <div className="fixed inset-0 bg-black/50 flex items-end justify-center z-50">
          <div className="bg-white rounded-t-3xl w-full max-w-lg p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-lg font-medium">Agregar metodo de pago</h2>
              <button
                onClick={() => setShowAddForm(false)}
                className="p-2 hover:bg-gray-100 rounded-full"
              >
                <ArrowLeft className="w-5 h-5" />
              </button>
            </div>

            {/* Payment Type Selector */}
            <div className="flex gap-3 mb-6">
              <button
                onClick={() => setPaymentType("card")}
                className={`flex-1 p-4 rounded-xl border-2 transition-colors ${
                  paymentType === "card"
                    ? "border-violet-600 bg-violet-50"
                    : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <CreditCard className={`w-6 h-6 mx-auto mb-2 ${
                  paymentType === "card" ? "text-violet-600" : "text-gray-400"
                }`} />
                <p className={`text-sm text-center ${
                  paymentType === "card" ? "text-violet-600 font-medium" : "text-gray-600"
                }`}>
                  Tarjeta
                </p>
              </button>
              <button
                onClick={() => setPaymentType("bank")}
                className={`flex-1 p-4 rounded-xl border-2 transition-colors ${
                  paymentType === "bank"
                    ? "border-violet-600 bg-violet-50"
                    : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <Building2 className={`w-6 h-6 mx-auto mb-2 ${
                  paymentType === "bank" ? "text-violet-600" : "text-gray-400"
                }`} />
                <p className={`text-sm text-center ${
                  paymentType === "bank" ? "text-violet-600 font-medium" : "text-gray-600"
                }`}>
                  Cuenta bancaria
                </p>
              </button>
            </div>

            <form className="space-y-4">
              {paymentType === "card" ? (
                <>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Numero de tarjeta
                    </label>
                    <input
                      type="text"
                      className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                      placeholder="1234 5678 9012 3456"
                      maxLength={19}
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Fecha de expiracion
                      </label>
                      <input
                        type="text"
                        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                        placeholder="MM/AA"
                        maxLength={5}
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        CVV
                      </label>
                      <input
                        type="text"
                        className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                        placeholder="123"
                        maxLength={4}
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Nombre en la tarjeta
                    </label>
                    <input
                      type="text"
                      className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                      placeholder="MARIA GONZALEZ"
                    />
                  </div>
                </>
              ) : (
                <>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Banco
                    </label>
                    <select className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent">
                      <option value="">Seleccionar banco...</option>
                      <option value="bbva">BBVA</option>
                      <option value="santander">Santander</option>
                      <option value="banorte">Banorte</option>
                      <option value="hsbc">HSBC</option>
                      <option value="citibanamex">Citibanamex</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      CLABE interbancaria
                    </label>
                    <input
                      type="text"
                      className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-violet-500 focus:border-transparent"
                      placeholder="18 digitos"
                      maxLength={18}
                    />
                  </div>
                </>
              )}

              <div className="pt-4 flex gap-3">
                <button
                  type="button"
                  onClick={() => setShowAddForm(false)}
                  className="flex-1 py-3 border border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  className="flex-1 py-3 bg-violet-600 text-white rounded-xl hover:bg-violet-700"
                >
                  Guardar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
