"use client";

import { useActionState } from "react";
import { requestMagicLink, type RequestMagicLinkState } from "./actions";

const initialState: RequestMagicLinkState = { status: "idle" };

export function LoginForm() {
  const [state, formAction, pending] = useActionState(
    requestMagicLink,
    initialState,
  );

  if (state.status === "sent") {
    return (
      <div className="text-center">
        <h2 className="mb-2 text-2xl font-semibold">Revisá tu mail</h2>
        <p className="text-zinc-600">
          Te mandamos un link a <strong>{state.email}</strong>. Abrilo en el
          dispositivo donde vas a usar el prode.
        </p>
      </div>
    );
  }

  return (
    <form action={formAction} className="flex flex-col gap-4">
      <label htmlFor="email" className="text-sm font-medium">
        Tu email
      </label>
      <input
        id="email"
        name="email"
        type="email"
        autoComplete="email"
        inputMode="email"
        required
        placeholder="vos@ejemplo.com"
        className="rounded-md border border-zinc-300 px-4 py-3 text-base focus:border-zinc-900 focus:outline-none disabled:opacity-60"
        disabled={pending}
      />
      {state.status === "error" && (
        <p role="alert" className="text-sm text-red-600">
          {state.message}
        </p>
      )}
      <button
        type="submit"
        disabled={pending}
        className="rounded-md bg-zinc-900 px-4 py-3 font-medium text-white transition-opacity hover:opacity-90 disabled:opacity-60"
      >
        {pending ? "Mandando…" : "Enviar link"}
      </button>
    </form>
  );
}
