export function HeroGraphic() {
  return (
    <svg
      viewBox="0 0 480 420"
      role="img"
      aria-label="Abstract component and code illustration"
      className="h-auto w-full"
    >
      <defs>
        <pattern id="dot-grid" width="24" height="24" patternUnits="userSpaceOnUse">
          <circle cx="1" cy="1" r="1" fill="var(--color-gray)" opacity="0.15" />
        </pattern>
      </defs>

      <rect width="480" height="420" fill="url(#dot-grid)" />

      <rect
        x="56"
        y="72"
        width="236"
        height="152"
        rx="18"
        fill="var(--color-black-2)"
        stroke="var(--color-gray)"
      />
      <rect
        x="88"
        y="108"
        width="148"
        height="12"
        rx="6"
        fill="var(--color-gray-1)"
      />
      <rect
        x="88"
        y="140"
        width="96"
        height="10"
        rx="5"
        fill="var(--color-gray-1)"
      />
      <rect
        x="88"
        y="176"
        width="56"
        height="24"
        rx="6"
        fill="var(--color-accent)"
      />

      <rect
        x="190"
        y="156"
        width="220"
        height="132"
        rx="16"
        fill="var(--color-black-2)"
        stroke="var(--color-gray)"
      />
      <rect
        x="224"
        y="194"
        width="128"
        height="8"
        rx="4"
        fill="var(--color-gray-1)"
      />
      <rect
        x="224"
        y="220"
        width="92"
        height="8"
        rx="4"
        fill="var(--color-gray-1)"
      />
      <rect
        x="224"
        y="246"
        width="148"
        height="8"
        rx="4"
        fill="var(--color-gray-1)"
      />

      <rect
        x="98"
        y="260"
        width="156"
        height="82"
        rx="14"
        fill="var(--color-black-2)"
        stroke="var(--color-gray)"
      />
      <rect
        x="124"
        y="288"
        width="82"
        height="8"
        rx="4"
        fill="var(--color-gray-1)"
      />
      <rect
        x="124"
        y="314"
        width="48"
        height="8"
        rx="4"
        fill="var(--color-gray-1)"
      />

      <circle cx="366" cy="94" r="10" fill="var(--color-accent)" />
      <rect x="330" y="318" width="18" height="18" rx="4" fill="var(--color-accent)" />
      <circle cx="78" cy="248" r="6" fill="var(--color-accent)" />
    </svg>
  );
}
