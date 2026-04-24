import { createBrowserRouter } from "react-router";
import { Home } from "./pages/Home";
import { Search } from "./pages/Search";
import { Profile } from "./pages/Profile";
import { Booking } from "./pages/Booking";
import { BookingConfirmation } from "./pages/BookingConfirmation";
import { ActiveService } from "./pages/ActiveService";
import { Rating } from "./pages/Rating";
import { History } from "./pages/History";
import { Chat } from "./pages/Chat";
import { AISymptoms } from "./pages/AISymptoms";
import { AIRecommendations } from "./pages/AIRecommendations";
import { MapRoute } from "./pages/MapRoute";
import { UserProfile } from "./pages/UserProfile";
import { Login } from "./pages/Login";
import { Layout } from "./components/Layout";
import { MedicalInfo } from "./pages/MedicalInfo";
import { FamilyMembers } from "./pages/FamilyMembers";
import { PaymentMethods } from "./pages/PaymentMethods";
import { Notifications } from "./pages/Notifications";
import { Privacy } from "./pages/Privacy";
import { HelpCenter } from "./pages/HelpCenter";
import { Terms } from "./pages/Terms";
import { ProfessionalRegister } from "./pages/ProfessionalRegister";
import { ProfessionalPending } from "./pages/ProfessionalPending";
import { AdminValidation } from "./pages/AdminValidation";
import { RateUser } from "./pages/RateUser";
import { UserVerification } from "./pages/UserVerification";

// Professional imports
import { ProfessionalLayout } from "./components/ProfessionalLayout";
import { ProfessionalHome } from "./pages/professional/ProfessionalHome";
import { ProfessionalRequests } from "./pages/professional/ProfessionalRequests";
import { ProfessionalRequestDetail } from "./pages/professional/ProfessionalRequestDetail";
import { ProfessionalServices } from "./pages/professional/ProfessionalServices";
import { ProfessionalAvailability } from "./pages/professional/ProfessionalAvailability";
import { ProfessionalActiveService } from "./pages/professional/ProfessionalActiveService";
import { ProfessionalProfile } from "./pages/professional/ProfessionalProfile";
import { ProfessionalRateUser } from "./pages/professional/ProfessionalRateUser";

export const router = createBrowserRouter([
  {
    path: "/login",
    Component: Login,
  },
  {
    path: "/professional-register",
    Component: ProfessionalRegister,
  },
  {
    path: "/professional-pending",
    Component: ProfessionalPending,
  },
  {
    path: "/admin/validation",
    Component: AdminValidation,
  },
  // User routes
  {
    path: "/",
    Component: Layout,
    children: [
      { index: true, Component: Home },
      { path: "search", Component: Search },
      { path: "profile/:id", Component: Profile },
      { path: "booking/:id", Component: Booking },
      { path: "booking-confirmation/:id", Component: BookingConfirmation },
      { path: "active-service/:id", Component: ActiveService },
      { path: "rating/:id", Component: Rating },
      { path: "history", Component: History },
      { path: "chat/:id", Component: Chat },
      { path: "ai-symptoms", Component: AISymptoms },
      { path: "ai-recommendations", Component: AIRecommendations },
      { path: "map-route/:id", Component: MapRoute },
      { path: "user-profile", Component: UserProfile },
      { path: "medical-info", Component: MedicalInfo },
      { path: "family-members", Component: FamilyMembers },
      { path: "payment-methods", Component: PaymentMethods },
      { path: "notifications", Component: Notifications },
      { path: "privacy", Component: Privacy },
      { path: "help", Component: HelpCenter },
      { path: "terms", Component: Terms },
      { path: "rate-user/:id", Component: RateUser },
      { path: "user-verification", Component: UserVerification },
    ],
  },
  // Professional routes (after approval)
  {
    path: "/professional",
    Component: ProfessionalLayout,
    children: [
      { index: true, Component: ProfessionalHome },
      { path: "requests", Component: ProfessionalRequests },
      { path: "request/:id", Component: ProfessionalRequestDetail },
      { path: "services", Component: ProfessionalServices },
      { path: "availability", Component: ProfessionalAvailability },
      { path: "active-service/:id", Component: ProfessionalActiveService },
      { path: "profile", Component: ProfessionalProfile },
      { path: "rate-user/:id", Component: ProfessionalRateUser },
      { path: "notifications", Component: Notifications },
    ],
  },
]);
