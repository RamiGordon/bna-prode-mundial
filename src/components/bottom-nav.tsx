"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  CalendarDays,
  CircleUserRound,
  ClipboardList,
  Trophy,
  type LucideIcon,
} from "lucide-react";
import { cn } from "@/lib/utils";

type NavItem = {
  href: string;
  label: string;
  icon: LucideIcon;
};

const NAV_ITEMS: ReadonlyArray<NavItem> = [
  { href: "/partidos", label: "Partidos", icon: CalendarDays },
  { href: "/mis-predicciones", label: "Predicciones", icon: ClipboardList },
  { href: "/ranking", label: "Ranking", icon: Trophy },
  { href: "/perfil", label: "Perfil", icon: CircleUserRound },
];

function isItemActive(pathname: string, href: string) {
  return pathname === href || pathname.startsWith(`${href}/`);
}

export function BottomNav() {
  const pathname = usePathname();

  return (
    <nav
      aria-label="Navegación principal"
      className="fixed inset-x-0 bottom-0 z-50 border-t border-zinc-200 bg-white pb-[env(safe-area-inset-bottom)]"
    >
      <ul className="flex">
        {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
          const active = isItemActive(pathname, href);
          return (
            <li key={href} className="flex-1">
              <Link
                href={href}
                aria-current={active ? "page" : undefined}
                className={cn(
                  "flex flex-col items-center gap-1 px-2 py-2 text-[11px] font-medium transition-colors",
                  active ? "text-zinc-900" : "text-zinc-500 hover:text-zinc-700",
                )}
              >
                <Icon
                  className="h-5 w-5 shrink-0"
                  aria-hidden="true"
                  strokeWidth={active ? 2.25 : 1.75}
                />
                <span className="truncate">{label}</span>
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
