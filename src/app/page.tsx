import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { logout } from "./actions";

export default async function Home() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Defensive fallback: the proxy should already have redirected,
  // but if its matcher ever drifts we still refuse to render to anon.
  if (!user) {
    redirect("/login");
  }

  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-6 p-6">
      <div className="text-center">
        <h1 className="mb-2 text-2xl font-bold">Hola</h1>
        <p className="text-zinc-600">
          Sesión iniciada como <strong>{user.email}</strong>
        </p>
      </div>
      <form action={logout}>
        <button
          type="submit"
          className="rounded-md border border-zinc-300 px-4 py-2 text-sm font-medium hover:bg-zinc-50"
        >
          Cerrar sesión
        </button>
      </form>
    </main>
  );
}
