import { logout } from "@/app/actions";
import { createClient } from "@/lib/supabase/server";

export default async function PerfilPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  return (
    <section className="p-4">
      <h1 className="text-2xl font-bold">Perfil</h1>

      <dl className="mt-6 space-y-2 text-sm">
        <div className="flex flex-col">
          <dt className="text-zinc-500">Email</dt>
          <dd className="text-zinc-900">{user?.email ?? "—"}</dd>
        </div>
      </dl>

      <form action={logout} className="mt-8">
        <button
          type="submit"
          className="w-full rounded-md border border-zinc-300 px-4 py-2 text-sm font-medium hover:bg-zinc-50"
        >
          Cerrar sesión
        </button>
      </form>
    </section>
  );
}
