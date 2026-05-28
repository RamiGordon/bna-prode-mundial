import { BottomNav } from "@/components/bottom-nav";

export default function AppLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <div className="flex min-h-full flex-1 flex-col">
      {/* Padding-bottom leaves room for the fixed bottom nav (h-14 ≈ icon+label+padding)
          plus the iOS safe area. Without this, screen content gets covered. */}
      <main className="flex-1 pb-[calc(3.5rem+env(safe-area-inset-bottom))]">
        {children}
      </main>
      <BottomNav />
    </div>
  );
}
