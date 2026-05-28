import { redirect } from "next/navigation";

// `/` is not a user-facing screen — authenticated landing is `/partidos`.
// The proxy already redirects anon users to `/login` before reaching this page.
export default function Home() {
  redirect("/partidos");
}
