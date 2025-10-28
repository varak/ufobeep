'use client'

import Link from 'next/link'
import { useState } from 'react'

interface FAQItem {
  question: string
  answer: string | JSX.Element
}

function FAQAccordion({ question, answer }: FAQItem) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div className="bg-dark-surface rounded-lg border border-dark-border overflow-hidden">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-full text-left p-6 hover:bg-dark-background transition-colors flex items-center justify-between gap-4"
      >
        <span className="text-lg font-semibold text-text-primary">{question}</span>
        <span className={`text-brand-primary text-2xl transition-transform ${isOpen ? 'rotate-45' : ''}`}>
          +
        </span>
      </button>
      {isOpen && (
        <div className="px-6 pb-6 text-text-secondary">
          {typeof answer === 'string' ? <p>{answer}</p> : answer}
        </div>
      )}
    </div>
  )
}

export default function FAQ() {
  const generalFAQs: FAQItem[] = [
    {
      question: "What is UFOBeep?",
      answer: "UFOBeep is a real-time alert network that notifies nearby users when someone reports a UFO sighting. Think of it as a 'NOW' button for the sky - when something unexplained appears, witnesses can immediately alert others within a 50-mile radius to look up and verify what they're seeing."
    },
    {
      question: "How does it work?",
      answer: (
        <div className="space-y-2">
          <p>When you see something unusual in the sky:</p>
          <ol className="list-decimal list-inside space-y-1 ml-4">
            <li>Open the app and hit "Beep Now"</li>
            <li>Optionally capture a photo or video</li>
            <li>The app automatically records GPS, time, and environmental data</li>
            <li>Push notifications are sent to all users within 50 miles</li>
            <li>Multiple witnesses can verify and discuss in real-time</li>
          </ol>
          <p className="mt-3">
            <Link href="/how-it-works" className="text-brand-primary hover:underline">
              Read the full technical explanation →
            </Link>
          </p>
        </div>
      )
    },
    {
      question: "Is UFOBeep free?",
      answer: "Yes! UFOBeep is completely free to download and use. There are no subscription fees, no ads, and no premium features. The entire app and its features are available to everyone at no cost."
    },
    {
      question: "Is this app serious or a joke?",
      answer: "100% serious. UFOBeep was created to address a real gap in UFO research: the lack of real-time community verification. Most UFO reports happen hours or days after the fact. UFOBeep enables immediate alerts so multiple witnesses can verify sightings while objects are still visible. The app includes serious scientific features like automatic weather data capture, aircraft tracking, satellite identification, and celestial object positions to help distinguish genuine unknowns from mundane explanations."
    },
    {
      question: "What platforms is UFOBeep available on?",
      answer: "UFOBeep is available on Android (Google Play Store) and iOS (App Store). The app is built with Flutter, so it works identically on both platforms. We also have a web interface at ufobeep.com where you can view recent sightings and browse the map."
    }
  ]

  const privacyFAQs: FAQItem[] = [
    {
      question: "What data does UFOBeep collect?",
      answer: (
        <div className="space-y-2">
          <p>UFOBeep collects minimal data necessary for functionality:</p>
          <ul className="list-disc list-inside space-y-1 ml-4">
            <li><strong>Location:</strong> GPS coordinates when you submit a beep (required for proximity alerts)</li>
            <li><strong>Photos/Videos:</strong> Only media you choose to upload</li>
            <li><strong>Account:</strong> Email and profile photo if you sign in with Google/Apple</li>
            <li><strong>Device token:</strong> For push notifications</li>
          </ul>
          <p className="mt-3">
            <Link href="/privacy" className="text-brand-primary hover:underline">
              Read our full Privacy Policy →
            </Link>
          </p>
        </div>
      )
    },
    {
      question: "Is my location shared with other users?",
      answer: "Not exactly. When you submit a beep, we share your approximate location (within ~1-2 miles) to show distance and direction to other users (e.g., '12 miles SW'). We never share your precise GPS coordinates publicly. Only you can see your exact location in the app."
    },
    {
      question: "Can I use UFOBeep anonymously?",
      answer: "Yes! You can use UFOBeep without creating an account. However, creating an account (via Google or Apple Sign-In) allows you to: save your beeps, participate in comments, receive personalized alerts, and sync across devices. Even with an account, you can choose a display name and control what information is public."
    },
    {
      question: "Who can see my photos and videos?",
      answer: "Photos and videos you attach to beeps are publicly visible to all UFOBeep users. This is intentional - the goal is community verification of sightings. If you don't want to share media publicly, simply don't attach it to your beep. You can still submit a text-only beep with location data."
    }
  ]

  const technicalFAQs: FAQItem[] = [
    {
      question: "Why is the alert radius 50 miles?",
      answer: (
        <div className="space-y-2">
          <p>A 50-mile radius was chosen for several reasons:</p>
          <ul className="list-disc list-inside space-y-1 ml-4">
            <li><strong>Sky visibility:</strong> Objects in the sky are often visible from 50+ miles away</li>
            <li><strong>Metro coverage:</strong> 50 miles typically covers an entire metropolitan area</li>
            <li><strong>Network density:</strong> Balances reach with user density for effective alerts</li>
            <li><strong>Practical distance:</strong> Close enough for quick verification, far enough for good coverage</li>
          </ul>
          <p className="mt-3">
            In rural areas, we may expand this radius in the future to improve coverage.
            <Link href="/the-math" className="text-brand-primary hover:underline ml-1">
              See the mathematical analysis →
            </Link>
          </p>
        </div>
      )
    },
    {
      question: "What environmental data does UFOBeep capture?",
      answer: (
        <div className="space-y-2">
          <p>When you submit a beep, we automatically capture:</p>
          <ul className="list-disc list-inside space-y-1 ml-4">
            <li><strong>Weather:</strong> Cloud cover, visibility, temperature, wind (OpenWeather API)</li>
            <li><strong>Aircraft:</strong> All planes in the sky above you (OpenSky Network)</li>
            <li><strong>Satellites:</strong> Visible satellites overhead (CelesTrak data)</li>
            <li><strong>Celestial objects:</strong> Sun, moon, planets, bright stars positions (Skyfield)</li>
            <li><strong>Location:</strong> GPS coordinates, altitude, compass bearing</li>
            <li><strong>Timestamp:</strong> Exact UTC time of sighting</li>
          </ul>
          <p className="mt-3">
            This data helps rule out conventional explanations and provides scientific context.
          </p>
        </div>
      )
    },
    {
      question: "How many users does UFOBeep need to be effective?",
      answer: (
        <div className="space-y-2">
          <p>
            Based on mathematical analysis using Poisson distribution and US population density data,
            UFOBeep needs approximately <strong className="text-brand-primary">15,000-20,000 users</strong>
            for effective network coverage in major metropolitan areas.
          </p>
          <p>
            At this threshold, there's a near 100% probability that when someone reports a sighting,
            at least one other nearby user receives the alert.
          </p>
          <Link href="/the-math" className="text-brand-primary hover:underline">
            Read the full mathematical analysis →
          </Link>
        </div>
      )
    },
    {
      question: "Is UFOBeep open source?",
      answer: (
        <div>
          <p className="mb-2">
            Yes! The entire UFOBeep codebase is open source and available on GitHub. This includes:
          </p>
          <ul className="list-disc list-inside space-y-1 ml-4">
            <li>Flutter mobile app (iOS & Android)</li>
            <li>FastAPI backend (Python)</li>
            <li>Next.js website</li>
            <li>Data enrichment scripts</li>
            <li>Database schemas</li>
          </ul>
          <a
            href="https://github.com/varak/ufobeep"
            className="inline-block mt-3 text-brand-primary hover:underline"
            target="_blank"
            rel="noopener noreferrer"
          >
            View the code on GitHub →
          </a>
        </div>
      )
    },
    {
      question: "What tech stack does UFOBeep use?",
      answer: (
        <div>
          <p className="mb-2"><strong>Mobile:</strong> Flutter, Dart, Riverpod, Firebase Cloud Messaging</p>
          <p className="mb-2"><strong>Backend:</strong> FastAPI (Python), PostgreSQL + PostGIS, MinIO, Redis</p>
          <p className="mb-2"><strong>Website:</strong> Next.js, TypeScript, Tailwind CSS, React Leaflet</p>
          <Link href="/how-it-works" className="text-brand-primary hover:underline">
            See full technical details →
          </Link>
        </div>
      )
    }
  ]

  const dataFAQs: FAQItem[] = [
    {
      question: "What historical UFO data does UFOBeep include?",
      answer: "UFOBeep includes over 250,000 historical UFO reports from two major sources: MUFON (Mutual UFO Network) - the world's largest civilian UFO investigation organization with 150K+ reports, and NUFORC (National UFO Reporting Center) with 100K+ reports dating back to 1974. All reports are enriched with AI-powered analysis to identify patterns and provide context."
    },
    {
      question: "Can I search historical UFO sightings?",
      answer: "Yes! The website (ufobeep.com) has a full map interface where you can browse all historical sightings by location, date, and characteristics. You can filter by shape, time of day, weather conditions, and more. The mobile app also includes a map view for exploring nearby historical reports."
    },
    {
      question: "How is UFOBeep different from MUFON or NUFORC?",
      answer: "MUFON and NUFORC are excellent historical databases, but reports are typically submitted hours or days after the sighting. UFOBeep adds real-time community alerts - when someone sees something NOW, nearby users are immediately notified while the object is still potentially visible. We also integrate MUFON and NUFORC data to provide historical context alongside live reports."
    },
    {
      question: "Can I contribute to UFOBeep's database?",
      answer: "Yes! Every beep you submit becomes part of the database. Unlike traditional UFO reporting systems, UFOBeep submissions are instant and include rich environmental data automatically. Your reports help build a comprehensive, scientifically-grounded database of UFO sightings."
    }
  ]

  const usageFAQs: FAQItem[] = [
    {
      question: "Do I need to keep the app open to receive alerts?",
      answer: "No! UFOBeep uses push notifications, so you'll receive alerts even when the app is closed. Just make sure notifications are enabled in your device settings. You can customize notification preferences in the app to control which types of alerts you receive."
    },
    {
      question: "How quickly do alerts arrive?",
      answer: "Alerts are sent immediately when someone submits a beep. Notification delivery via Firebase Cloud Messaging typically takes 1-5 seconds. As long as you have an internet connection and notifications enabled, you'll receive alerts in real-time."
    },
    {
      question: "What if I see something but can't take a photo?",
      answer: "That's perfectly fine! You can submit a beep without any media - just hit 'Beep Now' and the app will record all the environmental data (location, time, weather, aircraft, satellites, etc.). The goal is immediate alerts, not perfect documentation. Other nearby users might be able to capture photos."
    },
    {
      question: "Can I delete a beep I submitted?",
      answer: "Yes, you can delete your own beeps from your profile. However, keep in mind that other users may have already seen the alert or added comments. We encourage users to think carefully before submitting, but we understand mistakes happen."
    },
    {
      question: "What counts as a 'UFO' for UFOBeep?",
      answer: "UFOBeep is for reporting anything unusual or unidentified in the sky. This could be lights, objects, or phenomena that you can't immediately explain. It doesn't have to be an 'alien spacecraft' - we're interested in all unidentified aerial phenomena (UAP). The environmental data we capture often helps identify mundane explanations like aircraft, satellites, or celestial objects."
    }
  ]

  const communityFAQs: FAQItem[] = [
    {
      question: "How do I report inappropriate content?",
      answer: (
        <div>
          <p className="mb-2">
            UFOBeep has a zero-tolerance policy for spam, harassment, or inappropriate content.
            To report content:
          </p>
          <ol className="list-decimal list-inside space-y-1 ml-4">
            <li>Tap the three-dot menu on any beep or comment</li>
            <li>Select "Report"</li>
            <li>Choose a reason (spam, harassment, inappropriate, etc.)</li>
            <li>Our moderation team will review within 24 hours</li>
          </ol>
          <p className="mt-3">
            Serious violations result in immediate account suspension.
            <Link href="/safety" className="text-brand-primary hover:underline ml-1">
              Read our Safety Guidelines →
            </Link>
          </p>
        </div>
      )
    },
    {
      question: "Can I chat with other users?",
      answer: "UFOBeep has comment threads on each beep where you can discuss sightings with other witnesses. Comments auto-refresh in real-time and support threaded conversations. We don't currently have direct messaging between users to keep the focus on community verification of sightings."
    },
    {
      question: "How are beeps verified?",
      answer: "UFOBeep uses a combination of community verification and automatic data enrichment. When multiple users in the same area report seeing something, it adds credibility. The environmental data (aircraft, satellites, celestial objects) helps rule out conventional explanations. Beeps with photos/videos from multiple angles are particularly valuable for verification."
    }
  ]

  return (
    <main className="min-h-screen bg-dark-background">
      {/* Header */}
      <div className="bg-dark-surface border-b border-dark-border">
        <div className="max-w-6xl mx-auto px-6 py-6">
          <Link href="/" className="text-brand-primary hover:text-brand-primary-dark">
            ← Back to Home
          </Link>
        </div>
      </div>

      {/* Hero */}
      <section className="py-16 px-6 md:px-24">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl md:text-5xl font-bold mb-6 text-text-primary">
            Frequently Asked Questions
          </h1>
          <p className="text-xl text-text-secondary">
            Everything you need to know about UFOBeep
          </p>
        </div>
      </section>

      {/* General */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">General</h2>
          <div className="space-y-4">
            {generalFAQs.map((faq, index) => (
              <FAQAccordion key={index} question={faq.question} answer={faq.answer} />
            ))}
          </div>
        </div>
      </section>

      {/* Privacy & Security */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Privacy & Security</h2>
          <div className="space-y-4">
            {privacyFAQs.map((faq, index) => (
              <FAQAccordion key={index} question={faq.question} answer={faq.answer} />
            ))}
          </div>
        </div>
      </section>

      {/* Technical */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Technical</h2>
          <div className="space-y-4">
            {technicalFAQs.map((faq, index) => (
              <FAQAccordion key={index} question={faq.question} answer={faq.answer} />
            ))}
          </div>
        </div>
      </section>

      {/* Data & Research */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Data & Research</h2>
          <div className="space-y-4">
            {dataFAQs.map((faq, index) => (
              <FAQAccordion key={index} question={faq.question} answer={faq.answer} />
            ))}
          </div>
        </div>
      </section>

      {/* Usage */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Usage</h2>
          <div className="space-y-4">
            {usageFAQs.map((faq, index) => (
              <FAQAccordion key={index} question={faq.question} answer={faq.answer} />
            ))}
          </div>
        </div>
      </section>

      {/* Community */}
      <section className="py-12 px-6 md:px-24 bg-dark-surface">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold mb-6 text-brand-primary">Community</h2>
          <div className="space-y-4">
            {communityFAQs.map((faq, index) => (
              <FAQAccordion key={index} question={faq.question} answer={faq.answer} />
            ))}
          </div>
        </div>
      </section>

      {/* Still Have Questions */}
      <section className="py-12 px-6 md:px-24">
        <div className="max-w-4xl mx-auto">
          <div className="bg-dark-surface p-8 rounded-lg border border-brand-primary text-center">
            <h2 className="text-2xl font-bold mb-4 text-text-primary">Still have questions?</h2>
            <p className="text-text-secondary mb-6">
              Check out our technical documentation or explore the open source code
            </p>
            <div className="flex flex-wrap gap-4 justify-center">
              <Link
                href="/how-it-works"
                className="bg-brand-primary text-text-inverse px-6 py-3 rounded-lg font-semibold hover:bg-brand-primary-dark transition-all"
              >
                How It Works
              </Link>
              <Link
                href="/the-math"
                className="bg-dark-background text-brand-primary px-6 py-3 rounded-lg font-semibold hover:bg-dark-border transition-all border border-dark-border"
              >
                The Math
              </Link>
              <a
                href="https://github.com/varak/ufobeep"
                className="bg-dark-background text-brand-primary px-6 py-3 rounded-lg font-semibold hover:bg-dark-border transition-all border border-dark-border"
                target="_blank"
                rel="noopener noreferrer"
              >
                GitHub
              </a>
            </div>
          </div>
        </div>
      </section>
    </main>
  )
}
