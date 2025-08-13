interface UFOLogoProps {
  size?: number
  className?: string
  animate?: boolean
}

export default function UFOLogo({ size = 120, className = '', animate = true }: UFOLogoProps) {
  return (
    <div className={`${className} ${animate ? 'animate-pulse' : ''}`} style={{ width: size, height: size }}>
      <svg
        width={size}
        height={size}
        viewBox="0 0 120 120"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        {/* UFO Body (main disc) */}
        <ellipse
          cx="60"
          cy="55"
          rx="45"
          ry="15"
          fill="url(#ufoGradient)"
          stroke="#00ff88"
          strokeWidth="2"
        />
        
        {/* UFO Dome */}
        <ellipse
          cx="60"
          cy="45"
          rx="25"
          ry="15"
          fill="url(#domeGradient)"
          stroke="#00ff88"
          strokeWidth="1.5"
          opacity="0.8"
        />
        
        {/* Light beam */}
        <path
          d="M 40 70 L 30 100 L 90 100 L 80 70 Z"
          fill="url(#beamGradient)"
          opacity="0.6"
        />
        
        {/* UFO lights */}
        <circle cx="35" cy="55" r="3" fill="#00ff88" opacity="0.8">
          <animate attributeName="opacity" values="0.4;1;0.4" dur="2s" repeatCount="indefinite" />
        </circle>
        <circle cx="50" cy="52" r="2.5" fill="#00ff88" opacity="0.6">
          <animate attributeName="opacity" values="0.3;0.9;0.3" dur="1.8s" repeatCount="indefinite" />
        </circle>
        <circle cx="70" cy="52" r="2.5" fill="#00ff88" opacity="0.6">
          <animate attributeName="opacity" values="0.3;0.9;0.3" dur="1.6s" repeatCount="indefinite" />
        </circle>
        <circle cx="85" cy="55" r="3" fill="#00ff88" opacity="0.8">
          <animate attributeName="opacity" values="0.4;1;0.4" dur="2.2s" repeatCount="indefinite" />
        </circle>
        
        {/* Center light */}
        <circle cx="60" cy="65" r="4" fill="#00ff88" opacity="0.9">
          <animate attributeName="opacity" values="0.5;1;0.5" dur="1.5s" repeatCount="indefinite" />
        </circle>
        
        <defs>
          {/* UFO body gradient */}
          <linearGradient id="ufoGradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="#4a5568" stopOpacity="0.9" />
            <stop offset="50%" stopColor="#2d3748" stopOpacity="0.95" />
            <stop offset="100%" stopColor="#1a202c" stopOpacity="1" />
          </linearGradient>
          
          {/* Dome gradient */}
          <radialGradient id="domeGradient" cx="50%" cy="30%" r="70%">
            <stop offset="0%" stopColor="#00ff88" stopOpacity="0.3" />
            <stop offset="60%" stopColor="#2d3748" stopOpacity="0.6" />
            <stop offset="100%" stopColor="#1a202c" stopOpacity="0.8" />
          </radialGradient>
          
          {/* Light beam gradient */}
          <linearGradient id="beamGradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="#00ff88" stopOpacity="0.8" />
            <stop offset="50%" stopColor="#00ff88" stopOpacity="0.4" />
            <stop offset="100%" stopColor="#00ff88" stopOpacity="0.1" />
          </linearGradient>
        </defs>
      </svg>
    </div>
  )
}