"use server";

import { headers } from "next/headers";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";

const emailSchema = z.object({
  email: z
    .string()
    .trim()
    .toLowerCase()
    .email("Ingresá un email válido (algo@ejemplo.com)."),
});

export type RequestMagicLinkState =
  | { status: "idle" }
  | { status: "sent"; email: string }
  | { status: "error"; message: string };

export async function requestMagicLink(
  _prev: RequestMagicLinkState,
  formData: FormData,
): Promise<RequestMagicLinkState> {
  const parsed = emailSchema.safeParse({
    email: formData.get("email"),
  });

  if (!parsed.success) {
    return {
      status: "error",
      message:
        parsed.error.issues[0]?.message ?? "Ingresá un email válido.",
    };
  }

  const headerList = await headers();
  const host = headerList.get("host");
  const proto = headerList.get("x-forwarded-proto") ?? "http";
  const origin = `${proto}://${host}`;

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithOtp({
    email: parsed.data.email,
    options: {
      emailRedirectTo: `${origin}/auth/callback`,
    },
  });

  if (error) {
    console.error("[auth] signInWithOtp failed", {
      status: error.status,
      code: error.code,
      message: error.message,
    });

    const isRateLimit =
      error.status === 429 || error.code === "over_email_send_rate_limit";

    return {
      status: "error",
      message: isRateLimit
        ? "Pediste un link hace muy poco. Esperá un minuto y volvé a intentar."
        : "No pudimos mandarte el link. Probá de nuevo en un rato.",
    };
  }

  return { status: "sent", email: parsed.data.email };
}
